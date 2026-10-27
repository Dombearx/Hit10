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

**Grafika AI, wspólny szablon promptu** (portrety generatorów, ikony):

```
<obiekt>, mobile game character portrait, chunky cartoon style, thick dark outline,
soft 3D shading, bright saturated colors, warm lighting, centered, simple shape,
readable at 64px, transparent background, no text
```

- **U-10:** Najpierw powstaje jeden wzorcowy portret (Dziadek). Każdy kolejny
  generuje się z nim jako obrazkiem referencyjnym. Tło jest wycinane,
  a eksport to PNG 512×512 (w aplikacji skalowany).
- **U-11:** Potrzebne grafiki:
  - 14 portretów generatorów,
  - 11 ikon umiejętności,
  - 14 ikon ulepszeń (jedna na generator, z cyfrą poziomu nakładaną w kodzie),
  - 6 ikon synergii,
  - ok. 10 szablonów odznak osiągnięć (kategorie; liczby nakładane w kodzie),
  - 16 ikon perków,
  - złoty zegarek,
  - ikona aplikacji (512×512 i adaptacyjna),
  - grafika promocyjna 1024×500,
  - 4–8 zrzutów ekranu do sklepu.
- **U-12:** Do czasu gotowych grafik aplikacja działa na **zastępnikach**:
  kolorowe kółko z emoji albo inicjałem. Brak grafiki nigdy nie blokuje
  implementacji.

## 5. Dźwięk

- **U-13:** Lista efektów jak w tabeli z sekcji 3, ok. 20 plików (OGG, krótkie)
  i 2–3 pętle muzyczne: spokojna, Szał, Złota runda. Źródła: Kenney (CC0),
  jsfxr albo inne darmowe na licencji pozwalającej na użycie komercyjne,
  zawsze wpisane do `CREDITS.md`.
- **U-14:** Dźwięk trafienia musi zagrać w < 30 ms od dotknięcia
  (wstępnie załadowane próbki).
- **U-15:** Wysokość „ding” rośnie z serią (np. +1 półton co 2 kroki, max
  +12). To prosty, a bardzo skuteczny „juice”.

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
