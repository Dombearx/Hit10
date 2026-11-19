# 05 — Technika

## 1. Stos

- **Flutter** (aktualny stable) i **Dart**.
- **Flame:** tylko arena (zegar, cząsteczki, efekty), osadzona w drzewie
  widżetów przez `GameWidget`.
- Interfejs (sklep, panele, toasty) to zwykły Flutter.
- Stan: **Riverpod**. Animacje UI: `flutter_animate`.
- Dźwięk: **`flutter_soloud`** (silnik SoLoud w C++). Wybrany zamiast
  `audioplayers`/`flame_audio` z trzech powodów: małe opóźnienie (U-14),
  zmiana wysokości dźwięku w locie (U-15) i filtry na żywo (U-19). Wibracje:
  `HapticFeedback` z Fluttera.
- Zapis: plik JSON przez `path_provider`.
- Powiadomienia: `flutter_local_notifications` (lokalne, planowane na
  urządzeniu, bez backendu ani Firebase). Uprawnienie
  `POST_NOTIFICATIONS`. Planowanie nie wymaga dokładnych alarmów
  (`SCHEDULE_EXACT_ALARM`), bo kilkuminutowe przesunięcie nie przeszkadza.
  Każdy rodzaj przypomnienia ma osobny kanał Androida (02 R-POW-1…3).
- Ocena w sklepie: `in_app_review` (okno Google Play, 02 R-OCENA-1).
- Zapis w chmurze: `games_services` (Play Games Saved Games, T-35).
- Raporty o awariach: `firebase_crashlytics` (T-30).
- Tłumaczenia: `flutter_localizations` + ARB (`gen-l10n`).
- **T-1:** Szablon `MobileAppTemplate` nie jest używany. Projekt startuje
  z `flutter create`. Ze szablonu można później podejrzeć kroki podpisywania
  i wydania (M6).
- **T-2:** Żadnego własnego backendu. Z Firebase używamy wyłącznie
  Analytics i Crashlytics (T-30, §8a), z usług Google Play — Play Games
  do zapisu w chmurze (T-35). Bez uprawnienia `INTERNET` aż do M6
  (reklamy).

## 2. Struktura repo

```
app/
  lib/
    model/        czysty Dart: stan gry, wzory, ocena, ekonomia (BEZ importów Fluttera)
    balance/      wczytanie i walidacja pliku balansu
    engine/       pętla rundy, zegar gry, Złota Sekunda, offline, tick ekonomii
    persistence/  zapis/odczyt, migracje wersji zapisu
    arena/        Flame: zegar, cząsteczki, efekty
    ui/           ekrany, sklep, panele, toasty
    l10n/         app_pl.arb, app_en.arb
  assets/
    balance.json  JEDYNE źródło liczb (02, 03)
    images/ audio/ fonts/
  test/           testy jednostkowe i widżetów
  tool/
    simulate.dart symulator balansu (używa lib/model i assets/balance.json)
docs/             ta dokumentacja
CREDITS.md        autorzy i licencje zasobów
```

- **T-3:** `lib/model` i `lib/engine` nie importują Fluttera ani Flame.
  Pilnuje tego test (skan importów) albo osobny pakiet Dart.
- **T-4:** Symulator `dart run tool/simulate.dart` korzysta z **tego samego**
  kodu ekonomii co gra. Nie wolno mieć drugiej implementacji wzorów.
  Projektowy symulator w Pythonie (`design/`, wyniki w 03 §4–5) jest tylko
  punktem odniesienia do sprawdzenia portu (06 §1.2). Gra go nie używa.

## 3. Plik balansu

- **T-5:** `assets/balance.json` zawiera wszystkie liczby z 02 i 03: rundę,
  progi, combo, umiejętności, generatory, ulepszenia, synergie, Złotą
  Sekundę, tryby, offline, osiągnięcia (progi), prestiż, perki i siłę efektów.
  Teksty (nazwy, opisy) **nie** są w tym pliku, tylko w ARB, pod kluczami
  z `id`.
- **T-6:** Przy starcie plik jest walidowany: wymagane pola, okno PERFEKT
  mniejsze od ŚWIETNIE przy max poziomach, rosnące koszty, unikalne `id`,
  istniejące odwołania (synergie, perki). Błąd w trybie debug kończy się
  czytelnym wyjątkiem, a test pilnuje, że plik z repo jest poprawny.
- **T-7:** Plik ma pole `version`. Zapis gry pamięta, z którą wersją balansu
  powstał (do diagnostyki).

