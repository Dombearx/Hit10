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

- **R-RUNDA-10:** Start później: stoper rusza od `S(L) = 0.1333·L` (L =
  poziom 0–15: 0 … 2.00, §4) — każdy poziom daje tyle samo, a
  kolejne są coraz droższe — w normalnym tempie. Na max to ok. 54%
  więcej rund (5.7 → 3.7 s; przy dawnym limicie 0.80 było tylko ~16%).
  Cel zostaje `5.00`, a do strefy przy celu zawsze zostaje
  co najmniej 2.8 s (`round.latestStart` ≤ cel − strefa − 2.8), żeby
  złapać rytm.
- **R-RUNDA-11:** Zimna krew: okna gracza (PERFEKT, ŚWIETNIE, DOBRZE,
  BLISKO) są `1 / (1 − 0.04·L)` razy szersze (L = 0–15, ×2.5 na max, §4). Matematycznie
  to ta sama pomoc co dawne zwolnienie zegara, ale bez zmiany tempa.
  Generatory jej nie dostają.
- **R-RUNDA-12:** Ocena trafienia jest w czasie gry, który przy stałym tempie
  równa się czasowi rzeczywistemu.
- **R-RUNDA-13:** Z Zimną krwią strefa `4.8–5.2` ma tylko wskazówki:
  winietę, pulsujące cyfry i bicie serca. Tempo i dźwięk się nie zmieniają.
- Długość rundy w czasie rzeczywistym: od ok. **5.7 s** (bez ulepszeń) do
  ok. **3.7 s** (max Start później).

## 2. Progi trafienia

| Próg | Okno bazowe `|e|` | Nagroda bazowa (Tiki) | Udział Echa | Krok combo |
|---|---|---|---|---|
| **5.00** (jackpot) | < 0.010 s | PERFEKT + 5 s dochodu zegarów | – | mnożnik od razu do limitu |
| **PERFEKT** | < 0.015 s | 6 | 60% | +1 |
| **ŚWIETNIE** | < 0.030 s | 3 | 33% | 0 |
| **DOBRZE** | < 0.050 s | 1 | 10% | 0 |
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
- Kroki combo (docs/15, 11.2026): mnożnik podnosi tylko PERFEKT, a równe
  5.00 od razu do limitu (okno 5.00 nie rośnie z umiejętnościami, więc to
  zawsze wyczyn, a słabszy gracz ma czym wrócić). Dawne +3/+2/+1 za każde
  trafienie trzymało dobrego gracza stale na maksimum.

## 3. Wypłata za trafienie i combo

- **R-WYPLATA-1:** wypłata = `(nagroda_progu · (1 + 1.5·L_siła) · G + ⅓ s · L_echo · udział_echa · P) · combo · mnożnik_trybu`
  - `G` to globalny mnożnik (osiągnięcia, Chronony, Szał), patrz 03;
  - `P` to aktualny dochód pasywny na sekundę (już z `G`).
- **R-COMBO-1:** `kroki` mnożnika rosną o krok combo progu (tabela wyżej)
  i nigdy nie przekraczają limitu; równe 5.00 ustawia je na limit. Pudło
  (także BLISKO; dotknięcie za wcześnie lub za późno, R-RUNDA-6a) zeruje
  kroki, chyba że gracz ma ładunek Tarczy (zużywa go wtedy, a mnożnik
  zostaje). Tarcza chroni tylko przed pudłem. Ładunek wraca co 10 trafień
  (`combo.ladder.rechargeHits`); zużycie ładunku zeruje odliczanie.
- **R-COMBO-2:** `combo = 1 + 0.05 · kroki`, a `limit = 5 + 2·L_combo`,
  czyli od 5 do 35 (×1.25 do ×2.75).
- **R-COMBO-2a (seria):** seria — trafienia z rzędu — liczy się tylko dla
  wyzwania „seria” (R-WYZ-3): od zera od wydania wyzwania, każde pudło ją
  zeruje, także obronione Tarczą. Bez takiego wyzwania nie jest pokazywana.
- **R-COMBO-3:** Combo mnoży **całą** wypłatę, razem z Echem. Bez tego
  w późnej grze combo przestaje się liczyć (wyszło w symulacji).
- **R-COMBO-4:** Mnożnik jest stale widoczny i rośnie wizualnie (kolor,
  płomień, rozmiar — względem limitu). Utrata mnożnika ma swój efekt
  („rozbicie”). Obok, tylko przy wyzwaniu „seria”: „seria 12/40”.

## 4. Umiejętności gracza (sklep „Umiejętności”)

Każda umiejętność ma poziomy. Cena poziomu to `koszt_bazowy · wzrost^L`, gdzie
`L` to poziom obecny.

| id | Nazwa PL / EN | Max | Koszt bazowy | Wzrost | Efekt na poziomie L |
|---|---|---|---|---|---|
| `power` | Siła trafienia / Strike Power | 15 | 50 | ×7 | nagroda progu ×(1+1.5L) |
| `fastForward` | Start później / Late Start | 15 | 150 | ×3.66 | stoper rusza od 0.1333·L, max 2.0 |
| `ticking` | Tykanie / Ticking | 1 | 200 | – | dźwięk i wibracja co 0.1 s w ostatniej sekundzie |
| `wideEye` | Sokole oko / Hawk Eye | 15 | 600 | ×2.6 | okna ŚWIETNIE i DOBRZE ×(1+0.0533L), max ×1.8 |
| `combo` | Combo / Combo | 15 | 500 | ×8 | limit mnożnika +2 kroki (+0.10) na poziom (×1.25 → ×2.75) |
| `magnet` | Magnes / Magnet | 15 | 2 000 | ×3.66 | okno PERFEKT +0.00067 s na poziom, ±0.015 → ±0.025 |
| `echo` | Echo / Echo | 15 | 5 000 | ×9 | trafienie płaci dodatkowo ⅓·L s dochodu pasywnego × udział echa (max 5 s) |
| `bulletTime` | Zimna krew / Cold Blood | 15 | 5 000 | ×3.66 | okna gracza ×1/(1−0.04L), max ×2.5 |
| `luck` | Szczęście / Luck | 15 | 10 000 | ×8 | szansa 2%·L, że ŚWIETNIE→PERFEKT, a DOBRZE→ŚWIETNIE |
| `shield` | Tarcza / Shield | 5 | 2 000 | ×50 | L ładunków; pudło zużywa ładunek zamiast zerować mnożnik; +1 ładunek co 10 trafień |
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
- **R-GEN-2:** Kupowanie ×1 / ×10 / ×100 / PRÓG / MAX (przełącznik nad
  listą). PRÓG kupuje tyle sztuk, ile brakuje do następnego darmowego
  bonusu zegara (R-ULEP-1), a po ostatnim po jednej — jak „Next”
  w AdVenture Capitalist. Cena zbiorcza to suma ciągu geometrycznego.
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

- **R-ULEP-1:** Każdy generator ma 8 progów. Na każdym progu wszystkie
  sztuki tego generatora zarabiają więcej — za darmo, od razu, nic nie
  trzeba kupować. Prestiż zeruje sztuki, więc i bonusy. Droższe zegary
  mają niższe progi i mniejszy mnożnik, bo każdy próg (i jego śmieszna
  nazwa) ma być do zdobycia w pełnej grze:

  | Zegary | Progi (sztuki) | Mnożnik za próg | Razem |
  |---|---|---|---|
  | 1–6 (Dziadek … Sędzia) | 10, 20, 40, 75, 100, 115, 130, 150 | ×2 | ×256 |
  | 7–11 (Zegar dworcowy … Pulsar) | 10, 20, 30, 40, 50, 60, 70, 80 | ×1.7 | ×70 |
  | 12–14 (Maszyna czasu … Chronos) | 5, 10, 15, 20, 25, 30, 40, 50 | ×1.4 | ×15 |

  Playtest 27: dawne 200 i 250 sztuk nie padały nawet po 400 h bota
  (najwięcej 162 sztuki, ostatnie zegary 69–95). Niższe progi przy ×2
  wszędzie wpychały pełną grę w spiralę (ostatnie zegary 8 podwojeń
  zamiast 3–4, sufit gry ~2× wcześniej), stąd mniejsze mnożniki: przy
  10/20/40 sztukach dają mniej więcej tyle, co dawne ×2.
- **R-ULEP-2:** Każdy próg ma śmieszną nazwę w PL i EN (dawne nazwy
  ulepszeń), np. dziadek: „Okulary do czytania”, „Nowa bateria”,
  „Sanatorium”; pokazuje ją powiadomienie przy osiągnięciu progu.
