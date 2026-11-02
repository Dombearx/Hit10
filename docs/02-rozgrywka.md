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

- **R-RUNDA-1:** Stoper liczy czas gry w górę od `0.00`. Cel to `5.000`
  (test na telefonie: 10 s czekania na rundę to za długo; było `10.000`).
- **R-RUNDA-2:** Gracz dotyka **dowolnego miejsca obszaru zegara**. Liczy się
  moment **dotknięcia** (pointer down), nie puszczenia palca.
- **R-RUNDA-3:** Błąd `e = czas_gry_w_chwili_dotknięcia − 5.000`. Ocena
  zależy od `|e|` i aktualnych okien (sekcja 2).
- **R-RUNDA-4:** Dotknięcia w pierwszych `0.25 s` czasu rzeczywistego rundy
  i w trakcie pauzy na wynik są ignorowane. Chroni to przed podwójnym tapnięciem.
- **R-RUNDA-5a:** Dotknięcie wcześniej niż **1 s przed celem** (na stoperze
  < 4.00) to dotknięcie przypadkowe: jest pomijane, runda trwa dalej,
  seria zostaje. Statystyki liczą je osobno (playtest: przypadkowe
  dotknięcia na starcie rundy zerowały serię).
- **R-RUNDA-8a:** Przycisk ⏸ nad tarczą (po samouczku) świadomie zatrzymuje
  stoper: runda jest anulowana bez kary, następna rusza dopiero po
  dotknięciu tarczy albo ▶. Każda pauza (przycisk, panel zasłaniający
  zegar, wyjście z aplikacji) jest widoczna: tarcza pokazuje „Pauza ·
  dotknij, by grać”. Kupowanie w sklepie **nie** zatrzymuje stopera
  (playtest 22: w Szale gracz dokupuje zegary i nie chce czekać na nową
  rundę; runda bez dotknięcia i tak nic nie kosztuje, R-RUNDA-6a).
- **R-RUNDA-5:** Dotknięcie przed oknem DOBRZE to wynik **ZA WCZEŚNIE**
  (pudło). Jeśli gracz nie dotknie do `5.30`, runda kończy się wynikiem
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
  cyfry „przyciągają się” do `5.00` (efekt Magnesu), a błąd jest pokazany
  małym drukiem.

### 1.1 Start później i Zimna krew (tempo się nie zmienia)

Playtest na telefonie: zmiana tempa w trakcie rundy (dawne Przewijanie
i bullet time) zabierała rytm — gracz liczy w głowie, a przyspieszony
start i nagłe hamowanie przy 9.0 psuły to liczenie. Dlatego stoper
**zawsze płynie równo**, a obie umiejętności dają tę samą pomoc inaczej.

- **R-RUNDA-10:** Start później: stoper rusza od `S(L) = 0.08·L` (L =
  poziom 0–10: 0, 0.08 … 0.80) — każdy poziom daje tyle samo, a
  kolejne są coraz droższe (×7) — w normalnym tempie. Przy celu 5.00 to
  już mały bonus (do ~15% więcej rund); kandydat do zastąpienia. Cel zostaje `5.00`, a do celu zawsze zostają
  co najmniej 4 s (`round.latestStart` ≤ cel − strefa − 4), żeby złapać
  rytm.
- **R-RUNDA-11:** Zimna krew: okna gracza (PERFEKT, ŚWIETNIE, DOBRZE,
  BLISKO) są `1 / (1 − 0.06·L)` razy szersze (×2.5 na max). Matematycznie
  to ta sama pomoc co dawne zwolnienie zegara, ale bez zmiany tempa.
  Generatory jej nie dostają.
- **R-RUNDA-12:** Ocena trafienia jest w czasie gry, który przy stałym tempie
  równa się czasowi rzeczywistemu.
- **R-RUNDA-13:** Z Zimną krwią strefa `4.8–5.2` ma tylko wskazówki:
  winietę, pulsujące cyfry i bicie serca. Tempo i dźwięk się nie zmieniają.
- Długość rundy w czasie rzeczywistym: od ok. **5.7 s** (bez ulepszeń) do
  ok. **4.9 s** (max Start później).

## 2. Progi trafienia

