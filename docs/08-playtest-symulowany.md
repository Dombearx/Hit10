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
5. ~~Podpowiedź o średnim błędzie~~ — odrzucona: każdy wynik pokazuje
   dokładny błąd, a średnia jest w statystykach; kolejny dymek nie jest
   potrzebny.

## Test zamknięty (12 osób × 14 dni)

Wymaganie Google dotyczy prawdziwych kont Google, które dołączą do testu
i zostaną w nim 14 dni — boty ani fikcyjne konta tego nie spełnią
(i łamałyby zasady Play). Opcje: rodzina i znajomi, grupy wymiany testerów
(np. r/AndroidClosedTesting, społeczności „12 testers” na Discordzie/Reddicie
— testujesz ich aplikacje, oni twoją), albo konto organizacji (wymaga
numeru D-U-N-S; tego wymogu nie ma).

## Runda 2 — po poprawkach

Wprowadzone: szczęście początkującego (10 rund szerszych okien i ×3
wypłaty, potem 20 rund łagodnego wygaszania), runda bez dotknięcia nie
jest pudłem, stoper staje po 2 rundach bez dotknięcia, Turbo co 5 min.
Ceny i reszta balansu bez zmian; symulator przechodzi wszystkie progi.

| Persona | Pierwszy zakup (przed → po) | Zakupy w 10 min | Dochód po 10 min |
|---|---|---|---|
| Kasia | 2:54 → 0:44 / 1:49 | 15 → 28 / 31 | 2,9 → 18–23/s |
| Ola | 3:15 → 1:05 / 1:28 | 16 → 31 / 34 | 4,9 → 23–26/s |
| Pan Zdzisław | 6:20 → 0:54 / 1:48 | 2 → 12 / 9 | 0,2 → 0,9–1,2/s |
| Bartek | 9:45 → 2:12 / 1:05 | 1 → 22 / 19 | 0,1 → 6–12/s |
| Ania | 2:42 → 0:33 | 18 → 28 | 10,4 → 21,8/s |
| Tomek | 3:36 → 0:22 | 25 → 59 | 15,8 → 106/s |
| Ewa | 4:30 → 0:44 | 14 → 14 | 2,7 → 1,4/s |

(Dwie liczby po strzałce: dwa przebiegi po poprawkach — widać, ile waha
się wynik jednej sesji.)

- Pierwszy zakup: z 1,5–10 min do ~0,5–2 min. Najdłuższa przerwa bez
  zakupu: z 3–10 min do ~1–2 min.
- Odłożony telefon: 1 runda zamiast 13, combo zostaje.
- Wygaszanie premii: trafialność schodzi stopniowo (np. Ola 90% → 90% →
  60% → 43% w rundach 1–10, 11–20, 21–30, 31+) zamiast skoku po 10. rundzie.
- Zostaje: gracze bardzo nieprecyzyjni (σ ≈ 170 ms) pudłują w ~2/3 rund
  po okresie startowym. Postęp mają, ale wolny — to gra zręcznościowa.

## Porównanie z rekomendacjami dla gier mobilnych

| Rekomendacja | Stan |
|---|---|
| Pierwsze ~30 s decyduje („czy to ciekawe?”) | runda trwa 10 s, pierwsza nagroda po 10 s, pierwszy zakup ~0,5–2 min |
| Zawsze widoczny następny cel, ulepszenia zmieniające grę | zakup co ~1 min; Start później/tykanie od 2.–6. min |
| Samouczek grany, nie czytany; mechaniki stopniowo | jedno zdanie + strzałka; combo ~40 s, Złota Sekunda ~5 min |
| Sesja 5–9 min (GameAnalytics 2025) | 10-min sesja = 12–59 decyzji zakupowych |
| Powód do powrotu | dochód offline + powiadomienie o pełnym limicie |
| Reklamy dobrowolne, nie od razu | tylko nagradzane, od 5. min, Turbo co 5 min |
| Retencja D1 (branża: 77–90% nie wraca) | nie do zmierzenia botami — test z ludźmi |
| Nagroda dzienna | brak (opcja na później) |

Źródła: PocketGamer.biz „First impressions count…”, „PGC Digital: How to
enhance the first time user experience”; GameAnalytics Mobile Gaming
Benchmarks 2025; dev.to „I built 7 idle games in 30 days”; bugnet.io „How
to design an idle or incremental game”; Project Leap „The Definitive Guide
to Retaining Mobile Game Players”.

