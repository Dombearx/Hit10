# 11 — Po premierze: porównanie z gatunkiem i pomysły na później

Analiza z 6.11.2026 (playtest 27). **Nic z tego nie jest jeszcze
zaplanowane do zrobienia.** Najpierw zbieramy dane z pierwszego tygodnia
w Sklepie Play (§5), potem wybieramy, co wchodzi do 02 i 07.

## 1. Skąd ten dokument

Symulacja gracza idle (`app/tool/idle_sim.dart`, wyniki w 03 §4.2):
3 sesje dziennie po 3 min co 8 h, dochód offline pomiędzy, dzienna
premia, paradoks i perki.

| Dzień | Chronony | Perki | Bonusy zegarów | Osiągnięcia |
|---|---|---|---|---|
| 7 | 26 | 2/18 | 25/112 | 45/149 |
| 14 | 52 | 4/18 | 34/112 | 57/149 |
| 30 | 1129 | 17/18 | 67/112 | 79/149 |
| 42 | 10.7K | 18/18 | 112/112 | 109/149 |
| 120 | 43.5K | 18/18 | 112/112 | 115/149 |

Wnioski:

- Ok. **97% Tików przychodzi offline**. Klikanie w 9 min dziennie to
  dodatek.
- Wszystkie perki ok. 31. dnia, wszystkie bonusy zegarów ok. 42. dnia,
  **od ok. 75. dnia Chronony stoją** (paradoks już ich nie podwaja).
  Przy takim stylu gry treści starcza na ok. 1,5–2,5 miesiąca.
- Gracz idle dochodzi do dochodu, który aktywny bot ma po ~240 h gry, po
  ok. 40 dniach i ok. 6 h grania. W grze idle to normalne.
- Brakujące osiągnięcia wymagają grania, nie czekania (100 h gry, 100K
  rund, tryb na ślepo, sezony, konkretne godziny).

## 2. Porównanie z gatunkiem

Porównanie z Cookie Clickerem (nasz wzór), AdVenture Capitalist, Egg, Inc.
i Antimatter Dimensions. Opis innych gier jest z pamięci i z wiki/forów
(§7); źródła były słabej jakości, więc konkretne liczby są orientacyjne.

| Element | Hit5 | U innych | Ocena |
|---|---|---|---|
| Rdzeń | wyczucie czasu, PERFEKT, combo | klikanie na szybkość (Cookie Clicker) albo samo czekanie | **nasz wyróżnik** |
| Złoty bonus | Złota Sekunda (Szał, Fart, Gorąca ręka) | złote ciasteczka w Cookie Clickerze, prawie 1:1 | na poziomie |
| Bonusy za sztuki | 8 progów na zegar + synergie | progi w AdVenture Capitalist (25/50/100…) | na poziomie |
| Prestiż | jedna warstwa: Chronony (pierwiastek sześcienny) + 18 perków | anioły w AdVenture Capitalist, niebiańskie ulepszenia w Cookie Clickerze (bez końca), kilka warstw w Antimatter Dimensions | **za płytko na długi dystans** (§3.1) |
| Offline | 50% przez 8 h, perkami do 100% przez 24 h | Cookie Clicker kilka %, AdVenture Capitalist 100% bez limitu (menedżerowie), Egg, Inc. limit rośnie z rozbudową | hojnie, w normie |
| Powracające cele | dzienna premia (7 dni), 7 sezonów po kilka dni w roku | kontrakty co tydzień (Egg, Inc.), rotujące wydarzenia z osobną planetą (AdVenture Capitalist), wyzwania (Antimatter Dimensions, Clicker Heroes) | **brak celów tygodniowych** (§3.2) |
| Krótka sesja | odbiór offline, zakupy, trochę rund | doładowania, badania, drony (Egg, Inc.), decyzje co wizytę | **mało do roboty w 3 min** (§3.3) |
| Osiągnięcia | 149 | Cookie Clicker kilkaset | wystarczy |
| Kolekcje, minigry | brak | ogród, giełda, panteon (Cookie Clicker), artefakty (Egg, Inc.) | brak, ale drogie (§3.4) |
| Społeczność | brak (świadomie, bez backendu) | rankingi wydarzeń (AdVenture Capitalist), co-op (Egg, Inc.) | zostaje poza zakresem |
| Zapis | kopia Androida, eksport/import (05 T-32) | chmura | wystarczy |
| Monetyzacja | tylko reklamy z wyboru, bez presji przegapienia | dużo agresywniej | **nasz plus** |

## 3. Braki i pomysły

Każdy pomysł: co jest nie tak, skąd wzór, propozycja, koszt i jak
sprawdzić, czy jest potrzebny.

