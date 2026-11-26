// Clock traits for the master titles (docs/18): what each candidate is
// worth to the player of `late_game_report.dart`. From app/:
//
//   dart run tool/trait_report.dart [--only id,id] [--loops 6]
//       [--sessions 3] [--minutes 11] [--sigma 0.04] [--snap file.json]
//
// --snap keeps the state after loop 1 in a file (and reads it next time):
// several runs side by side then share it. FINAL2.I and FINAL3.II are the
// recommendation of docs/18 §4.
//
// The player plays the first Time Loop on today's rules, then the next
// [--loops] loops (their rules in order) once per candidate trait, with
// the trait on from the start of loop 2: a clock's third tier costs 6
// Mainsprings, about 3 days of winding, so a player who wants a trait has
// it by then. Candidates change the balance file or add a little to each
// session; the rest of the game is the engine's own.
//
// Per candidate: days to the goal of each loop and in total against the
// unchanged game ("none"), Mainsprings wound, mastery tiers at the end
// and Golden Seconds caught a session.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:hit10/balance/balance.dart';
import 'package:hit10/engine/game_engine.dart';
import 'package:hit10/sim/simulator.dart';
import 'package:hit10/model/game_state.dart';
import 'package:hit10/model/settings.dart';
import 'package:hit10/persistence/save_codec.dart';

import 'late_game_report.dart' show Player, clone;

typedef Json = Map<String, Object?>;
Json m(Object? v) => v! as Json;
List<Object?> l(Object? v) => v! as List<Object?>;
double d(Object? v) => (v! as num).toDouble();

/// A candidate: [edit] changes the balance file, [session] runs after
/// every session (extra Tiki, carried Chronons…).
class Trait {
  const Trait(this.id, this.clock, this.text, {this.edit, this.session});
  final String id;
  final String clock;
  final String text;
  final void Function(Json j)? edit;
  final void Function(TraitRun r, GameState s, double passive)? session;
}

/// What a [Trait.session] hook may need between sessions.
class TraitRun {
  TraitRun(this.b, this.sessions, this.minutes);
  final Balance b;
  final int sessions;
  final double minutes;
  var lastLoop = -1;
  var chrononsBefore = 0;
  var extra = 0.0;
  var sessionsPlayed = 0;
  var sigma = 0.04;

  /// This session is the first of a new loop (set before the hooks).
  var newLoop = false;

  /// Real seconds between the end of one session and the next.
  double get away => 24 * 3600 / sessions - minutes * 60;
}

void perkParam(Json j, String id, String key, double Function(double) f) {
  for (final p in l(m(j['prestige'])['perks'])) {
    if (m(p)['id'] == id) {
      final ps = m(m(p)['params']);
      ps[key] = f(d(ps[key]));
    }
  }
}

void offlineTimes(Json j, double k) {
  m(j['offline'])['efficiency'] = d(m(j['offline'])['efficiency']) * k;
  perkParam(j, 'deepSleep1', 'efficiency', (v) => v * k);
  perkParam(j, 'deepSleep2', 'efficiency', (v) => v * k);
}

void goldenEffect(Json j, String id, String key, double Function(double) f) {
  for (final e in l(m(j['golden'])['effects'])) {
    if (m(e)['id'] == id) m(e)[key] = f(d(m(e)[key]));
  }
}

void loopRule(Json j, String id, String key, double v) {
  for (final r in l(m(j['loops'])['rules'])) {
    if (m(r)['id'] == id) m(m(r)['params'])[key] = v;
  }
}

/// A new loop starts with [share] of the last loop's Chronons.
void Function(TraitRun, GameState, double) carry(double share) => (r, s, p) {
  if (r.newLoop) s.chronons += (r.chrononsBefore * share).round();
};

/// A new loop starts with [n] Chronons.
void Function(TraitRun, GameState, double) carryFlat(int n) => (r, s, p) {
  if (r.newLoop) s.chronons += n;
};

/// [n] Mainsprings every time [when] says so (over the stock cap, as the
/// Chronos bonuses are).
void Function(TraitRun, GameState, double) springsWhen(
  int n,
  bool Function(TraitRun r) when,
) => (r, s, p) {
  if (when(r)) s.springs += n;
};

void goldenOften(Json j, double k) {
  final g = m(j['golden']);
  g['intervalMin'] = d(g['intervalMin']) / k;
  g['intervalMax'] = d(g['intervalMax']) / k;
}

void goldenStrong(Json j, double k) {
  goldenEffect(j, 'frenzy', 'multiplier', (v) => 1 + (v - 1) * k);
  goldenEffect(j, 'lucky', 'productionSeconds', (v) => v * k);
  goldenEffect(j, 'hotHand', 'multiplier', (v) => 1 + (v - 1) * k);
}

void perksTimes(Json j, double k) {
  for (final p in l(m(j['prestige'])['perks'])) {
    m(p)['cost'] = (d(m(p)['cost']) * k).ceil();
  }
}

void clocksTimes(Json j, double k) {
  for (final g in l(j['generators'])) {
    m(g)['baseRate'] = d(m(g)['baseRate']) * k;
  }
}

void chrononsTimes(Json j, double k) {
  final p = m(j['prestige']);
  p['divisor'] = d(p['divisor']) / math.pow(k, 3);
}

void reserveTimes(Json j, double size, double refill) {
  final sp = m(j['springs']);
  sp['hitReserve'] = d(sp['hitReserve']) * size;
  sp['hitReserveRefill'] = d(sp['hitReserveRefill']) * refill;
}

/// All of [parts] at once.
Trait together(String id, String text, List<Trait> parts) => Trait(
  id,
  'all',
  text,
  edit: (j) {
    for (final x in parts) {
      x.edit?.call(j);
    }
  },
  session: (r, s, p) {
    for (final x in parts) {
      x.session?.call(r, s, p);
    }
  },
);

