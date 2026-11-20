# 15 — Nowe combo: mnożnik osobno, seria tylko do wyzwań

Stan: **w grze (11.2026).** Zasady w 02 (R-COMBO-1…4, R-COMBO-2a,
R-WYZ-3, R-PETLA-8), liczby w `combo.ladder` w pliku balansu.

## 1. Problem

- Wyzwanie „seria N” zaliczało się serią sprzed wydania (seria przechodzi
  przez pauzy i dni) i serią ratowaną Tarczą, choć cel liczy się bez Tarcz.
- Gracz w środku i pod koniec gry praktycznie cały czas ma maksymalny
  mnożnik.

## 2. Zasady (propozycja)

- **Seria** — tylko do wyzwań. Widać ją wyłącznie przy wyzwaniu „seria”,
  liczona od 0 od wydania, jako **trafienia z rzędu** (nie kroki
  +3/+2/+1). Każde pudło ją zeruje, także uratowane Tarczą.
- **Mnożnik** — osobny licznik ×1.00…×limit (limit z umiejętności Combo):
  PERFEKT +1 krok, ŚWIETNIE i DOBRZE nic, **równe 5.00 = od razu
  maksimum**, pudło zeruje. **Tarcza chroni tylko przed pudłem.** Ładunek
  Tarczy wraca co 10 trafień (z Szybką Tarczą co 7) zamiast co 10 kroków.
- **„Kruche combo”** — nowa zasada pętli: mnożnik liczy się na **oknach
  bazowych** (umiejętności, Szczęście i Gorąca ręka poszerzają wypłatę, nie
  mnożnik), DOBRZE −1 krok.

Wzory z innych gier: Guitar Hero (mnożnik co 10 nut, pudło → ×1; „Safety
Net” w GH Live jak Tarcza), Crypt of the NecroDancer (mnożnik złota
zerowany zgubionym rytmem), back-to-back w Tetrisie (trudne czyszczenie
buduje, łatwe zrywa, brak czyszczenia nie rusza), style rank w Devil May
Cry (trafienie przez wroga obniża o stopień).

## 3. Symulacje

### 3.1 Dlaczego „PERFEKT podbija” nie wystarcza (`design/combo_sim.py`)

Okna rosną z umiejętnościami (Magnes, Sokole oko, Zimna krew ×2.5):
PERFEKT ±15 ms na starcie, ±30 ms w środku, ±63 ms pod koniec. Gracz
z σ 35 ms trafia wtedy 33% → 63% → 95% PERFEKTÓW, więc każda drabinka
liczona na widocznych oknach trzyma go na maksimum. Bez „5.00 = max”
drabinka bije głównie w słabych (σ 100–150 ms: −25…−40% mnożnika). Tarcza
chroniąca też przed DOBRZE wypada gorzej (zużywa się na drobiazgi: środek
gry, σ 50 — 37% rund na maksimum zamiast 59%).

Rundy na maksimum pod koniec gry, zwykła gra → na ślepo (rozrzut ×1.5 → ×2):

| reguła | σ 20 | σ 35 | σ 50 | σ 100 |
|---|---|---|---|---|
| dziś | 97 → 97 → 97% | 97 → 97 → 97% | 97 → 96 → 96% | 96 → 90 → 32% |
| drabinka | 95 → 94 → 93% | 93 → 91 → 90% | 92 → 89 → 87% | 87 → 15 → 0% |
| Kruche combo | 87 → 70 → 47% | 59 → 30 → 20% | 32 → 17 → 12% | 12 → 7 → 5% |

W środku gry na ślepo drabinka już gryzie (σ 50: 87% → 6% przy ×1.5).
Pod koniec gry wyzwaniem dla dobrego gracza jest Kruche combo.

### 3.2 Tempo gry na silniku gry (`app/tool/combo_report.dart`, `simulate.dart --check`, `idle_sim.dart`)

- **Cele tempa B-1…B-10, A-1, A-2:** wszystkie przechodzą, liczby prawie
  bez zmian (B-7 0.453 → 0.487, A-1 3.67 → 3.52 h).
- **8 h pierwszego przejścia** (3 ziarna, druga połowa): σ 20–50 ms ma
  maksimum w 100% rund przy obu zasadach; Tiki po 8 h −3…+7% (szum
  ścieżki zakupów). Na ślepo z rozrzutem ×2, σ 50: −14%.
- **Pierwszy dzień gracza idle** (3 × 10 min): bez „5.00 = max” gracz
  z σ 80 ms zarabiał **−57%**, z σ 50 **−28%**; z „5.00 = max” −3% i −5%.
  ŚWIETNIE +1 albo PERFEKT +2 nie pomagały (−45%). Od 5. dnia wszystko
  w ±10% (ok. 85–90% Tików przychodzi offline).
- **40 dni:** σ 35 ms — identycznie (137ac), σ 80 ms — w szumie.
- **Pętle** (`late_game_report.dart --part 5`): Kruche combo trwa 3.7 dnia,
  tyle co „Szwajcarska precyzja” — długość pętli zależy od dochodu
  offline, zasada zmienia przeżycie, nie tempo.

## 4. Wdrożenie

- Belka combo: ten sam mnożnik w tym samym miejscu, płomień względem
  limitu; „seria 12/40” tylko przy wyzwaniu „seria” (liczba trafień
  z rzędu od wydania, każde pudło zeruje, także obronione Tarczą).
- Wyzwania: postęp (`Challenge.run`) i planer na trafieniach z rzędu.
- Osiągnięcia: „Najwyższy mnożnik” ×1.50 / ×2.00 / ×2.75 (id `combo_10`,
  `combo_20`, `combo_35`), tryby: PERFEKT na ślepo przy ×1.50+ i przy
  pełnym mnożniku. Zapis v3 obcina dawny rekord serii do limitu.
- Ratunek combo: po utracie ×1.75+ (15 kroków), przywraca mnożnik.
- Twarde lądowanie: 5 kroków (×1.25). Szybka Tarcza: co 7 trafień.
- Kruche combo: zasada spoza historii (`story: false`), do wyboru po niej;
  pieczęć „Hartowane combo” — pudło zabiera połowę kroków. Bez tarczy
  zegara.
