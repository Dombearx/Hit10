# 12 — Późna gra: cele na miesiące

Propozycja z 14.11.2026. Rozwija punkt 3.1 z [11-po-premierze.md](11-po-premierze.md)
(„gra kończy się za wcześnie”). **Jeszcze nie jest zaplanowana.** Po
akceptacji zasady trafiają do 02, liczby do pliku balansu, a zadania do 07.

## 1. Problem w liczbach

Z symulacji gracza idle (03 §4.2, 3 sesje po 3 min dziennie):

| Co się kończy | Kiedy |
|---|---|
| wszystkie 18 perków | ok. 31. dnia |
| wszystkie 112 bonusów zegarów | ok. 42. dnia |
| przyrost Chrononów (pierwiastek sześcienny, paradoks nie podwaja) | ok. 75. dnia |
| Okruchy | przychodzą dalej, ale od 31. dnia nie ma na co ich wydać |

Po ok. miesiącu gracz nie ma żadnej decyzji do podjęcia poza „kup więcej
tych samych zegarów”. Odchodzą wtedy najwierniejsi gracze, czyli ci,
którzy oglądają najwięcej reklam.

## 2. Jak to robią inne gry

| Gra | Mechanizm późnej gry | Czego się uczymy |
|---|---|---|
| Cookie Clicker | **kostki cukru**: ok. 1 na dobę, rosną w realnym czasie. Wydaje się je na **poziomy budynków** (+1% za poziom, poziom N kosztuje N kostek). Nie przepadają przy prestiżu | wolny zasób z realnego czasu pasuje do sesji „kilka razy dziennie”. Koszt rośnie liniowo, więc pierwsze poziomy przychodzą szybko, a ostatnie po latach |
| Egg, Inc. | **epickie badania** za złote jajka, które nie znikają przy prestiżu. Niektóre wzmacniają walutę prestiżu (Soul Food +1% do bonusu za jajko duszy) | postęp obok prestiżu, który nie przepada, sprawia, że reset nigdy nie zabiera wszystkiego. Wzmocnienie waluty prestiżu odpycha moment, w którym przyrost staje |
| Melvor Idle | **mistrzostwo**: każdy przedmiot ma własny poziom, a pula umiejętności daje bonusy przy 10/25/50/95% | „mistrzostwo” per rzecz daje zbieranie i ukończenie bez nowej waluty |
| Antimatter Dimensions, Clicker Heroes, Trimps | **wyzwania**: przejście z ograniczeniem (bez czegoś, z karą), nagroda na stałe, kilka poziomów trudności | wyzwania sprawiają, że kolejne przejścia się różnią, i wykorzystują mechaniki, które gracz już zna. Nie trzeba nowych treści |
| Clicker Heroes, Antimatter Dimensions | **druga warstwa prestiżu** (Transcendence, Eternity) resetuje pierwszą | najmocniejsze narzędzie, ale też najdroższe i najtrudniejsze do wytłumaczenia. Robi się je, gdy gracze faktycznie dochodzą do końca |
| AdVenture Capitalist | jeden główny cel („zbierz i ukończ wszystko”) rozbity na wiele małych | dalekie cele są pojedynczo rozsądne, a razem zajmują lata (GameAnalytics) |

Dobre praktyki, które z tego wynikają:

1. **Postęp obok prestiżu, który nie przepada.** Paradoks nie może być
   jedynym trwałym postępem, bo po zatrzymaniu się Chrononów nie ma już
   nic (Cookie Clicker, Egg, Inc.).
2. **Nowa warstwa wtedy, gdy stara się nasyca.** Gracz poznaje kolejny
   system, kiedy poprzedni się kończy, nie wcześniej (bugnet, Pecorella).
   Za dużo naraz na początku gry przytłacza.
3. **Przejścia muszą się różnić.** Gdy jedynym celem prestiżu jest
   „więcej tego samego”, gra robi się monotonna (r/incremental_games).
4. **Opieramy się na naszym wyróżniku.** Skoro ok. 97% Tików przychodzi
   offline, późna gra nie powinna być kolejnym licznikiem do czekania.
   Badanie z RPI o grach idle wskazuje kompetencję jako jedną z głównych
   potrzeb graczy, a trafianie w 5.00 to jedyne miejsce, gdzie u nas liczy
   się umiejętność.
5. **Bez kar za przegapienie.** Zgodnie z R-SEZ-3 i 01: zasób z realnego
   czasu się odkłada i nie przepada za dnia.
