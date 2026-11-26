# 18 — Cechy zegarów: co dają tytuły mistrzowskie

Stan: **zrobione** (26.11.2026), zasady w 02 R-CECHA. Symulacje: `app/tool/trait_report.dart`.
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
| **pierwsza rekomendacja, stopień 3** | **28.4 d** | **−13%** | 3.0–3.7 d |
| pierwsza rekomendacja, stopień 5, Kukułka przy każdym powrocie | 20.3 d | −38% | 1.7–2.3 d |
| **pierwsza rekomendacja, stopień 5** | **21.9 d** | **−33%** | 2.0–2.3 d |

Stopień 3 wszystkich zegarów mieści się w R-PETLA-6. Stopień 5 wszystkich
skraca późne pętle do ok. 2 dni, ale gracz ma go dopiero ok. 85. dnia, czyli
po fabule, gdy sam wybiera zasady pętli (R-PETLA-8) i bije rekordy. Decyzja
w §5.

### 3.3 Wybrany zestaw w prawdziwej grze (`trait_report.dart --real`)

Nowa gra, 150 dni, 3 ziarna. Gracz z cechami sam wydaje Sprężyny: najpierw
stopień 3 wszystkich zegarów (kolejność w `levelOrder`), potem stopień 5.
Cecha działa od chwili, gdy zegar ma swój stopień; stopień 5 **dodaje się**
do stopnia 3. Gracz „dziś” wydaje Sprężyny po staremu (na największy
dochód). Średnie z 3 ziaren:

| | Dziś | Z cechami |
|---|---|---|
| koniec fabuły (7 pętli) | dzień 55.3 | dzień 53.0 (−4%) |
| pętle 2–7 do celu | 8.2 / 8.0 / 4.9 / 4.0 / 3.3 / 4.3 d | 7.2 / 7.4 / 4.8 / 4.0 / 3.0 / 3.2 d |
| pętla po fabule do celu (dni 60–110) | 2.7 d | **1.7 d (−36%)** |
| pętli do 110. dnia | 22 | 33 |
| stopień 3 wszystkich zegarów | dzień 76 | dzień 39 |
| stopień 5 wszystkich zegarów | dzień 78 | dzień 61 |
| Złotych Sekund na sesję | 1.26 | 1.76 |
| „Na start!” (Sędzia) | — | 4% wszystkich Tików |

Co z tego wynika:
- **Fabuła prawie się nie zmienia.** Cechy przychodzą stopniowo, a stopień
  3 wszystkich zegarów gracz ma ok. 39. dnia, pod koniec fabuły.
- **Pętle po fabule skracają się o ok. jedną trzecią.** Już dziś trwają
  2.7 dnia, czyli poniżej „ok. 3 dni” z R-PETLA-6 (mistrzostwo ×7.6).
- **Żaden zegar nie odpowiada za to sam.** Zestaw bez cech jednego zegara
  (110 dni, 1 ziarno) daje pętle po fabule 1.68–1.87 d. Najwięcej dają
  Kukułka (1.87), Pulsar (1.83), Maszyna czasu (1.82) i Kwarc (1.81).
- **Po stopniu 5 wszystkich zegarów Sprężyny nie mają zastosowania**, dziś
  ok. 78. dnia, z cechami ok. 61. To osobny temat na później.

## 4. Wybrane cechy

Ustalone 26.11.2026. Cecha stopnia 3 widoczna na karcie od początku;
co daje stopień 5, widać dopiero po zdobyciu stopnia 3 (wcześniej szary
„Stopień 5” z kłódką, bez znaków zapytania). Nazwa tytułu i żart pojawiają
się po kupnie. Stopień 5 **dodaje się** do stopnia 3. Osiągnięcie +1% za
tytuł zostaje.

| Zegar | Stopień 3 | Stopień 5 (dodatkowo) |
|---|---|---|
| Dziadek z zegarkiem | limit offline +4 h | dochód offline +10% |
| Babcia z minutnikiem | jeden opuszczony dzień nigdy nie przerywa serii (dziś raz w tygodniu, R-DZIEN-3; przy wdrożeniu okazało się, że „1 dzień” już jest, więc cecha znosi limit) | 7. dzień premii: 3 Sprężyny zamiast 1 |
| Kukułka | o pełnej godzinie w czasie gry wylatuje Złota Sekunda | także o wpół do |
| Metronom | zapas dokręcania odnawia się 1.5× szybciej | zapas dokręcania ×2 |
| Zegarmistrz | perki −10% | perki −20% razem |
| Sędzia sprintu | **Na start!**: po ≥1 h przerwy pierwsze 10 trafień płaci ×(1 + godziny nieobecności), najwyżej ×9 | Na start! obejmuje 25 trafień |
| Zegar dworcowy | Złota Sekunda 10% częściej | **Ekspres**: co 5. złapana Złota Sekunda ma podwójny efekt (licznik przy Złotej Sekundzie / na karcie) |
| Zegar kwarcowy | wszystkie zegary +10% | **Synchronizacja**: +1% do wszystkich zegarów za każdy zegar ze stopniem 5 (najwyżej +14%) |
| Zegar atomowy | Sprężyna co 22 h zamiast 24 | co 20 h |
| Satelita GPS | komplet trzech wyzwań dziennych jednego dnia: dodatkowo ½ Sprężyny | wyzwanie tygodnia: +1 Sprężyna |
| Pulsar | efekty Złotej Sekundy +15% | Szał trwa 50% dłużej |
| Maszyna czasu | nowa pętla zaczyna się z 10 Chrononami | z 25 |
| Kot Schrödingera | rzut monetą przy paradoksie: 50% na +10% Chrononów | 50% na +20% |
| Chronos | perk Chronos 400 Chrononów zamiast 500 | każdy bonus Chronosa daje 2 Sprężyny |

Odrzucone (§3.1 i rozmowa): cechy od pudeł, okien i combo (gracz nie
pudłuje), szersze okno 5.00 (podstawa gry), cechy jednej pętli (Kwarc
i Bezsenność), Złota Sekunda po powrocie (dubluje pieczęć Promyk), Kukułka
zawsze z Szałem (Szał nie zawsze jest najlepszy), Gorąca ręka dla Sędziego,
procent Chrononów do nowej pętli (za mocne), zmiana wyzwania dziennego
(już jest: R-WYZ-6).

## 5. Do decyzji

1. **Pętle po fabule: 2.7 → 1.7 dnia.** Fabuła bez zmian, a po niej
   gracz sam wybiera zasady (R-PETLA-8) i bije rekordy, więc szybsze pętle
   to widoczna nagroda za mistrzostwo. Rekomendacja: przyjąć i dopisać do
   R-PETLA-6, że granica ok. 3 dni dotyczy fabuły. Jeśli pętle po fabule
   mają zostać ≥2.3 dnia, trzeba osłabić ok. 4 zegary (Kukułka, Pulsar,
   Maszyna czasu, Kwarc), bo żaden nie robi tego sam.
2. Cechy, których bot nie pokazuje (limit offline, seria premii, wyzwania
   dzienne), sprawdzić w analityce po wdrożeniu (`clock_level`).
