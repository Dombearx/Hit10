# 04 — Ekrany i oprawa

„Tryska” to wymaganie, a nie dodatek. Ten dokument opisuje, jak gra ma
wyglądać, brzmieć i reagować.

## 1. Układ ekranu głównego (pion)

```
┌───────────────────────────────┐
│ ⚙   🏆   [ 12.4M Tików ]   ⏳ │  ← pasek: ustawienia, osiągnięcia, saldo, prestiż
│        +38.2K / s             │     dochód na sekundę
│  [Szał 0:54] [Gorąca ręka]    │  ← aktywne efekty
│                               │
│        ╭───────────╮          │
│       │   09.87    │          │  ← ARENA (Flame): tarcza z pierścieniem
│       │    ●●●○    │          │     postępu, cyfry, cząsteczki
│        ╰───────────╯          │
│   COMBO ×2.3  🔥 seria 13     │
│  [Na ślepo]                   │  ← tryby (po odblokowaniu)
│  ░ dziadek: 10.02! +3 ░       │  ← „trafienia” generatorów lecące z boku
├───────────────────────────────┤
│  Zegary │ Umiejętności        │  ← zakładki sklepu
│ ┌───────────────────────────┐ │
│ │ 👴 Dziadek     x42   1.2K │ │  ← lista (przewijana); przełącznik ×1/×10/×100/MAX
│ │ 👵 Babcia      x17   3.4K │ │
│ └───────────────────────────┘ │
└───────────────────────────────┘
```

- **U-1:** Arena zajmuje ok. 45–50% wysokości. Cały jej obszar przyjmuje
  dotknięcia, a sklep nie.
- **U-2:** Sklep da się zwinąć (przeciągnięcie w dół), wtedy arena zajmuje
  ~80% ekranu.
- **U-3:** Saldo „nabija się” płynnie (animowany licznik) i podskakuje przy
  każdym wpływie.
- **U-3a:** Pod saldem: dochód zegarów „/s”, a pod nim ile zapłaci
  następny PERFEKT („PERFEKT +540”), z obecnym combo i trybem (playtest:
  przy dużym dochodzie nie było widać, czy klikanie się opłaca; pełny
  cennik trzech progów był za gęsty). Karty Siły trafienia i Echa pokazują, ile teraz płaci PERFEKT
  i ile to sekund dochodu zegarów.
- **U-4:** Pozostałe ekrany to pełnoekranowe arkusze nad grą:
  - Osiągnięcia: siatka odznak;
  - Prestiż: drzewko perków i przycisk resetu;
  - Statystyki;
  - Ustawienia.

  Otwarcie któregokolwiek pauzuje rundę (R-RUNDA-8).

## 2. Ustawienia

- Dźwięk efektów, muzyka (osobne suwaki).
- Wibracje (wł./wył.).
- Powiadomienia (wł./wył.): limit offline, dzienna premia, pełny zapas
  dokręcania (02 R-OFF-4, R-POW-1…3).
- Kalibracja opóźnienia (05 T-13) — tylko z flagą `FEATURE_CALIBRATION`.
- Język: systemowy / polski / angielski.
- Zapis liczb: skrócony (12.4M) / naukowy (1.24e7).
- **Tryb spokojny** (domyślnie wyłączony; dawniej „Ogranicz ruch”): mniej
  ruchu i migania dla osób, którym od efektów robi się niedobrze (U-6).
  Klucz w zapisie bez zmian (`reduceMotion`).
- Zapis w chmurze (Google Play Gry): połącz / wczytaj z chmury (05 T-35;
  tylko w buildzie z projektem Play Games).
- Eksport i import zapisu (tekst do skopiowania).
- Reset postępu (dwa potwierdzenia, drugie wymaga wpisania słowa).
- Statystyki gry i raporty o awariach (05 T-33). Prywatność reklam (UMP).
- Autorzy i licencje (z `CREDITS.md`). Polityka prywatności (link od M6).

## 3. Efekty („juice”) — tabela wymagań