### 3.1 Gra kończy się za wcześnie (najważniejsze)

**Problem.** Po ok. 31 dniach nie ma już perków do kupienia, po ok. 75
Chronony stoją. Najwierniejsi gracze (ci, którzy zostają najdłużej i
oglądają najwięcej reklam) nie mają dalej celu.

**Wzory.**
- Cookie Clicker: niebiańskie ulepszenia o coraz wyższych cenach, a do
  tego kostki cukru rosnące w realnym czasie (1 dziennie) na poziomy
  budynków (+1% za poziom).
- Egg, Inc.: rzadkie jajka z trwałym bonusem i artefakty.
- Antimatter Dimensions: kolejne warstwy prestiżu z nowymi zasadami
  (Pecorella, GDC Europe 2016: „meta prestiż”).

**Propozycje (od najtańszej):**
1. **Ulepszenia bez końca za Okruchy**, np. „+5% do wszystkiego”, cena
   rośnie ×1.5 za poziom. Zawsze jest w co wydać Okruchy. Mało pracy
   (nowa pozycja w drzewku perków), ale łatwo rozjechać balans: trzeba
   przeliczyć w `idle_sim.dart` i `achievement_report.dart`.
2. **Poziomy zegarów za zasób dzienny** (wzór: kostki cukru). Np.
   „Sprężyna” rośnie 1 na dobę, poziom zegara kosztuje N Sprężyn i daje
   +1–2% temu zegarowi. Pasuje do sesji kilka razy dziennie, daje powód
   do codziennego powrotu, nie znika przy paradoksie.
3. **Druga warstwa prestiżu** (np. „Pętla czasu”: reset Chrononów
   i perków za nową walutę i nowe zasady). Największa zmiana, sensowna
   dopiero, gdy będą gracze dochodzący do końca.

**Jak sprawdzić.** Za tydzień nikt nie dojdzie do 75. dnia. Patrzymy, jak
szybko rośnie `prestige` (`run`) i `perk_buy` u najaktywniejszych graczy
w porównaniu z symulacją. Jeśli są szybsi niż `idle_sim.dart`, punkt 3.1
robi się pilny.

### 3.2 Brak powracających celów tygodniowych

**Problem.** Między sezonami (kilka dni w roku) gracz ma tylko dzienną
premię. Nie ma nic w stylu „w tym tygodniu…”, co przyciąga z powrotem.

**Wzory.** Kontrakty w Egg, Inc. (cel na czas, nowe co tydzień),
wydarzenia w AdVenture Capitalist, wyzwania z ograniczeniami
w Antimatter Dimensions i Clicker Heroes.

**Propozycja: wyzwanie tygodnia bez serwera**, na tym samym mechanizmie
co sezony (14): gra wybiera wyzwanie z listy według numeru tygodnia.
Przykłady:
- „PERFEKT na ślepo 20 razy”,
- „Seria 25 bez Tarczy”,
- „Run do 1B Tików bez Echa”,
- „Złap 3 Złote Sekundy”.

Nagroda: Okruchy albo kosmetyka (motyw, skórka tarczy), bez trwałej
straty za przegapienie (jak R-SEZ-3). Koszt średni: lista wyzwań, okno,
plakietka w nagłówku, zapis postępu. Część wyzwań przy okazji zachęca
do grania, a nie tylko czekania, czyli wzmacnia nasz rdzeń.

**Jak sprawdzić.** Retencja D7 i liczba sesji dziennie (Firebase liczy je
sam). Jeśli gracze wracają kilka razy dziennie, ale odpadają po
kilku dniach, ten punkt jest pierwszy.

### 3.3 Krótka sesja ma mało do roboty

**Problem.** Ok. 97% Tików przychodzi offline, a Złota Sekunda pojawia
się średnio co 10 min, więc w 3-minutowej sesji zwykle jej nie ma.
Wizyta to: odbierz Tiki, kup, wyjdź. Celowanie, nasz wyróżnik, prawie
się nie liczy.

**Wzory.** W Egg, Inc. i AdVenture Capitalist każda wizyta ma decyzje
(doładowania, badania, drony). Cookie Clicker nagradza obecność złotymi
ciasteczkami.

**Propozycje (tanie):**
- **Złota Sekunda zaraz po powrocie** po dłuższej nieobecności (np. ≥1 h):
  pierwsza przylatuje w ciągu 30 s.
- **Rozgrzewka:** pierwsze ~10 trafień po powrocie płaci np. ×(1 + minuty
  nieobecności / 60), z limitem. Daje powód, żeby przez chwilę celować.

Obie rzeczy zmieniają ekonomię mało, ale trzeba je dodać do symulatorów.

