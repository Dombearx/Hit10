# 02 — Rozgrywka

Wymagania mają identyfikatory (np. `R-RUNDA-3`). Testy i kryteria akceptacji
w [06-testy-i-akceptacja.md](06-testy-i-akceptacja.md) odwołują się do nich.
Liczby w tabelach to wartości startowe. Ich źródłem prawdy jest plik balansu
(patrz [03-ekonomia.md](03-ekonomia.md) i [05-technika.md](05-technika.md)).

Pojęcia:
- **czas gry** to wartość na stoperze;
- **czas rzeczywisty** to czas na zegarku gracza.

Stoper zawsze płynie w tempie prawdziwego zegara: sekunda na stoperze to
sekunda. Start później zmienia tylko to, od czego zaczyna.

---

## 1. Runda

- **R-RUNDA-1:** Stoper liczy czas gry w górę od `0.00`. Cel to `10.000`.
- **R-RUNDA-2:** Gracz dotyka **dowolnego miejsca obszaru zegara**. Liczy się
  moment **dotknięcia** (pointer down), nie puszczenia palca.
- **R-RUNDA-3:** Błąd `e = czas_gry_w_chwili_dotknięcia − 10.000`. Ocena
  zależy od `|e|` i aktualnych okien (sekcja 2).
- **R-RUNDA-4:** Dotknięcia w pierwszych `0.25 s` czasu rzeczywistego rundy
  i w trakcie pauzy na wynik są ignorowane. Chroni to przed podwójnym tapnięciem.
- **R-RUNDA-5:** Dotknięcie przed oknem DOBRZE to wynik **ZA WCZEŚNIE**
  (pudło). Jeśli gracz nie dotknie do `10.30`, runda kończy się wynikiem
  **ZA PÓŹNO** (pudło).
- **R-RUNDA-6:** Po wyniku trwa pauza `0.7 s` (efekty, liczby), po której
  **następna runda startuje automatycznie** — chyba że 2 ostatnie rundy
  minęły bez dotknięcia (telefon odłożony): wtedy stoper czeka na dotyk
  (08, playtest).
- **R-RUNDA-6a:** Runda **bez dotknięcia** to runda pominięta, a nie pudło:
  nie zeruje serii, nie zużywa Tarczy, nic nie płaci i nie liczy się do
  statystyk trafień (08: zaglądanie do sklepu nie może karać).
- **R-RUNDA-7:** Przy pierwszym uruchomieniu i po powrocie do aplikacji zegar
  stoi na `0.00` z napisem „Dotknij, aby zacząć”. Pierwsze dotknięcie startuje
  rundę i nie jest oceniane.
- **R-RUNDA-8:** Wyjście z aplikacji, rozmowa przychodząca albo otwarcie
  panelu przykrywającego zegar **anuluje** bieżącą rundę bez kary (combo
  zostaje). Sklep jest panelem, który zegara nie zasłania, więc można grać
  z otwartym sklepem.
- **R-RUNDA-9:** Wynik pokazuje dokładny czas trafienia z dwoma miejscami po
  przecinku i błąd z trzema, np. `10.02` i `+0.017 s`. Przy wyniku PERFEKT
  cyfry „przyciągają się” do `10.00` (efekt Magnesu), a błąd jest pokazany
  małym drukiem.

### 1.1 Start później i Zimna krew (tempo się nie zmienia)

Playtest na telefonie: zmiana tempa w trakcie rundy (dawne Przewijanie
i bullet time) zabierała rytm — gracz liczy w głowie, a przyspieszony
start i nagłe hamowanie przy 9.0 psuły to liczenie. Dlatego stoper
**zawsze płynie równo**, a obie umiejętności dają tę samą pomoc inaczej.

- **R-RUNDA-10:** Start później: stoper rusza od `S(L) = 5.8 ·
  (1 − 0.75^L) / (1 − 0.75^10)` (L = poziom 0–10: 0, 1.54, 2.69, 3.55 …
  5.8), w normalnym tempie. Cel zostaje `10.00`, a do celu zawsze zostają
  co najmniej 4 s (`round.latestStart` ≤ cel − strefa − 4), żeby złapać
  rytm.