| Zdarzenie | Obraz | Dźwięk | Wibracja |
|---|---|---|---|
| **PERFEKT** | napis „PERFEKT!” z odbiciem (skala 0→1.3→1), 60 złotych gwiazdek, błysk tarczy, wstrząs 8 px / 250 ms, liczby lecą do salda | akord „ding” + brzęk monet; wysokość rośnie z serią | mocna |
| **ŚWIETNIE** | „ŚWIETNIE!”, 25 cząsteczek, wstrząs 4 px | „ding” | średnia |
| **DOBRZE** | „DOBRZE”, 8 cząsteczek | krótkie „tik” | lekka |
| **PUDŁO / ZA WCZEŚNIE / ZA PÓŹNO** | szare drgnięcie tarczy w poziomie, napis wpada i opada | głuche „bonk” | podwójna krótka |
| **Utrata combo** | licznik combo pęka na kawałki | „brzdęk” | – |
| **Start później** | stoper czeka na starcie z wyższą wartością, tempo jak zwykle | – | – |
| **Zimna krew (4.8–5.2)** | desaturacja tła, winieta, pulsujące cyfry, poświata | bicie serca | – |
| **Wydarzenie sezonowe** (02 §14) | tło w kolorach sezonu, przedmiot sezonowy zamiast złotego zegarka, plakietka z postępem w nagłówku | fanfara po ukończeniu | – |
| **Tykanie (umiejętność)** | delikatne pulsowanie co 0.1 s w ostatniej sekundzie | „tik” | mikro |
| **Złoty zegarek na ekranie** | lata po łuku, złoty ślad, świeci | dzwoneczki | – |
| **Złota runda** | złota tarcza, iskry dookoła | inna muzyka | – |
| **Szał** | całe tło świeci neonem, pulsuje w rytm | szybsza muzyka | – |
| **Zakup** | karta „wciska się” (skala 0.95→1.05→1), cząsteczki z karty, cena „ucieka” w górę | „ka-ching” | lekka |
| **Nowy generator odkryty** | sylwetka „???” zamienia się w portret z błyskiem | fanfara krótka | średnia |
| **Osiągnięcie** | toast z odznaką wjeżdża z góry, konfetti | fanfara | średnia |
| **Prestiż** | cały ekran „przewija się wstecz” (cyfry lecą do 0), biały błysk, spokojny start | dźwięk przewijania taśmy | długa |
| **Trafienie generatora** | mały dymek z portretem i wynikiem („5.00! +12K”) wylatuje z boku; najwyżej 3 na sekundę | ciche, tylko przy PERFEKT | – |

- **U-5:** Wszystkie efekty są w jednej warstwie (efekty areny w Flame,
  efekty UI we Flutterze). Siła każdego jest parametrem w jednym pliku
  (`effects` w pliku balansu albo osobny plik stylu).
- **U-6: Tryb spokojny.** Powód: tester zgłosił mdłości, najbardziej
  w Szale. Według Xbox Accessibility Guidelines 117/118 i WCAG 2.3 mdłości
  i dyskomfort wywołują przede wszystkim: (1) ruch lub zmiana koloru na
  dużej części ekranu, zwłaszcza w peryferiach (u nas pulsujące neonowe tło
  Szału, ~1 Hz, magenta ↔ cyjan, na cały ekran); (2) wstrząsy ekranu;
  (3) migotanie i błyski, szczególnie nasycone, kilka razy na sekundę;
  (4) obiekty rosnące lub powiększające się (efekt „zoomu”: fale uderzeniowe
  do 2.6× tarczy, odbicia napisów 0→1.3); (5) dużo rzeczy ruszających się
  naraz (cząsteczki, dymki generatorów, ciągłe pulsowanie). Przy włączonym
  trybie, w kolejności wpływu:

  | Efekt | Normalnie | Tryb spokojny |
  |---|---|---|
  | Tło Szału | neon na cały ekran, pulsuje magenta ↔ cyjan | stały, delikatny fioletowy odcień (30% zamiast 85%) |
  | Poświata tarczy w Szale | pulsuje kolorem i rozmiarem | stała, słabsza |
  | Wstrząsy ekranu, drgnięcie tarczy przy pudle, potrząsanie combo | są | brak |
  | Błysk tarczy, biały błysk prestiżu | są | brak |
  | Fale uderzeniowe (PERFEKT, ŚWIETNIE, 5.00) | są | brak |
  | Napisy (PERFEKT!, +Tiki…) | odbicie 0→1.3, pudło wpada z odbiciem | pojawiają się i znikają w miejscu |
  | Cząsteczki | pełne | 1/3, o 40% wolniejsze |
  | Dymki generatorów | do 3/s | do 1/s |
  | Pulsowanie: złota obwódka, cyfry w Zimnej krwi, „??” w trybie na ślepo, „dotknij, aby zacząć”, licznik Tików przy każdym zysku | jest | brak |
  | Złoty zegarek | lata falą, kołysze się, pulsuje, promienie się kręcą | lata falą (trzeba go złapać), bez kołysania, pulsowania i kręcenia |
  | Ozdoby tarcz (skórki) | ruchome | nieruchome |
  | Prestiż | cyfry kręcą się 3 razy | cyfry spadają bez obrotu |

  Nie zmienia się rozgrywka, czas rund, dźwięk ani muzyka (szybsza muzyka
  Szału zostaje). Zimna krew (desaturacja i winieta) zostaje, bo narasta
  płynnie przez 250 ms i jest sygnałem w grze. Pierścień samouczka zostaje.