## Runda 3 — BLISKO zamiast szerszych okien, dzienna premia

Okna PERFEKT/ŚWIETNIE/DOBRZE wróciły do normy; pudło w ±150 ms to BLISKO
(0,3 Tika, zeruje combo); szczęście początkującego to już tylko ×3 wypłaty.

| Persona | Pierwszy zakup (start → szersze okna → BLISKO) | Zakupy w 10 min | Dochód po 10 min |
|---|---|---|---|
| Kasia | 2:54 → 0:44 → 2:09 | 15 → 28 → 24 | 2,9 → 18 → 15/s |
| Ola | 3:15 → 1:05 → 1:59 | 16 → 31 → 24 | 4,9 → 23 → 16/s |
| Pan Zdzisław | 6:20 → 0:54 → 1:49 | 2 → 12 → 10 | 0,2 → 1,2 → 1,0/s |
| Bartek | 9:45 → 2:12 → 3:48 | 1 → 22 → 9 | 0,1 → 12 → 1,9/s |
| Ania | 2:42 → 0:33 → 1:05 | 18 → 28 → 40 | 10 → 22 → 81/s |
| Marek | 1:37 → 1:05 → 1:05 | 18 → 13 → 15 | 6,4 → 1,2 → 24/s |
| Tomek | 3:36 → 0:22 → 1:05 | 25 → 59 → 54 | 16 → 106 → 61/s |
| Ewa | 4:30 → 0:44 → 1:05 | 14 → 14 → 24 | 2,7 → 1,4 → 16/s |

- Prawie każde „pudło” przeciętnego gracza to teraz BLISKO (Kasia: 21
  trafień, 20 BLISKO, 2 prawdziwe pudła na 43 dotknięcia) — gra nagradza
  bycie blisko, a PERFEKT dalej jest rzadki (1–4 na sesję poza Anią).
- Pierwszy zakup: ~1–2 min (Bartek 3:48, bo pomija co trzecią rundę).
  Wolniej niż z szerszymi oknami, wyraźnie szybciej niż na starcie.

## Runda 4 — pierwszy test na telefonie

Feedback: Przewijanie zabiera rytm („leci szybko i nagle zwalnia na
koniec”), przez co trudniej trafić. Zmiana: stoper zawsze płynie równo.

- **Start później** (zamiast Przewijania): stoper rusza od 1.54 … 5.80
  zamiast od 0.00, w normalnym tempie; do 10.00 zawsze zostają ≥ 4 s.
- **Zimna krew** (zamiast bullet time): zegar nie zwalnia, za to okna
  gracza są do ×2.5 szersze — ta sama pomoc w liczbach, bez zmiany tempa.
  Zostały winieta i bicie serca przy 10.00, zniknął dźwięk „pod wodą”.

Symulator przechodzi wszystkie progi (B-9: 4.46 h ≤ 4.5 h). Runda na max
Startu później trwa 4.9 s zamiast 3.5 s, więc późne poziomy dają trochę
mniej niż dawne Przewijanie; balans tego nie odczuł.

## Runda 5 — po zmianach z testu na telefonie (combo +1/+2/+3, 10.00 = jackpot)

Boty, pierwsze 10 minut (jeden przebieg na personę, wyniki się wahają):

| Persona | Pierwszy zakup | Zakupy | Dochód po 10 min | PERFEKT/ŚWIETNIE/DOBRZE/pudło |
|---|---|---|---|---|
| Marek | 0:33 | 39 | 22/s | 8/25/16/8 |
| Ola | 0:56 | 63 | 151/s | 4/11/8/26 |
| Kasia | 1:05 | 41 | 35/s | 2/11/12/24 |
| Ania | 1:06 | 36 | 59/s | 3/12/23/16 |
| Bartek | 2:13 | 22 | 15/s | 1/5/11/18 |
| Pan Zdzisław | 3:38 | 15 | 2,5/s | 3/3/6/28 |

Odstęp między zakupami najwyżej ~1 min u wszystkich. Gra po 8 min dziennie
(symulator wielodniowy): koniec po 72–74 dniach niezależnie od precyzji
(30–80 ms), bo przeważa dochód offline; w czasie gry trafienia dają
8–100% dochodu zegarów w pierwszych dniach i 15–180% później, z czego
jackpot 10.00 to zwykle największa część. Progi B-1…A-2 przechodzą
(B-7 na granicy: 0,41 przy progu 0,4).