- **R-RUNDA-11:** Zimna krew: okna gracza (PERFEKT, ŚWIETNIE, DOBRZE,
  BLISKO) są `1 / (1 − 0.06·L)` razy szersze (×2.5 na max). Matematycznie
  to ta sama pomoc co dawne zwolnienie zegara, ale bez zmiany tempa.
  Generatory jej nie dostają.
- **R-RUNDA-12:** Ocena trafienia jest w czasie gry, który przy stałym tempie
  równa się czasowi rzeczywistemu.
- **R-RUNDA-13:** Z Zimną krwią strefa `9.8–10.2` ma tylko wskazówki:
  winietę, pulsujące cyfry i bicie serca. Tempo i dźwięk się nie zmieniają.
- Długość rundy w czasie rzeczywistym: od ok. **10.7 s** (bez ulepszeń) do
  ok. **4.9 s** (max Start później).

## 2. Progi trafienia

| Próg | Okno bazowe `|e|` | Nagroda bazowa (Tiki) | Udział Echa | Krok combo |
|---|---|---|---|---|
| **PERFEKT** | < 0.005 s (na ekranie „10.00”) | 10 | 100% | +2 |
| **ŚWIETNIE** | < 0.020 s | 3 | 33% | +1 |
| **DOBRZE** | < 0.050 s | 1 | 10% | 0 (combo się utrzymuje) |
| **BLISKO** | < 0.150 s (tylko dotknięcia gracza) | 0.3 | 0 | reset do 0 |
| **PUDŁO** | reszta, ZA WCZEŚNIE, ZA PÓŹNO | 0 | 0 | reset do 0 |

- **R-PROG-0:** BLISKO (08, playtest) to pudło z pocieszeniem: płaci mało
  (1/33 PERFEKTU), ale zeruje combo jak pudło. Okna PERFEKT/ŚWIETNIE/DOBRZE
  się nie zmieniają — trafienie 10.00 ma zostać wyczynem. Generatory nie
  mają BLISKO.

- **R-PROG-1:** Okna sprawdzane są od najwęższego. Wygrywa pierwszy pasujący
  próg.
- **R-PROG-2:** Okno PERFEKT nigdy nie może być szersze niż okno ŚWIETNIE.
  Gra pilnuje tego niezależnie od ulepszeń.
- Uzasadnienie liczb: typowy gracz po rozgrzewce ma rozrzut ok. 30 ms, co daje
  ok. 13% PERFEKT, 50% w ŚWIETNIE i 90% w DOBRZE. Szczegóły w 03.

## 3. Wypłata za trafienie i combo

- **R-WYPLATA-1:** wypłata = `(nagroda_progu · (1 + 1.5·L_siła) · G + 0.5 s · L_echo · udział_echa · P) · combo · mnożnik_trybu`
  - `G` to globalny mnożnik (osiągnięcia, Chronony, Szał), patrz 03;
  - `P` to aktualny dochód pasywny na sekundę (już z `G`).
- **R-COMBO-1:** `seria` rośnie o krok combo progu (tabela wyżej). Pudło
  (dotknięcie za wcześnie lub za późno, R-RUNDA-6a) zeruje serię, chyba że gracz ma ładunek Tarczy (zużywa go wtedy, a seria zostaje).
- **R-COMBO-2:** `combo = 1 + 0.05 · min(seria, limit)`, a
  `limit = 5 + 2·L_combo`, czyli od 5 do 25 (×1.25 do ×2.25).
- **R-COMBO-3:** Combo mnoży **całą** wypłatę, razem z Echem. Bez tego
  w późnej grze combo przestaje się liczyć (wyszło w symulacji).
- **R-COMBO-4:** Licznik combo jest stale widoczny i rośnie wizualnie (kolor,
  płomień, rozmiar). Utrata combo ma swój efekt („rozbicie”).

