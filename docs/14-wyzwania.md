# 14 — Wyzwania dzienne i tygodniowe

Stan: **zrobione** (11.2026), zasady w [02 §18](02-rozgrywka.md). Poniżej
pula pomysłów, z której wybraliśmy zestaw (§4), i wyniki symulacji
trudności (§5).

Skąd: przegląd dobrych praktyk (11.2026) i 11 §3.2. Między sezonami gra
ma tylko dzienną premię i dochód offline. Brakuje powodu, żeby w krótkiej
sesji **celować**, a nie tylko odebrać Tiki. Wzory: kontrakty w Egg, Inc.,
zadania dzienne w Idle Miner i Archero, wyzwania w Antimatter Dimensions.

## 1. Zasady wspólne (rekomendacja)

- **Bez serwera:** zestaw wynika z lokalnej daty (dzień, numer tygodnia),
  tak jak sezony (02 §14). Ten sam dzień = te same zadania po restarcie.
- **Tylko odblokowane rzeczy:** zadanie z trybem Na ślepo pojawia się po
  odblokowaniu trybu, ze Sprężynami po pierwszym paradoksie i tak dalej.
- **Cele dopasowane do gracza:** liczby rosną z jego typowym błędem
  i najlepszą serią (R-STAT-1), żeby gracz z σ = 80 ms i z σ = 25 ms
  dostawał zadanie na kilka minut, a nie niemożliwe albo darmowe.
- **Bez kary i bez presji:** przegapione zadanie po prostu znika, seria
  zadań nie istnieje. Nagrody nie są jedynym źródłem niczego (jak R-SEZ-3).
- **Jedno losowanie od nowa dziennie** (darmowe). Opcjonalnie drugie za
  reklamę — nowa, niewymuszona oferta.
- **Widoczność:** plakietka w nagłówku z postępem (jak sezon), lista
  w osobnym arkuszu, toast po ukończeniu, nic nie wyskakuje w trakcie
  rundy.

## 2. Pula pomysłów

Oznaczenia: **D** — dzienne (3–5 min gry), **T** — tygodniowe (kilka
sesji), ⭐ — rekomendowane na start.

### A. Precyzja (rdzeń gry)

| # | Typ | Zadanie | Uwagi |
|---|---|---|---|
| A1 ⭐ | D | **N× ŚWIETNIE lub lepiej** (N = 10–20 wg typowego błędu) | najprostsze, uczy celowania |
| A2 ⭐ | D | **Seria N** (N ≈ 60% najlepszej serii, min. 10) | adaptacyjne, nigdy nie „wygasa” |
| A3 ⭐ | D | **3× równe 5.00** w ciągu dnia | po pierwszym paradoksie nakręca też Sprężyny |
| A4 | D | **20 rund z rzędu bez pudła** (BLISKO to pudło) | trudniejsze dla nieprecyzyjnych |
| A5 | D | **3 PERFEKTY w 10 kolejnych rundach** | krótkie „okno skupienia” |
| A6 | D | **Średni błąd 20 trafień w ±20 ms** | uczy kalibrować się (pomaga T-13) |
| A7 | T | **25× równe 5.00** w tygodniu | rdzeń + Sprężyny |
| A8 ⭐ | T | **Typowy błąd ze 100 rund niższy niż w zeszłym tygodniu** („pokonaj siebie”) | rywalizacja bez rankingu; zapisuje się tylko jedna liczba na tydzień |
| A9 | T | **Seria 25 bez użycia Tarczy** | test opanowania; Tarcza dalej działa, tylko nie może się zużyć |

### B. Tryby i perki (po odblokowaniu)

| # | Typ | Zadanie | Uwagi |
|---|---|---|---|
| B1 ⭐ | D | **5× ŚWIETNIE+ na ślepo** | daje powód, żeby używać trybu |
| B2 | T | **50 PERFEKTÓW na ślepo** | dla zaawansowanych |
| B3 | D | **10 PERFEKTÓW na drugim zegarze** | po perku Drugi zegar |
| B4 | D | **3 PERFEKTY w czasie Szału** | łączy Złotą Sekundę z celowaniem |

### C. Złota Sekunda i wydarzenia

| # | Typ | Zadanie | Uwagi |
|---|---|---|---|
| C1 ⭐ | D | **Złap 2 Złote Sekundy** | wymaga ok. 10–30 min gry: lepiej jako tygodniowe „złap 10” |
| C2 | D | **Złota runda na ŚWIETNIE lub lepiej** | pełna siła efektu |
| C3 | D | **Złap Złotą Sekundę w 2 s od pojawienia się** | jak osiągnięcie „Refleks”, powtarzalne |

### D. Budowanie i ekonomia