**Jak sprawdzić.** `offline_collect` (długość przerw), `golden_catch`
w porównaniu z liczbą sesji, długość sesji (Firebase). Jeśli sesje są
krótkie, a Złote Sekundy rzadko łapane, ten punkt jest potrzebny.

### 3.4 Mniejsze rzeczy (nie braki krytyczne)

- **Kolekcje i minigry** (ogród w Cookie Clickerze, artefakty w Egg,
  Inc.): dają głębię, ale są drogie. Wracamy do tego, jeśli 3.1 i 3.2
  okażą się za mało.
- **Rankingi i gra ze znajomymi:** świadomie poza zakresem (01), bez
  backendu tak zostanie. Gatunek dobrze bez tego żyje (Cookie Clicker).
- **Offline prawie 100% z pełnymi perkami:** hojnie, ale w normie
  (AdVenture Capitalist ma 100% bez limitu). Do decyzji, czy przyciąć
  Głęboki sen II do 75%, jeśli gracze będą szli za szybko.

## 4. Proponowana kolejność

1. **3.3 Bonus na start sesji:** mało pracy, wzmacnia wyróżnik gry.
2. **3.2 Wyzwanie tygodnia:** powód do powrotu w kolejnym tygodniu.
3. **3.1 Cel bez końca po prestiżu:** zanim pierwsi gracze dojdą do
   ok. 30. dnia (wszystkie perki).

Kolejność może się zmienić po danych z §5.

## 5. Co mierzymy w pierwszym tygodniu

Zdarzenia są już w grze (05 T-34), retencję i długość sesji Firebase
liczy sam.

| Pytanie | Skąd | Na co patrzymy |
|---|---|---|
| Czy gracze zostają? | retencja D1, D3, D7 (Firebase) | spadek po D1: samouczek (`tutorial_step`); spadek po D3–D7: brak celów (3.2) |
| Jak grają? | długość i liczba sesji dziennie (Firebase), `offline_collect` (`away_min`, `capped`) | krótkie sesje + częste `capped` = gracz idle (3.3, limit offline) |
| Czy tempo zgadza się z symulacją? | `generator_first`, `prestige` (`run`, `play_min`), `perk_buy` | porównać z `idle_sim.dart` i `simulate.dart`; szybciej niż symulacja = 3.1 pilniejsze |
| Czy Złota Sekunda działa w krótkich sesjach? | `golden_catch` na sesję | rzadko = 3.3 |
| Które osiągnięcia padają? | `unlock_achievement` | za łatwe / nigdy nie padające |
| Reklamy | `ad_offer`, `ad_reward`, AdMob | czy oferta ×2 offline jest brana; czy reklamy nie zastępują gry |

Pierwszy tydzień nie pokaże końca gry (ok. 30.–75. dzień), więc 3.1
oceniamy po tempie, a nie po tym, czy ktoś już do końca doszedł.

## 6. Kryteria decyzji po tygodniu

- Retencja D1 słaba → najpierw samouczek i pierwsze minuty, nie ten
  dokument.
- D1 dobra, D7 słaba → 3.2 (wyzwanie tygodnia), potem 3.3.
- Sesje krótkie, Złote Sekundy rzadko łapane → 3.3.
- Gracze szybsi niż symulacja (paradoksy i perki wcześniej) → 3.1
  przed 3.2.

## 7. Źródła

- [Quest for Progress – A. Pecorella, GDC Europe 2016](https://www.slideshare.net/slideshow/quest-for-progress-gdc-europe-2016/65405507)
- [Egg, Inc. wiki – Contracts](https://egg-inc.fandom.com/wiki/Contracts?oldid=9822)
- [Egg, Inc. wiki – Egg of Prophecy](https://egg-inc.fandom.com/wiki/Egg_of_Prophecy?oldid=7373)
- [AdVenture Capitalist – poradnik (anioły, wydarzenia)](https://gameplay.tips/guides/adventure-capitalist-basic-guide-angels-events-suits-badges.html)
- [AdVenture Capitalist – Wikipedia](https://en.wikipedia-on-ipfs.org/wiki/AdVenture_Capitalist)
- [Cookie Clicker wiki – Sugar Lumps](https://cookieclicker.wiki.gg/wiki/Sugar_Lumps)
- [GameAnalytics – motywacja graczy grających latami](https://www.gameanalytics.com/blog/exploring-motivation-people-play-games-years)
- [Gold & Goblins – 5 lat live ops i retencji](https://www.pocketgamer.biz/deconstructing-a-100m-idle-game-what-5-years-of-gold-and-goblins-reveals-about-live-ops-and-retention/)
