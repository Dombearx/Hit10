// When each way of unlocking a dial face would pay out (docs/17). From app/:
//
//   dart run tool/dial_report.dart [--sessions 3] [--minutes 3]
//       [--sigma 0.05] [--days 365] [--loops 1] [--stay 2] [--force 0]
//       [--out dials.csv]
//
// The player of `late_game_report.dart` part 5 (Time Loops on the game's
// rules). --loops 0 never starts a new loop; --stay 7 --force 1 stays a
// week after every Chronos, even with all of his bonuses paid. One CSV row
// a day with every counter a dial could be tied to; docs/17 reads them
// with "the first day the counter reached N".
import 'dart:io';

import 'package:hit10/balance/balance.dart';
import 'package:hit10/model/game_state.dart';

import 'late_game_report.dart' show Player;

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final b = Balance.fromJsonString(
    File('assets/balance.json').readAsStringSync(),
  );
  final days = int.parse(opt('days', '365'));
  final st = GameState()..tutorialDone = true;
  final q = Player(
    b,
    st,
    sessions: int.parse(opt('sessions', '3')),
    minutes: double.parse(opt('minutes', '3')),
    sigma: double.parse(opt('sigma', '0.05')),
    loops: opt('loops', '1') == '1',
    stayDays: double.parse(opt('stay', '2')),
  )..forceStay = opt('force', '0') == '1';

  // Chronos owned: the most in the current loop and in any loop, read
  // after every session (a loop can end inside a day).
  var loop = st.loop, loopMax = 0, best = 0;
  q.onSession = (s, day, passive) {
    final c = s.owned['chronos'] ?? 0;
    if (s.loop != loop) {
      loop = s.loop;
      loopMax = 0;
    }
    if (c > loopMax) loopMax = c;
    if (c > best) best = c;
  };

  final out = File(opt('out', 'dials.csv')).openWrite()
    ..writeln(
      'day,loop,loopsDone,seals,paradoxes,earnedEver,chronosLoopMax,'
      'chronosBest,tiers,titles,achievements,springsWound,perfects,'
      'exactHits,golden,hours,daily,dials',
    );
  while (q.day < days) {
    q.playDay();
    final l = st.lifetime;
    out.writeln(
      [
        q.day,
        st.loop,
        st.loopsDone,
        st.seals.length,
        q.paradoxCount,
        l.earnedEver.toStringAsExponential(3),
        loopMax,
        best,
        st.clockLevels.values.fold(0, (a, x) => a + x),
        q.titles,
        st.achievements.length,
        l.springsWound,
        l.perfects,
        l.exactHits,
        l.goldenCaught,
        q.playHours.toStringAsFixed(2),
        l.dailyClaims,
        q.dials,
      ].join(','),
    );
  }
  out.close();
}