## 4. Umiejętności gracza (sklep „Umiejętności”)

Każda umiejętność ma poziomy. Cena poziomu to `koszt_bazowy · wzrost^L`, gdzie
`L` to poziom obecny.

| id | Nazwa PL / EN | Max | Koszt bazowy | Wzrost | Efekt na poziomie L |
|---|---|---|---|---|---|
| `power` | Siła trafienia / Strike Power | 10 | 50 | ×7 | nagroda progu ×(1+1.5L) |
| `fastForward` | Start później / Late Start | 10 | 150 | ×5 | stoper rusza od S(L), max 5.8 |
| `ticking` | Tykanie / Ticking | 1 | 200 | – | dźwięk i wibracja co 0.1 s w ostatniej sekundzie |
| `wideEye` | Sokole oko / Hawk Eye | 10 | 300 | ×5 | okna ŚWIETNIE i DOBRZE ×(1+0.08L), max ×1.8 |
| `combo` | Combo / Combo | 10 | 500 | ×8 | limit combo +2 na poziom (5 → 25) |
| `magnet` | Magnes / Magnet | 10 | 2 000 | ×7 | okno PERFEKT +0.001 s na poziom, max ±0.015 |
| `echo` | Echo / Echo | 10 | 5 000 | ×9 | trafienie płaci dodatkowo 0.5·L s dochodu pasywnego × udział echa (max 5 s) |
| `bulletTime` | Zimna krew / Cold Blood | 10 | 5 000 | ×7 | okna gracza ×1/(1−0.06L), max ×2.5 |
| `luck` | Szczęście / Luck | 10 | 10 000 | ×8 | szansa 2%·L, że ŚWIETNIE→PERFEKT, a DOBRZE→ŚWIETNIE |
| `shield` | Tarcza / Shield | 3 | 2 000 | ×50 | L ładunków; pudło zużywa ładunek zamiast zerować combo; +1 ładunek co 10 kroków serii |
| `goldenTouch` | Złoty dotyk / Golden Touch | 5 | 1 000 000 | ×50 | odstęp między Złotymi Sekundami ×(1−0.05L), czyli pojawia się częściej; jej efekt jest ×(1+0.05L) silniejszy |

- **R-UMIEJ-1:** Sokole oko i Magnes działają **także na generatory** (sekcja 5).
  Dzięki temu są przydatne przez całą grę.
- **R-UMIEJ-2:** Karta umiejętności pokazuje poziom, efekt teraz → po zakupie
  (np. „Okno PERFEKT: ±0.007 → ±0.008 s”) i cenę. Gdy zakup jest możliwy,
  karta delikatnie pulsuje.
- **R-UMIEJ-3:** Umiejętności odblokowują się stopniowo: karta pojawia się,
  gdy gracz ma choć raz ≥50% jej ceny. Wcześniej jest widoczna jako „???”,
  żeby było do czego dążyć.

## 5. Generatory (sklep „Zegary”)

Każdy generator „gra w tę samą grę” co gracz: próbuje trafić 10.00 co 10 s
z własnym rozrzutem σ. Dochód liczony jest z wartości oczekiwanej (03), a na
ekranie losowo wyskakują jego „trafienia” (sekcja 04).

