#!/usr/bin/env python3
"""Generator upgrade names and one-liners (docs/02 R-ULEP-2), 14 × 8.

Writes them into app/lib/l10n/app_{pl,en}.arb as upg_<generator>_<n> and
upg_<generator>_<n>_desc, and generates app/lib/l10n/upgrade_texts.dart, the
lookup the UI uses (AppLocalizations has no lookup by key). The humour is
written per language, not translated word for word (docs/04 U-18).

    python3 tools/l10n/upgrades.py && (cd app && flutter gen-l10n)
"""
import json
from collections import OrderedDict
from pathlib import Path

APP = Path(__file__).resolve().parents[2] / "app"

# generator: [(pl name, pl line, en name, en line)] × 8
UPGRADES = {
    "grandpa": [
        ("Okulary do czytania", "Wreszcie widzi wskazówki.",
         "Reading Glasses", "Finally sees the hands."),
        ("Nowa bateria", "Pierwsza od czasów kasety magnetofonowej.",
         "New Battery", "First one since cassette tapes."),
        ("Kapcie antypoślizgowe", "Stabilne stopy, stabilny kciuk.",
         "Non-slip Slippers", "Steady feet, steady thumb."),
        ("Krzyżówka z hasłem „CZAS”", "Rozwiązana w równe 10,00 s.",
         "Crossword: TIME", "Solved in exactly 10.00 s."),
        ("Sanatorium", "Wraca wypoczęty i dwa razy celniejszy.",
         "Spa Retreat", "Comes back rested and twice as sharp."),
        ("Wnuk informatyk", "Zsynchronizował mu zegarek z serwerem atomowym.",
         "Tech-savvy Grandson", "Synced his watch to an atomic server."),
        ("Medal za punktualność", "Przypięty dumnie do kamizelki.",
         "Punctuality Medal", "Pinned proudly to the waistcoat."),
        ("Zegarek po pradziadku", "Tyka w rodzinie od trzech pokoleń.",
         "Great-grandpa's Watch", "Ticking in the family for three generations."),
    ],
    "grandma": [
        ("Jajka od szczęśliwych kur", "Szczęśliwe kury, szczęśliwe minutniki.",
         "Happy Hen Eggs", "Happy hens, happy timers."),
        ("Fartuch w kropki", "Aerodynamiczny.",
         "Polka-dot Apron", "Aerodynamic."),
        ("Drugi minutnik", "Jeden do jajek, drugi do rosołu.",
         "A Second Timer", "One for the eggs, one for the soup."),
        ("Koło gospodyń", "Szkolenie z kuchennej precyzji. Z ciastem.",
         "Baking Club", "Precision training. With cake."),
        ("Książka „Dania w 10 sekund”", "Same szybkie przepisy.",
         "“Ten-Second Recipes”", "Quick dishes only."),
        ("Kuchenka indukcyjna", "Woda wrze, zanim pomyślisz.",
         "Induction Hob", "Boils before you think."),
        ("Wnuczka influencerka", "Nagrywa każde idealne 10,00.",
         "Influencer Granddaughter", "Films every perfect 10.00."),
        ("Złoty wałek", "Legenda całego osiedla.",
         "Golden Rolling Pin", "A neighbourhood legend."),
    ],
    "cuckoo": [
        ("Kurs dykcji", "Ku-ku. Wyraźnie i na czas.",
         "Diction Lessons", "Cuck-oo. Crisp and on time."),
        ("Nowe sprężynki", "Wyskakuje jak z procy.",
         "Fresh Springs", "Pops out like a slingshot."),
        ("Gniazdo z widokiem", "Lepszy widok, lepsze kukanie.",
         "Nest with a View", "Better view, better cuckoos."),
        ("Chór kukułek", "Kukają w kanonie.",
         "Cuckoo Choir", "Cuckooing in canon."),
        ("Lekcje u szwajcarskiego mistrza", "Precyzja prosto z Alp.",
         "Swiss Master Class", "Precision straight from the Alps."),
        ("Ziarna espresso", "Kuka szybciej, niż chce.",
         "Espresso Beans", "Cuckoos faster than it means to."),
        ("Własny agent", "Podpisała kontrakt na trasę koncertową.",
         "A Proper Agent", "Signed for a world tour."),
        ("Oryginał ze Schwarzwaldu", "Z certyfikatem i rodowodem.",
         "Black Forest Original", "Certified, with a pedigree."),
    ],
    "metronome": [
        ("Nowy obciążnik", "Mniej się waha, więcej trafia.",
         "New Weight", "Less wobble, more hits."),
        ("Smar do wahadła", "Cisza. Tylko tik-tak.",
         "Pendulum Oil", "Silence. Just tick-tock."),
        ("Takt na sześć ósmych", "Dla odmiany.",
         "Six-Eight Time", "For a change."),
        ("Posada w filharmonii", "Sto skrzypiec patrzy tylko na niego.",
         "Orchestra Gig", "A hundred violins watch only him."),
        ("Tryb techno", "140 uderzeń na minutę i ani jednego obok.",
         "Techno Mode", "140 beats a minute, not one off."),
        ("Cyfrowy bliźniak", "Rodzinna rywalizacja.",
         "Digital Twin", "Sibling rivalry."),
        ("Trasa z kwartetem jazzowym", "Swinguje, ale się nie spóźnia.",
         "Jazz Quartet Tour", "Swings, never late."),
        ("Złote wahadło", "Rytm doskonały.",
         "Golden Pendulum", "Perfect rhythm."),
    ],
    "watchmaker": [
        ("Nowa lupa", "Widzi każdą zębatkę. Nawet w myślach.",
         "New Loupe", "Sees every gear. Even the mental ones."),
        ("Zestaw śrubokrętów", "48 rozmiarów, wszystkie mikro.",
         "Screwdriver Set", "48 sizes, all of them tiny."),
        ("Czeladnik", "Uczy się na Twoich Tikach.",
         "Apprentice", "Learns on your Tiki."),
        ("Warsztat przy oknie", "Dzienne światło, dzienna precyzja.",
         "Window Workbench", "Daylight, daylight precision."),
        ("Mechanizm szwajcarski", "Przywieziony w walizce na kłódkę.",
         "Swiss Movement", "Delivered in a padlocked case."),
        ("Tourbillon", "Kręci się, żeby nigdy się nie mylić.",
         "Tourbillon", "Spins so it never errs."),
        ("Cech zegarmistrzów", "Tajemna wiedza przekazywana szeptem.",
         "Watchmakers' Guild", "Secret knowledge, passed on in whispers."),
        ("Wielka komplikacja", "Nikt nie wie, co robi. Ale działa.",
         "Grand Complication", "Nobody knows what it does. It works."),
    ],
    "sprintJudge": [
        ("Nowy gwizdek", "Fiuuu! Dokładnie na czas.",
         "New Whistle", "Tweet! Right on time."),
        ("Fotokomórka", "Widzi różnicę jednej setnej.",
         "Photo Finish", "Sees one hundredth of a second."),
        ("Pistolet startowy", "Bez naboi, za to z wyczuciem.",
         "Starter Pistol", "No bullets, all timing."),
        ("Wysokie krzesło", "Z widokiem prosto na metę.",
         "Umpire's Chair", "With a view straight down the line."),
        ("Licencja olimpijska", "Teraz to już oficjalne.",
         "Olympic Licence", "It's official now."),
        ("Powtórka wideo", "Klatka po klatce.",
         "Video Replay", "Frame by frame."),
        ("Rekord świata w sędziowaniu", "9,58 s? Za wolno.",
         "World-record Judging", "9.58 s? Too slow."),
        ("Złoty stoper", "Mierzy czas, jakby go wymyślił.",
         "Golden Stopwatch", "Times as if it invented time."),
    ],
    "stationClock": [
        ("Nowy rozkład jazdy", "Teraz uwzględnia rzeczywistość.",
         "New Timetable", "Now accounts for reality."),
        ("Umyta tarcza", "Widać ją z peronu piątego.",
         "Polished Face", "Visible from platform five."),
        ("Komunikat z megafonu", "„Pociąg o 10,00 przyjedzie punktualnie.”",
         "PA Announcement", "“The 10.00 will arrive on time.”"),
        ("Zawiadowca stacji", "Czapka z daszkiem i śmiertelna powaga.",
         "Stationmaster", "Peaked cap, dead serious."),
        ("Kolej dużych prędkości", "Mniej opóźnień, więcej trafień.",
         "High-speed Rail", "Fewer delays, more hits."),
        ("Zegar sterowany radiowo", "Radio wie, która godzina.",
         "Radio-controlled", "The radio knows the time."),
        ("Dworzec centralny", "Tysiąc pasażerów patrzy na jeden zegar.",
         "Grand Central", "A thousand commuters, one clock."),
        ("Punktualny pociąg", "Legenda, w którą nikt nie wierzył.",
         "The Train That Was On Time", "A legend nobody believed."),
    ],
    "quartz": [
        ("Świeży kryształ", "Drga jak nowy.",
         "Fresh Crystal", "Vibrates like new."),
        ("Porządne lutowanie", "Bez zimnych lutów, bez wymówek.",
         "Proper Soldering", "No cold joints, no excuses."),
        ("Wyświetlacz LCD", "Cyferki jak z lat 80.",
         "LCD Display", "Digits straight from the 80s."),
        ("Kompensacja temperatury", "Pogoda go nie obchodzi.",
         "Temperature Compensation", "Doesn't care about the weather."),
        ("Podwójny oscylator", "Dwa razy 32 768.",
         "Dual Oscillator", "Two times 32,768."),
        ("Fabryka w Szwajcarii", "Ironia losu.",
         "Swiss Factory", "The irony."),
        ("Kalkulator w zestawie", "Liczy Tiki w locie.",
         "Built-in Calculator", "Counts Tiki on the fly."),
        ("Kryształ górski", "Ten z legend.",
         "Rock Crystal", "The one from the legends."),
    ],
    "atomic": [
        ("Chłodzenie laserowe", "Atomy prawie stoją. Prawie.",
         "Laser Cooling", "Atoms almost stand still. Almost."),
        ("Czystszy cez", "Cez 133, bez dodatków.",
         "Purer Caesium", "Caesium-133, no additives."),
        ("Fontanna atomowa", "Atomy podskakują w rytm.",
         "Atomic Fountain", "Atoms bounce to the beat."),
        ("Zegar optyczny", "Mierzy czas światłem.",
         "Optical Clock", "Measures time with light."),
        ("Pułapka jonowa", "Jeden jon, zero wymówek.",
         "Ion Trap", "One ion, zero excuses."),
        ("Sieć laboratoriów", "Każda sekunda przechodzi głosowanie.",
         "Lab Network", "Every second is put to a vote."),
        ("Sekunda przestępna", "Dodana, gdy nikt nie patrzył.",
         "Leap Second", "Added while nobody was looking."),
        ("Zegar jądrowy", "Tor-229 nie zna żartów.",
         "Nuclear Clock", "Thorium-229 doesn't do jokes."),
    ],
    "gps": [
        ("Lepsza antena", "Słyszy Ziemię wyraźniej.",
         "Better Antenna", "Hears Earth more clearly."),
        ("Poprawka relatywistyczna", "Einstein byłby dumny.",
         "Relativity Fix", "Einstein would be proud."),
        ("Większy panel słoneczny", "Więcej mocy, więcej tików.",
         "Bigger Solar Panel", "More power, more ticks."),
        ("Konstelacja", "31 przyjaciół na orbicie.",
         "Constellation", "31 friends in orbit."),
        ("Poprawka jonosferyczna", "Przez chmury i burze.",
         "Ionosphere Correction", "Through clouds and storms."),
        ("Stacja naziemna", "Ktoś pilnuje z dołu.",
         "Ground Station", "Someone keeps watch from below."),
        ("Łącze laserowe", "Satelity szepczą do siebie światłem.",
         "Laser Link", "Satellites whispering in light."),
        ("Orbita geostacjonarna", "Zawsze w tym samym miejscu. Zawsze na czas.",
         "Geostationary Orbit", "Always in the same place. Always on time."),
    ],
    "pulsar": [
        ("Większy radioteleskop", "Słyszy każde stuknięcie.",
         "Bigger Dish", "Hears every pulse."),
        ("Pulsar milisekundowy", "700 obrotów na sekundę.",
         "Millisecond Pulsar", "700 spins a second."),
        ("Mapa nieba", "Wreszcie wiadomo, gdzie patrzeć.",
         "Sky Map", "Finally we know where to look."),
        ("Sieć pulsarów", "Kosmiczny chór metronomów.",
         "Pulsar Timing Array", "A cosmic metronome choir."),
        ("Fale grawitacyjne", "Czasoprzestrzeń drży w takt.",
         "Gravitational Waves", "Spacetime wobbles on the beat."),
        ("Magnetar", "Pulsar, ale z charakterem.",
         "Magnetar", "A pulsar with attitude."),
        ("Kosmiczna latarnia", "Prowadzi statki do domu. Na czas.",
         "Cosmic Lighthouse", "Guides ships home. On time."),
        ("Serce galaktyki", "Cała Droga Mleczna tyka razem z nim.",
         "Heart of the Galaxy", "The whole Milky Way ticks along."),
    ],
    "timeMachine": [
        ("Kondensator strumienia", "1,21 gigawata, ani wata mniej.",
         "Flux Capacitor", "1.21 gigawatts, not a watt less."),
        ("Pasy bezpieczeństwa", "Na wypadek paradoksu.",
         "Seat Belts", "In case of paradox."),
        ("Liścik z przyszłości", "„Kliknij teraz.”",
         "Note from the Future", "“Tap now.”"),
        ("Pętla czasowa", "Ćwiczy te same 10 sekund w kółko.",
         "Time Loop", "Practises the same ten seconds forever."),
        ("Zapasowa linia czasu", "Tak na wszelki wypadek.",
         "Spare Timeline", "Just in case."),
        ("Wycieczki do 10,00", "Z przewodnikiem.",
         "Tours to 10.00", "Guided, of course."),
        ("Spotkanie z samym sobą", "Uprzejme, ale dziwne.",
         "Meeting Yourself", "Polite, but weird."),
        ("Koniec czasu", "Bilet w jedną stronę.",
         "End of Time", "One-way ticket."),
    ],
    "schrodinger": [
        ("Większe pudełko", "Więcej miejsca na niepewność.",
         "Bigger Box", "More room for uncertainty."),
        ("Karma kwantowa", "Zjedzona i niezjedzona.",
         "Quantum Kibble", "Eaten and not eaten."),
        ("Splątany kłębek", "Splątanie na życzenie.",
         "Entangled Yarn", "Entanglement on demand."),
        ("Kocimiętka superpozycji", "Mruczy w dwóch stanach naraz.",
         "Superposition Catnip", "Purrs in two states at once."),
        ("Obserwator na urlopie", "Nikt nie patrzy, wszystko trafia.",
         "Observer on Holiday", "No one looks, everything hits."),
        ("Druga kotka", "Teraz stany są cztery.",
         "A Second Cat", "Now there are four states."),
        ("Wiele światów", "W którymś zawsze jest 10,00.",
         "Many Worlds", "In one of them it's always 10.00."),
        ("Otwarte pudełko", "Trafił. Zdecydowanie trafił.",
         "Box Opened", "It hit. Definitely hit."),
    ],
    "chronos": [
        ("Naostrzona kosa", "Tnie sekundy na setne.",
         "Sharpened Scythe", "Slices seconds into hundredths."),
        ("Klepsydra z Olimpu", "Piasek prosto od bogów.",
         "Olympian Hourglass", "Sand straight from the gods."),
        ("Świątynia", "Wierni przynoszą zegarki.",
         "Temple", "The faithful bring watches."),
        ("Rozmowa z Kairosem", "O właściwym momencie.",
         "A Word with Kairos", "About the right moment."),
        ("Tron z zębatek", "Wygodny, choć tyka.",
         "Throne of Gears", "Comfy, if a bit ticky."),
        ("Panteon punktualnych", "Bogowie, którzy zawsze zdążą.",
         "Pantheon of Punctuality", "Gods who are never late."),
        ("Wieczność", "Ma czas. Dosłownie.",
         "Eternity", "Has time. Literally."),
        ("Sekunda absolutna", "10,00. Od zawsze i na zawsze.",
         "The Absolute Second", "10.00. Always was, always will be."),
    ],
}