## 4. Pomiar czasu — najważniejsze wymaganie

Okno PERFEKT (±5 ms) jest węższe niż jedna klatka przy 60 Hz (16.7 ms), więc
liczenie wyniku „w klatce” byłoby niesprawiedliwe.

- **T-8:** Czas rundy mierzy monotoniczny `Stopwatch` (nie `DateTime.now()`,
  bo zmiana zegara systemowego nie może nic psuć).
- **T-9:** Dotknięcie odbiera `Listener.onPointerDown`. **Nigdy** `onTap`
  z `GestureDetector`, który działa dopiero po puszczeniu palca i po
  rozstrzygnięciu konkurencji gestów. Ocena zapada natychmiast w obsłudze
  zdarzenia. Do czasu z zegara rzeczywistego stosuje się mapowanie
  z R-RUNDA-10/11.
- **T-10:** Pomiar musi być odporny na spadki klatek: ocena nie zależy od
  tego, kiedy wyrenderowała się ostatnia klatka ani kiedy wątek UI
  obsłużył dotknięcie. Liczy się **znacznik czasu zdarzenia** z systemu
  (`PointerEvent.timeStamp`), przeliczony na `Stopwatch` gry
  (`lib/engine/tap_clock.dart`): różnica „odczyt w obsłudze − znacznik”
  to stałe przesunięcie zegarów plus czas czekania na wolny wątek, więc
  najmniejsza różnica z ostatnich 64 dotknięć daje przesunięcie,
  a dotknięcie liczy się w chwili `znacznik + przesunięcie`. Czekanie
  dłuższe niż 0.1 s oznacza, że zegary się rozjechały (np. telefon
  spał): wtedy liczy się odczyt w obsłudze, a historia startuje od nowa;
  po powrocie do aplikacji też. Bez znacznika (czytnik ekranu, przycisk
  ▶) liczy się odczyt w obsłudze. Wcześniej ocena brała odczyt
  `Stopwatch` w obsłudze zdarzenia, więc zajęta klatka spóźniała
  dotknięcie.
- **T-11:** Mapowanie czas rzeczywisty → czas gry (Start później) to
  czysta funkcja w `lib/model`,
  z odwrotnością (do planowania animacji). Pokrywają ją testy.
- **T-12:** Tryb diagnostyczny (ukryty, np. 7 dotknięć w wersję w
  ustawieniach) pokazuje:
  - różnicę `PointerEvent.timeStamp` → odczyt `Stopwatch` i największą
    poprawkę z T-10 („corrected ≤ … ms”: o ile obsługa spóźniłaby
    dotknięcie),
  - przesunięcie z kalibracji (T-13),
  - czasy klatek,
  - histogram błędów ostatnich 100 rund.

  Służy do sprawdzenia T-9 na prawdziwych telefonach (06, test ręczny M-1).
- **T-13 (kalibracja, za flagą `FEATURE_CALIBRATION`):** opóźnienie
  ekranu dotykowego (zwykle 20–60 ms) i obrazu (1–3 klatki, zanim cyfry
  trafią na ekran) jest stałe dla telefonu, ale różne na różnych
  telefonach. Gracz, który dotyka „gdy widzi 5.00”, jest więc zawsze
  spóźniony o tę sumę. Przy oknie 5.00 ±10 ms nieskorygowane 40 ms
  zmniejsza udział jackpotów gracza wprawnego (σ = 30 ms) z ok. 26% do
  ok. 11%, a od jackpotów zależą też Sprężyny (R-SPR-3). Gry rytmiczne
  (osu!, Beat Saber, Guitar Hero) dają do tego kalibrację.
  - Ustawienia → „Kalibracja opóźnienia”: 10 dotknięć stopera, który
    biegnie jak prawdziwy (od 3.00 do 5.00, te same cyfry). Dotknięcia
    dalej niż 0.2 s od celu są pomijane; mediana błędu to propozycja
    przesunięcia (od −80 do +200 ms). Gdy dotknięć jest mniej niż 6 albo
    są rozrzucone (mediana odchylenia > 45 ms), ekran radzi powtórzyć
    test. Gracz sam wybiera „Zastosuj”, „Powtórz” albo „Wyzeruj”.
  - Przesunięcie (`settings.inputOffsetMs`, w zapisie) odejmuje się od
    każdego ocenianego dotknięcia, także na drugim zegarze; dotknięcia,
    które startuje rundę, nie zmienia. Okna i rozrzut gracza się nie
    zmieniają: znika tylko stały błąd.
  - Wiersz w ustawieniach sam podpowiada kalibrację, gdy średni błąd
    z ostatnich ≥30 trafień przekracza ±25 ms.
  - **Flaga:** `lib/model/features.dart`, stała z
    `--dart-define=FEATURE_CALIBRATION=true`. Wydanie do Play jej nie
    ustawia, więc gracze nie widzą wiersza, a zapisane przesunięcie nie
    działa. APK testowe z CI (dla naszych telefonów) ma ją włączoną.
  - Zanim flaga trafi do graczy: test na ≥2 telefonach (M-1) — czy po
    kalibracji średni błąd w statystykach (R-STAT-1) schodzi do ok. 0
    i czy wyniki nie są gorsze niż bez niej.

