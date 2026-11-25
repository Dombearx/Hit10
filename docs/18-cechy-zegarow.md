# 18 — Cechy zegarów: co dają tytuły mistrzowskie

Stan: **propozycja** (25.11.2026). Symulacje: `app/tool/trait_report.dart`.
Dotyczy 02 R-SPR-6 (tytuły na stopniach 3 i 5).

## 1. Problem

Tytuł na 3. i 5. stopniu daje nazwę, żart i osiągnięcie +1%. Karta zegara
pokazuje przedtem „Stopień 3: ???”, co obiecuje nagrodę, a odsłania tylko
tekst. Sam stopień mnoży dochód swojego zegara ×1.5, ale w późnej grze to
mało: na 41. dzień Chronos daje 84% dochodu, Pulsar 0.5%
(`late_game_report.dart --part 2`). Mistrzostwo starego zegara jest więc
warte prawie zero.

**Propozycja.** Każdy tytuł odsłania **cechę zegara**: małą zasadę gry
związaną z tym, czym zegar jest. Tytuł I (stopień 3) to cecha, tytuł II
(stopień 5) to jej mocniejsza wersja (zastępuje I, nie dodaje się). Wzory:
ulepszenia budynków w Cookie Clickerze, menedżerowie w AdVenture
Capitalist (każdy zmienia coś innego).

## 2. Kim jest gracz, gdy zdobywa tytuły

Gracz z `late_game_report.dart`: 3 sesje po 11 min dziennie, σ = 40 ms,
reklama offline ×2.

- **Sprężyny:** ok. 2.4 na dobę. Stopień 3 jednego zegara (6 Sprężyn) to
  ok. 2.5 dnia, stopień 3 wszystkich (84) ok. 35. dzień, stopień 5
  wszystkich (210) ok. 85. dzień, czyli po fabule (7 pętli ok. 45 dni).
- **Pętle:** pierwsza 13 dni, druga 8, kolejne 3.3–4.3 dnia. To już blisko
  dolnej granicy R-PETLA-6 (nie mniej niż ok. 3 dni).
- **Sesja:** ok. 97% Tików przychodzi offline. Złotych Sekund jest ok. 1.1
  na sesję.
- **Trafienia:** przy pełnych umiejętnościach okna to 63/135/225 ms. Gracz
  z σ 40 ms trafia PERFEKT w 88% rund, a pudłuje w 0% (z σ 80 ms: 57%
  i 0.5%). Na początku przejścia pudło to 21%, ale umiejętności wracają
  w kilka minut.

Wniosek: **cechy oparte na pudłach, ZA WCZEŚNIE, oknie PERFEKT i combo
w późnej grze nie działają**, bo nikt już nie pudłuje, a mnożnik i tak
jest pełny.

## 3. Symulacje

`dart run tool/trait_report.dart [--only id,id] [--snap plik]`. Gracz
przechodzi pierwszą pętlę na dzisiejszych zasadach, potem pętle 2–7 (z ich
zasadami) raz dla każdej cechy, włączonej od początku pętli 2. Miara: dni
do celu pętli 2–7 razem (baza **32.6 dnia**, średnia z 3 ziaren; szum ok.
±1 dzień, czyli ±3%). Ujemny procent = pętle krótsze.

### 3.1 Pojedyncze cechy (ziarno 40 ms, baza 32.8)

| Cecha | Zmiana | Uwagi |
|---|---|---|
| offline +10% / +15% / +25% / +30% | 0 / −3% / −5% / −7% | |
| Bezsenność: offline 50% zamiast 25% | 0 (pętla 7: −8%) | działa tylko w tej jednej pętli |
| Głęboki sen I od startu pętli | 0 | perk i tak kupowany od razu |
| dzienna premia ×2 / ×5 | −2% / −1% | premia to minuty dochodu, prawie nic |
| 7. dzień premii: 3 Sprężyny zamiast 1 | 0 | +3 stopnie mistrzostwa na 40 dni |
| kuku: 1 lub 5 min dochodu za godzinę nieobecności | 0 | ginie przy dochodzie offline |
| Złota Sekunda zaraz po powrocie (+1 na sesję) | −5% | Złotych Sekund na sesję 1.1 → 2.0 |
| dwie Złote Sekundy po powrocie | −10% | 2.8 na sesję |
| combo: limit +3 / krok ×1.06 / Tarcza po 7 | 0 / 0 / 0 | mnożnik i tak pełny |
| zapas dokręcania: odnawianie ×1.5 / zapas i odnawianie ×2 | 0 / −3% | Sprężyn +0% / **+10%** |
| zegary −10% / perki −15% / −25% / −30% / umiejętności −50% | −1% / 0 / −2% / −3% / 0 | |
| okno PERFEKT +2 ms | 0 | gracz i tak trafia 88% PERFEKT |
| okno dokładnego 5.00 ×1.5 | −2% | Sprężyn tyle samo (ogranicza zapas) |
| pętla zaliczona: +1 / +2 Sprężyny | 0 | +2 / +3 stopnie |
| Złota Sekunda 20% częściej | −6% | 1.37 na sesję |
| efekty Złotej Sekundy +30% / Szał 50% dłużej | −2% / 0 | |
| podłoga combo 5 za darmo | 0 | |
| wszystkie zegary +10% / +25% (goły mnożnik, dla porównania) | −6% / −12% | |
| Sprężyna co 22 h / co 20 h | 0 / 0 | Sprężyn **+6% / +10%** |
| trafienie nakręca 45 min zamiast 30 | 0 | ogranicza zapas |
| impuls Pulsara w sesji (+10% lub 2 min dochodu co 5 min) | 0 | sesja to 3% dochodu |
| paradoks zostawia o 10 pkt więcej zegarów | 0 | |
| nowa pętla z 3% / 6% / 10% Chrononów poprzedniej | **−35% / −37% / −44%** | za mocne: 3% wystarcza na wszystkie perki od razu |
| nowa pętla z 10 / 25 / 50 / 200 Chrononami | 0 / −4% / −16% / −32% | |
| 10% pudeł jako DOBRZE / Fart +10 pkt | 0 / 0 | nie ma pudeł |
| Chronony +15% | −4% | |
| rzut monetą przy paradoksie: 50% na +20% / +40% Chrononów | −2% / −4% | |
| perk Chronos za 250 zamiast 500 | −5% | |
| bonus Chronosa: 2 Sprężyny zamiast 1 | −10% | Sprężyn **+45%** |

