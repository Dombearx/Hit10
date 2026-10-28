# 08 — Playtest symulowany (2026-10-28)

Osiem person zagrało w prawdziwy build (wersja web z hakiem QA,
`tools/playtest/playtest.js`) po ok. 10 minut od zera: dotknięcia stopera
z ludzkim błędem (przesunięcie, rozrzut malejący z wprawą, rozproszenie),
własne decyzje w sklepie, reklamy, złoty zegarek, przerwy. Do tego dłuższe
horyzonty z symulatora balansu.

**To nie zastępuje ludzi.** Boty nie czują frajdy ani nudy, a ich rozrzut
to założenie (03: wprawny σ = 30 ms, przeciętny 60 ms). Mierzą za to tempo,
przestoje i miejsca, w których gra karze — i to dość wyraźnie.

## Wyniki (pierwsze 10 minut)

| Persona | Rozrzut | Pierwszy zakup | Pudła (w tym brak dotknięcia) | Zakupy | Dochód po 10 min |
|---|---|---|---|---|---|
| Marek, gracz | 29 ms | 1:37 | 14% (1) | 18 | 6,4/s |
| Ania, optymalizatorka | 42 ms | 2:42 | 34% (3) | 18 | 10,4/s |
| Kasia, casual | 80 ms | 2:54 | 56% (14) | 15 | 2,9/s |
| Ola, 15 lat, klika za wcześnie | 59 ms, −28 ms | 3:15 | 58% (18) | 16 | 4,9/s |
| Tomek, idle | — | 3:36 | 76% | 25 | 15,8/s (po 8 h przerwy) |
| Ewa, gra z przerwami | 64 ms | 4:30 | 77% (12) | 14 | 2,7/s |
| Pan Zdzisław, 67 lat | 163 ms | **6:20** | 87% (11) | 2 | 0,2/s |
| Bartek, sceptyk | 67 ms | **9:45** | 71% (17) | 1 | 0,1/s |

Dłuższy horyzont (symulator, 8 h, bez rozproszeń): nawet σ = 120 ms dochodzi
do zegara dworcowego po ~83 min i atomowego po ~6 h, więc nikt nie utyka na
stałe. Problem leży w pierwszych minutach.

## Co działa

- **Gracze wprawni mają dobry rytm:** zakup co ~30 s po rozruchu,
  umiejętności od 4.–7. minuty, pierwsze ulepszenia przed 10. minutą.
- **Powrót po przerwie robi „wow”:** Tomek po 8 h zastał 1469 Tików
  i od razu kupił 22 rzeczy.
- Złoty zegarek, reklamy i samouczek nie blokują nikogo technicznie;
  zero błędów JS w 80 minutach gry.

## Problemy (od najważniejszego)

1. **Start jest za twardy dla każdego poza wprawnymi.** Przeciętny gracz
   patrzy ~3 minuty na pusty sklep, senior ponad 6, a sceptyk prawie 10.
   Dziadek kosztuje 15 Tików, a DOBRZE (±50 ms) daje 1 Tik, ŚWIETNIE 3.
   W grach mobilnych pierwsza decyzja pada zwykle w ciągu kilkudziesięciu
   sekund; tu tracimy ludzi pokroju Bartka i pana Zdzisława, zanim
   zobaczą, o co chodzi.
2. **Patrzenie w sklep kosztuje rundę i combo.** Sklep jest na ekranie
   w trakcie rundy, więc casuale tracą 15–30% rund na „brak dotknięcia”
   (Kasia 14, Ola 18, Bartek 17 z ~55), a każde takie pudło zeruje combo.
   Kara za robienie tego, do czego gra zachęca.
3. **Telefon odłożony z włączoną grą kręci rundy w kółko.** Ewa po
   2,5 min przerwy ma 13–14 pudeł „brak dotknięcia” (statystyki psują się,
   bateria pracuje, combo przepada).
4. **Turbo da się „nabić” serią reklam.** Ola i Ewa oglądały Turbo co
   ~20 s (8 reklam w 3 min) aż do limitu 4 h. Zgodne z zasadą (zapas do
   4 h), ale męczy gracza i odbiega od założenia ~6 reklam/h (A-2).
5. **Ola klika za wcześnie** (średnio −28 ms) — typowe dla niecierpliwych.
   Gra nie podpowiada, czy ktoś klika systematycznie za wcześnie albo
   za późno, a statystyki to pokazują dopiero w panelu.

## Propozycje

1. **Szczęście początkującego:** przez pierwsze ~10 rund okna szersze
   (DOBRZE ±120 ms, ŚWIETNIE ±40 ms, PERFEKT ±10 ms), a Dziadek kosztuje
   10 zamiast 15. Cel: pierwszy zakup ≤ 60 s dla σ = 80 ms (sprawdzić
   symulatorem i ponownym playtestem).
2. **„Brak dotknięcia” nie jest pudłem:** runda bez dotknięcia nie zeruje
   combo i nie liczy się do statystyk trafień (pudło = tylko dotknięcie
   za wcześnie/za późno).
3. **Auto-start do pierwszej przerwy:** po 2 rundach bez dotknięcia stoper
   czeka na dotyk zamiast kręcić dalej.
4. **Turbo:** odnowienie 5 min między reklamami (zapas do 4 h zostaje).
5. **Podpowiedź po kilku rundach:** „Klikasz średnio 0,03 s za wcześnie”
   jako dymek (dane już są w statystykach).

## Test zamknięty (12 osób × 14 dni)

Wymaganie Google dotyczy prawdziwych kont Google, które dołączą do testu
i zostaną w nim 14 dni — boty ani fikcyjne konta tego nie spełnią
(i łamałyby zasady Play). Opcje: rodzina i znajomi, grupy wymiany testerów
(np. r/AndroidClosedTesting, społeczności „12 testers” na Discordzie/Reddicie
— testujesz ich aplikacje, oni twoją), albo konto organizacji (wymaga
numeru D-U-N-S; tego wymogu nie ma).