| # | id | Nazwa PL / EN | σ (rozrzut) | Koszt bazowy | Tiki/s bazowo | Opis (ton) |
|---|---|---|---|---|---|---|
| 1 | `grandpa` | Dziadek z zegarkiem / Grandpa with a Pocket Watch | 0.80 s | 15 | 0.1 | „Za moich czasów sekunda była dłuższa.” |
| 2 | `grandma` | Babcia z minutnikiem / Grandma with an Egg Timer | 0.50 s | 100 | 1 | Jajka na miękko od 1974 |
| 3 | `cuckoo` | Kukułka / Cuckoo | 0.30 s | 1.1K | 8 | Kuka co 10 sekund. Zwykle. |
| 4 | `metronome` | Metronom / Metronome | 0.15 s | 12K | 47 | Tik. Tak. Tik. Tak. |
| 5 | `watchmaker` | Zegarmistrz / Watchmaker | 0.08 s | 130K | 260 | Lupa w oku, spokój w duszy |
| 6 | `sprintJudge` | Sędzia sprintu / Sprint Judge | 0.04 s | 1.4M | 1.4K | Falstart! |
| 7 | `stationClock` | Zegar dworcowy / Station Clock | 2.00 s | 20M | 7.8K | „Opóźnienie może ulec zmianie” (niedokładny, ale robi masę prób) |
| 8 | `quartz` | Zegar kwarcowy / Quartz Clock | 0.010 s | 330M | 44K | |
| 9 | `atomic` | Zegar atomowy / Atomic Clock | 0.002 s | 5.1B | 260K | |
| 10 | `gps` | Satelita GPS / GPS Satellite | 0.001 s | 75B | 1.6M | |
| 11 | `pulsar` | Pulsar / Pulsar | 0.0005 s | 1T | 10M | |
| 12 | `timeMachine` | Maszyna czasu / Time Machine | 0.0001 s | 14T | 65M | Trafia, zanim kliknie |
| 13 | `schrodinger` | Kot Schrödingera / Schrödinger's Cat | 0.0001 s | 170T | 430M | Trafił i nie trafił. Wymaga perku prestiżu. |
| 14 | `chronos` | Chronos / Chronos | 0 | 2.1aa | 2.9B | Bóg czasu, nie pudłuje. Wymaga perku prestiżu. |

- **R-GEN-1:** Cena n-tego egzemplarza (n = liczba już posiadanych):
  `koszt_bazowy · 1.15^n`.
- **R-GEN-2:** Kupowanie ×1 / ×10 / ×100 / MAX (przełącznik nad listą). Cena
  zbiorcza to suma ciągu geometrycznego.
- **R-GEN-3:** Brak sprzedaży generatorów w 1.0.
- **R-GEN-4:** Kolejny generator jest widoczny jako sylwetka „???”, dopóki
  gracz nie kupi poprzedniego. Ten po nim jest całkiem ukryty.
- **R-GEN-5:** Karta generatora pokazuje liczbę posiadanych, dochód jednej
  sztuki, dochód łączny, udział w całości (%) i opis z humorem.
- **R-GEN-6:** Szersze okna (Sokole oko, Magnes, Szczęście) zwiększają dochód
  generatora według jego σ (wzór w 03). Niedokładni zyskują na Sokolim oku,
  a precyzyjni na Magnesie. Karta pokazuje ten bonus („okna: ×1.84”).

### 5.1 Ulepszenia generatorów (jednorazowe)

- **R-ULEP-1:** Każdy generator ma 8 ulepszeń, każde to **×2** dla tego
  generatora. Ulepszenie odblokowuje się przy posiadaniu
  **1, 5, 25, 50, 100, 150, 200, 250** sztuk. Koszt to koszt bazowy
  generatora × **10, 50, 500, 50K, 5M, 500M, 50B, 5T**.
- **R-ULEP-2:** Każde ulepszenie ma śmieszną nazwę i opis w PL i EN, np.
  - dziadek: „Okulary do czytania”, „Nowa bateria”, „Sanatorium”;
  - babcia: „Jajka od szczęśliwych kur”;
  - kukułka: „Kurs dykcji”.

  Wszystkie 112 nazw (14 × 8) pisze się przy implementacji contentu.
- **R-ULEP-3:** Dostępne ulepszenia pokazują się w pasku „Ulepszenia” nad
  sklepem jako kafelki z ikonami, posortowane od najtańszego.

### 5.2 Synergie (jednorazowe)

Generator A dostaje +1% za każdą sztukę B, a B dostaje +0.1% za każdą sztukę A.
Synergia odblokowuje się, gdy gracz ma choć 1 A i 1 B.

