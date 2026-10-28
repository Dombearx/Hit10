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
│  [Na ślepo] [Szybki zegar]    │  ← tryby (po odblokowaniu)
│  ░ dziadek: 10.02! +3 ░       │  ← „trafienia” generatorów lecące z boku
├───────────────────────────────┤
│ [ulepszenie][ulepszenie][...] │  ← pasek dostępnych ulepszeń (przewijany)
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
- **U-4:** Pozostałe ekrany to pełnoekranowe arkusze nad grą:
  - Osiągnięcia: siatka odznak;
  - Prestiż: drzewko perków i przycisk resetu;
  - Statystyki;
  - Ustawienia.

  Otwarcie któregokolwiek pauzuje rundę (R-RUNDA-8).

## 2. Ustawienia

- Dźwięk efektów, muzyka (osobne suwaki).
- Wibracje (wł./wył.).
- Powiadomienie o pełnym limicie offline (wł./wył., R-OFF-4).
- Język: systemowy / polski / angielski.
- Zapis liczb: skrócony (12.4M) / naukowy (1.24e7).
- **Ogranicz ruch:** bez wstrząsów ekranu i błysków, mniej cząsteczek.
- Eksport i import zapisu (tekst do skopiowania).
- Reset postępu (dwa potwierdzenia, drugie wymaga wpisania słowa).
- Autorzy i licencje (z `CREDITS.md`). Polityka prywatności (link od M6).

## 3. Efekty („juice”) — tabela wymagań

| Zdarzenie | Obraz | Dźwięk | Wibracja |
|---|---|---|---|
| **PERFEKT** | napis „PERFEKT!” z odbiciem (skala 0→1.3→1), 60 złotych gwiazdek, błysk tarczy, wstrząs 8 px / 250 ms, liczby lecą do salda | akord „ding” + brzęk monet; wysokość rośnie z serią | mocna |
| **ŚWIETNIE** | „ŚWIETNIE!”, 25 cząsteczek, wstrząs 4 px | „ding” | średnia |
| **DOBRZE** | „DOBRZE”, 8 cząsteczek | krótkie „tik” | lekka |
| **PUDŁO / ZA WCZEŚNIE / ZA PÓŹNO** | szare drgnięcie tarczy w poziomie, napis wpada i opada | głuche „bonk” | podwójna krótka |
| **Utrata combo** | licznik combo pęka na kawałki | „brzdęk” | – |
| **Przewijanie (0→9.0)** | rozmycie ruchu cyfr, pierścień kręci się szybko; przy 9.0 „hamowanie” | szum przewijania → „whoosh” | – |
| **Strefa bullet time** | desaturacja tła, winieta, pulsujące cyfry, poświata | dźwięki obniżone, bicie serca | – |
| **Tykanie (umiejętność)** | delikatne pulsowanie co 0.1 s w ostatniej sekundzie | „tik” | mikro |
| **Złoty zegarek na ekranie** | lata po łuku, złoty ślad, świeci | dzwoneczki | – |
| **Złota runda** | złota tarcza, iskry dookoła | inna muzyka | – |
| **Szał** | całe tło świeci neonem, pulsuje w rytm | szybsza muzyka | – |
| **Zakup** | karta „wciska się” (skala 0.95→1.05→1), cząsteczki z karty, cena „ucieka” w górę | „ka-ching” | lekka |
| **Nowy generator odkryty** | sylwetka „???” zamienia się w portret z błyskiem | fanfara krótka | średnia |
| **Osiągnięcie** | toast z odznaką wjeżdża z góry, konfetti | fanfara | średnia |
| **Prestiż** | cały ekran „przewija się wstecz” (cyfry lecą do 0), biały błysk, spokojny start | dźwięk przewijania taśmy | długa |
| **Trafienie generatora** | mały dymek z portretem i wynikiem („10.00! +12K”) wylatuje z boku; najwyżej 3 na sekundę | ciche, tylko przy PERFEKT | – |

- **U-5:** Wszystkie efekty są w jednej warstwie (efekty areny w Flame,
  efekty UI we Flutterze). Siła każdego jest parametrem w jednym pliku
  (`effects` w pliku balansu albo osobny plik stylu).