| Próg | Okno bazowe `|e|` | Nagroda bazowa (Tiki) | Udział Echa | Krok combo |
|---|---|---|---|---|
| **5.00** (jackpot) | < 0.010 s | PERFEKT + 5 s dochodu zegarów | – | jak PERFEKT |
| **PERFEKT** | < 0.015 s | 6 | 60% | +3 |
| **ŚWIETNIE** | < 0.030 s | 3 | 33% | +2 |
| **DOBRZE** | < 0.050 s | 1 | 10% | +1 |
| **BLISKO** | < 0.150 s (tylko dotknięcia gracza) | 0.3 | 0 | reset do 0 |
| **PUDŁO** | reszta, ZA WCZEŚNIE, ZA PÓŹNO | 0 | 0 | reset do 0 |

Okna zmienione po playteście (wcześniej PERFEKT i 5.00 ±0.005 s, ŚWIETNIE
±0.020 s): ±5 ms to mniej niż jedna klatka ekranu (16.7 ms przy 60 Hz)
i rząd wielkości próbkowania dotyku, a najtrudniejszy poziom osu! daje na
najlepszą ocenę ±20 ms. PERFEKT przy rozrzucie 30 ms wypadał w 13% rund,
więc „10 PERFEKTÓW z rzędu” było praktycznie losowe. Teraz dobry gracz
(30 ms) ma ok. 38% PERFEKTÓW i 26% 5.00, przeciętny (60 ms) 20% i 13%;
pudeł jest tyle samo co wcześniej (DOBRZE bez zmian). Nagrody przestrojone
symulatorem (PERFEKT 10 → 6, Echo PERFEKTU 100% → 60%, jackpot 8 s → 5 s).

- **R-PROG-0:** BLISKO (08, playtest) to pudło z pocieszeniem: płaci mało
  (1/33 PERFEKTU), ale zeruje combo jak pudło. W czasie szczęścia
  początkującego płaci jak DOBRZE (1 zamiast 0.3, wygasa razem z ×3), żeby
  bardzo nieprecyzyjni gracze też szybko kupili pierwszy zegar. Okna PERFEKT/ŚWIETNIE/DOBRZE
  się nie zmieniają — trafienie 5.00 ma zostać wyczynem. Generatory nie
  mają BLISKO.

- **R-PROG-3 (5.00 — jackpot):** dotknięcie w oknie 5.00
  (|błąd| < 0.010 s; żadna umiejętność tego okna nie poszerza, Fart i
  Gorąca ręka go nie dają) — tarcza pokazuje wtedy równe 5.00, a błąd
  małym drukiem — płaci oprócz PERFEKTU **5 s dochodu zegarów**
  (co najmniej 5 bazowych PERFEKTÓW), razy combo i tryb. Oprawa: „5.00!”,
  deszcz złota, fanfara. Nagłówek pokazuje „5.00 = +X”. (Historia: przy
  oknie ±0.005 s) wielkość 8 s to
  granica z symulatora: przy 15 s gracz grający bez przerwy wyprzedza
  założone tempo, a gracz nieprecyzyjny zostaje za daleko w tyle (B-6c,
  B-7); 10 s mieściło się tylko na styk. Przy grze po kilka minut dziennie i tak przeważa dochód offline.
- **R-PROG-1:** Okna sprawdzane są od najwęższego. Wygrywa pierwszy pasujący
  próg.
- **R-PROG-2:** Okno PERFEKT nigdy nie może być szersze niż okno ŚWIETNIE.
  Gra pilnuje tego niezależnie od ulepszeń.
- Uzasadnienie liczb: wprawny gracz ma rozrzut ok. 30 ms, co daje ok. 13%
  PERFEKT, 50% w ŚWIETNIE i 90% w DOBRZE; przeciętny ok. 60 ms: 7% / 26% /
  60%. Szczegóły w 03. Okno PERFEKT (10 ms) jest węższe niż jedna klatka
  ekranu 60 Hz (16,7 ms) i niż najostrzejsze oceny gier rytmicznych — ma
  zostać wyczynem (playtest na telefonie: ok. 1 PERFEKT na 20 prób).
