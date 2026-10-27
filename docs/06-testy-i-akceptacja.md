# 06 — Testy i kryteria akceptacji

Funkcja jest „zrobiona”, gdy ma testy automatyczne z sekcji 1, spełnia swoje
kryteria z sekcji 3, a `make check` przechodzi.

## 1. Testy automatyczne

### 1.1 Jednostkowe (`lib/model`, `lib/engine`, bez Fluttera)

| Obszar | Co sprawdzamy | Wymagania |
|---|---|---|
| Ocena | granice okien (dokładnie na granicy, ±1 µs), kolejność progów, ZA WCZEŚNIE/ZA PÓŹNO, PERFEKT ≤ ŚWIETNIE przy max poziomach | R-RUNDA-3/5, R-PROG-1/2 |
| Mapowanie czasu | rzeczywisty ↔ gra przy każdej kombinacji Przewijania, bullet time i Szybkiego zegara; ciągłość na granicach stref; odwrotność | R-RUNDA-10…12, T-11 |
| Szczęście | podbicie tylko o jeden próg, nigdy z PUDŁA; rozkład przy stałym ziarnie losowania | 02 §4 |
| Combo | kroki, limit, reset, Tarcza (zużycie, ładowanie), Twarde lądowanie | R-COMBO-1…3 |
| Wypłata | wzór R-WYPLATA-1 na przykładach liczonych ręcznie (w tym Echo × combo × tryb) | R-WYPLATA-1 |
| Ceny | pojedyncze, ×10, ×100, MAX (k = największe, na które stać; k+1 już nie) | R-GEN-1/2 |
| Dochód | zysk okien dla σ = 0, małego i dużego σ; synergie; ulepszenia; G | 03 §2, R-GEN-6 |
| Złota Sekunda | interwał (z Złotym dotykiem i perkiem), siła wg progu, limit Fartu do 10% konta, nakładanie efektów | R-ZLOTA-1…4 |
| Offline | limit, wydajność, perki, ujemny czas → 0, bez Szału | R-OFF-1…3 |
| Prestiż | wzór Chrononów, przyrost, co się zeruje, a co zostaje, perki Pamięci mięśniowej | R-PRES-1…5 |
| Osiągnięcia | każde osiągnięcie ma test warunku (generowany z tabeli) | R-OSIAG-1/2 |
| Zapis | zapis → odczyt daje identyczny stan; migracja każdej wersji; uszkodzony plik → kopia; eksport/import | T-17…T-20 |
| Plik balansu | plik z repo przechodzi walidację; zepsute pliki są odrzucane z dobrym komunikatem | T-6 |
| Format liczb | progi przyrostków, `aa`/`ab`, separator PL/EN, notacja naukowa | U-16 |
| Architektura | `lib/model` i `lib/engine` nie importują Fluttera ani Flame | T-3 |

### 1.2 Balans (symulacja w CI)

- `dart run tool/simulate.dart --check` uruchamia scenariusze z 03 §3 (gracz
  σ = 30 ms, σ = 60 ms, pasywny po 10 min, drugi run z 20 Chrononami) ze
  stałym ziarnem losowania i kończy się błędem, gdy któryś cel B-1…B-10
  wypada poza przedział.
- Symulacja 8 h gry ma trwać poniżej 30 s.

### 1.3 Widżetowe (Flutter)

- Pierwsze uruchomienie: samouczek krok po kroku i jego pominięcie.
- Kupno generatora i umiejętności: saldo maleje, poziom rośnie, przycisk
  wyszarza się bez środków.
- Przełącznik ×1/×10/×100/MAX pokazuje poprawne ceny.
- Okno offline po powrocie (z podstawionym czasem).
- Prestiż: oba potwierdzenia, po resecie właściwy stan.
- Ustawienia: zmiana języka przełącza teksty bez restartu.

### 1.4 Tłumaczenia

- Test sprawdza, że `app_pl.arb` i `app_en.arb` mają **te same klucze**, że
  każdy `id` z pliku balansu (generator, umiejętność, ulepszenie, synergia,
  osiągnięcie, perk) ma nazwę i opis w obu językach i że placeholdery się
  zgadzają.

## 2. Testy ręczne na telefonie

| id | Test | Zaliczony, gdy |
|---|---|---|
| **M-1** | Precyzja: tryb diagnostyczny (T-12) na ≥2 telefonach (60 Hz i 120 Hz), 100 rund | rozrzut różnicy timeStamp→Stopwatch < 4 ms; histogram błędów gracza bez „schodków” co klatkę |
| **M-2** | Uczciwość przy obciążeniu: PERFEKT w Szale z pełnymi cząsteczkami | wyniki nie gorsze niż bez efektów (ten sam gracz, 50 rund) |
| **M-3** | Wydajność | brak klatek > 16 ms w profilerze przez 2 min gry z efektami (T-21) |
| **M-4** | Cykl życia: wyjście w połowie rundy, rozmowa, obrót telefonu, ubicie procesu | brak utraty postępu > 10 s, runda anulowana, offline naliczony |
| **M-5** | Zmiana daty w telefonie w przód i w tył | offline przycięty do limitu, przy cofnięciu 0, brak crasha |
| **M-6** | Dźwięk i wibracje | dźwięk trafienia bez odczuwalnego opóźnienia (U-14), wyłączniki działają |
| **M-7** | Ogranicz ruch | brak wstrząsów i błysków (U-6) |
| **M-8** | „Czy to wciąga?” — 3 osoby spoza projektu grają 15 min bez instrukcji | każda rozumie zasadę w < 1 min, ≥2 z 3 chcą grać dalej; notujemy, co było niejasne |
| **M-9** | Małe i duże ekrany (≈5" i tablet), tryb ciemny systemu | nic nie wychodzi poza ekran, cyfry czytelne |

## 3. Kryteria akceptacji etapów

Etapy są opisane w [07-plan.md](07-plan.md). Każdy etap jest zaliczony, gdy:
- wszystkie wymagania z jego listy mają testy z sekcji 1 i przechodzą;
- testy ręczne przypisane do etapu są zaliczone;
- `make check` jest zielony;
- działa wersja na telefon (debug APK), na której właściciel projektu może
  to zobaczyć.