6. **Najpierw symulacja.** Każdy mnożnik bez końca łatwo rozjeżdża
   balans (03 E-3). Liczby poniżej to wartości startowe do sprawdzenia
   w `idle_sim.dart` i `achievement_report.dart`.

## 3. Propozycja: dwa systemy, wprowadzane po kolei

Celowo tylko dwa. Oba korzystają z tego, co już jest w grze (zegary,
paradoks, osiągnięcia, tryb na ślepo, Złota Sekunda), więc nie dochodzi
dużo nowych zasad do nauczenia.

### 3.1 Etap 1: Sprężyny i poziomy zegarów

Odpowiednik kostek cukru, ale ładowany także celnością.

**Sprężyna** / Mainspring to nowa waluta. Nie przepada przy paradoksie.

- **R-SPR-1:** Pojawia się po pierwszym paradoksie (ok. 2. dnia), żeby
  do 30. dnia, kiedy kończą się perki, gracz miał już kilka poziomów
  i wiedział, po co jest. Na pierwszym ekranie po paradoksie jest jedna
  wskazówka (R-TUT-2).
- **R-SPR-2:** Nakręca się sama: **1 Sprężyna na 24 h** realnego czasu,
  także offline. Pasek „nakręcania” jest w nagłówku obok Chrononów.
- **R-SPR-3:** **Celność przyspiesza nakręcanie.** Każde „równo 5.00”
  (okno jackpotu, |błąd| < 0.010 s, to samo co liczy osiągnięcia
  „Równo 5.00”) dokręca sprężynę o **15 min**. Limit: **6 h dziennie**
  z trafień (najwyżej ok. 1.25 Sprężyny na dobę). Przy σ = 50 ms około
  16% rund to „równo 5.00”, więc 3-minutowa sesja daje 1.5–2 h, a cały
  limit jest w zasięgu przy kilku sesjach. To też część punktu 3.3 z 11:
  daje powód, żeby w krótkiej sesji przez chwilę celować.
- **R-SPR-4:** Gotowe Sprężyny się odkładają, do **7 sztuk** (tydzień).
  Kto wraca raz w tygodniu, nic nie traci. Kto nie gra dłużej, traci
  tylko nadwyżkę, nigdy postęp. Limit można potem podnieść perkiem
  albo nagrodą z wyzwania (3.2).
- **R-SPR-5:** **Poziom zegara.** Na pełnej karcie zegara (R-ULEP-2a)
  jest przycisk „Podnieś poziom”. Poziom N kosztuje **N Sprężyn**
  i daje temu zegarowi **+10% dochodu** (mnożnik razem ×(1 + 0.1·poziom)).
  Maksymalnie **10 poziomów** na zegar. Poziomy nie przepadają przy
  paradoksie, a zegar trzeba mieć choć raz kupiony.
- **R-SPR-6:** **Mistrz zegara.** Poziom 5 i poziom 10 każdego zegara
  dają tytuł ze śmieszną nazwą i opisem (jak progi w R-ULEP-2), np.
  Dziadek 5: „Emerytowany zegarmistrz”, Dziadek 10: „Dziadek wie
  lepiej”. Każdy tytuł to nowe osiągnięcie (+1%, 28 sztuk). Dzięki temu
  podnoszenie tanich, starych zegarów ma sens, a nie tylko pompowanie
  ostatniego (inaczej jedyny sensowny wybór to Chronos).

**Tempo.** Pełne poziomy to 14 × 55 = 770 Sprężyn, czyli ok. 600–700
dni przy codziennym graniu. Pierwszy poziom każdego zegara kosztuje 1,
więc na początku coś się dzieje co dzień. Wszystkie tytuły „poziom 5”
(14 × 15 = 210 Sprężyn) to ok. pół roku. To cel na lata, ale każdy krok
jest blisko (dobra praktyka z AdVenture Capitalist).

**Dlaczego tak.**
- Daje powód do codziennego powrotu bez kary za opuszczony dzień.
- Wybór, który zegar podnieść, to nowa decyzja w każdej sesji (11 §3.3).
- Nagradza nasz rdzeń, czyli celność, a nie tylko czekanie.
- Nie dotyka paradoksu, perków ani wzoru na Chronony.

**Koszt.** Mały do średniego: waluta w zapisie, licznik czasu jak
offline (z ochroną R-OFF-3 przed cofnięciem zegara telefonu), przycisk
na karcie zegara, 28 osiągnięć z tekstami PL/EN, mnożnik w `dochód_i`.