- **U-7:** Efekty nigdy nie zasłaniają cyfr stopera w trakcie rundy (cyfry
  są zawsze na wierzchu).

## 4. Styl graficzny

Decyzja z [01-wizja.md](01-wizja.md): jasny, cukierkowy cartoon. Neon tylko
na stany specjalne.

**Paleta startowa** (do dopracowania przy M5; wszystko jako tokeny w jednym
pliku motywu):

| Token | Kolor | Użycie |
|---|---|---|
| tło-góra | `#FFD36E` (ciepła żółć) | gradient tła |
| tło-dół | `#FF8A5B` (brzoskwinia) | gradient tła |
| tarcza | `#FFFFFF` + kontur `#2B2D42` 6 px | zegar |
| perfekt | `#FFC300` → `#FF6F00` (złoto) | PERFEKT, Złota Sekunda |
| świetnie | `#2EC4B6` (turkus) | ŚWIETNIE |
| dobrze | `#6C9BFF` (błękit) | DOBRZE |
| pudło | `#8D99AE` (szarość) | PUDŁO |
| akcent | `#FF3D7F` (róż) | przyciski kupna, combo |
| neon | `#00F5FF` / `#FF00E5` | Szał, Zimna krew |
| kontur | `#2B2D42` | wszystkie kontury i tekst |

- **U-8:** Progi są rozróżnialne **nie tylko kolorem** (napis i kształt
  ikony), ze względu na daltonizm.

**Czcionki (Google Fonts, OFL):** *Paytone One* na nagłówki, cyfry stopera
i liczby; *Nunito* na tekst. Obie mają pełne polskie znaki (Lilita One i
Fredoka ich nie mają — sprawdzone w M4). **U-9:** Cyfry stopera
mają stałą szerokość (tabular figures), żeby nie skakały.

### 4.1 Karty z emoji (grafika postaci i ikon w 1.0)

Źródło: własne ikony 3D wygenerowane modelem Qwen-Image (Apache 2.0) przez
RunPod, PNG 160×160 z przezroczystym tłem w `assets/art/` (docs/10,
`tools/art/`). Do 11.2026 były to Microsoft Fluent Emoji 3D; nazwy plików
zostały te same (`trophy`, `fire`…).

- **U-10:** Karta to widżet składany w kodzie, a nie gotowy obrazek:
  - zaokrąglony kwadrat (promień 20% boku) w pastelowym kolorze danej pozycji;
  - kontur `#2B2D42` o grubości ok. 3% boku;
  - odblask: półprzezroczysty biały pas w górnych 40%;
  - miękki cień pod kartą;
  - emoji główne zajmuje 68% boku i jest wyśrodkowane;
  - opcjonalnie emoji w rogu (36% boku) w białym kółku z konturem.

  Wzór to makieta z rozmowy projektowej: 14 kart generatorów. Kolory i emoji
  są danymi (tabela niżej), nie kodem.
- **U-11:** Przypisanie emoji. Nazwy to nazwy katalogów w repo Fluent Emoji.
  Przy postaciach z odcieniem skóry bierzemy wariant `Default`. Jeśli emoji
  nie istnieje w stylu 3D, bierzemy najbliższe pasujące i zmieniamy tabelę.