- **U-6:** Przy włączonym „Ogranicz ruch” wstrząsy i błyski są wyłączone,
  a cząsteczek jest 1/3.
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
| neon | `#00F5FF` / `#FF00E5` | Szał, bullet time |
| kontur | `#2B2D42` | wszystkie kontury i tekst |

- **U-8:** Progi są rozróżnialne **nie tylko kolorem** (napis i kształt
  ikony), ze względu na daltonizm.

**Czcionki (Google Fonts, OFL):** *Lilita One* na nagłówki, cyfry stopera
i liczby; *Fredoka* na tekst. Obie mają polskie znaki. **U-9:** Cyfry stopera
mają stałą szerokość (tabular figures), żeby nie skakały.

### 4.1 Karty z emoji (grafika postaci i ikon w 1.0)

Źródło: [Microsoft Fluent Emoji](https://github.com/microsoft/fluentui-emoji),
styl **3D** (PNG 256×256, licencja MIT). Do repo trafiają tylko używane pliki
(`assets/emoji/`), razem z plikiem licencji i wpisem w `CREDITS.md`.

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
| Przewijanie | Fast-forward button | | Pamięć mięśniowa I–III | Brain |
| Tykanie | Bell | | Długa drzemka I–II | Sleeping face |
| Sokole oko | Eagle | | Głęboki sen I–II | Bed |
| Combo | Fire | | Gorączka złota | Pick |
| Magnes | Magnet | | Tarcza na start | Shield |
| Echo | Speaker high volume | | Twarde lądowanie | Parachute |
| Bullet time | Snail | | Automatyczny kupiec | Shopping cart |
| Szczęście | Four leaf clover | | Śmiałek | Smiling face with sunglasses |
| Tarcza | Shield | | Pudełko z kotem | Package |
| Złoty dotyk | Sparkles | | Drugi zegar | Stopwatch |
| | | | Ołtarz Chronosa | Classical building |

- **U-12:** Pozostałe elementy:
  - **ulepszenia generatora:** karta generatora pomniejszona do ikony plus
    cyfra poziomu (1–8) w rogu, rysowana w kodzie;
  - **synergie:** dwa emoji generatorów na jednej karcie, ukośnie;
  - **osiągnięcia:** odznaka (okrągła karta) z emoji kategorii: Money bag
    (zarobione), emoji generatora (posiadane), Bullseye (PERFEKTY),
    Fire (serie i combo), Glowing star (Złote Sekundy), Cyclone (prestiż),
    See-no-evil monkey / High voltage (tryby), Red question mark (ukryte);
  - **oferty reklam:** Television w rogu przycisku.

### 4.2 Rysowane wektorowo przez nas
- **U-26:** **Ikona aplikacji:** tarcza stopera z „10.00” w stylu gry
  (kontur, gradient, odblask), jako SVG. Eksport: ikona adaptacyjna
  Androida (warstwy przednia i tylna) oraz 512×512 do sklepu.
- **U-27:** **Złoty zegarek** (Złota Sekunda) jako wektor w kodzie albo SVG,
  bo musi świecić i obracać się płynnie.
- **U-28:** **Do sklepu:** grafika promocyjna 1024×500 złożona z tła gry,
  logo i kart postaci. 4–8 zrzutów ekranu z gry z podpisami PL/EN.

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
  - **Efekty** (ok. 20 plików, OGG, krótkie): paczki Kenney.nl na licencji
    CC0 (*Interface Sounds*, *Casino Audio* na monety, *Impact Sounds*)
    i własne „tiki” z generatora jsfxr.
  - **Muzyka** (3 pętle: spokojna, Szał, złota runda): OpenGameArt z filtrem
    CC0 albo Pixabay Music (licencja Pixabay pozwala na użycie komercyjne).
    Żadnych utworów z serwisów AI na darmowych planach (brak praw
    komercyjnych).
  - Całe audio poniżej 5 MB.
- **U-14:** Dźwięk trafienia musi zagrać w < 30 ms od dotknięcia
  (wstępnie załadowane próbki).
- **U-15:** Wysokość „ding” rośnie z serią (np. +1 półton co 2 kroki, max
  +12). To prosty, a bardzo skuteczny „juice”.
- **U-19:** W strefie bullet time muzyka i efekty przechodzą przez filtr
  dolnoprzepustowy („jak pod wodą”). W Szale muzyka gra ok. 15% szybciej.
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