| # | Typ | Zadanie | Uwagi |
|---|---|---|---|
| D1 | D | **Kup N zegarów** (N wg etapu) | łatwe; dobre jako trzecie zadanie |
| D2 ⭐ | D | **Zdobądź 2 bonusy zegarów** (progi R-ULEP-1) | prowadzi do „PRÓG” w sklepie |
| D3 | D | **Kup 3 poziomy umiejętności** | |
| D4 | D | **Zarób trafieniami tyle, ile zegary robią w 10 min** | mierzy, czy klikanie się opłaca (B-6) |
| D5 | T | **Cofnij czas z co najmniej 2× Chrononów** | po pierwszym paradoksie |
| D6 | T | **Nakręć trafieniami 3 h Sprężyny** | po pierwszym paradoksie; wykorzystuje zapas dokręcania |

### E. Ograniczenia (tygodniowe „mini-wyzwania”, droższe w robocie)

| # | Typ | Zadanie | Uwagi |
|---|---|---|---|
| E1 | T | **Przejście bez Echa:** dojdź do X Tików z Echem wyłączonym | wymaga przełącznika umiejętności — dużo pracy |
| E2 | T | **Tylko trzy rodzaje zegarów** do X Tików | jak wyzwania Antimatter Dimensions; dużo pracy |
| E3 | T | **Pętla w pigułce:** zasada pętli (02 §16) na tydzień | wykorzystuje gotowy kod zasad, ale miesza się z bieżącą pętlą |

## 3. Nagrody (rekomendacja)

- **Dzienne:** każde zadanie płaci **10 min dochodu pasywnego** (co
  najmniej 200 Tików, jak dzienna premia); wszystkie trzy w jednym dniu
  dają dodatkowo **+30 min**. To mniej niż dzienna premia z 7. dnia
  (60 min), więc nie przejmuje ekonomii.
- **Tygodniowe:** **1 Sprężyna** po pierwszym paradoksie (przed nim
  60 min dochodu). Dziś Sprężyn jest ok. 7 na tydzień plus trafienia,
  więc +1 to odczuwalny, ale nie dominujący bonus mistrzostwa.
- **Kolekcja (bez presji):** co 10 ukończonych tygodniowych — naklejka na
  tarczę albo nowa tarcza w galerii (12 §3.3). Przegapiony tydzień
  niczego nie zabiera, tylko odsuwa kolejną naklejkę.
- Każda nagroda przechodzi przez `idle_sim.dart` i `simulate.dart`
  (cele B-x, A-1/A-2) przed wejściem do 02.

## 4. Wybrany zestaw (zrobione)

Rekomendacja niżej została przyjęta z dwiema zmianami po rozmowie:

- **Bez „pokonaj siebie” (A8).** Porównanie z zeszłym tygodniem bywa
  niemożliwe: kto w zeszłym tygodniu zagrał jedną rundę w 5.00, nie może
  jej poprawić, a kto osiągnął swój szczyt, nie poprawi się co tydzień.
  Zamiast tego **„precyzyjny tydzień”** — N trafień ŚWIETNIE+ w tygodniu,
  z N liczonym z własnej celności (zawsze do zrobienia samym graniem).
- **Bez zadania „na ślepo” (B1).** Tryb i tak płaci ×3, więc zachęta już
  jest. W jego miejsce **N× PERFEKT**.
- **Każde zadanie to celowanie w 5.00.** Przez chwilę było „z obu stron”
  (trafienia tuż przed i tuż po 5.00), ale kazało klikać celowo za późno
  — odpadło.
- **Nie od razu, ale w pierwszej sesji:** 3 min gry po końcu samouczka
  (nigdy w trakcie samouczka ani jego powtórki), także w trakcie sesji. Przez
  chwilę wyzwania czekały na powrót do gry po 10 min — za późno dla
  graczy, których mają zatrzymać (§7). Pierwszy zestaw jest łatwiejszy.

Zestaw: celność (A1, A2, A3), wyczyn (A5, N× PERFEKT, D4), rozwój
(D1, D2, D3), tydzień (ŚWIETNIE+, równe 5.00, seria, Złote Sekundy,
Sprężyny). Nagrody jak w §3.

### 4.1 Każde zadanie musi być osiągalne (playtest 11.2026)

Zadanie tygodniowe „seria 110” stanęło na 23: silnik ucinał samą serię na
limicie combo, a planer liczył ją bez limitu. Przegląd wszystkich rodzajów:

- **Seria (A2, tydzień):** limit dotyczy tylko mnożnika (R-COMBO-2), seria
  liczy się dalej — także przy „Krótkim loncie”.