| id | Nazwa | A | B | Koszt |
|---|---|---|---|---|
| `grandparents` | Dziadkowie na randce | dziadek | babcia | 50K |
| `birdRhythm` | Ptasi rytm | kukułka | metronom | 5M |
| `craftsmanship` | Rzemiosło i kwarc | zegarmistrz | zegar kwarcowy | 3B |
| `photoFinish` | Fotokomórka | sędzia sprintu | GPS | 700B |
| `cosmicBeat` | Kosmiczny rytm | zegar atomowy | pulsar | 10T |
| `delayedTrain` | Pociąg z przyszłości | zegar dworcowy | maszyna czasu | 140T |

## 6. Złota Sekunda

- **R-ZLOTA-1:** Co losowo `U(300, 900)` s (5–15 min, jak w Cookie Clickerze) czasu rzeczywistego gry
  (× modyfikator Złotego dotyku) na brzegu ekranu pojawia się złoty zegarek
  i lata przez **12 s**. Dotknięcie go sprawia, że **następna runda jest
  złota**.
- **R-ZLOTA-2:** Złota runda wygląda inaczej (złota tarcza, iskry, muzyka).
  Jej wynik decyduje o sile efektu: PERFEKT 100%, ŚWIETNIE 60%, DOBRZE 30%.
  Pudło: „Uciekła!” i brak efektu.
- **R-ZLOTA-3:** Efekt losowany z wagami:

| Efekt | Waga | Działanie (przy 100% siły) |
|---|---|---|
| **Szał** / Frenzy | 45% | cały dochód ×7 przez 77 s (czas × siła) |
| **Fart** / Lucky | 45% | natychmiast `min(600 s dochodu pasywnego, 10% stanu konta)` × siła |
| **Gorąca ręka** / Hot Hand | 10% | przez 30 s (× siła) każde trafienie, które nie jest pudłem, liczy się jako PERFEKT |

- **R-ZLOTA-4:** Aktywny efekt ma licznik z czasem do końca, widoczny przy
  zegarze. Efekty różnego typu mogą działać naraz. Ten sam typ przedłuża czas.
- **R-ZLOTA-5:** Złota Sekunda nie pojawia się offline ani w samouczku.

## 7. Tryby ryzyka

Tryby to przełączniki obok zegara, odblokowywane osiągnięciami. Działają tylko
na wypłatę z dotknięć gracza.

| Tryb | Odblokowanie | Działanie | Mnożnik wypłaty |
|---|---|---|---|
| **Na ślepo** / Blind | 100 PERFEKTÓW łącznie | cyfry znikają od 7.00 czasu gry (zostaje pulsujące „?”) | ×3 |

Szybki zegar (stoper ×1.5) został usunięty po teście na telefonie: sekunda
na stoperze ma zawsze być prawdziwą sekundą (zob. 1.1).

- **R-TRYB-1:** Zmiana trybu działa od następnej rundy.

## 8. Osiągnięcia

- **R-OSIAG-1:** Każde osiągnięcie daje **+1%** do globalnego mnożnika
  (sumowane: 50 osiągnięć to +50%). Ma ikonę-odznakę, nazwę i opis PL/EN.
  Zdobycie pokazuje toast z fanfarą.
- **R-OSIAG-2:** Lista, ok. 100 sztuk:

| Kategoria | Progi | Liczba |
|---|---|---|
| Zarobione łącznie | 1K, 1M, 1B, 1T, 1aa, 1ab, … co ×1000 do 1e30 | 10 |
| Posiadane sztuki generatora | 1, 50, 100, 200 dla każdego z 14 | 56 |
| PERFEKTY łącznie | 1, 10, 100, 1K, 10K, 100K | 6 |
| PERFEKTY z rzędu | 3, 5, 10 | 3 |
| Najwyższe combo | 10, 15, 25 (max) | 3 |
| Złapane Złote Sekundy | 1, 10, 50, 200 | 4 |
| Prestiże | 1, 5, 10, 25 | 4 |
| Tryby | PERFEKT na ślepo; PERFEKT w szybkim zegarze; PERFEKT w obu naraz | 3 |
| Ukryte / śmieszne | „Niecierpliwy” (100× ZA WCZEŚNIE), „Drzemka” (10 rund z rzędu bez dotknięcia), „Prawie” (9.99, a potem 10.01), „Punktualny” (PERFEKT o 10:00 rano, czas lokalny), „Dziesiątka” (10× PERFEKT 10. dnia miesiąca), „Pełna kolekcja” (wszystkie umiejętności na max), „Muzeum” (1 sztuka każdego generatora), „Jajko na miękko” (100 babć) | 8 |

- **R-OSIAG-3:** Ukryte osiągnięcia wyglądają jak „???” do momentu zdobycia.

## 9. Prestiż — „Paradoks czasowy”

- **R-PRES-1:** Prestiż jest dostępny, gdy dałby ≥1 nowy Chronon. Ekran
  prestiżu pokazuje, ile Chrononów gracz dostanie teraz i ile Tików brakuje do
  następnego.
- **R-PRES-2:** Łączne Chronony = `floor((Tiki_zarobione_przez_całą_grę / 1e8)^(1/3))`.
  Prestiż daje różnicę między tą wartością a Chrononami już posiadanymi.
- **R-PRES-3:** Każdy posiadany Chronon daje **+2%** do globalnego mnożnika
  na zawsze.
- **R-PRES-4:** Prestiż daje też **Okruchy czasu** w liczbie równej nowym
  Chrononom. Okruchy wydaje się na perki. Wydawanie ich **nie** zmniejsza
  liczby Chrononów.
- **R-PRES-5:** Reset zeruje: Tiki, generatory, ulepszenia generatorów,
  synergie, umiejętności (chyba że perk mówi inaczej), combo i aktywne efekty.
  **Zostają:** Chronony, Okruchy, perki, osiągnięcia, statystyki, odblokowane
  tryby i ustawienia.
- **R-PRES-6:** Prestiż wymaga podwójnego potwierdzenia i ma spektakularną
  animację („przewinięcie czasu” wstecz).

### 9.1 Perki (drzewko „Paradoks”)

| id | Nazwa | Koszt (Okruchy) | Działanie | Wymaga |
|---|---|---|---|---|
| `headStart` | Szybki start | 5 | start runu z 10 dziadkami i 1K Tików | – |
| `muscleMemory1` | Pamięć mięśniowa I | 10 | Start później zostaje po resecie | – |
| `muscleMemory2` | Pamięć mięśniowa II | 50 | Sokole oko i Magnes zostają | I |
| `muscleMemory3` | Pamięć mięśniowa III | 250 | pozostałe umiejętności zostają na połowie poziomu (w dół) | II |
| `longNap1` | Długa drzemka I | 10 | limit offline 12 h | – |
| `longNap2` | Długa drzemka II | 40 | limit offline 24 h | I |
| `deepSleep1` | Głęboki sen I | 20 | offline 75% wydajności | – |
| `deepSleep2` | Głęboki sen II | 80 | offline 100% wydajności | I |
| `goldRush` | Gorączka złota | 15 | Złota Sekunda pojawia się częściej (interwał ×0.85) | – |
| `startShield` | Tarcza na start | 20 | +1 ładunek Tarczy na start runu, nawet bez umiejętności | – |
| `comboFloor` | Twarde lądowanie | 40 | pudło zrzuca serię do 5, nie do 0 | – |
| `autoBuyer` | Automatyczny kupiec | 30 | przełącznik: automatycznie kupuje najtańszy generator co 5 s | – |
| `earlyModes` | Śmiałek | 10 | tryb Na ślepo odblokowany od razu | – |
| `unlockSchrodinger` | Pudełko z kotem | 25 | odblokowuje generator 13 | – |
| `secondClock` | Drugi zegar | 100 | patrz 9.2 | – |
| `unlockChronos` | Ołtarz Chronosa | 500 | odblokowuje generator 14 | `unlockSchrodinger` |