- Kroki combo (playtest na telefonie): każde trafienie, także DOBRZE,
  podnosi serię (+1/+2/+3), bo przy przeciętnym rozrzucie PERFEKT pod rząd
  praktycznie się nie zdarza; serię dalej zeruje BLISKO i pudło.

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
| `power` | Siła trafienia / Strike Power | 15 | 50 | ×7 | nagroda progu ×(1+1.5L) |
| `fastForward` | Start później / Late Start | 15 | 150 | ×3.66 | stoper rusza od 0.0533·L, max 0.8 |
| `ticking` | Tykanie / Ticking | 1 | 200 | – | dźwięk i wibracja co 0.1 s w ostatniej sekundzie |
| `wideEye` | Sokole oko / Hawk Eye | 15 | 600 | ×2.6 | okna ŚWIETNIE i DOBRZE ×(1+0.0533L), max ×1.8 |
| `combo` | Combo / Combo | 15 | 500 | ×8 | limit combo +2 na poziom (5 → 35) |
| `magnet` | Magnes / Magnet | 15 | 2 000 | ×3.66 | okno PERFEKT +0.00067 s na poziom, ±0.015 → ±0.025 |
| `echo` | Echo / Echo | 15 | 5 000 | ×9 | trafienie płaci dodatkowo 0.5·L s dochodu pasywnego × udział echa (max 7.5 s) |
| `bulletTime` | Zimna krew / Cold Blood | 15 | 5 000 | ×3.66 | okna gracza ×1/(1−0.04L), max ×2.5 |
| `luck` | Szczęście / Luck | 15 | 10 000 | ×8 | szansa 2%·L, że ŚWIETNIE→PERFEKT, a DOBRZE→ŚWIETNIE |
| `shield` | Tarcza / Shield | 5 | 2 000 | ×50 | L ładunków; pudło zużywa ładunek zamiast zerować combo; +1 ładunek co 10 kroków serii |
| `goldenTouch` | Złoty dotyk / Golden Touch | 8 | 1 000 000 | ×50 | odstęp między Złotymi Sekundami ×(1−0.05L), czyli pojawia się częściej; jej efekt jest ×(1+0.05L) silniejszy |

Więcej poziomów (zmiana po playteście, razem z R-PRES-5a): umiejętności
okien i tempa (Start później, Sokole oko, Magnes, Zimna krew) mają to samo
maksimum co wcześniej, rozłożone na 15 drobniejszych kroków — dawny 10.
poziom kosztuje mniej więcej tyle co przedtem, okna nie rosną bez końca.
Umiejętności dochodu (Siła, Combo, Echo, Szczęście, Tarcza, Złoty dotyk)
dostały nowe, mocniejsze i drogie poziomy: cel na kilka przejść gry.
Pierwsze 6 h kupuje ok. 63% wszystkich poziomów (85 ze 134).

- **R-UMIEJ-1:** Sokole oko i Magnes działają **także na generatory** (sekcja 5).
  Dzięki temu są przydatne przez całą grę.
- **R-UMIEJ-2:** Karta umiejętności pokazuje poziom, efekt teraz → po zakupie
  (np. „Okno PERFEKT: ±0.007 → ±0.008 s”) i cenę. Gdy zakup jest możliwy,
  karta delikatnie pulsuje.
- **R-UMIEJ-3:** Umiejętności odblokowują się stopniowo: karta pojawia się,
  gdy gracz ma choć raz ≥50% jej ceny. Wcześniej jest widoczna jako „???”,
  żeby było do czego dążyć.

## 5. Generatory (sklep „Zegary”)

Każdy generator „gra w tę samą grę” co gracz: próbuje trafić 5.00 co 10 s
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

### 5.1 Bonusy za liczbę sztuk (automatyczne)

Zmienione po pytaniu „czy ulepszenia się w ogóle opłacają?”: kupowane
ulepszenia (model Cookie Clickera) były tuż po odblokowaniu najgorszym
zakupem w sklepie (Dziadek ×2 przy 1 Dziadku zwracał się 25 min, kolejny
Dziadek 3 min), a wskazówka do nich kierowała. Teraz jak w AdVenture
Capitalist: bonus przychodzi sam za zbieranie sztuk.

- **R-ULEP-1:** Każdy generator ma 8 progów: **10, 20, 40, 75, 100, 150,
  200, 250** sztuk. Na każdym progu wszystkie sztuki tego generatora
  zarabiają **×2** — za darmo, od razu, nic nie trzeba kupować. Prestiż
  zeruje sztuki, więc i bonusy.
