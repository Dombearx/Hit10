#!/usr/bin/env python3
"""Master titles (docs/12 R-SPR-6, 14 clocks × levels 5 and 10) and the
stopwatch faces (docs/12 §3.3).

Writes them into app/lib/l10n/app_{pl,en}.arb as master_<generator>_<level>
(+ _desc) and dial_<id> (+ _desc), and generates app/lib/l10n/master_texts.dart
(AppLocalizations has no lookup by key). The humour is written per language,
not translated word for word (docs/04 U-18).

    python3 tools/l10n/masters.py && (cd app && flutter gen-l10n)
"""
import json
import re
from collections import OrderedDict
from pathlib import Path

APP = Path(__file__).resolve().parents[2] / "app"

LEVELS = (5, 10)

# generator: [(pl name, pl line, en name, en line)] for levels 5 and 10
MASTERS = {
    "grandpa": [
        ("Emerytowany zegarmistrz", "Naprawia zegarki sąsiadom. Za darmo, ale z wykładem.",
         "Retired Watchmaker", "Fixes the neighbours' watches. Free, with a lecture."),
        ("Dziadek wie lepiej", "I ma rację. Niestety.",
         "Grandpa Knows Best", "And he's right. Sadly."),
    ],
    "grandma": [
        ("Jajko idealne", "Ani sekundy za długo. Ani jednej.",
         "The Perfect Egg", "Not a second too long. Not one."),
        ("Babcia w trybie turbo", "Minutnik się jej boi.",
         "Turbo Grandma", "The egg timer is scared of her."),
    ],
    "cuckoo": [
        ("Kukułka z dyplomem", "Kuka równo. Wymaga, żeby mówić „pani magister”.",
         "Cuckoo with a Degree", "Cuckoos on time. Insists on being called Doctor."),
        ("Kukułka-celebrytka", "Wychodzi z domku tylko na wywiady.",
         "Celebrity Cuckoo", "Leaves the little house only for interviews."),
    ],
    "metronome": [
        ("Wirtuoz tyknięcia", "Tik. Tak. Brawa.",
         "Tick Virtuoso", "Tick. Tock. Applause."),
        ("Metronom filharmonii", "Dyryguje dyrygentem.",
         "Philharmonic Metronome", "Conducts the conductor."),
    ],
    "watchmaker": [
        ("Złota lupa", "Widzi atomy. I kurz na nich.",
         "Golden Loupe", "Sees atoms. And the dust on them."),
        ("Mistrz cechu", "Nawet zegar słoneczny przychodzi do niego po radę.",
         "Guild Master", "Even sundials come to him for advice."),
    ],
    "sprintJudge": [
        ("Oko sokoła", "Widzi falstart, zanim zawodnik o nim pomyśli.",
         "Eagle-eyed Judge", "Spots a false start before the runner thinks of it."),
        ("Sędzia olimpijski", "Gwizdek ma pozłacany. Cierpliwość nie.",
         "Olympic Judge", "Gold-plated whistle. Patience not included."),
    ],
    "stationClock": [
        ("Pociąg o czasie", "Pasażerowie nie wierzą. Robią zdjęcia.",
         "Train on Time", "Passengers don't believe it. They take photos."),
        ("Dworzec bez opóźnień", "Komunikat „może ulec zmianie” trafił do muzeum.",
         "Zero-delay Station", "\"Subject to change\" is now in a museum."),
    ],
    "quartz": [
        ("Kryształ bez skazy", "Drga dokładnie 32 768 razy. Sprawdzaliśmy.",
         "Flawless Crystal", "Vibrates exactly 32,768 times. We checked."),
        ("Kwarc królewski", "Na dworze nosi się go zamiast korony.",
         "Royal Quartz", "Worn at court instead of a crown."),
    ],
    "atomic": [
        ("Atom spokoju", "Elektrony chodzą na palcach.",
         "Atom of Calm", "Electrons tiptoe around it."),
        ("Wzorzec sekundy", "Sekunda trwa tyle, ile on mówi.",
         "The Standard Second", "A second lasts as long as it says."),
    ],
    "gps": [
        ("Satelita bez zgubień", "Nigdy nie mówi „zawróć, gdy to możliwe”.",
         "Never-lost Satellite", "Never says \"make a U-turn when possible\"."),
        ("Pan orbity", "Inne satelity ustawiają się według niego.",
         "Lord of the Orbit", "Other satellites set themselves by it."),
    ],
    "pulsar": [
        ("Pulsar z rytmem", "Wszechświat tupie nogą do taktu.",
         "Pulsar with Rhythm", "The universe taps its foot along."),
        ("Latarnia galaktyki", "Statki obcych synchronizują po nim zegarki.",
         "Lighthouse of the Galaxy", "Alien ships set their watches by it."),
    ],
    "timeMachine": [
        ("Bilet powrotny", "Wraca, zanim wyjedzie. Bez spóźnień.",
         "Return Ticket", "Back before it leaves. Never late."),
        ("Pętla doskonała", "Spotkała samą siebie. Obie trafiły w 5.00.",
         "Perfect Loop", "Met itself. Both hit 5.00."),
    ],
    "schrodinger": [
        ("Kot obserwowany", "Trafia, gdy patrzysz. Gdy nie patrzysz, też.",
         "Observed Cat", "Hits when you look. When you don't, too."),
        ("Kot w obu pudełkach", "Śpi i trafia jednocześnie. Mruczy w superpozycji.",
         "Cat in Both Boxes", "Asleep and on target at once. Purrs in superposition."),
    ],
    "chronos": [
        ("Chronos na urlopie", "Czas płynie sam, a i tak równo.",
         "Chronos on Holiday", "Time flows on its own, and still on the dot."),
        ("Pan wszystkich sekund", "Nawet ta sekunda przed chwilą była jego.",
         "Lord of All Seconds", "Even the second that just passed was his."),
    ],
}

