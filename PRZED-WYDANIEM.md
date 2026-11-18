# Przed wydaniem wersji 1.1 — podsumowanie i lista do zrobienia

Stan na 18.11.2026. Gałąź `ccr-85b95daf-fiqaid` w repo `Dombearx/Hit10`,
CI zielone (testy, symulator balansu, APK, AAB, uruchomienie na emulatorze).
Gałąź **nie jest jeszcze scalona do `main`**. Scalenie do `main` = CI samo
wysyła podpisany AAB na test zamknięty „Testerzy” w Google Play.

Dokument ma dwie części: **A — co jest zrobione** (do wiadomości) i **B — co
trzeba wyklikać** (dla człowieka albo agenta z przeglądarką). Szczegóły
zasad są w `docs/02`, techniki w `docs/05`, kont i konsol w
`store/PLAY_CONSOLE.md`.

---

## A. Co jest zrobione

### A1. Gra (kod na gałęzi)

| Co | Gdzie opisane |
|---|---|
| Dotknięcie liczone od znacznika czasu systemu, nie od chwili, gdy zajęty wątek UI je obsłużył (uczciwszy pomiar) | `docs/05` T-10 |
| Kalibracja opóźnienia dotyku (test 10 dotknięć w ustawieniach) **za flagą `FEATURE_CALIBRATION`**: włączona w testowym APK z CI i w `make apk`, wyłączona w wydaniu do Play | `docs/05` T-13, `docs/07` „Funkcje za flagą” |
| Pierwsze sekundy gry bez okien: prolog po pierwszych Tikach; zgoda na reklamy (UMP) i pytanie o statystyki dopiero po samouczku | `docs/02` R-TUT-0, `docs/05` T-26, T-33 |
| Statystyki i raporty o awariach w UE czekają na zgodę gracza (zatrzymane na telefonie, po „tak” wysyłane, po „nie” kasowane) | `docs/05` T-33 |
| Crashlytics zamiast zdarzenia `app_error` (bez wtyczki Gradle; tylko błędy Darta) | `docs/05` T-30 |
| Reklamy: wymiana załadowanej reklamy po 55 min, osobny komunikat, gdy reklama się nie wyświetli | `docs/02` R-AD-3, R-AD-8 |
| Zapis w chmurze przez Google Play Gry — **gotowy w kodzie, nieaktywny**, dopóki nie skonfigurujesz Play Games (B5) | `docs/05` T-35 |
| Prośba o ocenę w sklepie: późno (≥3 h gry, ≥3 dni), po 2. paradoksie, ukończeniu pętli albo wydarzenia; najwyżej 2 razy | `docs/02` §17 R-OCENA-1 |
| Przypomnienia: limit offline, dzienna premia, pełny zapas dokręcania; najwyżej 2 na nieobecność, nigdy 22:00–9:00 | `docs/02` §10.1 R-POW |
| Jedno okno „Witaj z powrotem” (offline + dzienna premia, „Odbierz wszystko”) | `docs/02` R-OFF-2, `docs/04` U-34 |
| Dzień łaski w dziennej premii (1 pominięty dzień w tygodniu nie zeruje serii) | `docs/02` R-DZIEN-3 |
| Kupowanie zegarów „PRÓG” (do następnego bonusu ×2) | `docs/02` R-GEN-2 |
| Bateria: arena przestaje rysować, gdy nic się nie rusza (pauza) | `docs/05` T-21a |
| Zapisy gry nigdy się nie nakładają | `docs/05` T-18 |
| Duża czcionka systemowa: tekst rośnie najwyżej ×1.3; test układu | `docs/04` U-35 |
| **Wyzwania dzienne (3) i tygodniowe (1)**, liczby dopasowane do celności gracza (symulacja z jego dotknięć), pojawiają się 3 min gry po końcu samouczka, pierwszy zestaw łatwiejszy | `docs/02` §18, `docs/14` |
| Nowe zdarzenia Analytics: `challenge_done`, `challenge_reroll`, `challenges_unlocked`, `calibration`, `cloud_offer`, `cloud_connect`, `ad_show_failed`, `review_prompt`, parametr `grace` w `daily_collect` | `docs/05` T-34 |
| Dokumentacja 01, 02, 04, 05, 06, 07, 14, `store/PLAY_CONSOLE.md`, `store/listing.md` zaktualizowane | — |