- **R-ULEP-2a:** Pełna karta zegara (dotknięcie zegara w sklepie) pokazuje
  wszystkie 8 progów i synergie z tym zegarem. Zdobyte progi mają nazwę
  i śmieszny opis. Niezdobyte pokazują tylko liczbę sztuk i ×2, a zamiast
  nazwy „???”, żeby zdobycie było niespodzianką. Niewłączona synergia też
  ma „???” zamiast nazwy, ale mówi, co daje i ile sztuk brakuje
  (playtest 25: nazwy migały tylko w powiadomieniu).
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
| **Fart** / Lucky | 45% | natychmiast `600 s dochodu pasywnego` × siła (playtest 25: bez limitu 10% stanu konta — gracz wydaje na bieżąco, więc limit zjadał prawie cały Fart) |
| **Gorąca ręka** / Hot Hand | 10% | przez 60 s (× siła) każde trafienie, które nie jest pudłem, liczy się jako PERFEKT i płaci ×10 (playtest 25: samo „jak PERFEKT” dawało ~1 s dochodu) |

- **R-ZLOTA-4:** Aktywny efekt ma licznik z czasem do końca, widoczny przy
  zegarze. Efekty różnego typu mogą działać naraz. Ten sam typ przedłuża czas.
- **R-ZLOTA-5:** Złota Sekunda nie pojawia się offline ani w samouczku.
- **R-ZLOTA-6:** Złapany zegarek, latający zegarek oraz czas Szału
  i Gorącej ręki są w zapisie. Restart gry (aktualizacja, system zamknął
  grę) ich nie zabiera: złota runda czeka na następną rundę, także gdy
  restart przerwał ją w trakcie (playtest: po złapaniu zegarka
  i aktualizacji złota runda przepadała).
- **R-ZLOTA-7 (bilet rundy):** runda bierze przy starcie „bilet” i liczy
  się według niego do oceny (playtest: licznik Szału kończył się w trakcie
  rundy i brakowało chwili).
  - Runda, która wystartowała w czasie Szału albo Gorącej ręki, dostaje
    ten efekt także wtedy, gdy licznik dojdzie do 0 w trakcie rundy.
    Runda, która wystartowała po końcu efektu, go nie dostaje. Szał
    z biletu działa tylko na wypłatę za trafienie: dochód pasywny kończy
    się z licznikiem.
  - Złota runda należy do jednego zegara: do pierwszej rundy, która
    wystartowała po złapaniu zegarka. Tylko ona rozlicza efekt. Drugi
    zegar gra w tym czasie zwykłą rundę (wcześniej flaga była wspólna:
    złote mogły być obie tarcze, a efekt rozliczała ta, która skończyła
    pierwsza).
  - Przy dwóch zegarach każdy bierze bilet osobno, przy swoim starcie.
    Licznik nie stoi na 0:00, dopóki trwa runda: przy dwóch zegarach
    przesuniętych o pół rundy któraś runda trwa zawsze.
  - Oprawa: tarcza z biletem Szału zachowuje neonową poświatę, a z biletem
    Gorącej ręki ma pomarańczowy pierścień, do oceny rundy. Po 0:00 chip
    efektu zostaje przygaszony z napisem „ostatnia runda”, aż ostatnia
    runda z biletem zostanie oceniona. Tło i muzyka Szału trwają tak samo.
    Trafienie, które dostało efekt po końcu licznika, pokazuje „NA STYK!”.
  - Zapas to najwyżej jedna runda na zegar (3.7–5.7 s). Bilet nie jest
    w zapisie: runda przerwana restartem i tak się nie liczy.

## 7. Tryby ryzyka

Tryby to przełączniki obok zegara, odblokowywane osiągnięciami. Działają tylko
na wypłatę z dotknięć gracza.

| Tryb | Odblokowanie | Działanie | Mnożnik wypłaty |
|---|---|---|---|
| **Na ślepo** / Blind | 100 PERFEKTÓW łącznie | w losowym momencie między 3.60 a 4.20 czasu gry (losowany co rundę, `hideDigitsAt`…`hideDigitsTo`) znikają cyfry i pasek postępu wokół tarczy (zostaje pulsujące „?”); stały moment 4.00 sam był wskazówką „odlicz sekundę”, teraz trzeba zapamiętać ostatnią liczbę i odliczyć inny czas; milknie bicie serca i nie pojawia się winieta Zimnej krwi; Tykanie (kupiona pomoc) działa dalej (playtest 22: pasek zdradzał czas) | ×3 |

Szybki zegar (stoper ×1.5) został usunięty po teście na telefonie: sekunda
na stoperze ma zawsze być prawdziwą sekundą (zob. 1.1).

- **R-TRYB-1:** Zmiana trybu działa od następnej rundy. Wyjątki dotyczą Na ślepo:
  wyłączenie działa od razu (zegar wraca, runda płaci bez mnożnika), a
  włączenie przed 4.00 czasu gry działa od razu, z mnożnikiem, bo gracz nie
  widział jeszcze niczego, co tryb ukrywa. Włączone po 4.00 czeka na następną
  rundę, a przełącznik pokazuje wtedy „od następnej rundy” (testerowi wyglądało
  to tak, jakby trzeba było kilku rund, zanim tryb zadziała).

## 8. Osiągnięcia

- **R-OSIAG-1:** Każde osiągnięcie daje **+1%** do globalnego mnożnika
  (sumowane: 50 osiągnięć to +50%). Ma ikonę-odznakę, nazwę i opis PL/EN.
  Zdobycie pokazuje toast z fanfarą.
- **R-OSIAG-2:** Lista, ok. 175 sztuk (w tym 28 tytułów mistrzowskich za poziomy zegarów, §15) (po playteście 25 dołożone kategorie wzorowane na Cookie Clickerze: dochód na sekundę, łączna liczba budynków i ulepszeń, liczba kliknięć, wyzwanie „Neverclick”, osiągnięcia za osiągnięcia):

| Kategoria | Progi | Liczba |
|---|---|---|
| Zarobione łącznie | 1K, 1M, 1B, 1T, 1aa, 1ab, 100ab, 1ac | 8 |
| Posiadane sztuki generatora | zegary 1–6: 1, 50, 100, 180; zegary 7–11: 1, 25, 60, 120; zegary 12–14: 1, 25, 50, 100 | 56 |
| PERFEKTY łącznie | 1, 10, 100, 1K, 10K, 100K | 6 |
| PERFEKTY z rzędu | 3, 5, 10 | 3 |
| Najwyższy mnożnik | ×1.50, ×2.00, ×2.75 (pełne Combo) | 3 |
| Złapane Złote Sekundy | 1, 10, 50, 200, 500 | 5 |
| Prestiże | 1, 5, 10, 25, 50 | 5 |
| Tryby | PERFEKT na ślepo; PERFEKT na ślepo przy mnożniku ×1.50+; przy pełnym mnożniku (wystarczy PERFEKT, nie równe 5.00) | 3 |
| Wydarzenia sezonowe | po jednym na włączone wydarzenie (§14) | 2 |
| Równo 5.00 na tarczy (PERFEKT w oknie jackpotu, błąd < 0.010 s) | 1, 100, 1K, 10K | 4 |
| Zagrane rundy | 100, 1K, 10K, 100K | 4 |
| Dochód pasywny na sekundę (bez Szału i Turbo) | 1K, 1M, 1B, 1T, 100T, 1aa | 6 |
| Zegary łącznie | 100, 500, 1000, 2000 | 4 |
| Poziomy umiejętności łącznie | 25, 50, 100 | 3 |
| PERFEKTY na ślepo łącznie | 10, 100, 1K | 3 |
| Czas gry | 1 h, 10 h, 100 h | 3 |
| Zdobyte osiągnięcia | 25, 50, 100 | 3 |
| Odebrane dzienne premie | 7, 30, 100 | 3 |
| Mnożnik uratowany Tarczą | 10, 100 | 2 |
| Wyczyny | „Refleks” (Złota Sekunda złapana do 1 s od pojawienia się), „Złoto do złota” (w trakcie Szału), „Pełny tydzień” (7. dzień premii), „Sen zimowy” (powrót po przerwie dłuższej niż limit offline), „Obie ręce” (PERFEKT na jednym zegarze zaraz po PERFEKCIE na drugim), „Władca czasu” (wszystkie perki), „Bez rąk” (1M Tików w jednym przejściu przy najwyżej 15 trafieniach, wzór: Neverclick z Cookie Clickera) | 7 |
| Tytuły mistrzowskie (§15) | poziom 5 i 10 każdego zegara, nazwa i żart na każdy | 28 |
| Ukryte / śmieszne | „Niecierpliwy” (100× ZA WCZEŚNIE), „Drzemka” (10 rund z rzędu bez dotknięcia), „Prawie” (4.99, a potem 5.01), „Punktualny” (PERFEKT o 5:00 albo 17:00, czas lokalny), „Piątka” (10× PERFEKT 5. dnia miesiąca), „Pełna kolekcja” (wszystkie umiejętności na max), „Muzeum” (1 sztuka każdego generatora), „Jajko na miękko” (74 babcie: minutnik z siedemdziesiątego czwartego; nie pokrywa się z progami babci 1, 50, 100, 180), „Kopciuszek” (PERFEKT o północy), „Uparty” (1000 pudeł), „Zegar atomowy” (połowa z ostatnich 100 trafień w granicach 15 ms, czyli w oknie PERFEKT; liczy dopiero przy pełnych 100 trafieniach) | 11 |

