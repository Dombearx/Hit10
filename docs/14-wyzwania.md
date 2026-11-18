# 14 — Wyzwania dzienne i tygodniowe (propozycja do wyboru)

Stan: **lista do wyboru, nic nie jest jeszcze zrobione.** Wybierz pozycje
(numery), a ja dopiszę zasady do 02, przeliczę nagrody w symulatorach
i zrobię implementację.

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

## 4. Moja rekomendacja na pierwszą wersję

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
