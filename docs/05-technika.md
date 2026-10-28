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
- Tłumaczenia: `flutter_localizations` + ARB (`gen-l10n`).
- **T-1:** Szablon `MobileAppTemplate` nie jest używany. Projekt startuje
  z `flutter create`. Ze szablonu można później podejrzeć kroki podpisywania
  i wydania (M6).
- **T-2:** Żadnego backendu ani Firebase. Bez uprawnienia `INTERNET` aż do M6
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
  zdarzenia, z odczytu `Stopwatch` w tej chwili. Do czasu z zegara
  rzeczywistego stosuje się mapowanie z R-RUNDA-10/11.
- **T-10:** Pomiar musi być odporny na spadki klatek: ocena nie zależy od
  tego, kiedy wyrenderowała się ostatnia klatka.
- **T-11:** Mapowanie czas rzeczywisty → czas gry (Przewijanie, bullet time,
  Szybki zegar) to czysta funkcja przedziałami liniowa w `lib/model`,
  z odwrotnością (do planowania animacji). Pokrywają ją testy.
- **T-12:** Tryb diagnostyczny (ukryty, np. 7 dotknięć w wersję w
  ustawieniach) pokazuje:
  - różnicę `PointerEvent.timeStamp` → odczyt `Stopwatch`,
  - czasy klatek,
  - histogram błędów ostatnich 100 rund.

  Służy do sprawdzenia T-9 na prawdziwych telefonach (06, test ręczny M-1).
- **T-13:** Opóźnienie ekranu dotykowego (stałe, zwykle 20–60 ms) **nie** jest
  kompensowane automatycznie. Gracze uczą się go sami, a statystyka
  „średni błąd” (R-STAT-1) im w tym pomaga. Kalibracja może dojść później,
  jeśli testy pokażą potrzebę.

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
  główny plik jest uszkodzony.
- **T-19:** Eksport to JSON → gzip → base64 jako tekst do schowka. Import
  robi to samo w drugą stronę, z walidacją i potwierdzeniem nadpisania.
- **T-20:** Uszkodzony zapis i brak kopii oznaczają komunikat i start od zera,
  a nie wyłożenie się aplikacji.
- **T-32:** Zapis jest objęty **kopią zapasową Androida** (Auto Backup na
  koncie Google, darmowa, bez backendu). Po zmianie telefonu postęp wraca
  sam. Kopią objęty jest tylko plik zapisu, bez ustawień urządzenia.

## 7. Wydajność i jakość

- **T-21:** Stabilne 60 fps (i 120 na ekranach 120 Hz) na średniaku sprzed
  ok. 3–4 lat, także przy PERFEKT z pełnymi cząsteczkami i w Szale.
  Cząsteczki z puli obiektów, bez alokacji w każdej klatce.
- **T-22:** Zimny start do ekranu gry poniżej 2 s na tym samym urządzeniu.
- **T-23:** Rozmiar pobieranego AAB/APK poniżej 40 MB.
- **T-24:** `flutter analyze` bez ostrzeżeń, `dart format`, wszystkie testy
  zielone (06). Do repo dochodzi `Makefile` z `make check`.
- **T-31:** **CI w GitHub Actions** (darmowe minuty, bez stałych kosztów):
  - każdy push uruchamia `make check` i symulator `--check`, a potem buduje
    debug APK jako artefakt;
  - tag `m0`…`m6` tworzy GitHub Release z APK, który właściciel pobiera
    i instaluje prosto na telefonie (włączona „instalacja z nieznanych
    źródeł”).

## 8. Reklamy (M6, przygotowanie od początku)

- **T-25:** Od M1 w kodzie istnieje interfejs `RewardedAds`
  (`isReady`, `show() → Future<bool>`) z implementacją-atrapą, która zawsze
  „daje” nagrodę po 1 s. Ekrany korzystają tylko z tego interfejsu.
- **T-26:** W M6 dochodzi implementacja z `google_mobile_ads` (wyłącznie
  format rewarded) i formularzem zgody **UMP** (wymagany w UE). Do tego:
  - polityka prywatności i `app-ads.txt` na `https://dombearx.github.io`
    (01, „Strona WWW bez domeny”);
  - ankieta Data Safety: reklamy zbierają identyfikator reklamowy, a gra
    sama nic nie zbiera i niczego nie wysyła.
- **T-28:** Podczas tworzenia gry używamy **wyłącznie testowych jednostek
  reklamowych** Google. Prawdziwe ID trafiają tylko do wersji wydawanej.
  Klikanie własnych prawdziwych reklam grozi blokadą konta AdMob.
- **T-29:** Logika ofert (czasy odnowienia, zapas Turbo, warunki pojawienia
  się) jest w `lib/engine`, a nie w warstwie reklam, więc testy i symulator
  działają z atrapą `RewardedAds`.
- **T-30:** Brak analityki i Crashlytics. Raporty awarii dostarcza za darmo
  Google Play Console (Android vitals), bez żadnego SDK. Przychód
  i oglądalność reklam widać w panelu AdMob.
- **T-27:** Brak reklamy (offline, błąd ładowania) oznacza, że przycisk jest
  wyszarzony z opisem. Gra nigdy nie czeka na reklamę.

## 9. Wydanie (M6)

- Android: `applicationId` = `io.github.dombearx.hit10`. Bez własnej domeny
  używamy odwróconej domeny GitHub Pages. Identyfikatora nie da się zmienić
  po pierwszym wydaniu. Klucz
  podpisu poza repo, wersjonowanie `versionName+versionCode`, AAB do
  Play Console.
- Ikona adaptacyjna, ekran startowy w kolorach gry, nazwa w sklepie PL/EN.