### 9.2 Drugi zegar

- **R-DRUGI-1:** Z perkiem `secondClock` gracz może włączyć drugi zegar. Ekran
  dzieli się na lewą i prawą połowę, każda z własnym stoperem. Prawy startuje
  pół rundy później.
- **R-DRUGI-2:** Każda połowa oceniana jest osobno, według własnego czasu.
  Combo jest wspólne. Zimna krew i Start później działają na oba zegary.

## 10. Dochód offline

- **R-OFF-1:** Po powrocie, jeśli gracza nie było ≥60 s: dochód =
  `P_bez_efektów · min(czas_nieobecności, limit) · wydajność`. Domyślnie limit
  8 h i wydajność 50% (perki zmieniają oba).
- **R-OFF-2:** Okno „Gdy cię nie było…” pokazuje kwotę i animację wsypywania
  Tików. W M6 dochodzi przycisk „×2 za reklamę”.
- **R-OFF-3:** Ochrona przed cofnięciem zegara telefonu: ujemny czas
  nieobecności daje 0. Czas offline jest zawsze przycinany do limitu.
- **R-OFF-4:** Przy wyjściu z gry planowane jest **jedno lokalne
  powiadomienie** na moment, gdy dochód offline dojdzie do limitu, np.
  „Dziadkowie uzbierali 2,4M Tików! Limit pełny.” Kwota jest liczona przy
  wyjściu. Powrót do gry albo ponowne wyjście anuluje stare powiadomienie
  i planuje nowe. Nigdy więcej niż jedno naraz, żadnych innych powiadomień.
- **R-OFF-5:** O zgodę na powiadomienia (Android 13+) gra pyta dopiero przy
  pierwszym oknie „Gdy cię nie było…”, z jednym zdaniem wyjaśnienia,
  a nie przy starcie. Odmowa nic nie psuje. Powiadomienia da się wyłączyć
  w ustawieniach gry.

## 11. Samouczek (pierwsze uruchomienie)

- **R-TUT-1:**
  1. Ekran z zegarem i jednym zdaniem: „Dotknij, gdy będzie dokładnie 10.00”.
  2. Pierwsze 3 rundy z podpowiedzią (strzałka, pulsowanie przy 9.5).
  3. Po pierwszym trafieniu strzałka do sklepu i do Dziadka (15 Tików).
  4. Po zakupie krótki dymek „Dziadek będzie próbował za ciebie”.

  Koniec samouczka. Każdy krok da się pominąć.
- **R-TUT-2:** Nowe mechaniki (pierwsza umiejętność, Złota Sekunda, combo,
  prestiż) mają jednorazowy dymek z wyjaśnieniem przy pierwszym pojawieniu się.

### 11.1 Szczęście początkującego (08, playtest)

- **R-TUT-3:** Pierwsze **10 rund** nowej gry (przed pierwszym paradoksem)
  płaci **×3** (także BLISKO); przez kolejne 20 rund mnożnik maleje
  liniowo do ×1. Okna trafienia się nie zmieniają. Generatory tego nie
  dostają. Cel: pierwszy zakup w ok. minutę także dla gracza
  nieprecyzyjnego.

### 11.2 Dzienna premia (08, playtest)

- **R-DZIEN-1:** Przy pierwszym uruchomieniu (lub powrocie) danego dnia,
  po samouczku, gra pokazuje okno „Dzienna premia” z serią 7 dni.
- **R-DZIEN-2:** Dzień N płaci `max(25·N, dochód pasywny × minuty[N])`,
  gdzie minuty = 5, 10, 15, 20, 30, 45, 60. Po 7. dniu seria wraca do 1.
- **R-DZIEN-3:** Pominięty dzień (kalendarzowy, czas lokalny) zaczyna serię
  od 1. Bez reklam przy tym oknie.

## 12. Statystyki