/// The proposal of docs/18: tier 3 (I) and tier 5 (II) of every clock.
final tierI = <Trait>[
  Trait(
    'I.grandpa',
    'grandpa',
    'offline +15%',
    edit: (j) => offlineTimes(j, 1.15),
  ),
  Trait(
    'I.cuckoo',
    'cuckoo',
    'Golden Second on return',
    edit: (j) => goldenOften(j, 1.75),
  ),
  Trait(
    'I.metronome',
    'metronome',
    'reserve refills ×1.5',
    edit: (j) => reserveTimes(j, 1, 1.5),
  ),
  Trait(
    'I.watchmaker',
    'watchmaker',
    'perks −15%',
    edit: (j) => perksTimes(j, 0.85),
  ),
  Trait(
    'I.sprintJudge',
    'sprintJudge',
    'loop under its record: +1 Mainspring',
    session: springsWhen(1, (r) => r.newLoop),
  ),
  Trait(
    'I.stationClock',
    'stationClock',
    'Golden Second 20% more often',
    edit: (j) => goldenOften(j, 1.25),
  ),
  Trait(
    'I.quartz',
    'quartz',
    'all clocks +10%',
    edit: (j) => clocksTimes(j, 1.10),
  ),
  Trait(
    'I.atomic',
    'atomic',
    'a Mainspring in 22 h',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 79200,
  ),
  Trait(
    'I.pulsar',
    'pulsar',
    'Golden effects +30%',
    edit: (j) => goldenStrong(j, 1.3),
  ),
  Trait(
    'I.timeMachine',
    'timeMachine',
    'carry 3% of Chronons',
    session: carry(0.03),
  ),
  Trait(
    'I.schrodinger',
    'schrodinger',
    'paradox: 50% for +20% Chronons',
    edit: (j) => chrononsTimes(j, 1.10),
  ),
  Trait(
    'I.chronos',
    'chronos',
    'Chronos perk −50%',
    edit: (j) {
      for (final p in l(m(j['prestige'])['perks'])) {
        if (m(p)['id'] == 'unlockChronos') m(p)['cost'] = 250;
      }
    },
  ),
];
final tierII = <Trait>[
  Trait(
    'II.grandpa',
    'grandpa',
    'offline +30%',
    edit: (j) => offlineTimes(j, 1.30),
  ),
  Trait(
    'II.grandma',
    'grandma',
    '7th daily day: 3 Mainsprings',
    edit: (j) => m(j['daily'])['lastDaySprings'] = 3,
  ),
  Trait(
    'II.cuckoo',
    'cuckoo',
    'two Golden Seconds on return',
    edit: (j) => goldenOften(j, 2.5),
  ),
  Trait(
    'II.metronome',
    'metronome',
    'reserve ×2, refill ×2',
    edit: (j) => reserveTimes(j, 2, 2),
  ),
  Trait(
    'II.watchmaker',
    'watchmaker',
    'perks −30%',
    edit: (j) => perksTimes(j, 0.70),
  ),
  Trait(
    'II.sprintJudge',
    'sprintJudge',
    'loop under its record: +2 Mainsprings',
    session: springsWhen(2, (r) => r.newLoop),
  ),
  Trait(
    'II.stationClock',
    'stationClock',
    'Golden Second 40% more often',
    edit: (j) => goldenOften(j, 1.4),
  ),
  Trait(
    'II.quartz',
    'quartz',
    'all clocks +25%',
    edit: (j) => clocksTimes(j, 1.25),
  ),
  Trait(
    'II.atomic',
    'atomic',
    'a Mainspring in 20 h',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 72000,
  ),
  Trait(
    'II.gps',
    'gps',
    'weekly challenge +1 Mainspring',
    session: springsWhen(1, (r) => r.sessionsPlayed % (7 * r.sessions) == 0),
  ),
  Trait(
    'II.pulsar',
    'pulsar',
    'Golden effects +30%, Frenzy ×1.5 longer',
    edit: (j) {
      goldenStrong(j, 1.3);
      goldenEffect(j, 'frenzy', 'duration', (v) => v * 1.5);
    },
  ),
  Trait(
    'II.timeMachine',
    'timeMachine',
    'carry 6% of Chronons',
    session: carry(0.06),
  ),
  Trait(
    'II.schrodinger',
    'schrodinger',
    'paradox: 50% for +40% Chronons',
    edit: (j) => chrononsTimes(j, 1.20),
  ),
  Trait(
    'II.chronos',
    'chronos',
    'Chronos bonus: 2 Mainsprings',
    edit: (j) => m(j['loops'])['goalBonusSprings'] = 2,
  ),
];

void chronosPerk(Json j, int cost) {
  for (final p in l(m(j['prestige'])['perks'])) {
    if (m(p)['id'] == 'unlockChronos') m(p)['cost'] = cost;
  }
}