- **R-OSIAG-2b:** Każde osiągnięcie ma być osiągalne. Sprawdza to
  `tool/achievement_report.dart`: bot gra kolejne 8-godzinne przejścia,
  kupuje perki za Okruchy i robi paradoks na końcu każdego. Gra bez
  dochodu offline i premii z osiągnięć, więc jest wolniejszy od gracza.
  Wyniki (σ = 30 ms):

  | Czas gry | Dochód pasywny/s | Zegary łącznie | Zarobione łącznie | Rundy |
  |---|---|---|---|---|
  | 8 h | 25.4M | 484 | 1.1T | 7.3K |
  | 80 h | 1.13B | 632 | 238T | 76K |
  | 160 h | 70.2B | 785 | 8.9aa | 153K |
  | 240 h | 1.13aa | 1762 | 636ab | 231K |
  | 400 h | 4.25aa | 1921 | 14.8ac | 386K |

  (Playtest 27: progi bonusów zegarów z R-ULEP-1 i Start później do 2 s.)
  Po ok. 240 h przyrost się wypłaszcza: wszystkie perki są kupione,
  a Chronony rosną z pierwiastkiem sześciennym. Stąd górne progi:
  1aa/s (~240 h bota), 1500 zegarów (~230 h), 1ac zarobione (~255 h).
  Raport wypisuje też, ile sztuk każdego zegara bot miał naraz: po 400 h
  co najmniej 165 z zegarów 1–6, 106 z 7–11 i 79 z 12–14, więc ostatnie
  progi bonusów (150 / 80 / 50) padają. Ten bot gra bez dochodu offline,
  więc mocno zaniża późną grę: progi sztuk i zegarów łącznie ustawia
  teraz R-OSIAG-2c na realistycznym graczu.
  Dawne 1ab/s, 2000 zegarów, 1e24–1e30 zarobionych i 200 sztuk ostatnich
  zegarów były nieosiągalne i zostały obniżone. Mediana błędu bota wynosi
  ok. 21 ms przy σ = 30 ms i 11.5 ms przy σ = 15 ms, stąd 15 ms dla Zegara
  atomowego.
- **R-OSIAG-2c (wyzwanie, nie czekanie; 11.2026):** najwyższe progi
  sztuk i zegarów łącznie mają wymagać zostania w jednej pętli ok. tydzień
  po Chronosie, ale nie dni czekania na jedną sztukę. Sprawdza to
  `tool/achievement_timeline.dart` (gracz z `late_game_report.dart`: sesje,
  offline, paradoksy, perki, Sprężyny, pętle). Dzień, w którym gracz
  zostający w pętli pierwszy raz ma tyle sztuk (3 × 11 min / 4 × 25 min /
  2 × 5 min dziennie):

  | Zegary | dawny próg | nowy próg | zaczyna się czekanie |
  |---|---|---|---|
  | 1–6 | 150: dzień 15 / 11 / 23 | **180: 19–23 / 13–18 / 26–31** | 210: 50 / 36 / 55; 225: 80–140 |
  | 7–11 | 80: 12–15 / 8–11 / 17–23 | **120: 14–20 / 10–16 / 20–30** | 144: 15–46; 160: 17–66 |
  | 12–14 | 50: 14–15 / 10 / 20–22 | **100: 20 / 14–16 / 26–29** | 125: 34–49 |
  | łącznie | 1500: 15 / 11 / 23 | **2000: 19 / 13 / 26** | 2500: 52 / 41 / 59 |

  Pierwszy Chronos pada ok. 13.–15. dnia (3 × 11 min), więc dawne górne
  progi padały razem z nim, w pierwszej pętli. Gracz, który po bonusach
  Chronosa od razu zaczyna nową pętlę, nie przekracza ok. 142 / 96 / 61
  sztuk — górne progi wymagają decyzji, żeby zostać. Progi bonusów zegarów
  (R-ULEP-1: 150 / 80 / 50) zostają: to ekonomia, nie osiągnięcia.
  Zdobyte osiągnięcia ze zmienionych progów znikają przy wczytaniu (jak
  przy poprzedniej zmianie progów).
- **R-OSIAG-2a:** Razem osiągnięcia mogą dać do ok. +150% do `G`.
  Symulator tempa ich nie liczy (03), więc prawdziwa gra jest nieco
  szybsza niż cele B-x. Nowe dotyczą głównie późnej gry.
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
  umiejętności (poza tym, co zachowują Pamięć mięśniowa i Nawyk,
  R-PRES-5a/5b), combo i aktywne efekty.
  **Zostają:** Chronony, Okruchy, perki, wybrane Nawyki, osiągnięcia,
  statystyki, odblokowane tryby i ustawienia.
- **R-PRES-5a:** Pamięć mięśniowa I/II/III: po paradoksie każda umiejętność
  zachowuje **50% / 65% / 80%** swoich poziomów, zaokrąglone (połówka
  w górę). Wcześniej był to stały próg „do 4 / 6 / 8 poziomu”. Zmiana po
  playteście: poziomy powyżej 8 (np. drogiej Siły trafienia kupowanej
  jako inwestycja w następny start) przepadały w całości. Teraz im wyżej
  gracz zainwestuje, tym więcej zostaje. Karta umiejętności pokazuje kłódkę
  z liczbą zachowanych poziomów, a szczegóły mówią, ile zostanie (albo że
  bez perku wszystko wraca do zera).
- **R-PRES-5b:** Nawyk I/II (wzór: „stałe sloty na ulepszenia” w Cookie
  Clickerze): każdy daje slot na **jedną wybraną umiejętność, która
  zachowuje po paradoksie wszystkie poziomy**. Wybór jest w szczegółach
  umiejętności („Zachowaj w całości”). Można go zmienić w każdej chwili
  i liczy się dopiero przy paradoksie. Gdy sloty są zajęte, nowy wybór
  wypycha najstarszy. Wybrane umiejętności mają na karcie pinezkę zamiast
  kłódki.
- **Symulacja** (tool/prestige_report.dart, 3 przejścia po 6 h, czas, po
  którym drugie przejście dogania całe pierwsze): bez perku 4.4 h,
  50/65/80% 4.25/4.07/3.90 h, 80% + Nawyk I/II 3.72/3.48 h, wszystko
  zostaje 3.26 h (dawne „do 4/6/8” 4.18/3.92/3.55 h). Cały zestaw daje tyle
  co dawna Pamięć III, ale sam procent jest słabszy, bo tanie dolne poziomy
  i tak szybko się odkupuje. Zachowanie wszystkiego skraca przejścia
  o ok. 35%, ale wtedy od drugiego przejścia nie ma już w co inwestować,
  więc żaden zestaw perków nie zachowuje wszystkiego.
- **R-PRES-6:** Prestiż wymaga podwójnego potwierdzenia i ma spektakularną
  animację („przewinięcie czasu” wstecz).
- **R-PRES-6a:** Po animacji gracz dostaje Chronony i Okruchy, ale run
  resetuje się dopiero po „Zacznij nową grę” (albo zamknięciu ekranu).
  W międzyczasie Okruchy z tego paradoksu kupują perki, które od razu
  działają w nowej grze (Pamięć mięśniowa, Szybki start).
  Zamknięcie aplikacji w tym momencie kończy reset przy następnym starcie
  (playtest 22).

### 9.1 Perki (drzewko „Paradoks”)