# dial id: (pl name, pl line, en name, en line), in unlock order
DIALS = {
    "classic": ("Klasyczna", "Biała, czysta, niezawodna.",
                "Classic", "White, clean, reliable."),
    "wood": ("Drewniak", "Pachnie warsztatem dziadka.",
             "Woodgrain", "Smells like Grandpa's workshop."),
    "porcelain": ("Porcelana babci", "Z serwisu na specjalne okazje. Nie upuść.",
                  "Grandma's Porcelain", "From the good china. Don't drop it."),
    "brass": ("Mosiądz", "Błyszczy jak klamka w ratuszu.",
              "Brass", "Shines like a town hall door handle."),
    "station": ("Dworcowa", "Duża, żeby było widać opóźnienie z daleka.",
                "Station", "Big, so you can see the delay from far away."),
    "swiss": ("Szwajcarka", "Czerwona, precyzyjna i trochę zadufana.",
              "Swiss", "Red, precise and a little smug."),
    "quartz": ("Kwarcówka", "Zielone cyfry, jak w budziku z lat 80.",
               "Quartz LCD", "Green digits, like an 80s alarm clock."),
    "atomic": ("Atomowa", "Świeci lekko na niebiesko. Podobno to normalne.",
               "Atomic", "Glows faintly blue. Apparently that's normal."),
    "neon": ("Neonówka", "Do grania po północy.",
             "Neon", "For playing after midnight."),
    "cosmic": ("Kosmiczna", "Gwiazdy w tle, sekundy na pierwszym planie.",
               "Cosmic", "Stars behind, seconds in front."),
    "golden": ("Złota", "Lita. No, prawie lita.",
               "Golden", "Solid gold. Well, almost."),
    "rift": ("Pęknięta czasoprzestrzeń", "Przez szczelinę widać wczorajsze 5.00.",
             "Spacetime Rift", "Through the crack you can see yesterday's 5.00."),
}