/// The recommendation of docs/18. What the bot cannot show (a streak
/// forgiven, a challenge rerolled, a longer offline cap for 3 sessions a
/// day, the Golden Second staying longer: it catches every one) is left
/// out; it changes no pace here.
final finalI = <Trait>[
  Trait('', 'cuckoo', 'cuckoo on the hour', edit: (j) => goldenOften(j, 1.16)),
  Trait(
    '',
    'metronome',
    'reserve refill ×1.5',
    edit: (j) => reserveTimes(j, 1, 1.5),
  ),
  Trait('', 'watchmaker', 'perks −15%', edit: (j) => perksTimes(j, 0.85)),
  Trait(
    '',
    'sprintJudge',
    'loop record +1',
    session: springsWhen(1, (r) => r.newLoop),
  ),
  Trait('', 'stationClock', 'golden ×1.15', edit: (j) => goldenOften(j, 1.15)),
  Trait(
    '',
    'quartz',
    'insomnia 50%',
    edit: (j) => loopRule(j, 'insomnia', 'offlineEfficiency', 0.5),
  ),
  Trait(
    '',
    'atomic',
    'spring 22 h',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 79200,
  ),
  Trait('', 'pulsar', 'golden +30%', edit: (j) => goldenStrong(j, 1.3)),
  Trait('', 'timeMachine', '+10 Chronons', session: carryFlat(10)),
  Trait('', 'schrodinger', 'coin +20%', edit: (j) => chrononsTimes(j, 1.10)),
  Trait('', 'chronos', 'Chronos perk 350', edit: (j) => chronosPerk(j, 350)),
];
final finalII = <Trait>[
  Trait('', 'grandpa', 'offline +15%', edit: (j) => offlineTimes(j, 1.15)),
  Trait(
    '',
    'grandma',
    '7th day 3 springs',
    edit: (j) => m(j['daily'])['lastDaySprings'] = 3,
  ),
  Trait('', 'cuckoo', 'golden on return', edit: (j) => goldenOften(j, 1.75)),
  Trait('', 'metronome', 'reserve ×2', edit: (j) => reserveTimes(j, 2, 2)),
  Trait('', 'watchmaker', 'perks −30%', edit: (j) => perksTimes(j, 0.70)),
  Trait(
    '',
    'sprintJudge',
    'loop record +2',
    session: springsWhen(2, (r) => r.newLoop),
  ),
  Trait('', 'stationClock', 'golden ×1.3', edit: (j) => goldenOften(j, 1.3)),
  Trait(
    '',
    'quartz',
    'insomnia 50%, clocks +10%',
    edit: (j) {
      loopRule(j, 'insomnia', 'offlineEfficiency', 0.5);
      clocksTimes(j, 1.10);
    },
  ),
  Trait(
    '',
    'atomic',
    'spring 20 h',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 72000,
  ),
  Trait(
    '',
    'gps',
    'weekly +1 spring',
    session: springsWhen(1, (r) => r.sessionsPlayed % (7 * r.sessions) == 0),
  ),
  Trait(
    '',
    'pulsar',
    'golden +30%, frenzy ×1.5',
    edit: (j) {
      goldenStrong(j, 1.3);
      goldenEffect(j, 'frenzy', 'duration', (v) => v * 1.5);
    },
  ),
  Trait('', 'timeMachine', '+25 Chronons', session: carryFlat(25)),
  Trait('', 'schrodinger', 'coin +40%', edit: (j) => chrononsTimes(j, 1.20)),
  Trait(
    '',
    'chronos',
    'bonus 2 springs, perk 350',
    edit: (j) {
      m(j['loops'])['goalBonusSprings'] = 2;
      chronosPerk(j, 350);
    },
  ),
];

/// The same, about half as strong (docs/18 §4: the budget).
final final2I = <Trait>[
  Trait('', 'cuckoo', 'cuckoo on the hour', edit: (j) => goldenOften(j, 1.10)),
  Trait(
    '',
    'metronome',
    'reserve refill ×1.5',
    edit: (j) => reserveTimes(j, 1, 1.5),
  ),
  Trait('', 'watchmaker', 'perks −10%', edit: (j) => perksTimes(j, 0.90)),
  Trait(
    '',
    'sprintJudge',
    'loop record +1',
    session: springsWhen(1, (r) => r.newLoop),
  ),
  Trait('', 'stationClock', 'golden ×1.10', edit: (j) => goldenOften(j, 1.10)),
  Trait(
    '',
    'quartz',
    'insomnia 35%',
    edit: (j) => loopRule(j, 'insomnia', 'offlineEfficiency', 0.35),
  ),
  Trait(
    '',
    'atomic',
    'spring 22 h',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 79200,
  ),
  Trait('', 'pulsar', 'golden +15%', edit: (j) => goldenStrong(j, 1.15)),
  Trait('', 'timeMachine', '+10 Chronons', session: carryFlat(10)),
  Trait('', 'schrodinger', 'coin +10%', edit: (j) => chrononsTimes(j, 1.05)),
  Trait('', 'chronos', 'Chronos perk 400', edit: (j) => chronosPerk(j, 400)),
];
final final2II = <Trait>[
  Trait('', 'grandpa', 'offline +10%', edit: (j) => offlineTimes(j, 1.10)),
  Trait(
    '',
    'grandma',
    '7th day 3 springs',
    edit: (j) => m(j['daily'])['lastDaySprings'] = 3,
  ),
  Trait('', 'cuckoo', 'golden on return', edit: (j) => goldenOften(j, 1.75)),
  Trait('', 'metronome', 'reserve ×2', edit: (j) => reserveTimes(j, 2, 2)),
  Trait('', 'watchmaker', 'perks −20%', edit: (j) => perksTimes(j, 0.80)),
  Trait(
    '',
    'sprintJudge',
    'loop record +2',
    session: springsWhen(2, (r) => r.newLoop),
  ),
  Trait(
    '',
    'stationClock',
    'golden ×1.10 (+ stays longer)',
    edit: (j) => goldenOften(j, 1.10),
  ),
  Trait(
    '',
    'quartz',
    'insomnia 50%',
    edit: (j) => loopRule(j, 'insomnia', 'offlineEfficiency', 0.5),
  ),
  Trait(
    '',
    'atomic',
    'spring 20 h',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 72000,
  ),
  Trait(
    '',
    'gps',
    'weekly +1 spring',
    session: springsWhen(1, (r) => r.sessionsPlayed % (7 * r.sessions) == 0),
  ),
  Trait(
    '',
    'pulsar',
    'golden +15%, frenzy ×1.5',
    edit: (j) {
      goldenStrong(j, 1.15);
      goldenEffect(j, 'frenzy', 'duration', (v) => v * 1.5);
    },
  ),
  Trait('', 'timeMachine', '+25 Chronons', session: carryFlat(25)),
  Trait('', 'schrodinger', 'coin +20%', edit: (j) => chrononsTimes(j, 1.10)),
  Trait(
    '',
    'chronos',
    'bonus 2 springs, perk 400',
    edit: (j) {
      m(j['loops'])['goalBonusSprings'] = 2;
      chronosPerk(j, 400);
    },
  ),
];