| id | Nazwa | Koszt (Okruchy) | Działanie | Wymaga |
|---|---|---|---|---|
| `headStart` | Szybki start | 5 | start runu z 10 dziadkami i 1K Tików | – |
| `muscleMemory1` | Pamięć mięśniowa I | 10 | każda umiejętność zachowuje po paradoksie 50% poziomów | – |
| `muscleMemory2` | Pamięć mięśniowa II | 50 | …65% poziomów | I |
| `muscleMemory3` | Pamięć mięśniowa III | 250 | …80% poziomów | II |
| `habit1` | Nawyk I | 40 | slot: jedna wybrana umiejętność zachowuje wszystkie poziomy (R-PRES-5b) | – |
| `habit2` | Nawyk II | 150 | drugi slot | I |
| `longNap1` | Długa drzemka I | 10 | limit offline 12 h | – |
| `longNap2` | Długa drzemka II | 40 | limit offline 24 h | I |
| `deepSleep1` | Głęboki sen I | 20 | offline 75% wydajności | – |
| `deepSleep2` | Głęboki sen II | 80 | offline 100% wydajności | I |
| `goldRush` | Gorączka złota | 15 | Złota Sekunda pojawia się częściej (interwał ×0.85) | – |
| `shieldRecharge` | Szybka Tarcza | 20 | ładunek Tarczy co 7 trafień zamiast co 10 (playtest 25; zastąpił „Tarczę na start”, która nic nie dawała przy Pamięci mięśniowej) | – |
| `comboFloor` | Twarde lądowanie | 40 | pudło zrzuca mnożnik do 5 kroków (×1.25), nie do 0 | – |
| `autoBuyer` | Automatyczny kupiec | 30 | przełącznik: kupuje zegar wskazany przez gracza, jeden co 5 s, do jego najbliższego progu (§9.3) | – |
| `daredevil` | Śmiałek | 10 | Na ślepo płaci ×4 zamiast ×3 (playtest 25; wcześniej odblokowywał tryb, który i tak był odblokowany przed pierwszym paradoksem) | – |
| `unlockSchrodinger` | Pudełko z kotem | 25 | odblokowuje generator 13 | – |
| `secondClock` | Drugi zegar | 100 | patrz 9.2 | – |
| `unlockChronos` | Ołtarz Chronosa | 500 | odblokowuje generator 14 | `unlockSchrodinger` |

### 9.2 Drugi zegar

- **R-DRUGI-1:** Z perkiem `secondClock` gracz może włączyć drugi zegar. Ekran
  dzieli się na lewą i prawą połowę, każda z własnym stoperem. Prawy startuje
  pół rundy później.
- **R-DRUGI-2:** Każda połowa oceniana jest osobno, według własnego czasu.
  Combo jest wspólne. Zimna krew i Start później działają na oba zegary.

### 9.3 Automatyczny kupiec

- **R-AUTO-1:** Z perkiem `autoBuyer` w pasku trybów jest przycisk
  auto-kupca. Gracz wskazuje w arkuszu jeden zegar spośród tych, które
  pokazuje sklep. Kupiec kupuje go po jednej sztuce co `intervalSeconds`
  (5 s), póki starcza Tików, aż do najbliższego progu (R-ULEP-1); gdy
  zegar ma już wszystkie progi — 10 sztuk więcej. Potem staje i czeka.
- **R-AUTO-2:** Gra niczego nie podpowiada: wybór zegara należy do gracza.
  Symulacja (`tool/autobuyer_sim.dart`): dawny kupiec „najtańszy zegar”
  dawał mniej niż brak perka (wydawał Tiki na najgorsze zegary), a kupiec
  „najbardziej opłacalny” grał za gracza (68–94% wyniku bez zaglądania do
  sklepu). Kupiec bez zatrzymania na progu kupował dalej zegar, który już
  się nie opłacał.
- **R-AUTO-3 (przycisk):** wyłączony — „Auto-kupiec”; kupuje — zielony,
  ikona zegara i postęp `34/40`; czeka — pomarańczowy, `✓ 40 · wybierz`,
  z czerwoną kropką, aż gracz wybierze. Przy samym zatrzymaniu nie ma
  osobnego komunikatu ani dźwięku: zatrzymania zdarzają się co 2–5 min.
- **R-AUTO-4 (przypomnienie):** jeśli kupiec czeka `remindAfterSeconds`
  (75 s), przycisk raz pulsuje (nie przy „Ogranicz ruch”), potem już nic
  do następnego zatrzymania. Symulacja: reakcja w ciągu ~30 s daje
  przy zaglądaniu co 2 min +60% zarobku, reakcja po 2 min — nic.
- **R-AUTO-5:** Dotknięcie przycisku otwiera arkusz: gdy kupiec czeka,
  pierwszy jest przycisk „Dalej: <zegar> → <następny próg>”; niżej lista
  zegarów z `posiadane → cel` (wybrany podświetlony) i „Wyłącz”. W sklepie
  pasek progu wybranego zegara ma ikonę wózka. Paradoks i nowa pętla
  kasują wybór.

## 10. Dochód offline

- **R-OFF-1:** Po powrocie, jeśli gracza nie było ≥60 s: dochód =
  `P_bez_efektów · min(czas_nieobecności, limit) · wydajność`. Domyślnie limit
  8 h i wydajność 50% (perki zmieniają oba).
- **R-OFF-2:** Okno „Gdy cię nie było…” pokazuje kwotę i animację wsypywania
  Tików. W M6 dochodzi przycisk „×2 za reklamę”. Gdy czeka też dzienna
  premia (R-DZIEN-1), oba są w jednym oknie „Witaj z powrotem!” z jednym
  przyciskiem „Odbierz wszystko” (×2 za reklamę dotyczy części offline);
  nowe wydarzenie sezonowe dostaje w nim jedną linijkę zamiast własnego
  okna (R-SEZ-4). Wcześniej przy powrocie wyskakiwały nawet cztery okna
  po kolei.
- **R-OFF-2a:** Kwota z okna jest w zapisie, dopóki gracz jej nie odbierze.
  Zamknięcie aplikacji nad oknem niczego nie kasuje: przy następnym
  otwarciu okno wraca, a nowa nieobecność dolicza się do niego (razem
  najwyżej do limitu offline). Playtest 23: kwota przepadała.
- **R-OFF-3:** Ochrona przed cofnięciem zegara telefonu: ujemny czas
  nieobecności daje 0. Czas offline jest zawsze przycinany do limitu.
- **R-OFF-4:** Przy wyjściu z gry planowane jest lokalne powiadomienie na
  moment, gdy dochód offline dojdzie do limitu: „Twoje zegary uzbierały
  2,4M Tików!” i „Limit offline jest pełny: dalsze czekanie nic już nie
  dorzuci.” Kwota jest liczona przy wyjściu. Powrót do gry albo ponowne
  wyjście anuluje stare przypomnienia i planuje nowe. Inne przypomnienia
  i limity: R-POW-1…3.
- **R-OFF-5:** O zgodę na powiadomienia (Android 13+) gra pyta dopiero przy
  pierwszym oknie „Gdy cię nie było…”, z jednym zdaniem wyjaśnienia,
  a nie przy starcie. Odmowa nic nie psuje. Powiadomienia da się wyłączyć
  w ustawieniach gry (jeden przełącznik), a każdy rodzaj osobno
  w ustawieniach Androida (osobne kanały).

### 10.1 Przypomnienia (R-POW)

Tylko rzeczy, na które gracz może coś zrobić; mało i nie w nocy.

- **R-POW-1 (pełny zapas dokręcania):** po pierwszym paradoksie, gdy przy
  wyjściu zapas dokręcania (R-SPR-3) jest zużyty co najmniej w połowie
  i napełnia się co najmniej 30 min: „Zapas dokręcania pełny — równe 5.00
  znów nakręcają Sprężynę — każde o 30 min”.
- **R-POW-2 (dzienna premia):** gdy dzisiejsza premia jest odebrana,
  a seria ma co najmniej 2 dni: jutro o 18:00 „Dzienna premia czeka —
  dzień 5/7”.
- **R-POW-3 (zasady):** najwyżej **2 przypomnienia na jedną nieobecność**,
  co najmniej 3 h odstępu, nigdy między 22:00 a 9:00 (czas lokalny; takie
  czeka do 9:00). Przy kolizji wygrywa ważniejsze: limit offline, dzienna
  premia, zapas dokręcania. Każde wyjście planuje je od nowa, powrót
  anuluje wszystkie.

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
  4. Po zakupie (bez przyciemnienia — gracz dalej gra): dymek przy
     liczniku „/s”: „Dziadek sam dorzuca Tiki: +0,1 na sekundę, także gdy
     nie grasz.” Zamyka się przyciskiem OK albo następnym zakupem — nie
     sam (testerzy: dymek znikał po 7 s, zanim ktoś go przeczytał, i nie
     mówił, czego jest „/s”).
  5. Po OK: dymek na arenie „Od teraz stoper startuje sam: po każdym
     wyniku od razu rusza kolejna runda.” (OK).

  Przez cały samouczek runda **nie startuje sama** (wyjątek od
  R-RUNDA-6): po wyniku zegar czeka na dotknięcie, żeby gracz mógł
  przeczytać dymek, zanim poleci następna runda (playtest: nowa runda
  startowała razem z przyciemnieniem i dymkiem). To samo przy powtórce
  samouczka z pomocy. Obwódka celu: ciemna linia na białej poświacie,
  widoczna na żółtym tle (licznik Tików) i na białych kartach.

  Koniec samouczka. W jego trakcie nie ma znaczka wydarzenia, czerwonych
  kropek ani Złotej Sekundy (jedna nowa rzecz naraz).