- **Tiki z trafień (D4):** cel nie liczy chwilowego Szału, Turbo ani
  trybu na ślepo, który gracz może wyłączyć (tylko wymuszony przez pętlę).
  Po paradoksie albo nowej pętli trafienia płacą o rzędy mniej, więc cel
  liczy się na nowo, z zachowaniem zrobionej części.
- **Złote Sekundy (tydzień):** gdy w trakcie tygodnia zaczyna się pętla
  z „Pochmurnym dniem”, zadanie wymienia się na inne.
- **Sprężyny (tydzień):** pełny zapas nie nakręca nic (R-SPR-4). Zadanie
  nie trafia się wtedy, a trwające wymienia się, jeśli zapasu nie ma na co
  wydać (żaden zegar nie wejdzie poziom wyżej).
- Reszta (ŚWIETNIE+, równe 5.00, PERFEKTY, okno PERFEKTÓW, zakupy zegarów,
  premie, poziomy umiejętności) liczy się z tych samych reguł co gra albo
  ma cel ograniczony tym, co gracz ma w zasięgu.

## 5. Trudność — symulacja (`tool/challenge_report.dart`)

Cele liczy się z własnych dotknięć gracza (02 R-WYZ-2). Narzędzie gra za
200 graczy na każdym poziomie celności: z ich 100 dotknięć planuje cel,
a potem gra nowymi dotknięciami tej samej celności, aż wyzwanie jest
zrobione. Minuty gry (mediana / 80% graczy), runda 5.7 s:

| Rodzaj | σ 20 ms | σ 50 ms | σ 100 ms | σ 150 ms |
|---|---|---|---|---|
| ŚWIETNIE+ ×N | cel 35 · 3.7 / 4.0 | 15 · 3.2 / 4.0 | 9 · 3.5 / 4.6 | 6 · 3.3 / 4.8 |
| seria N | 90 · 3.7 / 5.2 | 11 · 2.1 / 4.5 | 6 · 2.3 / 5.6 | 4 · 2.1 / 4.8 |
| równe 5.00 ×N | 15 · 3.2 / 4.1 | 6 · 3.4 / 4.7 | 3 · 3.0 / 5.0 | 2 · 2.8 / 5.0 |
| PERFEKTY w 10 rundach | 8 · 2.2 / 5.3 | 4 · 2.3 / 5.3 | 2 · 1.9 / 5.2 | 2 · 1.8 / 5.3 |
| PERFEKT ×N | 20 · 3.4 / 3.9 | 9 · 3.5 / 4.6 | 4 · 3.1 / 4.8 | 3 · 2.9 / 4.9 |
| zarób trafieniami | 3.9 / 4.5 | 3.6 / 4.7 | 3.4 / 5.1 | 3.5 / 5.1 |
| tydzień: ŚWIETNIE+ | 310 · 34 / 36 | 160 · 33 / 37 | 80 · 32 / 37 | 50 · 32 / 39 |
| tydzień: równe 5.00 | 130 · 33 / 36 | 50 · 31 / 37 | 25 · 31 / 41 | 15 · 27 / 40 |
| tydzień: seria | 250 · 13 / 26 | 20 · 9 / 25 | 9 · 11 / 29 | 7 · 9 / 24 |

(σ 50/100/150 ms z przesunięciem +10/+20/+30 ms, jak u prawdziwych
graczy.) Każde dzienne wyzwanie jest więc na kilka minut niezależnie od
celności, a liczby rosną z umiejętnością — trafiać trzeba zawsze. Seria
tygodniowa najbardziej zależy od szczęścia, dlatego jest liczona dla
połowy tygodniowego czasu gry (wcześniej 80% graczy potrzebowało do
56 min).

**Wpływ na tempo** (`idle_sim.dart --challenges`, górna granica: gracz
robi wszystkie wyzwania codziennie, 3 × 3 min dziennie, σ = 50 ms):
perki i wszystkie bonusy zegarów w tych samych dniach co bez wyzwań
(ok. 21. i 30.), Chronony w dniach 30–60 o 15–35% wyżej, Tiki zarobione
po 60 dniach +17%, 3 stopnie mistrzostwa więcej (tygodniowe Sprężyny).
Mieści się w zwykłym rozrzucie symulacji.

## 6. Rekomendacja, od której zaczęliśmy

**3 dzienne + 1 tygodniowe**, bez kategorii E:

1. stałe miejsce „precyzja”: losowo **A1, A2 albo A3**,
2. stałe miejsce „gra”: losowo **B1** (po odblokowaniu), **C2** albo **D2**,
3. trzecie z całej puli D (łatwe: **D1, D2, D3**),
4. tygodniowe: na zmianę **A8** („pokonaj siebie”), **A7**, **C1 jako
   „złap 10”** i **D6** (po paradoksie).