## 5. Pętla gry i ekonomia w czasie

- **T-14:** Ekonomia „tyka” 10× na sekundę: dolicza `P · Δt` i sprawdza
  efekty i Złotą Sekundę. Animowane saldo interpoluje między tyknięciami.
- **T-15:** Losowe „trafienia generatorów” na ekranie to wyłącznie efekt
  wizualny. Losuje się je z rozkładu σ generatora, ale saldo rośnie zawsze
  z wartości oczekiwanej, więc przy 10 000 jednostek gra się nie zatnie.
- **T-16:** Po `AppLifecycleState.paused`: zapis, anulowanie rundy (R-RUNDA-8)
  i zapamiętanie czasu wyjścia (`DateTime`, do offline). Po `resumed`:
  naliczenie offline (R-OFF-1…3).

## 6. Zapis stanu

- **T-17:** Stan to jeden obiekt serializowany do JSON, z polem
  `saveVersion` i migracjami `vN → vN+1` (każda z testem).
- **T-18:** Zapis automatyczny co 10 s, po każdym zakupie, przy wyjściu
  z aplikacji i przed prestiżem. Zapis jest atomowy: plik tymczasowy, potem
  zmiana nazwy. Zostaje też kopia poprzedniego zapisu, wczytywana, jeśli
  główny plik jest uszkodzony. **Zapisy nigdy się nie nakładają:** kolejny
  czeka na trwający, a kilka zleconych w tym czasie zapisuje się raz,
  najnowszy stan. Wcześniej wyjście z aplikacji (zdarzenia „ukryta”
  i „wstrzymana” zaraz po sobie) pisało dwa razy naraz do tego samego
  pliku tymczasowego. Import i reset czekają na trwający zapis, żeby nie
  nadpisał nowego stanu.
- **T-19:** Eksport to JSON → gzip → base64 jako tekst do schowka. Import
  robi to samo w drugą stronę, z walidacją i potwierdzeniem nadpisania.
- **T-20:** Uszkodzony zapis i brak kopii oznaczają komunikat i start od zera,
  a nie wyłożenie się aplikacji.
- **T-32:** Zapis jest objęty **kopią zapasową Androida** (Auto Backup na
  koncie Google, darmowa, bez backendu). Po zmianie telefonu postęp wraca
  sam. Kopią objęty jest tylko plik zapisu, bez ustawień urządzenia.
  Auto Backup robi kopię najwyżej raz na dobę (ładowanie, Wi-Fi,
  bezczynność) i przywraca ją tylko przy instalacji, dlatego dochodzi
  zapis w chmurze (T-35).
- **T-35 (zapis w chmurze, Play Games Saved Games):** darmowe, bez
  własnego backendu i bez naszego konta; gracz loguje się do Google Play
  Gry (w v2 zwykle samo przy starcie).
  - Jeden zapis w chmurze (`hit5-save`), ten sam tekst co eksport (T-19).
    Wysyłany przy każdym wyjściu z gry, najwyżej raz na minutę, i od razu
    po połączeniu w ustawieniach.
  - Po starcie gra sprawdza chmurę. Zapis z co najmniej 2 min więcej gry
    (`lifetime.secondsPlayed`) gra **proponuje**, pokazując obie strony
    (czas gry, Tiki łącznie); „Wczytaj” działa jak import i restartuje
    grę, „Zostaw” zapamiętuje odmowę dla tego zapisu, a najbliższe
    wyjście nadpisuje chmurę. Dopóki pytanie czeka, nic nie jest
    wysyłane. Nigdy nic nie wczytuje się samo.
  - Ustawienia → „Zapis w chmurze”: „Połącz z Google Play Gry” albo
    „Wczytaj z chmury” (ręcznie, także zapis wcześniej odrzucony).
  - Identyfikator projektu Play Games trafia do gry przez
    `--dart-define=PLAY_GAMES_APP_ID` i do manifestu przez Gradle (ta sama
    zmienna, zasób `play_games_app_id`). Bez niego gra nie woła Play Games,
    a wiersza w ustawieniach nie ma (APK testowe, web). Konfiguracja
    w Play Console: `store/PLAY_CONSOLE.md` §2b.
  - Logika porównania jest w `lib/persistence/cloud_save.dart` (czysty
    Dart, testy z `MemoryCloudSave`), Play Games tylko
    w `lib/ui/cloud_save_device.dart`.