- **R-ULEP-2:** Każdy próg ma śmieszną nazwę w PL i EN (dawne nazwy
  ulepszeń), np. dziadek: „Okulary do czytania”, „Nowa bateria”,
  „Sanatorium”; pokazuje ją powiadomienie przy osiągnięciu progu.
- **R-ULEP-3:** Karta generatora ma pasek postępu do następnego progu
  („7/10 → ×2”), po ostatnim „Wszystkie bonusy zdobyte”. Osiągnięcie
  progu: fanfara, wibracja, powiadomienie „Nowy bonus · <nazwa>
  — <generator> ×2”. Nie ma osobnego paska ulepszeń nad sklepem.

### 5.2 Synergie (automatyczne)

Generator A dostaje +1% za każdą sztukę B, a B dostaje +0.1% za każdą sztukę A.
- **R-SYN-1:** Synergia włącza się sama, gdy gracz ma co najmniej **25 A
  i 25 B** (`requires` w pliku balansu), z powiadomieniem „Synergia!”.

| id | Nazwa | A | B | Dawny koszt (nieużywany) |
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
| **Na ślepo** / Blind | 100 PERFEKTÓW łącznie | od 4.00 czasu gry znikają cyfry i pasek postępu wokół tarczy (zostaje pulsujące „?”); milkną też tykanie i bicie serca, a winieta Zimnej krwi się nie pojawia (playtest 22: pasek zdradzał czas) | ×3 |

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
| Ukryte / śmieszne | „Niecierpliwy” (100× ZA WCZEŚNIE), „Drzemka” (10 rund z rzędu bez dotknięcia), „Prawie” (4.99, a potem 5.01), „Punktualny” (PERFEKT o 5:00 albo 17:00, czas lokalny), „Piątka” (10× PERFEKT 5. dnia miesiąca), „Pełna kolekcja” (wszystkie umiejętności na max), „Muzeum” (1 sztuka każdego generatora), „Jajko na miękko” (100 babć) | 8 |

- **R-OSIAG-3:** Ukryte osiągnięcia wyglądają jak „???” do momentu zdobycia.
  Tak samo osiągnięcia „Miej N × zegar” dla zegarów, których gracz jeszcze
  nie odkrył (nie miał ich i nie są następne w kolejce w sklepie) —
  playtest: lista zdradzała wszystkie zegary w grze.

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
  umiejętności (powyżej limitu Pamięci mięśniowej, R-PRES-5a), combo i
  aktywne efekty.
  **Zostają:** Chronony, Okruchy, perki, osiągnięcia, statystyki, odblokowane
  tryby i ustawienia.
- **R-PRES-5a:** Pamięć mięśniowa I/II/III: po paradoksie każda umiejętność
  zostaje do **4 / 6 / 8** poziomu; wyższe poziomy trzeba odkupić. Karta
  umiejętności pokazuje kłódkę z liczbą zachowanych poziomów, szczegóły
  mówią, ile zostanie (albo że bez perku wszystko wraca do zera).
  Symulacja (tool/prestige_report.dart): zachowanie 3 poziomów prawie nic
  nie daje (tanie poziomy i tak się odkupuje), 5–7 poziomów skraca kolejne
  przejścia o 10–25%, zachowanie wszystkiego o ok. 35% — ale wtedy od
  drugiego przejścia nie ma już w co inwestować.
- **R-PRES-6:** Prestiż wymaga podwójnego potwierdzenia i ma spektakularną
  animację („przewinięcie czasu” wstecz).
- **R-PRES-6a:** Po animacji gracz dostaje Chronony i Okruchy, ale run
  resetuje się dopiero po „Zacznij nową grę” (albo zamknięciu ekranu).
  W międzyczasie Okruchy z tego paradoksu kupują perki, które od razu
  działają w nowej grze (Pamięć mięśniowa, Szybki start, Tarcza na start).
  Zamknięcie aplikacji w tym momencie kończy reset przy następnym starcie
  (playtest 22).

### 9.1 Perki (drzewko „Paradoks”)