| Generator | Emoji główne | W rogu | Tło |
|---|---|---|---|
| Dziadek | Old man | Stopwatch | `#FFD36E` |
| Babcia | Old woman | Egg | `#FFB38A` |
| Kukułka | Bird | Mantelpiece clock | `#9BE7C4` |
| Metronom | Musical note | – | `#B9A7FF` |
| Zegarmistrz | Man mechanic | Magnifying glass tilted left | `#FFC9DE` |
| Sędzia sprintu | Chequered flag | Stopwatch | `#A7E0FF` |
| Zegar dworcowy | Station | Snail (opóźnienia) | `#FFE29A` |
| Zegar kwarcowy | Gem stone | – | `#C8F2FF` |
| Zegar atomowy | Atom symbol | – | `#D7C4FF` |
| Satelita GPS | Satellite | – | `#B4D8FF` |
| Pulsar | Dizzy | – | `#FFE6A7` |
| Maszyna czasu | Hourglass done | Cyclone | `#FFC2A8` |
| Kot Schrödingera | Cat | Package | `#E2D2FF` |
| Chronos | Mantelpiece clock | Dizzy | `#FFD86E` |

| Umiejętność | Emoji | | Perk | Emoji |
|---|---|---|---|---|
| Siła trafienia | Flexed biceps | | Szybki start | Rocket |
| Start później | Fast-forward button | | Pamięć mięśniowa I–III | Brain |
| Tykanie | Bell | | Długa drzemka I–II | Sleeping face |
| Sokole oko | Eagle | | Głęboki sen I–II | Bed |
| Combo | Fire | | Gorączka złota | Pick |
| Magnes | Magnet | | Szybka Tarcza | Shield |
| Echo | Speaker high volume | | Twarde lądowanie | Parachute |
| Zimna krew | Bullseye | | Automatyczny kupiec | Shopping cart |
| Szczęście | Four leaf clover | | Śmiałek | Smiling face with sunglasses |
| Tarcza | Shield | | Pudełko z kotem | Package |
| Złoty dotyk | Sparkles | | Drugi zegar | Stopwatch |
| | | | Ołtarz Chronosa | Classical building |

- **U-12:** Pozostałe elementy:
  - **bonusy generatora (R-ULEP-3):** złoty pasek postępu na karcie
    generatora z napisem „7/10 → ×2”; osiągnięcie progu pokazuje
    powiadomienie z ikoną generatora;
  - **osiągnięcia:** odznaka (okrągła karta) z emoji kategorii: Money bag
    (zarobione), emoji generatora (posiadane), Bullseye (PERFEKTY),
    Fire (serie i combo), Glowing star (Złote Sekundy), Cyclone (prestiż),
    See-no-evil monkey / High voltage (tryby), Red question mark (ukryte);
  - **oferty reklam:** Television w rogu przycisku.

### 4.2 Rysowane wektorowo przez nas
- **U-26:** **Ikona aplikacji:** tarcza stopera z „5.00” w stylu gry
  (kontur, gradient, odblask), jako SVG. Eksport: ikona adaptacyjna
  Androida (warstwy przednia i tylna) oraz 512×512 do sklepu.
- **U-27:** **Złoty zegarek** (Złota Sekunda) jako wektor w kodzie albo SVG,
  bo musi świecić i obracać się płynnie.
- **U-28:** **Do sklepu:** grafika promocyjna 1024×500 złożona z tła gry,
  logo i kart postaci. 4–8 zrzutów ekranu z gry z podpisami PL/EN.

- **U-30:** **Ikony zasobów** (jak w grach planszowych): każdy zasób ma
  jedną ikonę, która stoi przed jego nazwą w każdym tekście, we wszystkich
  formach (Tiki/Tików/Tikami, Ticks): Tiki — moneta, Chronony — wir
  paradoksu, Okruchy czasu — fioletowa czteroramienna gwiazdka (rysowana
  w kodzie, zastępuje znak „✦”), Sprężyny — spirala (U-27 jak złoty
  zegarek: rysowana w kodzie). Ta sama ikona stoi za ceną na przyciskach
  zakupu (zegary i umiejętności — moneta, perki — gwiazdka) i przy kwotach
  w oknach „Gdy cię nie było” i dziennej premii.
- **U-31:** **Okna dialogowe** w stylu gry, bez systemowego wyglądu: kremowe
  tło, gruby ciemny kontur, zaokrąglenie 26, ikona-karta u góry, pytanie,
  pod nim duży różowy przycisk „tak” i cichy przycisk tekstowy „nie”
  (playtest: systemowe okienko pytania o powiadomienia wyglądało obco).