Co działa: **Złota Sekunda** (częściej, po powrocie), **offline** (dużo),
**Chronony na start pętli** (bardzo mocno) i **Sprężyny** (nie skracają
pętli, ale przyspieszają samo mistrzostwo). Reszta jest w szumie.

### 3.2 Wszystkie cechy naraz (budżet)

Cechy się mnożą, a pętle już są blisko 3 dni. Zestawy (średnia z 3 ziaren,
wszystko od pętli 2, więc to górna granica; w grze cechy dochodzą
stopniowo):

| Zestaw | Pętle 2–7 | Zmiana | Najkrótsza pętla |
|---|---|---|---|
| baza | 32.6 d | — | 3.0–4.0 d |
| pierwsza wersja, stopień 3 | 26.0 d | −20% | 2.3–3.0 d |
| pierwsza wersja, stopień 5 | 17.8 d | −45% | 1.3–2.0 d |
| **rekomendacja (§4), stopień 3** | **28.4 d** | **−13%** | 3.0–3.7 d |
| rekomendacja, stopień 5, Kukułka przy każdym powrocie | 20.3 d | −38% | 1.7–2.3 d |
| **rekomendacja, stopień 5 (§4)** | **21.9 d** | **−33%** | 2.0–2.3 d |

Stopień 3 wszystkich zegarów mieści się w R-PETLA-6. Stopień 5 wszystkich
skraca późne pętle do ok. 2 dni, ale gracz ma go dopiero ok. 85. dnia, czyli
po fabule, gdy sam wybiera zasady pętli (R-PETLA-8) i bije rekordy. Decyzja
w §5.

## 4. Cechy: 2–3 propozycje na zegar i rekomendacja

Opisy robocze; nazwy cech i żarty do napisania w `tools/l10n/masters.py`.
„Nie w symulacji” = wygoda, której bot nie pokaże (łapie każdą Złotą
Sekundę, gra codziennie, nie gra wyzwań).