| id | Nazwa | Koszt (Okruchy) | Działanie | Wymaga |
|---|---|---|---|---|
| `headStart` | Szybki start | 5 | start runu z 10 dziadkami i 1K Tików | – |
| `muscleMemory1` | Pamięć mięśniowa I | 10 | każda umiejętność zostaje po resecie do 4. poziomu | – |
| `muscleMemory2` | Pamięć mięśniowa II | 50 | …do 6. poziomu | I |
| `muscleMemory3` | Pamięć mięśniowa III | 250 | …do 8. poziomu | II |
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

Zasady ogólne (po playteście z prawdziwymi testerami i przeglądzie
dobrych praktyk samouczków mobilnych): uczymy przez działanie, nie przez
czytanie; jeden dymek = jedna myśl, najwyżej ~10 słów; dymek jest
przypięty strzałką do rzeczy, o której mówi; nic nie blokuje gry (dymki,
przyciemnienie i obwódki przepuszczają dotyk); wszystko da się pominąć.

- **R-TUT-1:**
  1. Zegar sam pokazuje moment: złoty znacznik celu na górze tarczy
     i złoty okrąg, który zamyka się na tarczy dokładnie na 5.00.
     Działa w samouczku i przez pierwsze 10 rund nowego gracza (przed
     pierwszym paradoksem). Dymek: „Dotknij, gdy złoty okrąg dojdzie do
     zegara — na 5.00!”.
  2. Po pierwszych Tikach, jeśli nie starcza na Dziadka: dymek przy
     liczniku „To twoje Tiki. Zbierz 15 na pierwszy zegar!”.
  3. Gdy stać gracza na Dziadka: reszta ekranu przyciemniona, przycisk
     zakupu Dziadka w złotej, pulsującej obwódce, dymek „Kup Dziadka —
     będzie grał za ciebie!”. Sklep sam rozwija się na zakładce Zegary.
  4. Po zakupie (bez przyciemnienia — gracz dalej gra): dymek przy liczniku „/s”: „Dziadek zarabia 0,1/s za
     ciebie, nawet offline.” Zamyka się przyciskiem OK albo sam po 7 s gry.

  Koniec samouczka. W jego trakcie nie ma znaczka wydarzenia, czerwonych
  kropek ani Złotej Sekundy (jedna nowa rzecz naraz).
- **R-TUT-2:** Wskazówki o nowych rzeczach, każda raz, przypięta do swojej
  rzeczy: pasek bonusu na karcie Dziadka (gdy gracz ma 3 Dziadki, przed
  pierwszym ×2), pierwsza umiejętność,
  na którą stać gracza (zakładka), pierwszy przełącznik trybu, Złota
  Sekunda (gdy leci), seria (licznik combo), prestiż (wir).
  - Najwyżej jedna naraz; pierwsza po 20 s gry od końca samouczka,
    kolejne co najmniej 45 s gry po poprzedniej.
  - Znika, gdy gracz zrobi to, o czym mówi (otworzy zakładkę, dotknie
    próg bonusu, przełączy tryb, złapie zegarek, otworzy prestiż) — i wtedy
    już nigdy się nie pojawi; kto odkrył rzecz sam, nie dostaje
    wskazówki. Wskazówka o serii znika sama po 7 s. Każdą można zamknąć
    krzyżykiem. Złota Sekunda, która odleciała, wraca ze wskazówką
    następnym razem.
  - Wskazówka zignorowana przez 15 s gry chowa się i wraca jeszcze raz
    (po zwykłym odstępie); zignorowana drugi raz już nie wraca. Bez tego
    jedna wisząca wskazówka blokowała wszystkie następne (symulacja
    onboardingu: wskazówka o ulepszeniu wisiała 3–5 minut).
- **R-TUT-3a (położenie dymków):** dymek nigdy nie zasłania tarczy w czasie
  gry. Cel nad areną (licznik Tików, „/s”, wir) → dymek na dole areny,
  pod tarczą, cel świeci obwódką. Cel tuż pod areną (combo,
  przełączniki) → dymek pod celem. Sprawdza to
  `tools/playtest/onboarding.js` (persony grają od zera, raport: kiedy
  który dymek, jak długo, jak zniknął, czy zasłania tarczę lub cel).
- **R-TUT-4:** Czerwona kropka na zakładce Zegary / Umiejętności, gdy za
  nią jest coś, na co gracza stać (po samouczku).