/// Extra production seconds once a session (the passive income).
void Function(TraitRun, GameState, double) produce(
  double Function(TraitRun r) seconds,
) => (r, s, passive) {
  final t = passive * seconds(r);
  s.earn(t);
  r.extra += t;
};

final traits = <Trait>[
  const Trait('none', '—', 'the game as it is'),
  // Noise: the same game with the timing spread a hair different.
  Trait('noise', '—', 'σ 40 → 40.4 ms (how far chance alone moves it)'),
  // -- grandpa: sleeps, the offline income.
  Trait(
    'g.offline10',
    'grandpa',
    'offline income +10% (over 100% too)',
    edit: (j) => offlineTimes(j, 1.10),
  ),
  Trait(
    'g.offline25',
    'grandpa',
    'offline income +25%',
    edit: (j) => offlineTimes(j, 1.25),
  ),
  Trait(
    'g.insomnia',
    'grandpa',
    '"Insomnia" loop: offline 50% instead of 25%',
    edit: (j) => loopRule(j, 'insomnia', 'offlineEfficiency', 0.5),
  ),
  Trait(
    'g.deepSleepStart',
    'grandpa',
    'offline 75% from the start of every loop (Deep sleep I free)',
    edit: (j) {
      m(j['offline'])['efficiency'] = 0.75;
    },
  ),
  // -- grandma: looks after you, the daily bonus.
  Trait(
    'gm.daily2',
    'grandma',
    'daily bonus ×2',
    edit: (j) {
      final dl = m(j['daily']);
      dl['minutes'] = [for (final v in l(dl['minutes'])) d(v) * 2];
    },
  ),
  Trait(
    'gm.daily5',
    'grandma',
    'daily bonus ×5',
    edit: (j) {
      final dl = m(j['daily']);
      dl['minutes'] = [for (final v in l(dl['minutes'])) d(v) * 5];
    },
  ),
  Trait(
    'gm.weekSprings',
    'grandma',
    'the 7th day of the daily bonus gives 3 Mainsprings instead of 1',
    edit: (j) => m(j['daily'])['lastDaySprings'] = 3,
  ),
  // -- cuckoo: the hour.
  Trait(
    'c.cuckoo1',
    'cuckoo',
    'back after a while: one "cuckoo" (1 min of income) per hour away, 8 at most',
    session: produce((r) => math.min(8, r.away / 3600).floorToDouble() * 60),
  ),
  Trait(
    'c.cuckoo5',
    'cuckoo',
    'the same, 5 min of income a cuckoo',
    session: produce((r) => math.min(8, r.away / 3600).floorToDouble() * 300),
  ),
  Trait(
    'c.goldOnReturn',
    'cuckoo',
    'a Golden Second within 30 s of coming back (one more a session)',
    edit: (j) {
      // About 1.3 a session now (11 min, every 10 min ×0.85): one more.
      final g = m(j['golden']);
      g['intervalMin'] = d(g['intervalMin']) * 0.57;
      g['intervalMax'] = d(g['intervalMax']) * 0.57;
    },
  ),
  // -- metronome: rhythm, the combo.
  Trait(
    'm.cap3',
    'metronome',
    'combo cap +3 steps (+0.15)',
    edit: (j) => m(j['combo'])['baseCap'] = d(m(j['combo'])['baseCap']) + 3,
  ),
  Trait(
    'm.step',
    'metronome',
    'each combo step ×1.06 instead of ×1.05 (+20%)',
    edit: (j) => m(j['combo'])['multiplierPerStep'] = 0.06,
  ),
  Trait(
    'm.shield',
    'metronome',
    'Shield charges back after 7 hits instead of 10',
    edit: (j) => m(m(j['combo'])['ladder'])['rechargeHits'] = 7,
  ),
  // -- watchmaker: the craftsman, prices.
  Trait(
    'w.clocks10',
    'watchmaker',
    'clocks 10% cheaper',
    edit: (j) {
      for (final g in l(j['generators'])) {
        m(g)['baseCost'] = d(m(g)['baseCost']) * 0.9;
      }
    },
  ),
  Trait(
    'w.perks25',
    'watchmaker',
    'perks 25% cheaper (Chronons)',
    edit: (j) {
      for (final p in l(m(j['prestige'])['perks'])) {
        m(p)['cost'] = (d(m(p)['cost']) * 0.75).ceil();
      }
    },
  ),
  Trait(
    'w.skills50',
    'watchmaker',
    'skills 50% cheaper',
    edit: (j) {
      for (final sk in l(j['skills'])) {
        m(sk)['baseCost'] = d(m(sk)['baseCost']) * 0.5;
      }
    },
  ),
  // -- sprint judge: the photo finish, exact timing.
  Trait(
    'sj.perfect2',
    'sprintJudge',
    'PERFECT window +2 ms',
    edit: (j) {
      final t = m(l(j['tiers']).first);
      t['window'] = d(t['window']) + 0.002;
    },
  ),
  Trait(
    'sj.jackpot',
    'sprintJudge',
    'the exact 5.00 window ×1.5 (more 5.00 hits, more winding)',
    edit: (j) => m(j['jackpot'])['window'] = 0.015,
  ),
  Trait(
    'sj.precision',
    'sprintJudge',
    '"Swiss precision" loop: GOOD pays half instead of nothing',
    // Left out: the engine has no knob for it (see the docs).
  ),
  // -- station clock: the timetable.
  Trait(
    'st.goldOften',
    'stationClock',
    'Golden Second 20% more often',
    edit: (j) {
      final g = m(j['golden']);
      g['intervalMin'] = d(g['intervalMin']) * 0.8;
      g['intervalMax'] = d(g['intervalMax']) * 0.8;
    },
  ),
  Trait(
    'st.goldStrong',
    'stationClock',
    'Golden Second effects +30% (Frenzy ×9, Lucky 13 min…)',
    edit: (j) {
      goldenEffect(j, 'frenzy', 'multiplier', (v) => 1 + (v - 1) * 1.3);
      goldenEffect(j, 'lucky', 'productionSeconds', (v) => v * 1.3);
      goldenEffect(j, 'hotHand', 'multiplier', (v) => 1 + (v - 1) * 1.3);
    },
  ),
  Trait(
    'st.frenzyLong',
    'stationClock',
    'Frenzy lasts 50% longer',
    edit: (j) => goldenEffect(j, 'frenzy', 'duration', (v) => v * 1.5),
  ),
  // -- quartz: steady.
  Trait(
    'q.floor',
    'quartz',
    'a miss keeps 5 combo steps (Combo floor, free from the start)',
    edit: (j) {
      // The perk's floor for everyone: no Shield-free loop drops below 5.
      perkParam(j, 'comboFloor', 'floor', (v) => v);
      for (final p in l(m(j['prestige'])['perks'])) {
        if (m(p)['id'] == 'comboFloor') m(p)['cost'] = 0;
      }
    },
  ),
  Trait(
    'q.passive10',
    'quartz',
    'all clocks +10% (a plain multiplier, to compare)',
    edit: (j) {
      for (final g in l(j['generators'])) {
        m(g)['baseRate'] = d(m(g)['baseRate']) * 1.1;
      }
    },
  ),
  // -- atomic: the exact second, the Mainsprings.
  Trait(
    'a.springs20',
    'atomic',
    'a Mainspring winds in 20 h instead of 24',
    edit: (j) => m(j['springs'])['secondsPerSpring'] = 72000,
  ),
  Trait(
    'a.hit50',
    'atomic',
    'an exact hit winds 45 min instead of 30',
    edit: (j) => m(j['springs'])['hitSeconds'] = 2700,
  ),
  Trait(
    'a.reserve',
    'atomic',
    'winding reserve ×2 (4 h, refills twice as fast)',
    edit: (j) {
      final sp = m(j['springs']);
      sp['hitReserve'] = d(sp['hitReserve']) * 2;
      sp['hitReserveRefill'] = d(sp['hitReserveRefill']) * 2;
    },
  ),
  // -- GPS: the way, challenges (the player here plays none: see docs).
  // -- pulsar: the pulse.
  Trait(
    'p.pulse',
    'pulsar',
    'a pulse every 5 min of play: ×2 income for 30 s (+10% in sessions)',
    session: produce((r) => r.minutes * 60 * 0.10),
  ),
  Trait(
    'p.pulseBig',
    'pulsar',
    'a pulse every 5 min: 2 min of income at once',
    session: produce((r) => r.minutes / 5 * 120),
  ),
  // -- time machine: the paradox and the loop.
  Trait(
    't.keep',
    'timeMachine',
    'a paradox keeps 10 points more of the clocks (Muscle memory)',
    edit: (j) {
      for (final id in ['muscleMemory1', 'muscleMemory2', 'muscleMemory3']) {
        perkParam(j, id, 'keepShare', (v) => math.min(0.95, v + 0.1));
      }
    },
  ),
  Trait(
    't.carry10',
    'timeMachine',
    'a new loop starts with 10% of the last loop\'s Chronons',
    session: carry(0.10),
  ),
  Trait('t.carry25', 'timeMachine', 'the same with 25%', session: carry(0.25)),
  // -- Schrödinger: chance.
  Trait(
    'sc.miss10',
    'schrodinger',
    '10% of misses count as GOOD',
    edit: (j) {
      // GOOD's window wider by what turns a tenth of the misses into it
      // at σ 40 ms (the windows the player has late: see the table).
      final t = m(l(j['tiers'])[2]);
      t['window'] = d(t['window']) * 1.10;
    },
  ),
  Trait(
    'sc.luck',
    'schrodinger',
    'Luck +10 points (a GREAT/GOOD bumped up a tier)',
    edit: (j) {
      for (final sk in l(j['skills'])) {
        if (m(sk)['id'] == 'luck') {
          m(sk)['perLevel'] = d(m(sk)['perLevel']) + 0.1 / 15;
        }
      }
    },
  ),
  // -- Chronos: the goal.
  Trait(
    'ch.chronons15',
    'chronos',
    'Chronons from a paradox +15%',
    edit: (j) {
      final p = m(j['prestige']);
      p['divisor'] = d(p['divisor']) / math.pow(1.15, 3);
    },
  ),
  Trait(
    'ch.bonusSprings',
    'chronos',
    'each Chronos bonus in a loop gives 2 Mainsprings instead of 1',
    edit: (j) => m(j['loops'])['goalBonusSprings'] = 2,
  ),
  Trait(
    'ch.unlockCheap',
    'chronos',
    'the "Chronos" perk costs half (250 Chronons)',
    edit: (j) {
      for (final p in l(m(j['prestige'])['perks'])) {
        if (m(p)['id'] == 'unlockChronos') m(p)['cost'] = 250;
      }
    },
  ),
  Trait('t.carry3', 'timeMachine', 'carry 3%', session: carry(0.03)),
  Trait('t.carry6', 'timeMachine', 'carry 6%', session: carry(0.06)),
  Trait(
    'g.offline30',
    'grandpa',
    'offline +30%',
    edit: (j) => offlineTimes(j, 1.30),
  ),
  Trait(
    'st.gold40',
    'stationClock',
    'Golden Second 40% more often',
    edit: (j) => goldenOften(j, 1.4),
  ),
  Trait(
    'q.passive25',
    'quartz',
    'all clocks +25%',
    edit: (j) => clocksTimes(j, 1.25),
  ),
  ...tierI,
  ...tierII,
  Trait(
    't.flat50',
    'timeMachine',
    'a new loop starts with 50 Chronons',
    session: carryFlat(50),
  ),
  Trait(
    't.flat200',
    'timeMachine',
    'a new loop starts with 200 Chronons',
    session: carryFlat(200),
  ),
  together('SET.I-tm', 'tier 3 without the Time Machine, +50 Chronons a loop', [
    for (final x in tierI)
      if (x.clock != 'timeMachine') x,
    Trait('', '', '', session: carryFlat(50)),
  ]),
  together(
    'SET.II-tm',
    'tier 5 without the Time Machine, +200 Chronons a loop',
    [
      for (final x in tierII)
        if (x.clock != 'timeMachine') x,
      Trait('', '', '', session: carryFlat(200)),
    ],
  ),
  Trait(
    't.flat10',
    'timeMachine',
    'a new loop starts with 10 Chronons',
    session: carryFlat(10),
  ),
  Trait(
    't.flat25',
    'timeMachine',
    'a new loop starts with 25 Chronons',
    session: carryFlat(25),
  ),
  together('FINAL.I', 'the recommended tier-3 traits (docs/18)', finalI),
  together('FINAL.II', 'the recommended tier-5 traits (docs/18)', finalII),
  together('FINAL2.I', 'the recommendation, tier 3, half strength', final2I),
  together('FINAL2.II', 'the recommendation, tier 5, half strength', final2II),
  together('FINAL3.II', 'tier 5, cuckoo once a day, Chronos bonus 1 spring', [
    for (final x in final2II)
      if (x.clock == 'cuckoo')
        Trait(
          '',
          'cuckoo',
          'golden on the first return of the day',
          edit: (j) => goldenOften(j, 1.25),
        )
      else if (x.clock == 'chronos')
        Trait('', 'chronos', 'perk 400', edit: (j) => chronosPerk(j, 400))
      else
        x,
  ]),
  together('SET.I', 'every tier-3 trait at once', tierI),
  together(
    'SET.II',
    'every tier-5 trait at once (they replace tier 3)',
    tierII,
  ),
];

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final sessions = int.parse(opt('sessions', '3'));
  final minutes = double.parse(opt('minutes', '11'));
  final sigma = double.parse(opt('sigma', '0.04'));
  final loops = int.parse(opt('loops', '6'));
  final only = opt('only', '').split(',').where((x) => x.isNotEmpty).toSet();
  final snapPath = opt('snap', '');
  final json = File('assets/balance.json').readAsStringSync();
  if (args.contains('--real')) {
    realRun(
      json,
      sessions,
      minutes,
      sigma,
      int.parse(opt('days', '120')),
      !args.contains('--today'),
      opt('without', ''),
    );
    return;
  }
  final base = Balance.fromJsonString(json);

  // Loop 1 on today's rules, once (or read from --snap).
  GameState snap;
  if (snapPath.isNotEmpty && File(snapPath).existsSync()) {
    snap = decodeSave(jsonDecode(File(snapPath).readAsStringSync()) as Json)
        .state;
  } else {
    final s = GameState()..tutorialDone = true;
    final p = Player(
      base,
      s,
      sessions: sessions,
      minutes: minutes,
      sigma: sigma,
      loops: true,
    );
    while (s.loop < 2 && p.day < 60) {
      p.playDay();
    }
    stdout.writeln('loop 1 done on day ${p.day}: ${p.loopLog.join()}');
    snap = s;
    if (snapPath.isNotEmpty) {
      File(snapPath)
          .writeAsStringSync(jsonEncode(encodeSave(SaveData(s, Settings()))));
    }
  }
  final tiers0 = snap.clockLevels.values.fold(0, (a, x) => a + x);
  stdout.writeln(
    'start of loop ${snap.loop}: mastery tiers $tiers0, '
    'Mainsprings ${snap.springs}, levels ${snap.clockLevels}',
  );

  for (final t in traits) {
    if (only.isNotEmpty && !only.contains(t.id)) continue;
    if (t.edit == null &&
        t.session == null &&
        !{'none', 'noise'}.contains(t.id)) {
      stdout.writeln('${t.id.padRight(16)} (not simulated) ${t.text}');
      continue;
    }
    final j = jsonDecode(json) as Json;
    t.edit?.call(j);
    final b = Balance.fromJsonString(jsonEncode(j));
    final s = clone(snap);
    final run = TraitRun(b, sessions, minutes);
    var golden = 0;
    final p = Player(
      b,
      s,
      sessions: sessions,
      minutes: minutes,
      sigma: t.id == 'noise' ? sigma * 1.01 : sigma,
      loops: true,
    );
    var lastGolden = s.lifetime.goldenCaught;
    p.onSession = (st, day, passive) {
      golden += st.lifetime.goldenCaught - lastGolden;
      lastGolden = st.lifetime.goldenCaught;
      run.sessionsPlayed++;
      run.newLoop = run.lastLoop >= 0 && st.loop != run.lastLoop;
      t.session?.call(run, st, passive);
      run.lastLoop = st.loop;
      run.chrononsBefore = st.chronons;
    };
    final springs0 = s.lifetime.springsWound;
    final startLoop = s.loop;
    var sessionsPlayed = 0;
    while (s.loop < startLoop + loops && p.day < 90) {
      p.playDay();
      sessionsPlayed += sessions;
    }
    final goals = [
      for (final line in p.loopLog) double.parse(line.substring(16, 27).trim()),
    ];
    final exits = [
      for (final line in p.loopLog) double.parse(line.substring(35, 46).trim()),
    ];
    String f(double v) => v.toStringAsFixed(1);
    stdout.writeln(
      'RESULT ${t.id.padRight(16)} ${t.clock.padRight(12)} '
      'goal ${goals.map(f).join(' ')}  sum ${f(goals.fold(0.0, (a, x) => a + x))}'
      '  exit-sum ${f(exits.fold(0.0, (a, x) => a + x))}'
      '  springs ${s.lifetime.springsWound - springs0}'
      '  tiers ${s.clockLevels.values.fold(0, (a, x) => a + x)}'
      '  golden/session ${(golden / math.max(1, sessionsPlayed)).toStringAsFixed(2)}'
      '  | ${t.text}',
    );
  }
}