### A2. Strona WWW

- **Zrobione:** nowa polityka prywatności (Crashlytics, zgoda w UE, zapis
  w chmurze, przypomnienia) — PR
  https://github.com/Dombearx/Dombearx.github.io/pull/1 scalony 18.11.2026.

---

## B. Co trzeba wyklikać

Kolejność ma znaczenie. **B1–B3 blokują wydanie**, reszta jest zalecana albo
opcjonalna. Przy każdym kroku: gdzie, co kliknąć, jakie wartości, jak
sprawdzić.

### Zasady dla agenta wykonującego kroki

- Nie wpisuj nigdzie haseł ani kluczy, których nie masz. Gdy krok wymaga
  sekretu (klucz, JSON konta usługi), zatrzymaj się i poproś człowieka.
- Nie zmieniaj ustawień spoza tej listy.
- Przed krokami nieodwracalnymi albo publicznymi zapytaj człowieka:
  scalenie do `main` (B8 — wysyła wersję do testerów), opublikowanie
  konfiguracji Play Games (B5, krok 8), wysłanie formularza do sprawdzenia.
- Interfejs Play Console bywa po polsku albo angielsku; nazwy podane są po
  polsku z angielskim odpowiednikiem w nawiasie. Gdy menu wygląda inaczej,
  użyj wyszukiwarki u góry konsoli.

### B1. Sprawdź opublikowaną politykę prywatności — blokuje

1. Otwórz https://dombearx.github.io/hit5/privacy.html
2. U góry ma być „Obowiązuje od / Effective: **2026-11-18**”, a w treści
   sekcje „Statystyki gry i raporty o awariach” i „Zapis w chmurze (Google
   Play Gry)”.
3. Jeśli jest stara data (2026-11-03), odczekaj kilka minut (GitHub Pages)
   i odśwież; jeśli dalej stara: repo `Dombearx/Dombearx.github.io` →
   Actions → sprawdź, czy wdrożenie Pages się udało.

### B2. Play Console: Bezpieczeństwo danych (Data safety) — blokuje

Gdzie: https://play.google.com/console → aplikacja **Hit5: Zatrzymaj stoper
na 5.00** → lewe menu **Monitoruj i ulepszaj** (Monitor and improve) →
**Zasady i programy** (Policy and programs) → **Treść aplikacji** (App
content) → **Bezpieczeństwo danych** (Data safety) → **Zarządzaj**.

**Krok 1 — Przegląd:** Dalej.

**Krok 2 — Zbieranie danych i bezpieczeństwo:**

| Pytanie | Odpowiedź |
|---|---|
| Czy aplikacja zbiera lub udostępnia wymagane typy danych? | **Tak** |
| Czy dane są szyfrowane podczas przesyłania? | **Tak** |
| Metody tworzenia konta | **Moja aplikacja nie umożliwia użytkownikom tworzenia konta** |
| Logowanie kontami utworzonymi poza aplikacją? | **Nie** (zmienić na „Tak” dopiero po włączeniu Play Games, B5) |
| Prośba o usunięcie danych (opcjonalne) | **„Nie, ale dane użytkownika są usuwane automatycznie w ciągu 90 dni”** — tylko jeśli B4 potwierdzi przechowywanie danych Analytics 2 miesiące; w przeciwnym razie **Nie** |

**Krok 3 — Typy danych.** Zaznacz **tylko** te:

- **Identyfikatory urządzenia lub inne** (Device or other IDs)
- **Aktywność w aplikacji → Interakcje z aplikacją** (App activity → App
  interactions)
- **Informacje o aplikacji i jej wydajność → Logi awarii** (Crash logs)
- **Informacje o aplikacji i jej wydajność → Diagnostyka** (Diagnostics)

Nie zaznaczaj: lokalizacji, danych osobowych, finansowych, zdrowia,
wiadomości, zdjęć, plików, kalendarza, kontaktów, wyszukiwań, innych
działań (to ostatnie dopiero z Play Games, B5).

**Krok 4 — Wykorzystanie i przetwarzanie danych**, dla każdego typu:

| Typ | Zbierane | Udostępniane | Przetwarzane tymczasowo | Wymagane czy opcjonalne | Cele |
|---|---|---|---|---|---|
| Identyfikatory urządzenia lub inne | Tak | **Tak** (AdMob) | Nie | **Wymagane** | Reklamy lub marketing; Analityka |
| Interakcje z aplikacją | Tak | Nie | Nie | **Użytkownicy mogą wybrać** (opcjonalne) | Analityka |
| Logi awarii | Tak | Nie | Nie | **Użytkownicy mogą wybrać** | Analityka |
| Diagnostyka | Tak | Nie | Nie | **Użytkownicy mogą wybrać** | Analityka |

„Nieudostępniane” przy danych Firebase, bo Firebase przetwarza je w imieniu
twórcy (dostawca usług). „Opcjonalne”, bo gracz może nie wyrazić zgody albo
wyłączyć statystyki w ustawieniach.

**Krok 5 — Podgląd:** sprawdź zgodność z tabelą wyżej → **Zapisz** (Save).
Zmiana trafi do sprawdzenia razem z najbliższą wersją.

### B3. Firebase: włącz Crashlytics — blokuje (inaczej raporty nie są widoczne)

1. https://console.firebase.google.com → projekt **Hit5**.
2. Lewe menu: **Crashlytics** (kategoria „Run” / „Uruchamianie”; albo
   wyszukaj „Crashlytics”).
3. Wybierz aplikację Android `io.github.dombearx.hit10` → **Włącz
   Crashlytics** (Enable Crashlytics).
4. Nic więcej nie konfiguruj: **nie** dodawaj wtyczki Gradle ani
   `google-services.json` — gra ich celowo nie używa (`docs/05` T-30, T-32).
5. Sprawdzenie: ekran Crashlytics pokazuje „czeka na pierwszy raport”
   (Waiting for first report). Pierwszy raport pojawi się po pierwszym
   błędzie u gracza, który zgodził się na statystyki.

### B4. Google Analytics: przechowywanie danych 2 miesiące — zalecane

1. https://analytics.google.com → usługa (property) połączona z projektem
   Firebase **Hit5**.
2. **Administracja** (koło zębate, Admin) → **Gromadzenie i modyfikowanie
   danych** (Data collection and modification) → **Przechowywanie danych**
   (Data retention).
3. **Przechowywanie danych o zdarzeniach** (Event data retention):
   **2 miesiące** → Zapisz. (Tak mówi polityka prywatności.)
4. W tym samym miejscu **Sygnały Google** (Google signals) mają być
   **wyłączone**.

### B4a. Google Analytics: wymiary niestandardowe — opcjonalne

Bez tego zdarzenia się zbierają, ale ich parametrów nie widać w raportach.
**Administracja → Wyświetlanie danych → Definicje niestandardowe** (Custom
definitions) → **Utwórz wymiar niestandardowy**, zakres **Zdarzenie**
(Event), dla każdego parametru:

| Parametr zdarzenia | Nazwa wymiaru | Zdarzenia |
|---|---|---|
| `kind` | Rodzaj wyzwania | `challenge_done`, `challenge_reroll` |
| `weekly` | Wyzwanie tygodniowe | `challenge_done` |
| `grace` | Dzień łaski | `daily_collect` |
| `load` | Chmura: wczytano | `cloud_offer` |
| `applied` | Kalibracja zastosowana | `calibration` |
| `offer` | Oferta reklamy | `ad_*` (jeśli jeszcze nie ma) |

Jako **dane niestandardowe** (Custom metric, zakres Zdarzenie, jednostka
standardowa): `target` (`challenge_done`), `offset_ms` i `spread_ms`
(`calibration`, jednostka milisekundy), `lead_min` (`cloud_offer`).
Parametr już zarejestrowany pomiń.

### B5. Play Games Services (zapis w chmurze) — opcjonalne

Bez tego gra działa normalnie, tylko nie ma wiersza „Zapis w chmurze”.
Pełny opis: `store/PLAY_CONSOLE.md` §2b.

1. Play Console → aplikacja Hit5 → lewe menu **Zwiększaj liczbę
   użytkowników** (Grow users) → **Usługi gier Play** (Play Games Services)
   → **Konfiguracja i zarządzanie** (Setup and management) →
   **Konfiguracja** (Configuration).
2. Wybierz **„Nie, moja gra nie korzysta z interfejsów Google API”** →
   nazwa projektu **Hit5** → Utwórz.
3. **Dane logowania** (Credentials) → **Dodaj dane logowania** → Android →
   pakiet `io.github.dombearx.hit10` → utwórz klienta OAuth z odciskiem
   **SHA-1 klucza podpisywania aplikacji**: Play Console → **Testuj
   i publikuj** → **Integralność aplikacji** (App integrity) →
   **Podpisywanie aplikacji** (App signing) → skopiuj „Odcisk cyfrowy
   certyfikatu SHA-1” klucza podpisywania aplikacji.
4. Drugie dane logowania z SHA-1 **klucza przesyłania** (upload key) — ten
   sam ekran „Podpisywanie aplikacji” pokazuje też certyfikat klucza
   przesyłania. (Potrzebne, żeby testowe APK też się logowały.)
5. **Właściwości** (Properties) → **Zapisane gry** (Saved Games): **Wł.**
6. **Testerzy** (Testers) → dodaj konta Google testerów (te same co w teście
   zamkniętym).
7. Skopiuj **Identyfikator projektu** (Project ID — długa liczba u góry
   ekranu Konfiguracja) i dodaj jako sekret GitHub: https://github.com/Dombearx/Hit10
   → Settings → Secrets and variables → Actions → **New repository secret**
   → nazwa `PLAY_GAMES_APP_ID`, wartość: ten identyfikator.
8. **Nie publikuj** jeszcze konfiguracji Play Games — dopiero gdy testerzy
   sprawdzą zapis w chmurze (test M-12 w `docs/06`). Wtedy: **Sprawdź
   i opublikuj** (Review and publish) — zapytaj człowieka.
9. Po włączeniu: w B2 dodaj typ **Aktywność w aplikacji → Inne działania**
   (zebrane, nieudostępniane, opcjonalne, cel: Funkcje aplikacji) i zmień
   „Logowanie kontami spoza aplikacji” na **Tak**.

### B6. Numer wersji — zalecane (zmiana w repo)

W `app/pubspec.yaml` zmień `version: 1.0.0+1` na `version: 1.1.0+1`,
commit na gałąź `ccr-85b95daf-fiqaid`. Numer kompilacji (versionCode) CI
ustawia samo z numeru przebiegu.

### B7. Notatka „Co nowego” dla testerów — zalecane

CI nie dodaje notatki. Po wysłaniu wersji (B8): Play Console → **Testuj
i publikuj** → **Testowanie** → **Testy zamknięte** → **Testerzy** →
najnowsza wersja → informacje o wersji. Każdy tekst ≤ 500 znaków.

**pl-PL:**