- **R-TUT-5:** Przycisk „?” w nagłówku otwiera „Jak grać”: zwijana lista
  (cel, Tiki, zegary, ulepszenia, umiejętności, seria, Złota Sekunda,
  przełączniki, wydarzenia, paradoks, ikony nagłówka) — same tytuły,
  dotknięcie rozwija opis — plus „Pokaż samouczek od nowa”.
- **R-TUT-6:** Karta zegara, którego gracz jeszcze nie ma, mówi najpierw,
  ile zarabia („+0,1/s za sztukę”), dopiero potem żart. Przycisk
  umiejętności mówi, co kupuje („Kup poz. 3”), a nie „Poziom 2/10”.
  Znaczek wydarzenia ma przy liczbach ikony (świąteczny zegarek, tarcza
  strzelnicza).

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
  - typowy błąd (mediana odległości od celu) i średnie przesunięcie (ms)
    z ostatnich 100 dotknięć bliskich celu (±0.3 s) — przypadkowe
    dotknięcia nie psują tych liczb (playtest: 3 przypadkowe dotknięcia
    zrobiły z ok. 40 ms „rozrzut” 440 ms),
  - liczbę przypadkowych dotknięć (pominiętych, R-RUNDA-5a),
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
| `adBag` | Worek Tików / Bag of Ticks | sklep, gdy na coś brakuje | 5 min dochodu pasywnego od razu, bez Turbo i Szału; okno oferty pokazuje dokładnie tę kwotę | raz na 30 min |
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

## 14. Wydarzenia sezonowe

Wzór: sezony Cookie Clickera. Gra sama włącza wydarzenie według lokalnej
daty telefonu — bez serwera i bez stałych kosztów — i każde wraca co roku.
Daty i cel są w `balance.json` (`seasons`).

| id | Wydarzenie | Daty (włącznie) | Zamiast złotego zegarka |
|---|---|---|---|
| `valentine` | Walentynki / Valentine's | 10–16 lutego | serce |
| `easter` | Wielkanoc / Easter | od Niedzieli Palmowej do Poniedziałku Wielkanocnego | pisklę |
| `summer` | Lato / Summer | 1–14 lipca | słońce |
| `fiveDay` | Dzień Piątki / Five Day | 3–7 maja | „5” |
| `halloween` | Halloween | 24 października – 2 listopada | dynia |
| `christmas` | Boże Narodzenie / Christmas | 18–27 grudnia | prezent |
| `newYear` | Sylwester / New Year | 28 grudnia – 2 stycznia | konfetti |

- **R-SEZ-1:** W czasie wydarzenia tło ma kolory sezonu, a zamiast złotego
  zegarka przylatuje przedmiot sezonowy. Działa tak samo jak Złota Sekunda
  (te same efekty, ten sam czas); stoper i okna trafień się nie zmieniają.
- **R-SEZ-2:** Cel: złapać 5 przedmiotów i trafić 50 razy (DOBRZE lub
  lepiej; BLISKO się nie liczy) w czasie wydarzenia. Postęp liczy się
  osobno dla każdego roku (`halloween-2026`).
- **R-SEZ-3:** Nagroda (raz na wydarzenie w roku): 30 min dochodu
  pasywnego (co najmniej 1000 Tików), motyw wydarzenia na zawsze do wyboru
  w Ustawieniach i osiągnięcie sezonowe (+1%, jedno na wydarzenie).
  Nagrody są kosmetyczne albo jednorazowe — przegapione wydarzenie nie
  zostawia trwałej straty (bez presji FOMO).
- **R-SEZ-4:** Przy pierwszym uruchomieniu w czasie wydarzenia (po oknach
  offline i dziennej premii) gra pokazuje okno wydarzenia; potem otwiera je
  plakietka w nagłówku z postępem („2/5 · 31/50”).
- **R-SEZ-5:** Motyw: „Sezonowy” (domyślny, zmienia się z wydarzeniami),
  „Klasyczny” albo motyw ukończonego wydarzenia.
- **R-SEZ-6:** Panel diagnostyczny (T-12) ma podgląd każdego wydarzenia bez
  zmiany daty; postęp innych wydarzeń zostaje zapamiętany.