- **R-TUT-2:** Wskazówki o nowych rzeczach, każda raz, przypięta do swojej
  rzeczy: pasek bonusu na karcie Dziadka (gdy gracz ma 3 Dziadki, przed
  pierwszym ×2), pierwsza umiejętność,
  na którą stać gracza (zakładka), pierwszy przełącznik trybu, Złota
  Sekunda (gdy leci), seria (licznik combo), prestiż (wir), Sprężyny
  (plakietka w nagłówku, po pierwszym paradoksie; znika po otwarciu
  Sprężyn), nowa pętla (wir, raz — w pierwszej pętli po Chronosie, z nazwą
  zasady Chronosa; znika po otwarciu paradoksu), wyzwania (plakietka,
  gdy pojawią się pierwszy raz, §18; znika po otwarciu wyzwań).
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
- **R-TUT-0 (prolog):** zaraz po pierwszych Tikach nowej gry (bez
  paradoksu i ukończonej pętli), gdy minie wynik tej rundy, jedno okno
  z prologiem. Wcześniej był przed pierwszą rundą: pierwsze sekundy gry
  to teraz zegar i pierwsze dotknięcie, a historia czyta się lepiej
  z pierwszym Tikiem w kieszeni. Przed pierwszym dotknięciem nie ma
  żadnego okna — także zgody na reklamy ani statystyki: o nie gra pyta
  dopiero po samouczku (05 T-26, T-33). Prolog: Dziadek spóźnia się
  siedem minut na podwieczorek u Babci i postanawia zdobyć zegar, który
  się nie myli — Chronosa (docs/16). Scena gra dymek po dymku (04 U-33a),
  na końcu cel jednym zdaniem: „Cel: zdobądź Chronosa”. Pokazuje się
  raz; prolog jest też pierwszym wpisem rozdziałów w Kronice (zawsze
  otwarty). Playtest: fabuła zaczynała się dopiero po pierwszej pętli, więc
  nic nie mówiło, do czego gra prowadzi.
- **R-TUT-5:** Przycisk „?” w nagłówku otwiera „Jak grać”: zwijana lista
  (cel gry, runda, Tiki, zasoby, zegary, seria, bonusy zegarów,
  umiejętności, Złota Sekunda, wyzwania, przełączniki, wydarzenia, paradoks,
  Sprężyny, pętla czasu, tarcze, ikony nagłówka) — same tytuły,
  dotknięcie rozwija opis — plus „Pokaż samouczek od nowa”. Opisy krótko
  tłumaczą, jak działa system, nie doradzają strategii. Sekcje o rzeczach,
  których gracz jeszcze nie spotkał (przełączniki przed odblokowaniem,
  paradoks przed pierwszą możliwością cofnięcia, Sprężyny, pętla, tarcze,
  wydarzenia poza sezonem), są zakryte: kłódka i „???”, a pod nimi „Graj
  dalej, aby odblokować nowe mechaniki”. Sekcja „Zasoby” wymienia tylko
  zasoby już spotkane.
- **R-TUT-5a (powtórka):** „Pokaż samouczek od nowa” pokazuje wszystkie
  cztery kroki także graczowi, który ma już zegary: kroki nie wynikają
  wtedy ze stanu gry, tylko idą po kolei, każdy z przyciskiem OK (krok 1
  przechodzi też po dotknięciu, krok 3 po zakupie; krok 2 mówi „To twoje
  Tiki. Wydajesz je na zegary.”). Gra w tym czasie niczego nie chowa
  i niczego nie zapisuje. Gracz bez Dziadka dostaje zwykły pierwszy
  samouczek. Arkusze („Jak grać”, ustawienia…) kończą się nad systemowym
  paskiem nawigacji, żeby jego przyciski nie zasłaniały ostatniego wiersza.
- **R-TUT-7 (następny cel):** po samouczku, do pierwszego paradoksu, nad
  sklepem jest jeden pasek z celem i postępem (wypełnienie paska):
  najpierw pierwszy bonus Dziadka („Cel: Dziadek z zegarkiem 3/10 → ×2”),
  potem każdy kolejny zegar, którego gracz jeszcze nie ma („Cel: nowy
  zegar — Babcia z minutnikiem”, postęp = Tiki do ceny). Dotknięcie
  otwiera zakładkę Zegary. W samouczku paska nie ma. Pierwszy paradoks
  nie jest celem (1 Chronon niewiele daje, gracz sam wybiera moment):
  gdy staje się dostępny, dymek przy wirze mówi, że można cofnąć czas,
  że Chronony na stałe przyspieszają dochód, a perki za Okruchy zostają
  po każdym resecie. Ten dymek nie znika sam — czeka na zamknięcie albo
  otwarcie ekranu paradoksu.
- **R-TUT-7b (bez podpowiadania momentu paradoksu):** pasek celu nigdy
  nie wskazuje paradoksu („cofnij czas”). Gracz sam decyduje, kiedy
  paradoks się opłaca, i sam odkrywa, że Okruchy na klucz do zegara daje
  właśnie paradoks. Dymek przy wirze (R-TUT-7) zostaje bez zmian: pojawia
  się, gdy tylko paradoks jest możliwy, bo uczy, że taka opcja istnieje.
- **R-TUT-7a (cel przez całą grę):** pasek zostaje na całą grę (13 §5.5)
  i pokazuje tylko drogę do Chronosa, celu pętli (R-PETLA-1). Nigdy nie
  wskazuje innych perków. Zawsze jeden cel, w tej kolejności:
  1. przed pierwszym paradoksem: pierwszy bonus Dziadka (R-TUT-7);
  2. następny zegar, którego gracz w tym przejściu jeszcze nie ma
     („Cel: nowy zegar — …”);
  3. gdy gracz ma już każdy dostępny zegar, a następny wymaga perku:
     „Cel: odblokuj 13. zegar — 12/25 Okruchów”. Pasek wypełniają Okruchy
     (liczą się też te, które dałby paradoks teraz). Nazwy perku ani
     zegara pasek nie podaje. Po kupnie kota tak samo: „Cel: odblokuj
     14. zegar — …/500 Okruchów” (Ołtarz Chronosa);
  4. po kupnie Chronosa (cel pętli osiągnięty): „Cel: nowa pętla —
     kolejny rozdział”, a po całej historii (R-PETLA-8) „Cel: nowa pętla”.

  Cel z kluczem do zegara otwiera ekran paradoksu, cel nowej pętli —
  Kronikę, pozostałe — zakładkę Zegary.
- **R-TUT-7c (zegar za perkiem):** gdy gracz ma każdy zegar przed
  zegarem wymagającym perku, sklep pokazuje na końcu listy jego kartę
  z kłódką: sylwetka, „???”, „Zamknięty — klucz znajdziesz wśród perków
  paradoksu”. Dotknięcie otwiera ekran paradoksu. Zegary dalej (Chronos
  przed kupnem kota) zostają niewidoczne. Wcześniej taki zegar w ogóle się
  nie pokazywał i gracz nie wiedział, że perk „Pudełko z kotem” coś
  w sklepie otwiera (playtest).
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
  po samouczku, gra pokazuje okno „Dzienna premia” z serią 7 dni (razem
  z dochodem offline, jeśli jest, R-OFF-2).
- **R-DZIEN-2:** Dzień N płaci `max(25·N, dochód pasywny × minuty[N])`,
  gdzie minuty = 5, 10, 15, 20, 30, 45, 60. Po 7. dniu seria wraca do 1.
  7. dzień daje też **1 Sprężynę** (`daily.lastDaySprings`), gdy Sprężyny
  już są (po pierwszym paradoksie, R-SPR-1), także ponad limit magazynu
  (R-SPR-4). Wcześniej 7. dzień płaci samą walutę, a kafelek nie zapowiada
  nagrody, której gracz nie mógłby dostać. Cykl ma przez to finał, więc
  powrót do dnia 1 czyta się jak nowy tydzień, a nie strata; waluta
  tygodnia zostaje ta sama (185 min dochodu pasywnego).
- **R-DZIEN-3:** Pominięty dzień (kalendarzowy, czas lokalny) zaczyna serię
  od 1 — z wyjątkiem **dnia łaski**: jeden pominięty dzień na tydzień
  (7 odbiorów) seria wybacza, a okno mówi „Ominął cię jeden dzień —
  dzień łaski tego tygodnia uratował serię”. Dwa pominięte dni z rzędu
  albo drugi pominięty dzień w tym samym tygodniu zaczynają od 1. Nowy
  tydzień (dzień 1) przywraca dzień łaski. Bez reklam przy tym oknie.

## 12. Statystyki