**Ryzyko.** Do 2× na każdy zegar to razem z nowymi osiągnięciami ok. 2.2×
dochodu po pełnym rozwinięciu. To mało wobec Chrononów (43.5K Chrononów
to ×870), więc balans wczesnej gry się nie zmieni. Do sprawdzenia
w symulacji: czy +10% za poziom jest w ogóle odczuwalne w późnej grze.
Jeśli nie, zamiast tego mnożnik ×1.15 za poziom (×4 przy 10).

### 3.2 Etap 2: Wyzwania paradoksu

Odpowiednik wyzwań z Antimatter Dimensions i Clicker Heroes. Rozwiązuje
też zatrzymanie się Chrononów ok. 75. dnia.

- **R-WYZ-1:** Odblokowanie: osiągnięcie „Władca czasu” (wszystkie perki,
  ok. 31. dnia). Wcześniej gracz ma wystarczająco dużo do roboty, a to
  dokładnie moment, w którym perki się kończą.
- **R-WYZ-2:** Na ekranie paradoksu, obok „Zacznij nową grę”, jest „Zacznij
  wyzwanie”. Wyzwanie to zwykłe przejście z jednym ograniczeniem. Cel:
  zarobić w tym przejściu określoną liczbę Tików. W każdej chwili można
  je porzucić (zwykły paradoks bez nagrody za wyzwanie).
- **R-WYZ-3:** Każde wyzwanie ma **3 stopnie** (cel ×1000 za stopień,
  wartości startowe 1T / 1aa / 1ab, do strojenia). Za każdy stopień:
  Sprężyny (3 / 5 / 10) i jednorazowy wzrost wartości Chrononu
  o **+0.1 punktu procentowego** (+2% → +2.1% → …, przy 18 stopniach
  do +3.8%). To ponownie daje przyrost, gdy sam pierwiastek sześcienny
  już nic nie daje (wzór Soul Food z Egg, Inc.).
- **R-WYZ-4:** Za pierwszy stopień każdego wyzwania jest dodatkowo stały
  bonus związany z tematem.

Wyzwania na start (6). Każde korzysta z mechaniki, którą gracz już zna:

| id | Nazwa PL / EN | Ograniczenie | Stały bonus za 1. stopień |
|---|---|---|---|
| `blindfold` | Zepsuty stoper / Broken Stopwatch | Na ślepo jest zawsze włączone | Na ślepo płaci +1 (×4 → ×5 ze Śmiałkiem) |
| `noGold` | Pochmurny dzień / Cloudy Day | brak Złotej Sekundy | efekty Złotej Sekundy +10% |
| `amnesia` | Amnezja / Amnesia | Pamięć mięśniowa i Nawyk nie działają | Pamięć mięśniowa zachowuje +5% poziomów |
| `oldSchool` | Po staremu / Old School | tylko zegary 1–6 | zegary 1–6 ×3 |
| `shortFuse` | Krótki lont / Short Fuse | combo najwyżej 5, bez Tarczy | +1 ładunek Tarczy |
| `precision` | Szwajcarska precyzja / Swiss Precision | DOBRZE nic nie płaci (gracz i zegary) | okno PERFEKT +0.001 s |

**Dlaczego tak.**
- Kolejne przejścia się różnią (dobra praktyka 3), a nie dochodzą nowe
  treści do narysowania: 6 ikon i teksty.
- Część wyzwań (`blindfold`, `precision`, `shortFuse`) wymaga grania,
  a nie czekania, czyli znowu wzmacnia nasz rdzeń.
- Okruchy dalej się nie przydają. Jeśli to przeszkadza, najprostsze
  rozwiązanie to płacić Okruchami za start wyzwania (koszt do strojenia).
- Lista wyzwań może potem służyć jako **wyzwanie tygodnia** z 11 §3.2:
  gra wybiera jedno według numeru tygodnia i daje za nie dodatkowe
  Sprężyny. Bez serwera, ten sam mechanizm co sezony.

**Koszt.** Średni: flagi ograniczeń w stanie przejścia (wszystkie
mechaniki już są, wyzwanie tylko je wyłącza albo przycina), wybór na
ekranie paradoksu, plakietka z postępem w nagłówku, zapis, symulacja
każdego wyzwania w `simulate.dart` (cele stopni muszą być osiągalne, jak
R-OSIAG-2b).

### 3.3 Czego teraz nie robimy