- **R-STAT-1:** Ekran statystyk pokazuje:
  - Tiki zarobione w tym runie i łącznie,
  - liczbę rund i rozkład progów (%),
  - średni błąd i rozrzut (ms) z ostatnich 100 rund,
  - najlepszą serię i najwyższe combo,
  - liczbę złapanych Złotych Sekund,
  - czas gry,
  - prestiże i Chronony.

  Średni błąd pomaga graczowi zobaczyć, czy klika za wcześnie, czy za późno.

## 13. Reklamy nagradzane

Każda oferta jest **opcjonalna**, a nagroda jest **opisana na przycisku**
przed obejrzeniem. Reklama nigdy nie przerywa rundy: przycisk reklamy
pauzuje rundę tak jak otwarcie panelu (R-RUNDA-8).

| id | Oferta PL / EN | Gdzie | Nagroda | Ograniczenie |
|---|---|---|---|---|
| `adOffline` | Podwój / Double it | okno „Gdy cię nie było…” | ×2 dochodu offline | tylko przy nieobecności ≥ 30 min |
| `adTurbo` | Turbo / Turbo | przycisk przy zegarze | **×2 całego dochodu** na 30 min | zapas najwyżej 4 h; czas Turbo płynie tylko podczas gry; kolejna reklama Turbo najwcześniej po 5 min (08) |
| `adBag` | Worek Tików / Bag of Ticks | sklep, gdy na coś brakuje | 5 min dochodu pasywnego od razu | raz na 30 min |
| `adRescue` | Ratunek combo / Combo Rescue | wyskakuje od razu po utracie serii ≥ 15 | przywraca serię sprzed pudła | raz na 15 min; okno znika po 5 s albo przy następnym dotknięciu |
| `adGolden` | Złota Sekunda / Golden Second | przycisk przy zegarze | Złota Sekunda pojawia się od razu | raz na 30 min |

- **R-AD-1:** Czasy odnowienia liczone są w czasie rzeczywistym (także gdy
  gra jest zamknięta), z wyjątkiem Turbo, którego zapas maleje tylko podczas
  gry.
- **R-AD-2:** Turbo wchodzi do globalnego mnożnika `G` (03 §2), więc działa
  na generatory, trafienia, Echo i Fart. **Nie** działa na dochód offline,
  bo od tego jest `adOffline`.
- **R-AD-3:** Nagroda trafia do gracza tylko po pełnym obejrzeniu (callback
  „reward earned” z SDK). Przerwana albo nieudana reklama oznacza brak
  nagrody, brak kary i brak zużycia czasu odnowienia.
- **R-AD-4:** Przycisk niedostępnej oferty (czas odnowienia, brak reklamy,
  brak sieci) pokazuje powód i czas do dostępności. Gra nigdy nie czeka na
  załadowanie reklamy (T-27).
- **R-AD-5:** Oferty pojawiają się dopiero po samouczku i po pierwszych
  5 minutach gry. Pierwsze wrażenie ma być „bez reklam”.
- **R-AD-6:** Brak reklam przy starcie aplikacji i przy wychodzeniu z niej.
  Nie ma też żadnej reklamy, której gracz sam nie wybrał.
- **R-AD-7:** Przed reklamą gracz widzi ofertę: co dostanie (konkretnie, np.
  „×2 Tików przez 30 min”, kwota Worka), że to krótka reklama wideo
  z nagrodą po obejrzeniu do końca, oraz przyciski „▶ Obejrzyj” i „Nie
  teraz” (zasady AdMob: nagroda i wymagane działanie ujawnione przed każdą
  reklamą, osobna zgoda na każdą). Ratunek combo i „Podwój” offline mówią
  to na samym przycisku („▶ … za reklamę”), bo już są ofertą.
- **R-AD-8:** Po reklamie komunikat potwierdza nagrodę („Turbo włączone!
  ×2 jeszcze przez 30:00”) albo jej brak („Reklama nie została obejrzana
  do końca — bez nagrody”).