- **R-STAT-2 (mnożniki dochodu):** Na górze ekranu statystyk jest lista
  wszystkiego, co mnoży dochód, zawsze jako mnożnik, żeby dało się
  porównać źródła (13 §5.5): Chronony („×9,74”), osiągnięcia, poziomy
  zegarów (łączny efekt na zegary, które gracz teraz ma; po pierwszym
  paradoksie), Turbo (gdy działa) i „Razem”. Ekran paradoksu też mówi
  mnożnikiem: „Chronony: 437 · dochód ×9,74”, a przy możliwym paradoksie
  „Dochód ×9,74 → ×13”. Wcześniej było „+874% na zawsze”, przy którym
  „+10%” poziomu zegara wyglądało na nic niewarte.
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
| `adRescue` | Ratunek combo / Combo Rescue | wyskakuje od razu po utracie mnożnika ×1.75 lub wyższego (15 kroków) | przywraca mnożnik sprzed pudła | raz na 15 min; okno znika po 5 s albo przy następnym dotknięciu |
| `adGolden` | Złota Sekunda / Golden Second | przycisk przy zegarze | Złota Sekunda pojawia się od razu | raz na 30 min |
| `adSpring` | Napełnij / Refill | warsztat Sprężyn, gdy zapas dokręcania jest pusty | zapas dokręcania znów pełny (2 h, R-SPR-3b); po reklamie trzeba jeszcze trafić „równo 5.00” | 2 razy na lokalną dobę; po pierwszym paradoksie |

- **R-AD-1:** Czasy odnowienia liczone są w czasie rzeczywistym (także gdy
  gra jest zamknięta), z wyjątkiem Turbo, którego zapas maleje tylko podczas
  gry.
- **R-AD-2:** Turbo wchodzi do globalnego mnożnika `G` (03 §2), więc działa
  na generatory, trafienia, Echo i Fart. **Nie** działa na dochód offline,
  bo od tego jest `adOffline`.
- **R-AD-3:** Nagroda trafia do gracza tylko po pełnym obejrzeniu (callback
  „reward earned” z SDK). Przerwana albo nieudana reklama oznacza brak
  nagrody, brak kary i brak zużycia czasu odnowienia. Załadowana reklama
  jest wymieniana po 55 min (AdMob uznaje ją za ważną ok. godziny).
- **R-AD-4:** Przycisk niedostępnej oferty (czas odnowienia, brak reklamy,
  brak sieci) pokazuje powód i czas do dostępności. Gra nigdy nie czeka na
  załadowanie reklamy (T-27).
- **R-AD-5:** Oferty pojawiają się dopiero po samouczku i po pierwszych
  5 minutach gry. Pierwsze wrażenie ma być „bez reklam”.
- **R-AD-6:** Brak reklam przy starcie aplikacji i przy wychodzeniu z niej.
  Nie ma też żadnej reklamy, której gracz sam nie wybrał. Formularz zgody
  na reklamy (UE) pokazuje się po samouczku, nie przy starcie (05 T-26).
- **R-AD-7:** Przed reklamą gracz widzi ofertę: co dostanie (konkretnie, np.
  „×2 Tików przez 30 min”, kwota Worka), że to krótka reklama wideo
  z nagrodą po obejrzeniu do końca, oraz przyciski „▶ Obejrzyj” i „Nie
  teraz” (zasady AdMob: nagroda i wymagane działanie ujawnione przed każdą
  reklamą, osobna zgoda na każdą). Ratunek combo i „Podwój” offline mówią
  to na samym przycisku („▶ … za reklamę”), bo już są ofertą.
- **R-AD-8:** Po reklamie komunikat potwierdza nagrodę („Turbo włączone!
  ×2 jeszcze przez 30:00”) albo jej brak („Reklama nie została obejrzana
  do końca — bez nagrody”). Reklama, która się nie wyświetliła (błąd sieci,
  przeterminowana), mówi „Nie udało się wyświetlić reklamy — bez nagrody,
  ale oferta na ciebie czeka”: gracz nic nie zrobił źle.
- **R-AD-9:** Na czas okna oferty i samej reklamy **czas gry stoi**. Szał,
  Gorąca ręka, zapas Turbo, złoty zegar na ekranie, czas do następnej
  Złotej Sekundy i dochód pasywny czekają na gracza. Reklama ani czytanie
  oferty nie zabierają aktywnego bonusu (playtest: Szał przepadał
  w trakcie reklamy Turbo). Gra tylko stoi, bez kary i bez nagrody, tak jak
  pauza (R-RUNDA-8a).

## 14. Wydarzenia sezonowe

Wzór: sezony Cookie Clickera. Gra sama włącza wydarzenie według lokalnej
daty telefonu — bez serwera i bez stałych kosztów — i każde wraca co roku.
Daty i cel są w `balance.json` (`seasons`).

**Na razie włączone są tylko `christmas` i `newYear`** (decyzja z listopada
2026). Pozostałe wydarzenia z tabeli są wyjęte z `balance.json`, ale ich
wygląd i teksty zostały w kodzie: żeby je przywrócić, wystarczy dopisać
ich wpisy (daty poniżej) z powrotem do `seasons.list`.

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
- **R-SEZ-4:** Przy pierwszym uruchomieniu w czasie wydarzenia gra mówi
  o nim: linijką w oknie „Witaj z powrotem” (R-OFF-2), a gdy tego okna nie
  ma — własnym oknem wydarzenia. Potem otwiera je plakietka w nagłówku
  z postępem („2/5 · 31/50”).
- **R-SEZ-5:** Motyw: „Sezonowy” (domyślny, zmienia się z wydarzeniami),
  „Klasyczny” albo motyw ukończonego wydarzenia.
- **R-SEZ-6:** Panel diagnostyczny (T-12) ma podgląd każdego wydarzenia bez
  zmiany daty; postęp innych wydarzeń zostaje zapamiętany.

## 15. Sprężyny, mistrzostwo zegarów i tarcze (późna gra)

Skąd i dlaczego: [12-pozna-gra.md](12-pozna-gra.md). Wzór: kostki cukru
w Cookie Clickerze. Liczby w pliku balansu (`springs`, `dials`).

- **R-SPR-1:** Sprężyny pojawiają się z pierwszym paradoksem; ten paradoks
  daje od razu 1 Sprężynę na próbę. W nagłówku jest plakietka: spirala
  z pierścieniem nakręcania i liczba gotowych Sprężyn. Gdy stać gracza na
  jakiś poziom, plakietka jest złota. Dotknięcie otwiera warsztat (lista
  kupionych kiedykolwiek zegarów z poziomami).
- **R-SPR-1a:** Plakietka mówi też, co da następne „równo 5.00”, bez
  wchodzenia do warsztatu. Pod liczbą Sprężyn są 4 kropki (2 rzędy po
  2): jedna kropka to 30 min zapasu, czyli jedno trafienie (R-SPR-3).
  Złota kropka to trafienie, które jeszcze się liczy, pusta to zużyte.
  Pusty zapas: wszystkie kropki puste,
  spirala przygaszona. Pełny magazyn (R-SPR-4): zamiast kropek napis
  „MAX”. Bez animacji ciągłej, żeby nie rozpraszać przy celowaniu.
  Plakietka nie jest przez to szersza, więc nagłówek się nie zmniejsza.
- **R-SPR-2:** 1 Sprężyna na 24 h czasu rzeczywistego, także offline.
  Cofnięty zegar telefonu nic nie nakręca (jak R-OFF-3).
- **R-SPR-3:** Każde „równo 5.00” (okno jackpotu, |błąd| < 0.010 s)
  dokręca 30 min z **zapasu dokręcania**. Zapas mieści 2 h i wraca sam,
  30 min na godzinę czasu rzeczywistego (pełny po 4 h, także offline;
  cofnięty zegar telefonu nic nie oddaje). Trafienie zabiera z zapasu
  tyle, ile dokręca; gdy zostało mniej niż minuta, nie dokręca nic. Pod
  tarczą wyskakuje „Sprężyna +30 min”, a przy pierwszym trafieniu na
  pustym zapasie „Zapas dokręcania pusty” (raz, do następnego
  dokręcenia). Warsztat pokazuje zapas paskiem („1 h 15 min z 2 h”)
  i mówi, kiedy będzie pełny. Wcześniej limit był dzienny (6 h na dobę):
  symulacja pokazała, że wybija się w 7–9 minut jednej sesji i nie
  zachęca do powrotu w ciągu dnia (13 §2.3).
- **R-SPR-3a (usunięte):** Było: pierwsze „równo 5.00” po co najmniej
  1 h bez trafienia dokręca 1 h zamiast 15 min. Zastąpione przez 30 min
  za każde trafienie (13 §5.4a): zapas opróżniają 4 trafienia, czyli
  2–3 minuty gry, więc krótkie wejścia opłacają się tak samo (1.25
  Sprężyny dziennie przy 3 × 3 min, 1.42 przy 6 × 2 min), a gracz ma
  jedną zasadę mniej. Oferta `adSpring` pokazuje się wtedy także
  w krótkich sesjach.