Dlaczego: dwa z trzech dziennych wymagają celowania (wzmacnia wyróżnik
gry, 11 §3.3), jedno zawsze da się zrobić w 3 minuty (gracz casual nie
odpada), a A8 daje rywalizację bez backendu. Koszt: średni — ok. 10
liczników, które gra już w większości prowadzi (statystyki, osiągnięcia),
arkusz z listą, plakietka i zapis postępu. Zdarzenia do Analytics:
`challenge_done` (`id`, `kind`) i `challenge_reroll`.

**Jak sprawdzić, czy działa:** retencja D7 i liczba sesji dziennie przed
i po (Firebase), udział graczy, którzy kończą choć jedno zadanie dziennie,
i czy typowy błąd graczy z zadaniami spada szybciej (`accuracy`).

## 7. Kiedy odblokować — jak robią to inne gry (11.2026)

Pytanie: czy wyzwania po 2–3 sesjach to nie za późno? Dane o sesjach:
gracz idle ma ok. 5 sesji dziennie po ok. 8 min, mediana gier mobilnych
5–6 min (GameAnalytics); mediana retencji D1 ok. 22%, ponad połowa graczy
nie wraca po pierwszej sesji. Codzienne zadania pracują głównie na powroty
w dniach 1–7, więc gracz, który zagrał raz czy dwa po kilka minut, musi je
zobaczyć jeszcze w dniu instalacji.

| Gra | Kiedy codzienne zadania |
|---|---|
| Subway Surfers | od początku (prosty dzienny cel: litery) |
| Candy Crush | od początku (dzienne koło nagród) |
| Clash Royale | wcześnie, na ekranie głównym: 3 zadania, premia dzienna i tygodniowa |
| Brawl Stars | od 300 pucharów; 2 małe zadania dziennie |
| Dragon Mania Legends | od poziomu 11 |
| Merge Mansion | od poziomu 15 |
| AFK Arena, Archero | po rozdziale 3 kampanii |
| Honkai Star Rail, Genshin | po kilku godzinach fabuły; 4 zadania i premia za wszystkie |

Wnioski: proste gry casual dają dzienne rzeczy od pierwszego dnia, gry
z wieloma systemami dopiero po zrozumieniu podstawowej pętli; prawie nikt
nie liczy sesji, tylko postęp. Poradniki branżowe: dzienne nagrody pod
koniec pierwszego doświadczenia z grą (FTUE), na koniec sesji coś
rozpoczętego, przy pierwszym wejściu nagroda od razu albo prawie od razu.
Hit5 ma jedną mechanikę, której uczy się w minutę, stąd 3 min gry
i łatwiejszy pierwszy zestaw. Sprawdzamy to zdarzeniem
`challenges_unlocked` (`play_min`) i retencją D1/D7 graczy, którzy
zobaczyli wyzwania pierwszego dnia.

Źródła: [Supercell — Brawl Stars](https://supercell.com/en/games/brawlstars/blog/game-updates/update-taras-bazaar),
[Mobile Matters — Clash Royale daily tasks](https://mobilematters.gg/clash-royale/supercell-introduces-daily-tasks-to-clash-royale),
[Merge Mansion support](https://support.metacoregames.com/hc/en/merge-mansion/articles/daily-challenges-daily-scoop-467),
[Dragon Mania Legends wiki](https://dragon-mania-legends.wiki/wiki/Daily_Task),
[BlueStacks — AFK Arena](https://www.bluestacks.com/blog/game-guides/afk-arena/afka-daily-todo-list-en.html),
[Archero patch notes](https://progameguides.com/archero/archero-patch-notes/),
[Destructoid — Honkai Star Rail](https://destructoid.com/how-to-unlock-daily-training-and-daily-missions-in-honkai-star-rail),
[Codashop — Genshin](https://news.codashop.com/sg/?p=15563),
[AppGamer — Subway Surfers](https://www.appgamer.com/subway-surfers/daily-challenge),
[King — Candy Crush](https://community.king.com/en/candy-crush-saga/kb/articles/394-what-are-boosters-learn-all-about-them-here),
[MAF — daily rewards po FTUE](https://maf.ad/en/blog/daily-login-rewards-engagement-retention/),
[Udonis — FTUE](https://www.blog.udonis.co/mobile-marketing/mobile-games/first-time-user-experience),
[Playio — pierwsza sesja](https://blog.playio.co/mobile-game-onboarding-retention),
[Apple — Onboarding for Games](https://developer.apple.com/app-store/onboarding-for-games/),
[WN Hub — GameAnalytics, gry idle](https://wnhub.io/news/marketing/item-3203),
[GameAnalytics 2025](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks),
[Game Growth Advisor — retencja](https://gamegrowthadvisor.com/blog/2026-03-17-mobile-game-retention-strategies-2026/).