# Clock traits (docs/18 §4): generator → [tier 3, tier 5], each
# (pl name, pl text, en name, en text). {a}, {b}, {c} are filled in by the
# app from the balance file (app/lib/ui/trait_text.dart), so the numbers
# here never go stale.
TRAITS = {
    "grandpa": [
        ("Drzemka po obiedzie", "Limit dochodu offline +{a}.",
         "After-Lunch Nap", "Offline income limit +{a}."),
        ("Chrapie równo", "Dochód offline +{a}.",
         "Snores in Time", "Offline income +{a}."),
    ],
    "grandma": [
        ("Babcia pamięta", "Jeden opuszczony dzień nigdy nie przerywa serii dziennej premii, nie tylko raz w tygodniu.",
         "Grandma Remembers", "A single missed day never breaks the daily bonus streak, not just once a week."),
        ("Niedzielny obiad", "7. dzień dziennej premii daje {a} Sprężyny zamiast 1.",
         "Sunday Dinner", "Day 7 of the daily bonus gives {a} Mainsprings instead of 1."),
    ],
    "cuckoo": [
        ("Kuku o pełnej", "O każdej pełnej godzinie w czasie gry wylatuje dodatkowa Złota Sekunda.",
         "Cuckoo on the Hour", "On every full hour while you play, an extra Golden Second flies out."),
        ("Kuku o wpół do", "Kukułka wylatuje też o wpół do.",
         "Half-Past Cuckoo", "The cuckoo also comes out at half past."),
    ],
    "metronome": [
        ("Równe tempo", "Zapas dokręcania odnawia się {a} szybciej.",
         "Steady Tempo", "The winding reserve refills {a} faster."),
        ("Dłuższy takt", "Zapas dokręcania jest {a} większy.",
         "Longer Bar", "The winding reserve is {a} bigger."),
    ],
    "watchmaker": [
        ("Rabat u pana Henia", "Perki tańsze o {a}.",
         "Mr Henry's Discount", "Perks cost {a} less."),
        ("Po znajomości", "Perki tańsze o {a} razem.",
         "Friend of the Trade", "Perks cost {a} less in all."),
    ],
    "sprintJudge": [
        ("Na start!", "Po przerwie od {a} pierwsze {b} trafień płaci ×(1 + godziny nieobecności), najwyżej {c}.",
         "On Your Marks!", "After a break of {a} or more, your first {b} hits pay ×(1 + hours away), up to {c}."),
        ("Długi sprint", "„Na start!” obejmuje {a} trafień.",
         "Long Sprint", "“On Your Marks!” covers {a} hits."),
    ],
    "stationClock": [
        ("Według rozkładu", "Złota Sekunda pojawia się {a} częściej.",
         "On Schedule", "Golden Seconds come {a} more often."),
        ("Ekspres", "Co {a}. złapana Złota Sekunda ma podwójny efekt.",
         "Express", "Every {a}th Golden Second you catch has double the effect."),
    ],
    "quartz": [
        ("Kwarcowy chód", "Wszystkie zegary dają +{a} dochodu.",
         "Quartz Accuracy", "All clocks earn +{a}."),
        ("Synchronizacja", "+{a} do wszystkich zegarów za każdy zegar z 5. stopniem mistrzostwa (teraz +{b}).",
         "Synchronisation", "+{a} to all clocks for every clock at mastery tier 5 (now +{b})."),
    ],
    "atomic": [
        ("Co do sekundy", "Sprężyna nakręca się w {a} zamiast 24 h.",
         "To the Second", "A Mainspring winds in {a} instead of 24 h."),
        ("Rozpad połowiczny", "Sprężyna nakręca się w {a}.",
         "Half-Life", "A Mainspring winds in {a}."),
    ],
    "gps": [
        ("Wyznaczona trasa", "Komplet trzech wyzwań dziennych nakręca dodatkowo {a} Sprężyny.",
         "Route Planned", "All three daily challenges wind {a} of a Mainspring on top."),
        ("Cel osiągnięty", "Wyzwanie tygodnia daje +{a} Sprężynę.",
         "Destination Reached", "The weekly challenge gives +{a} Mainspring."),
    ],
    "pulsar": [
        ("Sygnał z kosmosu", "Efekty Złotej Sekundy są o {a} mocniejsze.",
         "Signal from Space", "Golden Second effects are {a} stronger."),
        ("Długi impuls", "Szał trwa o {a} dłużej.",
         "Long Pulse", "Frenzy lasts {a} longer."),
    ],
    "timeMachine": [
        ("Bilet powrotny", "Nowa pętla zaczyna się z {a} Chrononami i Okruchami.",
         "Return Ticket", "A new loop starts with {a} Chronons and Shards."),
        ("Bagaż podręczny", "Nowa pętla zaczyna się z {a} Chrononami i Okruchami.",
         "Hand Luggage", "A new loop starts with {a} Chronons and Shards."),
    ],
    "schrodinger": [
        ("Żyje czy nie?", "Przy paradoksie rzut monetą: {a} szans na +{b} Chrononów.",
         "Alive or Not?", "At a paradox, a coin toss: {a} chance of +{b} Chronons."),
        ("Dziewięć żyć", "Wygrany rzut daje +{a} Chrononów.",
         "Nine Lives", "A won toss gives +{a} Chronons."),
    ],
    "chronos": [
        ("Znajomość z Czasem", "Perk „Chronos” kosztuje {a} zamiast {b} Okruchów.",
         "Friends with Time", "The “Chronos” perk costs {a} instead of {b} Shards."),
        ("Hojny Czas", "Każdy bonus Chronosa daje {a} Sprężyny zamiast 1.",
         "Generous Time", "Every Chronos bonus gives {a} Mainsprings instead of 1."),
    ],
}