// ------------------------------------------------- the real game (--real) --

/// One clock's traits: [i] at tier 3, [ii] added at tier 5 (docs/18 §4).
class ClockTraits {
  const ClockTraits(this.clock, this.i, this.ii);
  final String clock;
  final Trait i;
  final Trait ii;
}

/// Extra pay of the first [hits] hits after a break: ×(1 + hours away),
/// at most ×9 ("Na start!", docs/18).
void Function(TraitRun, GameState, double) warmUp(int hits) => (r, s, p) {
  if (r.away < 3600) return;
  final sim = Simulator(r.b, SimConfig(sigma: r.sigma), state: s);
  final perHit = (sim.totalIncome(false) - p) * sim.econ.roundSeconds();
  final extra = perHit * hits * (math.min(9.0, 1 + r.away / 3600) - 1);
  s.earn(extra);
  r.extra += extra;
};

final chosenAll = <ClockTraits>[
  ClockTraits(
    'grandpa',
    const Trait('', '', 'offline cap +4 h (3 sessions a day: never reached)'),
    Trait('', '', 'offline +10%', edit: (j) => offlineTimes(j, 1.10)),
  ),
  ClockTraits(
    'grandma',
    const Trait(
      '',
      '',
      'the daily streak forgives a day (the bot never misses)',
    ),
    Trait(
      '',
      '',
      '7th day 3 Mainsprings',
      edit: (j) => m(j['daily'])['lastDaySprings'] = 3,
    ),
  ),
  ClockTraits(
    'cuckoo',
    // A session of 11 min holds a full hour 18% of the time, a half 37%.
    Trait(
      '',
      '',
      'golden on the hour',
      edit: (j) => goldenOften(j, 1 + 0.18 / 1.1),
    ),
    Trait(
      '',
      '',
      'and on the half hour',
      edit: (j) => goldenOften(j, (1 + 0.37 / 1.1) / (1 + 0.18 / 1.1)),
    ),
  ),
  ClockTraits(
    'metronome',
    Trait('', '', 'reserve refill ×1.5', edit: (j) => reserveTimes(j, 1, 1.5)),
    Trait('', '', 'reserve ×2', edit: (j) => reserveTimes(j, 2, 1)),
  ),
  ClockTraits(
    'watchmaker',
    Trait('', '', 'perks −10%', edit: (j) => perksTimes(j, 0.90)),
    Trait('', '', 'perks −20% in all', edit: (j) => perksTimes(j, 0.80 / 0.90)),
  ),
  ClockTraits(
    'sprintJudge',
    Trait('', '', 'Na start!: 10 hits', session: warmUp(10)),
    Trait('', '', 'Na start!: 25 hits in all', session: warmUp(15)),
  ),
  ClockTraits(
    'stationClock',
    Trait('', '', 'golden 10% more often', edit: (j) => goldenOften(j, 1.10)),
    // Every 5th caught one twice as strong: +20% on average.
    Trait('', '', 'Express', edit: (j) => goldenStrong(j, 1.2)),
  ),
  ClockTraits(
    'quartz',
    Trait('', '', 'clocks +10%', edit: (j) => clocksTimes(j, 1.10)),
    const Trait('', '', 'Synchronisation: +1% a clock at tier 5 (below)'),
  ),
  ClockTraits(
    'atomic',
    Trait(
      '',
      '',
      'a Mainspring in 22 h',
      edit: (j) => m(j['springs'])['secondsPerSpring'] = 79200,
    ),
    Trait(
      '',
      '',
      'in 20 h',
      edit: (j) => m(j['springs'])['secondsPerSpring'] = 72000,
    ),
  ),
  ClockTraits(
    'gps',
    // All three daily challenges done every day (the bot plays none):
    // half a Mainspring, one every second day.
    Trait(
      '',
      '',
      'all dailies: ½ Mainspring',
      session: springsWhen(1, (r) => r.sessionsPlayed % (2 * r.sessions) == 0),
    ),
    Trait(
      '',
      '',
      'weekly +1 Mainspring',
      session: springsWhen(1, (r) => r.sessionsPlayed % (7 * r.sessions) == 0),
    ),
  ),
  ClockTraits(
    'pulsar',
    Trait('', '', 'golden effects +15%', edit: (j) => goldenStrong(j, 1.15)),
    Trait(
      '',
      '',
      'Frenzy 50% longer',
      edit: (j) => goldenEffect(j, 'frenzy', 'duration', (v) => v * 1.5),
    ),
  ),
  ClockTraits(
    'timeMachine',
    Trait('', '', 'a loop starts with 10 Chronons', session: carryFlat(10)),
    Trait('', '', '+15 more', session: carryFlat(15)),
  ),
  ClockTraits(
    'schrodinger',
    // The coin: half the paradoxes pay +10% (+20% at tier 5).
    Trait('', '', 'coin: 50% for +10%', edit: (j) => chrononsTimes(j, 1.05)),
    Trait(
      '',
      '',
      'coin: 50% for +20%',
      edit: (j) => chrononsTimes(j, 1.10 / 1.05),
    ),
  ),
  ClockTraits(
    'chronos',
    Trait('', '', 'Chronos perk 400', edit: (j) => chronosPerk(j, 400)),
    Trait(
      '',
      '',
      'Chronos bonus 2 Mainsprings',
      edit: (j) => m(j['loops'])['goalBonusSprings'] = 2,
    ),
  ),
];