- **R-SPR-3b:** Oferta `adSpring` (§13): reklama napełnia zapas od razu.
  Najwyżej 2 razy na lokalną dobę, tylko gdy zapas jest pusty (mniej niż
  jedno trafienie). Przycisk jest w warsztacie, a plakietka Sprężyn
  w nagłówku pokazuje wtedy mały telewizor.
- **R-SPR-4:** Gotowe Sprężyny odkładają się do 10 (najdroższy stopień
  mistrzostwa kosztuje 5). Przy pełnym magazynie sprężyna się nie
  nakręca. Prezenty (zwrot z R-SPR-5a, bonusy Chronosa z R-PETLA-2a)
  mogą wyjść ponad limit; tak samo Sprężyna z 7. dnia dziennej premii
  (R-DZIEN-2).
  Wcześniej było 7: symulacja pokazała, że gracz odkładający na poziom 8
  stał miesiącami z pełnym magazynem i nie mógł go kupić.
  Przy pełnym magazynie „równo 5.00” nic nie dokręca i **nie zabiera
  zapasu**: wszystko czeka, aż gracz wyda Sprężynę.
  Trafienie, które kończy ostatnią Sprężynę, zabiera z zapasu tylko tyle,
  ile jej brakowało. Toast „Zapas dokręcania pusty” nie wyskakuje wtedy,
  bo zapas nie jest pusty. Wcześniej trafienie zużywało zapas, a nakręcony
  czas przepadał.
- **R-SPR-5 (mistrzostwo zegara):** Stopień N zegara kosztuje N Sprężyn,
  jest 5 stopni (razem 15 na zegar, 210 na wszystkie). Każdy stopień mnoży
  dochód tego zegara **×1.5** (×7.6 przy pięciu). Mistrzostwo nie
  przepada ani przy paradoksie, ani w nowej pętli czasu (§16): to jedyna
  moc, która przechodzi przez pętle. Podnieść można zegar kupiony choć
  raz. Sekcja mistrzostwa jest też na pełnej karcie zegara. Wcześniej
  było 10 poziomów po +10% (770 Sprężyn, ok. 1.7 roku, razem ×2): za
  drogo i za mało (13 §2.2).
- **R-SPR-5a (zwrot):** Zapis sprzed tej zmiany dostaje z powrotem
  wszystkie Sprężyny wydane na poziomy (poziom N kosztował N), także
  ponad limit magazynu, a poziomy wracają do zera. Warsztat mówi to raz
  („Wydane Sprężyny (39) wróciły do ciebie”). Zdobyte tytuły zostają.
- **R-SPR-6:** Stopnie 3 i 5 każdego zegara to tytuł mistrzowski: nazwa
  i żart (PL/EN, `tools/l10n/masters.py`; teksty i identyfikatory
  osiągnięć mają dawne klucze 5 i 10), osiągnięcie +1%. Przed zdobyciem
  widać tylko „Stopień 3: ???”.
- **R-TARCZA-1:** 17 tarcz zegara (wygląd stopera, rysowany kodem:
  kolory i dekoracja) na pięciu ścieżkach (docs/17 §5, symulacje 17 §3).
  Każda ma jeden warunek w `balance.json` (`dials`):

  | Ścieżka | Tarcze | Warunek |
  |---|---|---|
  | Zarobki | Klasyczna, Drewniak, Porcelana babci, Mosiądz | Tiki zarobione w całej grze (`lifetime.earnedEver`): 0, 1M, 10B, 1T |
  | Mistrzostwo zegarów | Sprężynka, Szwajcarka, Mistrzowska, Arcymistrzowska | stopnie mistrzostwa wszystkich zegarów razem (R-SPR-5): 5, 30, 50, 70 (wszystkie) |
  | Pętle czasu | Dworcowa, potem Kwarcówka … Pęknięta czasoprzestrzeń | ukończona pierwsza pętla (R-PETLA-1), potem pieczęć każdej zasady (R-PETLA-5) |
  | Wyczyn | Klepsydra | 100 Chronosów naraz w jednej pętli (powyżej 50 nie ma już bonusów Chronosa, więc to wybór: zostać czy iść dalej) |
  | Wierność | Kalendarzowa | 100 dni z odebraną dzienną premią, bez wymogu serii |

  Zarobki liczą się tylko do 1T, bo nowa pętla zeruje Tiki zarobione
  łącznie i dalsze progi nagradzałyby niegranie pętli (17 §1). Odblokowana
  tarcza zostaje na zawsze, także gdy jej warunek się zmienił (dawne
  progi za zarobki: Dworcowa 100aa, Szwajcarka 100ac) albo licznik spadł
  (Chronosy w nowej pętli; gra zapamiętuje tarczę co sekundę i przed
  nową pętlą). Nowa tarcza: toast „Nowa tarcza zegara”. Sezony nie dają
  tarcz, tylko motywy (17 §6).
- **R-TARCZA-2:** Wybór przyciskiem z tarczą w nagłówku. Galeria ma
  sekcję na każdą ścieżkę: odblokowane tarcze z nazwą, następna
  zablokowana z warunkiem („Zarób 1T”, „30 stopni mistrzostwa”,
  „Zdobądź Chronosa”, „Trofeum pętli”, „100 Chronosów w jednej pętli”,
  „100 dni z odebraną dzienną premią”) i postępem nad nią („Zarobione
  łącznie: 1K z 1M”, „12 z 30”), dalsze jako „???”. Następna wypełnia się
  jak wskazówka zegara (od godziny 12, zgodnie z ruchem wskazówek),
  liniowo: udział licznika między warunkiem poprzedniej tarczy na tej
  ścieżce a jej warunkiem. Trofea pieczęci nie mają postępu. Wyczyn jest
  „???” do pierwszego Chronosa. Pod galerią żart wybranej tarczy. Złota
  runda zawsze wygląda po swojemu (złota tarcza), a ciemne tarcze mają
  jasne cyfry i jaśniejsze kolory wyników.

## 16. Pętla czasu (cel gry i gra po nim)

Skąd i dlaczego: [13-petla-gry.md](13-petla-gry.md). Liczby w pliku
balansu (`loops`). Każda waluta ma jeden zasięg: Tiki przejście (do
paradoksu), Chronony i Okruchy pętlę, Sprężyny całą grę.

- **R-PETLA-1 (cel):** Pętla jest ukończona, gdy gracz kupi pierwszego
  Chronosa. W pierwszej pętli liczy się też Chronos kupiony kiedykolwiek
  (zapisy sprzed pętli).
- **R-PETLA-2 (zakończenie):** Ekran „Czas pokonany!” pokazuje się raz,
  po oknach offline i dziennej premii: numer pętli, czas gry i liczba
  paradoksów w niej, nowy rozdział Kroniki, zdobyta pieczęć i tarcza (w
  pierwszej pętli Dworcowa, od drugiej tarcza pieczęci), zapowiedź następnej zasady z pieczęcią jako „???”.
  Dwa przyciski: „Zostaję jeszcze” i „Nowa pętla”. Nic nie wymusza
  resetu.
- **R-PETLA-2a (bonusy Chronosa):** Każdy bonus Chronosa zdobyty w tej
  pętli (8 progów) daje raz +1 Sprężynę, także ponad limit magazynu.
  Pasek celu pokazuje wtedy „Cel: Chronos 7/10 → +1 Sprężyna”, a toast
  „Bonus Chronosa”.
- **R-PETLA-3 (nowa pętla):** Po potwierdzeniu (okno z listami „wraca do
  zera” i „zostaje”) zeruje się to, co przy paradoksie, a do tego
  Chronony, Okruchy, perki, Nawyki i Tiki zarobione łącznie (od nich
  liczą się Chronony). **Zostają:** Sprężyny, mistrzostwo zegarów,
  pieczęcie, osiągnięcia, tarcze, motywy, statystyki, licznik paradoksów
  i Tiki zarobione w całej grze.