| Zegar | Propozycje | Wynik | **Rekomendacja: I (stopień 3) / II (stopień 5)** |
|---|---|---|---|
| **Dziadek z zegarkiem** (śpi) | a) limit offline +4 h · b) offline +10…30% · c) Bezsenność łagodniejsza | a) nie w symulacji (liczy się dla gracza, który wpada raz dziennie) · b) 0…−7% · c) tylko jedna pętla | **I: limit offline +4 h. II: dochód offline +10%.** |
| **Babcia z minutnikiem** (pilnuje) | a) seria dziennej premii wybacza 1 opuszczony dzień w tygodniu · b) 7. dzień premii: 3 Sprężyny · c) premia ×2 | a) nie w symulacji · b) +3 stopnie na 40 dni · c) −2%, niewidoczne | **I: seria wybacza 1 dzień. II: 7. dzień daje 3 Sprężyny.** |
| **Kukułka** (wylatuje o pełnej) | a) o pełnej godzinie w czasie gry wylatuje Złota Sekunda · b) Złota Sekunda po powrocie · c) kuku za Tiki | a) ok. +10% Złotych Sekund · b) −5% raz na sesję; to samo daje pieczęć Promyk, więc raz dziennie · c) 0 | **I: kuku o pełnej godzinie. II: pierwsza sesja dnia: Złota Sekunda w 30 s.** |
| **Metronom** (rytm) | a) zapas dokręcania odnawia się 1.5× szybciej · b) zapas ×2 · c) combo (limit, krok, Tarcza) | a) 0 · b) +10% Sprężyn · c) 0 | **I: zapas odnawia się ×1.5. II: zapas ×2 i odnawia się ×2.** Combo odpada. |
| **Zegarmistrz** (rzemieślnik) | a) perki taniej · b) zegary −10% · c) umiejętności −50% | a) −2…−3% · b) −1% · c) 0 | **I: perki −10%. II: perki −20%.** |
| **Sędzia sprintu** (rekordy) | a) pętla szybsza od rekordu: Sprężyny · b) okno PERFEKT +2 ms · c) szersze okno 5.00 | a) +2…3 stopnie · b) 0 · c) −2% | **I: pętla poniżej rekordu: +1 Sprężyna. II: +2 i międzyczas w Kronice.** |
| **Zegar dworcowy** (rozkład jazdy) | a) Złota Sekunda częściej · b) zostaje dłużej na ekranie · c) efekty +30% | a) −6% za 20% · b) nie w symulacji (realny gracz łapie więcej) · c) −2% | **I: Złota Sekunda 10% częściej. II: do tego zostaje 2× dłużej (12 → 24 s).** |
| **Zegar kwarcowy** (na baterii, nie śpi) | a) Bezsenność: offline 35% / 50% zamiast 25% · b) wszystkie zegary +10% | a) −8% w tej pętli · b) −6%, ale to goły mnożnik | **I: Bezsenność 35%. II: Bezsenność 50%.** |
| **Zegar atomowy** (dokładna sekunda) | a) Sprężyna szybciej (22 h / 20 h) · b) trafienie nakręca dłużej | a) +6% / +10% Sprężyn · b) 0 (ogranicza zapas) | **I: Sprężyna co 22 h. II: co 20 h.** |
| **Satelita GPS** (wyznacza trasę) | a) raz dziennie zmień wyzwanie dzienne · b) wyzwanie tygodnia +1 Sprężyna | nie w symulacji / +1 stopień na 40 dni | **I: zmiana wyzwania dziennego. II: wyzwanie tygodnia +1 Sprężyna.** |
| **Pulsar** (impuls) | a) efekty Złotej Sekundy mocniejsze · b) Szał dłuższy · c) impuls w sesji | a) −2% za 30% · b) 0 · c) 0 | **I: efekty Złotej Sekundy +15%. II: do tego Szał 50% dłużej.** Impuls odpada. |
| **Maszyna czasu** (cofa) | a) nowa pętla z Chrononami: stała liczba · b) z % poprzedniej · c) paradoks zostawia więcej | a) 0 za 10, −4% za 25, −16% za 50 · b) −35% i więcej · c) 0 | **I: nowa pętla zaczyna z 10 Chrononami. II: z 25.** Procent odpada. |
| **Kot Schrödingera** (żyje i nie żyje) | a) rzut monetą przy paradoksie: 50% na więcej Chrononów · b) pudła jako DOBRZE · c) Fart | a) −2…−4% · b), c) 0 | **I: 50% na +10% Chrononów. II: 50% na +20%.** Ekran paradoksu pokazuje rzut. |
| **Chronos** (cel) | a) perk Chronos taniej · b) bonus Chronosa: 2 Sprężyny · c) Chronony +15% | a) −5% za połowę · b) −10%, Sprężyn +45% · c) −4% | **I: perk Chronos 400 zamiast 500. II: każdy bonus Chronosa 2 Sprężyny.** |

Z cech, które coś dają, rekomendacja bierze ok. połowę siły (§3.2:
pierwsza wersja dawała −20% / −45%). Odpadają wszystkie cechy od pudeł,
okien i combo, Tiki w sesji (kuku, impuls) i procent Chrononów.

Karta zegara przed zdobyciem: „Stopień 3: ??? · nowa zdolność”, po: nazwa
tytułu, żart i cecha. Osiągnięcie +1% zostaje.

## 5. Do decyzji

1. **Stopień 5 wszystkich zegarów skraca późne pętle do ok. 2 dni
   (−33%).** Albo przyjmujemy (to nagroda po ok. 85 dniach, po fabule; do
   R-PETLA-6 dopisek „bez pełnego mistrzostwa”), albo tytuły II tylko
   z wygodą i Sprężynami (bez Kukułki II, Chronosa II i Kota II), co
   według §3.1 daje ok. −20%. Rekomendacja: przyjąć.
2. **Kukułka II a pieczęć Promyk** (`noGold`): obie dają Złotą Sekundę po
   powrocie. Propozycja: Kukułka raz dziennie po dowolnej przerwie,
   Promyk co powrót po ≥1 h; razem przylatują dwie.
3. Cechy „nie w symulacji” (seria, zmiana wyzwania, limit offline, dłużej
   na ekranie) warto sprawdzić w analityce po wdrożeniu (`clock_level`).