def key(gen, i):
    return f"upg_{gen}_{i + 1}"


def write_arb(path, lang):
    d = json.loads(path.read_text(), object_pairs_hook=OrderedDict)
    for k in [k for k in d if k.startswith("upg_")]:
        del d[k]
    for gen, items in UPGRADES.items():
        for i, (pl, pl_line, en, en_line) in enumerate(items):
            name, line = (pl, pl_line) if lang == "pl" else (en, en_line)
            d[key(gen, i)] = name
            d[key(gen, i) + "_desc"] = line
    path.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n")


def write_dart(path):
    lines = [
        "// GENERATED by tools/l10n/upgrades.py — do not edit by hand.",
        "import 'gen/app_localizations.dart';",
        "",
        "/// Name and one-liner of upgrade [index] (1-based) of [generator]",
        "/// (docs/02 R-ULEP-2); null for an unknown pair.",
        "(String, String)? upgradeTexts(",
        "  AppLocalizations l,",
        "  String generator,",
        "  int index,",
        ") => switch ((generator, index)) {",
    ]
    for gen, items in UPGRADES.items():
        for i in range(len(items)):
            k = key(gen, i)
            lines.append(f"  ('{gen}', {i + 1}) => (l.{k}, l.{k}_desc),")
    lines += ["  _ => null,", "};", ""]
    path.write_text("\n".join(lines))


if __name__ == "__main__":
    assert all(len(v) == 8 for v in UPGRADES.values()) and len(UPGRADES) == 14
    write_arb(APP / "lib/l10n/app_pl.arb", "pl")
    write_arb(APP / "lib/l10n/app_en.arb", "en")
    write_dart(APP / "lib/l10n/upgrade_texts.dart")
    print("112 upgrades written")