> Nowości: wyzwania dnia i tygodnia dopasowane do Twojej celności; jedno
> okno „Witaj z powrotem” z dochodem offline i dzienną premią; dzień łaski
> — jeden pominięty dzień w tygodniu nie zeruje serii; kupowanie zegarów
> „PRÓG”; dokładniejszy pomiar dotknięcia; mniejsze zużycie baterii na
> pauzie; przypomnienia (najwyżej dwa, nigdy w nocy). W UE gra raz zapyta
> o zgodę na statystyki i raporty o awariach.

**en-US:**

> New: daily and weekly challenges sized to your aim; one "Welcome back"
> window for offline income and the daily bonus; a grace day — one missed
> day a week keeps your streak; the "BONUS" buy mode for clocks; more
> accurate tap timing; less battery use while paused; reminders (two at
> most, never at night). In the EU the game asks once about statistics
> and crash reports.

### B8. Wydanie do testerów — po B1–B3 (zapytaj człowieka przed scaleniem)

1. https://github.com/Dombearx/Hit10 → **Pull requests** → **New pull
   request** → base `main`, compare `ccr-85b95daf-fiqaid` → Create.
2. Poczekaj na zielone CI na PR → **Merge**.
3. CI na `main` zbuduje podpisany AAB i wyśle go na tor **Testerzy** (job
   `play`; wymaga sekretu `PLAY_SERVICE_ACCOUNT_JSON`, który już powinien
   być). Bez sekretu: pobierz artefakt `hit5-aab` (plik `…-signed.aab`)
   z przebiegu CI i wgraj ręcznie w Play Console → Testy zamknięte →
   Testerzy → Utwórz wersję.
4. Google sprawdza wersję (zwykle kilka godzin). Testerzy dostaną
   aktualizację; gra sama zaproponuje restart (in-app update).

---

## C. Dla człowieka (nie do wyklikania)

### C1. Test na telefonie przed B8 — zalecane

Testowe APK: GitHub → Hit10 → **Actions** → ostatni zielony przebieg gałęzi
`ccr-85b95daf-fiqaid` → artefakt **hit5-apk** (ma włączoną kalibrację).
Najlepiej po wyczyszczeniu danych aplikacji:

- [ ] przed pierwszym dotknięciem zegara nie ma żadnego okna; prolog po
      pierwszych Tikach;
- [ ] po samouczku (z UE): pytanie o statystyki, potem formularz zgody na
      reklamy;
- [ ] ok. 3 min po samouczku: plakietka wyzwań + wskazówka; jedno wyzwanie
      ukończ i odbierz;
- [ ] po przerwie > 30 min: jedno okno „Witaj z powrotem”;
- [ ] reklama obejrzana do końca daje nagrodę, przerwana nic;
- [ ] Ustawienia → Kalibracja opóźnienia: test działa, przesunięcie się
      zapisuje;
- [ ] pauza ⏸, kilka sekund, dotknięcie od razu wznawia grę.

Pełna lista testów ręcznych: `docs/06` (M-1…M-13).

### C2. Testerzy

- Uprzedź testerów z UE, że raz zobaczą pytanie o statystyki.
- Test zamknięty: Play wymaga ≥ 12 testerów przez 14 dni (teraz 7).

### C3. Otwarte decyzje (na później)

| Decyzja | Kiedy |
|---|---|
| Włączyć kalibrację wszystkim (`FEATURE_CALIBRATION`) | po teście M-1 z kalibracją na ≥ 2 telefonach (`docs/05` T-13) |
| Bonus za trafienie przy powrocie do gry (punkt 5 z przeglądu: celowanie a dochód offline) | odłożone — do dokładniejszej analizy |
| Kolejne zdarzenia Analytics: `session_summary`, `notification_open`, otwieranie arkuszy, wskazówki | do decyzji |
| Opublikowanie konfiguracji Play Games | po teście M-12 (B5) |