## 7. Wydajność i jakość

- **T-21:** Stabilne 60 fps (i 120 na ekranach 120 Hz) na średniaku sprzed
  ok. 3–4 lat, także przy PERFEKT z pełnymi cząsteczkami i w Szale.
  Cząsteczki z puli obiektów, bez alokacji w każdej klatce.
- **T-21a (bateria):** gdy na arenie nic się nie rusza (każdy stoper
  czeka: pauza, stop po rundach bez dotknięcia, zasłaniający arkusz; nie
  leci złoty zegarek; gracz nie ma żadnego zegara-generatora, bo ich
  dymki z wynikami lecą też w pauzie) przez 3 s, silnik Flame przestaje rysować
  (`pauseEngine`), a ekonomia tyka timerem 10 Hz bez klatek. Zmiana tego,
  co pokazuje stojąca tarcza (skórka, start później, pauza), rysuje jedną
  klatkę (`stepEngine`). Dotknięcie areny, start rundy (także z ▶) albo
  złoty zegarek budzą silnik od razu. W tle timer nie tyka (czas offline
  liczy R-OFF-1). Gry idle często leżą otwarte na stole.
- **T-22:** Zimny start do ekranu gry poniżej 2 s na tym samym urządzeniu.
- **T-23:** Rozmiar pobieranego AAB/APK poniżej 40 MB.
- **T-24:** `flutter analyze` bez ostrzeżeń, `dart format`, wszystkie testy
  zielone (06). Do repo dochodzi `Makefile` z `make check`.
- **T-31:** **CI w GitHub Actions** (darmowe minuty, bez stałych kosztów):
  - każdy push uruchamia `make check` i symulator `--check`, a potem buduje
    debug APK jako artefakt;
  - po scaleniu etapu do `main` CI tworzy tag i GitHub Release z APK
    (nazwa etapu z pliku `MILESTONE`). Właściciel pobiera APK i instaluje
    prosto na telefonie (włączona „instalacja z nieznanych źródeł”);
  - QA lokalne: build web z hakiem QA (`make web-qa`, `--dart-define=QA=true`)
    pozwala testom w przeglądarce dotykać w dokładnym czasie gry; buildy
    wydawane go nie zawierają.

## 8. Reklamy (M6, przygotowanie od początku)

- **T-25:** Od M1 w kodzie istnieje interfejs `RewardedAds`
  (`isReady`, `show() → Future<AdResult>`: obejrzana, przerwana albo
  niewyświetlona) z implementacją-atrapą, która zawsze „daje” nagrodę po
  1 s. Ekrany korzystają tylko z tego interfejsu.
- **T-26:** W M6 dochodzi implementacja z `google_mobile_ads` (wyłącznie
  format rewarded) i formularzem zgody **UMP** (wymagany w UE). Do tego:
  - przy każdym starcie gra tylko sprawdza, czy zgoda jest potrzebna
    (`requestConsentInfoUpdate`, bez okna). **Formularz pokazuje się
    dopiero po samouczku**, po pytaniu o statystyki (T-33), raz na
    uruchomienie, i tylko gdy jest potrzebny i bez odpowiedzi. SDK reklam
    startuje od razu, gdy zgoda już jest albo nie jest potrzebna. Oferty
    i tak pojawiają się dopiero po samouczku i 5 min gry (02 R-AD-5),
    a pierwsze sekundy gry należą do zegara (02 R-TUT-0);
  - załadowana reklama jest ważna ok. godziny: po 55 min jest wymieniana
    na nową, żeby wyświetlenie się udało i zostało policzone;
  - błąd wyświetlenia daje komunikat „nie udało się wyświetlić”, a nie
    „nie obejrzana do końca” (02 R-AD-8), i nie zużywa oferty;
  - polityka prywatności i `app-ads.txt` na `https://dombearx.github.io`
    (01, „Strona WWW bez domeny”);
  - ankieta Data Safety: `store/PLAY_CONSOLE.md` §5 (reklamy, statystyki,
    raporty o awariach, zapis w chmurze).