def mkey(gen, lv):
    return f"master_{gen}_{lv}"


def write_arb(path, lang):
    d = json.loads(path.read_text(), object_pairs_hook=OrderedDict)
    for k in [k for k in d if k.startswith(("master_", "dial_", "trait_", "@trait_"))]:
        del d[k]
    for gen, items in MASTERS.items():
        for lv, (pl, pl_line, en, en_line) in zip(LEVELS, items):
            name, line = (pl, pl_line) if lang == "pl" else (en, en_line)
            d[mkey(gen, lv)] = name
            d[mkey(gen, lv) + "_desc"] = line
    for gen, items in TRAITS.items():
        for tier, (pl, pl_text, en, en_text) in enumerate(items, 1):
            name, text = (pl, pl_text) if lang == "pl" else (en, en_text)
            k = f"trait_{gen}_{tier}"
            d[k] = name
            d[k + "_desc"] = text
            args = trait_args(pl_text)
            if args:
                d["@" + k + "_desc"] = {
                    "placeholders": {a: {"type": "String"} for a in args}
                }
    for did, (pl, pl_line, en, en_line) in DIALS.items():
        name, line = (pl, pl_line) if lang == "pl" else (en, en_line)
        d[f"dial_{did}"] = name
        d[f"dial_{did}_desc"] = line
    path.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n")


def trait_args(text):
    return sorted(set(re.findall(r"\{([abc])\}", text)))


def write_dart(path):
    lines = [
        "// GENERATED by tools/l10n/masters.py — do not edit by hand.",
        "import 'gen/app_localizations.dart';",
        "",
        "/// Master title and one-liner of clock [generator] at Mainspring",
        "/// [level] (docs/12 R-SPR-6); null for an unknown pair.",
        "(String, String)? masterTexts(",
        "  AppLocalizations l,",
        "  String generator,",
        "  int level,",
        ") => switch ((generator, level)) {",
    ]
    for gen in MASTERS:
        for lv in LEVELS:
            k = mkey(gen, lv)
            lines.append(f"  ('{gen}', {lv}) => (l.{k}, l.{k}_desc),")
    lines += ["  _ => null,", "};", ""]
    lines += [
        "/// Name and one-liner of stopwatch face [id] (docs/12 §3.3).",
        "(String, String)? dialTexts(AppLocalizations l, String id) =>",
        "    switch (id) {",
    ]
    for did in DIALS:
        lines.append(f"      '{did}' => (l.dial_{did}, l.dial_{did}_desc),")
    lines += ["      _ => null,", "    };", ""]
    lines += [
        "/// Name and text of clock [generator]'s trait [tier] (1 at the first",
        "/// master title, 2 at the second; docs/18). [args] fill {a}, {b}, {c}.",
        "(String, String)? traitTexts(",
        "  AppLocalizations l,",
        "  String generator,",
        "  int tier,",
        "  List<String> args,",
        ") {",
        "  String a(int i) => i < args.length ? args[i] : '';",
        "  return switch ((generator, tier)) {",
    ]
    for gen, items in TRAITS.items():
        for tier, (pl, pl_text, en, en_text) in enumerate(items, 1):
            k = f"trait_{gen}_{tier}"
            n = len(trait_args(pl_text))
            call = f"l.{k}_desc(" + ", ".join(f"a({i})" for i in range(n)) + ")" if n else f"l.{k}_desc"
            lines.append(f"    ('{gen}', {tier}) => (l.{k}, {call}),")
    lines += ["    _ => null,", "  };", "}", ""]
    path.write_text("\n".join(lines))


if __name__ == "__main__":
    assert len(MASTERS) == 14 and all(len(v) == len(LEVELS) for v in MASTERS.values())
    assert set(TRAITS) == set(MASTERS) and all(len(v) == 2 for v in TRAITS.values())
    for items in TRAITS.values():
        for pl, pl_text, en, en_text in items:
            assert trait_args(pl_text) == trait_args(en_text), pl
    write_arb(APP / "lib/l10n/app_pl.arb", "pl")
    write_arb(APP / "lib/l10n/app_en.arb", "en")
    write_dart(APP / "lib/l10n/master_texts.dart")
    print(f"{len(MASTERS) * len(LEVELS)} titles and {len(DIALS)} dials written")