- **Druga warstwa prestiżu** (np. „Pętla czasu”, reset Chrononów i perków).
  Najmocniejsze narzędzie, ale najdroższe, a wyzwania z R-WYZ-3 i tak
  odsuwają zatrzymanie Chrononów. Wracamy do tego, gdy gracze faktycznie
  przejdą wszystkie wyzwania.
- **Minigry i kolekcje** (ogród, artefakty): drogie, nie korzystają
  z celowania.
- **Ulepszenia bez końca za Okruchy** (11 §3.1 pkt 1): prostsze, ale to
  kolejny licznik do czekania i najłatwiej nim zepsuć balans. Sprężyny
  dają to samo („zawsze jest w co inwestować”) z górnym limitem.

## 4. Kolejność i warunki

1. **Etap 1 (Sprężyny):** zaraz po danych z pierwszego tygodnia (11 §5),
   najlepiej zanim pierwsi gracze dojdą do ok. 30. dnia. Mały koszt,
   a pomaga od razu, także w krótkich sesjach.
2. **Etap 2 (Wyzwania):** gdy pierwsi gracze mają wszystkie perki albo
   `perk_buy` pokazuje, że są szybsi niż `idle_sim.dart`.
3. Wyzwanie tygodnia na bazie listy wyzwań: jeśli D7 jest słabe
   (11 §6).

## 5. Jak sprawdzić, czy działa

| Pytanie | Zdarzenie (nowe w `T-34`) | Na co patrzymy |
|---|---|---|
| Czy gracze podnoszą poziomy? | `clock_level` (`clock`, `level`) | czy wybierają różne zegary, czy tylko ostatni |
| Czy celowanie dokręca sprężynę? | `spring_wind` (minuty z trafień dziennie) | ilu graczy dochodzi do limitu 6 h; jeśli nikt, 15 min jest za mało |
| Czy Sprężyny przepadają? | `spring_overflow` | jeśli często, limit 7 jest za niski |
| Czy wyzwania są grane? | `challenge_start`, `challenge_done` (`id`, `tier`) | które wyzwania porzucane; czy któreś nigdy nie pada |
| Czy gracze zostają dłużej? | retencja D30, D60 (Firebase) | porównanie przed i po etapie 1 |

## 6. Źródła

- [Cookie Clicker – kostki cukru (Pocket Gamer)](https://www.pocketgamer.com/cookie-clicker/sugar-lumps)
- [Cookie Clicker Wiki – Sugar Lumps](https://cookieclicker.wiki.gg/wiki/Sugar_Lumps)
- [Cookie Clicker – kiedy zbierać i co podnosić najpierw](https://cookie-clicker2.org/guides/cookie-clicker-sugar-lumps-guide-when-to-harvest)
- [Egg, Inc. – poradnik (epickie badania, co zostaje po prestiżu)](https://www.levelwinner.com/egg-inc-tips-cheats-guide-build-biggest-egg-farm/)
- [Egg, Inc. – Wikipedia](https://en.wikipedia.org/wiki/Egg,_Inc.)
- [Melvor Idle Wiki – Mastery pool](https://wiki.melvoridle.com/w/Mastery_pool)
- [Clicker Heroes – Transcendence i Outsiders](https://blog.clickerheroes.com/best-time-to-transcend-when-to-hit-zone-300-and-beyond/)
- [Clicker Heroes – Ancient Souls](https://blog.clickerheroes.com/ancient-souls-per-transcension-how-to-maximize-your-gain/)
- [A. Pecorella – The Math of Idle Games, Part III](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii)
- [A. Pecorella – Quest for Progress, GDC Europe 2016](https://www.slideshare.net/slideshow/quest-for-progress-gdc-europe-2016/65405507)
- [bugnet – How to design an idle or incremental game](https://bugnet.io/blog/how-to-design-an-idle-or-incremental-game)
- [r/incremental_games – dyskusja o różnorodności przejść](https://red.chatoyer.de/r/incremental_games/comments/vfmhs5/design_choices_questions_and_discussion/idhsvcw/?context=3)
- [GameAnalytics – motywacja graczy grających latami](https://www.gameanalytics.com/blog/exploring-motivation-people-play-games-years)
- [RPI – Idle yet engaged: idle games, competence and autonomy](https://dspace.rpi.edu/items/64643720-6def-468e-a497-754e607c4941)

Źródła o innych grach to głównie wiki i poradniki fanów, więc konkretne
liczby z innych gier są orientacyjne.