- **T-28:** Podczas tworzenia gry używamy **wyłącznie testowych jednostek
  reklamowych** Google. Prawdziwe ID trafiają tylko do wersji wydawanej.
  Klikanie własnych prawdziwych reklam grozi blokadą konta AdMob.
- **T-29:** Logika ofert (czasy odnowienia, zapas Turbo, warunki pojawienia
  się) jest w `lib/engine`, a nie w warstwie reklam, więc testy i symulator
  działają z atrapą `RewardedAds`.
- **T-30:** Statystyki gry zbieramy w **Firebase Analytics** (§8a).
  Wyjątki Darta, które Flutter przechwytuje i których Android vitals nie
  widzi, trafiają do **Firebase Crashlytics** (darmowe; pełny stos
  wywołań, wersje, urządzenia). Wcześniej było to zdarzenie `app_error`
  w Analytics, ucięte do 100 znaków. Awarie natywne dalej pokazuje Play
  Console (Android vitals). Bez wtyczki Gradle Crashlytics (zasób
  `com.google.firebase.crashlytics.RequireBuildId=false`): wysyłamy tylko
  błędy Darta, a ich stosy są czytelne bez mapowania. Zbieranie jest
  wyłączone w manifeście (`firebase_crashlytics_collection_enabled`)
  i podlega tej samej zgodzie co statystyki (T-33). Przychód
  i oglądalność reklam widać w panelu AdMob.
- **T-27:** Brak reklamy (offline, błąd ładowania) oznacza, że przycisk jest
  wyszarzony z opisem. Gra nigdy nie czeka na reklamę.

## 8a. Statystyki gry (Firebase Analytics)

Cel: stroić ekonomię i samouczek na danych prawdziwych graczy, a nie tylko
symulatora (03). Firebase Analytics jest darmowy bez limitu liczby zdarzeń.
Limit wynosi 500 różnych nazw zdarzeń i 25 właściwości gracza.

- **T-31:** Kod gry loguje przez interfejs `Analytics`
  (`lib/analytics`, czysty Dart, T-3). Firebase jest za nim tylko
  w `lib/ui/analytics_device.dart`. Web i testy używają `NoAnalytics`
  / `RecordingAnalytics`.
- **T-32:** Projekt Firebase trafia do gry tylko przez `--dart-define`
  (`FIREBASE_APP_ID`, `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`,
  `FIREBASE_SENDER_ID`). Bez `google-services.json` i bez wtyczki Gradle.
  Dostaje go tylko wydanie do Play (CI, sekrety). APK testowe nic nie
  wysyłają, tak jak nie klikamy własnych reklam (T-28).
- **T-33:** Prywatność:
  - zbieranie jest wyłączone w manifeście
    (`firebase_analytics_collection_enabled=false`) i włącza je dopiero
    zgoda gracza. Tam, gdzie prawo jej wymaga (EOG, Wielka Brytania;
    odpowiedź z kontroli zgody UMP przy starcie, a gdy jej brak — jak
    w EOG), statystyki i raporty o awariach **czekają na telefonie**
    (najwyżej 300 zdarzeń, `ConsentAwareAnalytics`), a gra pyta
    („Pomożesz dopracować grę?”) po samouczku. „Tak” wysyła zatrzymane
    zdarzenia (lejek samouczka nie ginie) i raporty, „Nie” je kasuje.
    Domyślnie zaznaczone pole nie jest zgodą w rozumieniu RODO. Poza EOG
    statystyki są włączone od razu, z wyłącznikiem w ustawieniach.
    Wybór w ustawieniach też jest odpowiedzią; dawne „wyłączone” liczy się
    jako odpowiedź „nie”;
  - bez identyfikatora reklamowego
    (`google_analytics_adid_collection_enabled=false`);
  - bez sygnałów personalizacji reklam;
  - Consent Mode: `ad_*` zawsze odmowa, `analytics_storage` według
    ustawienia;
  - bez `setUserId`, bez imion i bez tekstów wpisanych przez gracza.