- **R-PETLA-4 (zasada pętli):** Każda pętla od drugiej ma jedną zmienioną
  zasadę, w stałej kolejności. Ogłasza ją Chronos na ekranie zakończenia.
  W czasie pętli przypomina o niej znaczek „Pętla 2 · Zepsuty stoper”
  w rzędzie przełączników (dotknięcie otwiera Kronikę).

  | id | Nazwa PL / EN | Zmieniona zasada | Pieczęć (na zawsze) |
  |---|---|---|---|
  | `blindfold` | Zepsuty stoper / Broken Stopwatch | Na ślepo jest zawsze włączone (płaci jak zwykle); przełącznika nie da się wyłączyć | Wyczucie: Na ślepo płaci o 1 więcej (×4, ze Śmiałkiem ×5) |
  | `inflation` | Drożyzna / Price Hike | cena zegara rośnie ×1.20 za sztukę zamiast ×1.15 | Stały klient: pierwsze 10 sztuk każdego zegara za pół ceny |
  | `noGold` | Pochmurny dzień / Cloudy Day | Złota Sekunda nie przylatuje, oferta `adGolden` jest wyłączona; przedmioty sezonowe latają dalej (R-SEZ-3) | Promyk: po powrocie po co najmniej 1 h Złota Sekunda przylatuje w 30 s |
  | `shortFuse` | Krótki lont / Short Fuse | limit mnożnika +10 kroków (+0.50), ale każde trafienie słabsze niż PERFEKT zeruje go jak pudło (Fart i Gorąca ręka liczą się, Twarde lądowanie też); Tarcza nie działa | Długi lont: limit mnożnika +4 kroki (+0.20) |
  | `precision` | Szwajcarska precyzja / Swiss Precision | DOBRZE nic nie płaci graczowi | Pewna ręka: okno PERFEKT +0.001 s (nigdy szersze niż ŚWIETNIE) |
  | `insomnia` | Bezsenność / Insomnia | dochód offline najwyżej 25% | Dobry sen: limit offline +12 h |

- **R-PETLA-5 (co daje ukończenie):** rozdział Kroniki, pieczęć zasady
  tej pętli, tarcza zegara przypisana do tej pieczęci (R-TARCZA-1)
  i zapowiedź następnej zasady. Pierwsza pętla nie ma zasady, więc daje
  rozdział, tarczę Dworcową i zapowiedź.
- **R-PETLA-6 (tempo):** druga pętla 50–65% czasu pierwszej, kolejne
  ok. 4–6 dni, nie mniej niż ok. 3 (03 §4.4).
- **R-PETLA-7 (Kronika):** jeden ekran, otwierany z karty na górze ekranu
  paradoksu (od pierwszego Chronosa) i ze znaczka pętli: bieżąca pętla
  (zasada, cel, czas), zapowiedź następnej i przycisk „Nowa pętla” (gdy
  cel osiągnięty), 7 rozdziałów (niezdobyte jako „Rozdział n: ???”,
  tylko następny mówi „Ukończ pętlę n”), 6 pieczęci (niezdobyte jako
  „???”, z rekordem czasu po zdobyciu). Fabuła (docs/16): Dziadek wzywa
  Chronosa, żeby zdążać na podwieczorek; Chronos cofa czas do tamtego
  podwieczorku i w każdej pętli daje lekcję punktualności (zasadę);
  ostatni rozdział mówi, dlaczego akurat 5.00. W pierwszej pętli cztery
  rzadkie sceny (docs/16 §4), w oknie „Witaj z powrotem” kwestia dnia.
- **R-PETLA-8 (po historii):** po zdobyciu sześciu pieczęci gracz sam
  wybiera w Kronice zasady następnej pętli: dowolne, kilka naraz albo
  żadną. Kronika pamięta najkrótszy czas gry każdej zasady. (Kruche combo
  z docs/15 usunięte 11.2026: PERFEKT na ekranie, który nie podnosi
  mnożnika, wyglądał jak błąd.)

## 17. Ocena w sklepie

- **R-OCENA-1:** Gra prosi o ocenę systemowym oknem Google Play (In-App
  Review API) tylko w dobrym momencie i późno: po drugim lub kolejnym
  paradoksie (po zamknięciu ekranu paradoksu), po ukończeniu pętli (ekran
  „Czas pokonany!”) albo po ukończeniu wydarzenia sezonowego (przy
  najbliższej przerwie, nie w trakcie gry). Warunki: samouczek ukończony,
  co najmniej 3 h gry i odebrana dzienna premia w co najmniej 3 różne dni.
  Najwyżej dwa razy w całej grze, co najmniej 120 dni odstępu, nigdy
  w tej samej przerwie co formularz zgody i nigdy po pudle. Google samo
  decyduje, czy okno się pokaże; gra nie zna odpowiedzi i o nią nie pyta.
  Opis w sklepie dalej nie prosi o oceny.

## 18. Wyzwania dzienne i tygodniowe

Skąd i dlaczego: [14-wyzwania.md](14-wyzwania.md). Liczby w pliku balansu
(`challenges`), wyniki symulacji trudności w 14 §5.

- **R-WYZ-1 (zestaw):** codziennie trzy wyzwania, po jednym z każdej
  grupy, i jedno tygodniowe (od poniedziałku, czas lokalny), bez serwera.
  W tym samym miejscu nie wypada ten sam rodzaj dwa dni (tygodnie) z rzędu.
  Pierwsze wyzwania przychodzą po 3 min gry **liczonych od końca
  samouczka** (`unlockPlaySeconds`) — nigdy w trakcie samouczka, w chwili
  jego zakończenia ani w czasie jego powtórki z pomocy — także w trakcie
  sesji, przy starcie rundy, jak inne odblokowania. Zwykle to jeszcze
  pierwsza sesja, więc pierwsza nagroda daje powód do powrotu (przegląd
  innych gier: 14 §7). Pierwszy raz ze wskazówką przy plakietce, w zwykłym
  odstępie wskazówek (R-TUT-2), więc nie nakłada się na inne nowości.
  Każde zadanie to celowanie w 5.00 albo zwykła gra — żadne nie każe
  klikać celowo obok.

  | Grupa | Rodzaje |
  |---|---|
  | celność | N× ŚWIETNIE lub lepiej; N trafień z rzędu; N× równe 5.00 |
  | wyczyn | N PERFEKTÓW w 10 kolejnych rundach; N× PERFEKT; zarób trafieniami N Tików |
  | rozwój | kup N zegarów; zdobądź N bonusów zegarów (tylko gdy któryś jest w zasięgu 10 sztuk); kup N poziomów umiejętności (gdy jeszcze są) |
  | tydzień | N× ŚWIETNIE+; N× równe 5.00; seria N; złap N Złotych Sekund (nie w pętli „Pochmurny dzień”); nakręć trafieniami N h Sprężyny (po pierwszym paradoksie) |

- **R-WYZ-2 (trudność z własnej gry):** liczby nie są stałe. Gra bierze
  100 ostatnich dotknięć gracza, odtwarza z nich 160 symulowanych sesji
  i ustawia cel na tyle, ile gracz osiąga w 60% z nich (`reachShare`) —
  dzienne w sesji ok. 4 min gry (`dailySeconds`), tygodniowe ok. 35 min
  (`weeklySeconds`; seria tygodniowa: połowa, bo zależy od szczęścia).
  Liczą się okna z umiejętności i długość rundy (Start później). Nowy
  gracz bez dotknięć jest liczony jak gracz o rozrzucie 75 ms. Cel jest
  ustalany raz, przy wydaniu wyzwania, i zaokrąglany do „ładnych” liczb.
  **Pierwszy zestaw jest łatwiejszy:** cel osiągany w 80% sesji
  (`firstReachShare`) — dzienne zajmują wtedy 1–3.5 min (mediana), żeby
  pierwsza wizyta szybko coś dała.
  Symulacja (14 §5): dzienne zajmują 2–4 min (mediana) i do 5–6 min
  (80% graczy) przy każdej celności od 20 do 150 ms.
- **R-WYZ-3 (postęp):** liczą się dotknięcia gracza na obu zegarach (runda
  bez dotknięcia nie), także w Gorącej ręce i na ślepo. „Seria” to
  najwięcej trafień z rzędu od wydania wyzwania; każde pudło, także
  obronione Tarczą, zaczyna ją od zera (R-COMBO-2a, docs/15). Zakupy automatycznego
  kupca też są zakupami.
- **R-WYZ-4 (nagrody):** dzienne — 10 min dochodu pasywnego (co najmniej
  200 Tików); wszystkie trzy jednego dnia — dodatkowo 30 min (co najmniej
  600); tygodniowe — 1 Sprężyna po pierwszym paradoksie (może wyjść ponad
  limit magazynu, R-SPR-4), wcześniej 60 min dochodu (co najmniej 1000).
  Gracz odbiera nagrodę przyciskiem „Odbierz” w arkuszu wyzwań.
- **R-WYZ-5 (bez straty):** ukończone, a nieodebrane wyzwanie wypłaca się
  samo, gdy przychodzą nowe (komunikat „Nagrody za wczorajsze ukończone
  wyzwania”). Nieukończone po prostu znika — bez kary, bez serii dni.
- **R-WYZ-6 (wymiana):** raz dziennie można wylosować inne wyzwanie
  dzienne w miejsce jednego nieukończonego (przycisk ↻); tygodniowego się
  nie wymienia.
- **R-WYZ-7 (widoczność):** plakietka z tarczą strzelniczą w nagłówku
  pokazuje „1/3” ukończonych dziś, a „!” na złotym tle, gdy coś czeka na
  odbiór. Ukończenie: fanfara, wibracja i komunikat z przyciskiem
  „Odbierz”. Nic nie wyskakuje w trakcie rundy ponad ten komunikat.