- **U-32:** **Płomień serii** rośnie z combo w polu o stałym rozmiarze
  (wysokość paska combo, 30 px), więc nawet przy pełnym combo nie zasłania
  mnożnika, licznika serii, chipów trybów ani dołu tarczy (playtest:
  powiększony płomień wychodził poza pasek). Tarcza i pasek combo nie mają
  dodatkowych marginesów: zapas na płomień zmniejszał tarczę, gdy ekran był
  pełny (chipy trybów, efekty).

- **U-33:** **Ilustracje fabuły:** prolog i każdy z siedmiu rozdziałów ma
  ilustrację 16:9 (zaokrąglona ramka z konturem) nad tekstem — w oknie
  prologu, w Kronice i w zakończeniu pętli. Plik
  `app/assets/story/<id>.jpg` (`prologue`, `chapter_1` … `chapter_7`).
  Dopóki pliku nie ma, w tym miejscu stoi placeholder: postacie rozdziału
  (karty z ikonami) na miękkim gradiencie w kolorze sceny. Dodanie
  obrazka nie wymaga zmian w kodzie (docs/10, „Ilustracje fabuły”).

- **U-34:** **„Witaj z powrotem”** (02 R-OFF-2, R-DZIEN-1): dochód offline
  i dzienna premia w jednym oknie — kwota offline (z ×2 za reklamę),
  pod nią seria 7 dni z kwotą premii i ewentualną informacją o dniu łaski,
  linijka o nowym wydarzeniu, jeden przycisk „Odbierz wszystko”. Gdy jest
  tylko jedno z dwojga, okno ma jego tytuł („Gdy cię nie było…” albo
  „Dzienna premia”). Kolejność okien przy starcie: zapis w chmurze
  (05 T-35), prolog, „Witaj z powrotem”, wydarzenie (gdy nie było linijki),
  koniec pętli, pytanie o statystyki i zgoda na reklamy (05 T-33, T-26),
  prośba o ocenę (02 R-OCENA-1).
- **U-36:** **Wyzwania** (02 §18): plakietka z tarczą strzelniczą w rzędzie
  plakietek nagłówka (przed Sprężynami i wydarzeniem) z „1/3”; złota z „!”,
  gdy nagroda czeka. Arkusz „Wyzwania”: „Dzisiaj” — trzy karty (ikona,
  zadanie z liczbą, pasek postępu „7/12”, nagroda z ikoną zasobu,
  przycisk „Odbierz” albo ↻), wiersz premii za wszystkie trzy; „Ten
  tydzień” — karta tygodniowa z liczbą dni do końca. Ukończenie:
  komunikat z przyciskiem „Odbierz” otwierającym arkusz.
- **U-35:** **Duża czcionka systemowa:** tekst rośnie razem z ustawieniem
  Androida, ale najwyżej ×1.3 (`maxTextScale`): ekran gry jest ułożony co
  do piksela, a większe liczby nie mieszczą się na telefonie. Saldo
  zmniejsza się, zamiast wychodzić poza ekran. Pilnuje tego
  `text_scale_test.dart` (×1.3, ×1.6, ×2.0, PL i EN: gra, sklep, wszystkie
  arkusze, okno powitalne).

### 4.3 Grafika AI (po wydaniu, opcjonalnie)
Nie jest potrzebna do 1.0. Jeśli dojdzie, zastępuje emoji w tych samych
kartach (U-10), więc kod się nie zmienia. Wspólny szablon promptu:

```
<obiekt>, mobile game character portrait, chunky cartoon style, thick dark outline,
soft 3D shading, bright saturated colors, warm lighting, centered, simple shape,
readable at 64px, transparent background, no text
```

Najpierw powstaje jeden wzorcowy portret, kolejne generuje się z nim jako
obrazkiem referencyjnym. Modele z licencją pozwalającą na użycie
komercyjne, do uruchomienia u siebie:
- **SDXL:** karta NVIDIA z 8 GB pamięci;
- **FLUX.1 [schnell]:** 12–16 GB;
- **Qwen-Image / Qwen-Image-Edit:** 24 GB;
- Mac M1+ z 16 GB: aplikacja Draw Things.

FLUX.1 [dev] odpada, bo ma licencję niekomercyjną.

## 5. Dźwięk