- **T-34:** Zdarzenia. Każde ma też `run` (liczba prestiży) i `play_min`
  (minuty gry od instalacji):

  | Zdarzenie | Parametry | Po co |
  |---|---|---|
  | `tutorial_step` | `step` | lejek samouczka: gdzie odpadają nowi |
  | `tutorial_complete` | `at_step`, `rounds` | ukończony (`autoStart`) czy pominięty |
  | `tutorial_replay` | – | czy samouczek jest niejasny |
  | `accuracy` | `rounds`, `typical_ms`, `mean_ms`, `perfect_pct`, `miss_pct` | jak szybko gracze uczą się trafiać (po 10, 50, 200, 1000, 5000 rundach) |
  | `generator_first` | `id` | tempo progresji: minuta pierwszego zegara każdego rodzaju (cele B-x z 03) |
  | `skill_buy` | `id`, `level` | które umiejętności kupują i kiedy |
  | `perk_buy` | `id`, `shards` | wybory po prestiżu |
  | `prestige` | `chronons`, `top_clock` | kiedy i z jakim zegarem robią paradoks |
  | `ad_offer` | `offer`, `watch` | ile osób przyjmuje każdą ofertę |
  | `ad_reward` / `ad_closed_early` | `offer` | czy reklamy są oglądane do końca |
  | `ad_show_failed` | `offer` | reklama załadowana, ale nie wyświetliła się (np. przeterminowana) |
  | `ad_unavailable` | `offer` | brak reklamy (fill rate) |
  | `offline_collect` | `away_min`, `capped` | jak długie są przerwy i czy limit offline ich nie ucina |
  | `daily_collect` | `day`, `grace` | seria dziennej premii; czy uratował ją dzień łaski (R-DZIEN-3) |
  | `golden_catch` | – | czy złota sekunda jest łapana |
  | `unlock_achievement` | `achievement_id` | które osiągnięcia są za łatwe lub za trudne |
  | `season_complete` | `season` | wydarzenia sezonowe |
  | `clock_level` | `id`, `level`, `springs` | mistrzostwo (02 R-SPR-5): który zegar gracze podnoszą — wczesne, późne czy tylko ostatni |
  | `loop_done` | `loop`, `rule`, `play_min`, `paradoxes` | pętle czasu (02 §16): ilu graczy dochodzi do Chronosa i po jakim czasie w porównaniu z 03 §4.4 |
  | `loop_start` | `loop`, `rule`, `springs` | ilu graczy po Chronosie zaczyna następną pętlę |
  | `dial_unlock` | `id` | tarcze (12 §3.3): kiedy padają w porównaniu z `idle_sim.dart` |
  | `mode_toggle` | `mode`, `on` | czy tryby są używane |
  | `review_prompt` | – | ile razy gra poprosiła o ocenę (02 R-OCENA-1) |
  | `challenges_unlocked` | – | kiedy gracze dostają pierwsze wyzwania (`play_min`); porównanie retencji D1/D7 (14 §7) |
  | `challenge_done` | `kind`, `weekly`, `target` | które wyzwania gracze kończą i przy jakich liczbach (02 §18) |
  | `challenge_reroll` | `kind` | które rodzaje gracze wymieniają (za trudne albo nudne) |
  | `cloud_offer` | `load`, `lead_min` | zapis z chmury: wczytany czy nie, ile minut gry przewagi (T-35) |
  | `cloud_connect` | `ok` | połączenie z Play Gry z ustawień |
  | `calibration` | `offset_ms`, `spread_ms`, `used`, `applied` | opóźnienie prawdziwych telefonów (Firebase dodaje model); tylko z flagą T-13 |

  Wyjątki Darta idą do Crashlytics (T-30), nie jako zdarzenie.

  Właściwości gracza: `prestiges`, `top_clock`, `tutorial_done`.
  Firebase sam zbiera `first_open`, `session_start`, czas zaangażowania,
  retencję, kraj, urządzenie i wersję gry. Gdy AdMob jest połączony
  z projektem Firebase, w statystykach pojawia się też `ad_impression`.
  Nowe zdarzenia dopisujemy najpierw do tej tabeli.

## 9. Wydanie (M6)

- Android: `applicationId` = `io.github.dombearx.hit10`. Bez własnej domeny
  używamy odwróconej domeny GitHub Pages. Identyfikatora nie da się zmienić
  po pierwszym wydaniu. Klucz
  podpisu poza repo, wersjonowanie `versionName+versionCode`, AAB do
  Play Console.
- Ikona adaptacyjna, ekran startowy w kolorach gry, nazwa w sklepie PL/EN.