/// The order a player who reads the cards levels the clocks in: tier 3
/// everywhere first, then tier 5 (Chronos once it is there).
const levelOrder = [
  'quartz',
  'stationClock',
  'chronos',
  'timeMachine',
  'cuckoo',
  'atomic',
  'watchmaker',
  'schrodinger',
  'pulsar',
  'metronome',
  'gps',
  'sprintJudge',
  'grandpa',
  'grandma',
];

void realRun(
  String json,
  int sessions,
  double minutes,
  double sigma,
  int days,
  bool traitsOn, [
  String without = '',
]) {
  final chosen = [
    for (final c in chosenAll)
      if (c.clock != without) c,
  ];
  final cache = <String, Balance>{};
  Balance balanceFor(GameState s) {
    if (!traitsOn) {
      return cache.putIfAbsent('', () => Balance.fromJsonString(json));
    }
    final lv = s.clockLevels;
    final key = [for (final c in chosen) '${c.clock}${lv[c.clock] ?? 0}']
        .join();
    return cache.putIfAbsent(key, () {
      final j = jsonDecode(json) as Json;
      var at5 = 0;
      for (final c in chosen) {
        final l = lv[c.clock] ?? 0;
        if (l >= 3) c.i.edit?.call(j);
        if (l >= 5) {
          c.ii.edit?.call(j);
          at5++;
        }
      }
      if ((lv['quartz'] ?? 0) >= 5) clocksTimes(j, 1 + 0.01 * at5);
      return Balance.fromJsonString(jsonEncode(j));
    });
  }

  final s = GameState()..tutorialDone = true;
  final p = Player(
    balanceFor(s),
    s,
    sessions: sessions,
    minutes: minutes,
    sigma: sigma,
    loops: true,
    spendSprings: !traitsOn,
  );
  final run = TraitRun(p.b, sessions, minutes)..sigma = sigma;
  double? all3, all5;
  var golden = 0, lastGolden = 0;
  p.onSession = (st, day, passive) {
    golden += st.lifetime.goldenCaught - lastGolden;
    lastGolden = st.lifetime.goldenCaught;
    run.sessionsPlayed++;
    run.newLoop = run.lastLoop >= 0 && st.loop != run.lastLoop;
    if (traitsOn) {
      for (final c in chosen) {
        final l = st.clockLevels[c.clock] ?? 0;
        if (l >= 3) c.i.session?.call(run, st, passive);
        if (l >= 5) c.ii.session?.call(run, st, passive);
      }
      // Spend: every clock to 3 in [levelOrder], then every one to 5.
      final e = GameEngine(p.b, st);
      for (final target in [3, 5]) {
        for (final id in levelOrder) {
          while ((st.clockLevels[id] ?? 0) < target &&
              e.econ.clockLevelable(id) &&
              e.levelClock(id) == BuyResult.ok) {}
        }
      }
      p.b = balanceFor(st);
    }
    run.lastLoop = st.loop;
    run.chrononsBefore = st.chronons;
    final lv = st.clockLevels;
    final n = run.b.generators.length;
    if (all3 == null && lv.values.where((x) => x >= 3).length == n) all3 = day;
    if (all5 == null && lv.values.where((x) => x >= 5).length == n) all5 = day;
  };
  while (p.day < days) {
    p.playDay();
  }
  String f(double v) => v.toStringAsFixed(1);
  final goals = [
    for (final x in p.loopLog) double.parse(x.substring(16, 27).trim()),
  ];
  final exits = [
    for (final x in p.loopLog) double.parse(x.substring(35, 46).trim()),
  ];
  var t = 0.0;
  final ends = [for (final e in exits) t += e];
  stdout.writeln(
    'REAL ${traitsOn ? 'traits' : 'today '} without ${without.isEmpty ? '—' : without} σ ${(sigma * 1000).toStringAsFixed(1)}  '
    'loops ${p.loopLog.length} by day $days  goal days ${goals.map(f).join(' ')}\n'
    '     loop ends on day ${ends.map(f).join(' ')}\n'
    '     tiers ${s.clockLevels.values.fold(0, (a, x) => a + x)}  all at 3: day ${all3 == null ? '—' : f(all3!)}'
    '  all at 5: day ${all5 == null ? '—' : f(all5!)}  wound ${s.lifetime.springsWound}'
    '  golden/session ${(golden / (days * sessions)).toStringAsFixed(2)}'
    '  warm-up ${(100 * run.extra / s.lifetime.earnedEver).toStringAsFixed(2)}% of all Tiki',
  );
}