- **U-13:** Wszystkie dźwięki są **darmowe** i na licencji pozwalającej na
  użycie komercyjne. Każdy jest wpisany do `CREDITS.md` z linkiem i licencją.
  - **Efekty** (ok. 20 plików, OGG, krótkie): **syntetyzowane w repo**
    skryptem `tools/sfx/generate.py` (oscylatory i szum, numpy + ffmpeg),
    więc należą do projektu i nie wymagają licencji. Paczki Kenney.nl (CC0)
    zostają opcją, gdyby własne brzmienia nie wystarczyły.
  - **Muzyka** (3 pętle: spokojna, Szał, złota runda): również
    **syntezowana w repo** (`tools/sfx/music.py`: woodblocki „tik-tak”,
    marimba, bas, dzwonki), więc należy do projektu. OpenGameArt (CC0) albo
    Pixabay Music zostają opcją na później. Żadnych utworów z serwisów AI na
    darmowych planach (brak praw komercyjnych).
  - Całe audio poniżej 5 MB.
- **U-14:** Dźwięk trafienia musi zagrać w < 30 ms od dotknięcia
  (wstępnie załadowane próbki).
- **U-15:** Wysokość „ding” rośnie z serią (np. +1 półton co 2 kroki, max
  +12). To prosty, a bardzo skuteczny „juice”.
- **U-19:** Tempo dźwięku się nie zmienia (playtest: „pod wodą” sugerowało
  zwolnienie, którego już nie ma). W Szale gra osobna, szybsza pętla.
  Wszystko robione filtrami silnika dźwięku, bez osobnych plików.
- **U-20:** Efekty są domyślnie włączone, muzyka też, ale cicha (ok. 40%).
  Jeśli przy starcie w telefonie gra inna muzyka, muzyka gry startuje
  wyłączona, a efekty zostają.
- **U-21:** Dźwięk wycisza się, gdy aplikacja przechodzi w tło.

## 5a. Reklamy w interfejsie

- **U-22:** Przyciski Turbo i Złotej Sekundy to małe kafelki z ikoną
  telewizorka obok zegara. Nigdy nie leżą w obszarze areny przyjmującym
  dotknięcia, żeby nie było przypadkowych kliknięć. Aktywne Turbo pokazuje
  pasek z pozostałym czasem („×2 · 1:23:40”).
  Gdy kafelki są widoczne, arena rezerwuje na nie pas 48 px u góry:
  tarcza mieści się pod nim i nic jej nie zasłania (playtest: na niskich
  ekranach kafelki wchodziły na tarczę).
- **U-29:** Przycisk pauzy: okrągły, 40 px, na środku pasa nad tarczą
  (między kafelkami reklam). ⏸ gdy runda trwa, złoty ▶ gdy stoper stoi.
  Umiejętności na karcie pokazują wartości w jednostkach gry (Tiki, ms, s,
  ×, „2%” trafień), a w szczegółach okienkowych także „Twoje PERFEKTY:
  ok. 13% → 15% rund”, zamiast procentów od niewidocznej bazy.
  Okruchy czasu mają wszędzie ten sam znak ✦: przy liczbie posiadanych
  i przy cenach perków (playtest 22).
- **U-23:** Worek Tików pojawia się na karcie, na którą brakuje Tików, jako
  drugi przycisk („📺 +5 min”).
- **U-24:** Ratunek combo to wyskakujący dymek nad licznikiem combo z
  odliczaniem 5 s, w stylu „Seria 18 przepadła! 📺 Przywróć”.
- **U-25:** Po nagrodzie z reklamy pojawia się pełny efekt (cząsteczki,
  dźwięk), żeby nagroda była odczuwalna.

## 6. Liczby i teksty

- **U-16:** Format skrócony: poniżej 1000 z jednym miejscem po przecinku, gdy
  jest ułamek (0.1, 12.5), a od 1000 trzy cyfry znaczące i przyrostek: K, M,
  B, T, potem aa, ab, …, az, ba, … (tak samo w PL i EN). Separator dziesiętny
  zależy od języka (PL: `12,4M`, EN: `12.4M`).
- **U-17:** Stoper zawsze z kropką i dwoma miejscami (`09.87`) w obu
  językach. To element graficzny, nie liczba w tekście.
- **U-18:** Wszystkie teksty są w plikach tłumaczeń (ARB), bez tekstów
  wpisanych na sztywno. Humor jest pisany osobno dla każdego języka, nie
  tłumaczony dosłownie.
