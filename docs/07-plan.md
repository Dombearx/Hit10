# 07 — Plan implementacji

Każdy etap kończy się **APK do zainstalowania na telefonie** (GitHub Release
z tagiem `m0`…`m6`, T-31). Kolejność jest ustawiona tak, żeby jak
najwcześniej sprawdzić to, co najbardziej ryzykowne: czy klikanie w 10.00
jest uczciwe i czy daje frajdę.

Etap jest zaliczony, gdy spełnia kryteria z
[06 §3](06-testy-i-akceptacja.md#3-kryteria-akceptacji-etapów): testy
automatyczne przechodzą, testy ręczne etapu są zaliczone, a `make check` i CI
są zielone.

```
M0 Szkielet ─► M1 Rdzeń ─► ⏸ „czy to fajne?” ─► M2 Ekonomia ─► M3 Umiejętności ─► ⏸ „czy to fajne?”
          ─► M4 Głębia ─► M5 Oprawa ─► M6 Wydanie (test zamknięty 14 dni) ─► Google Play
```

---

## M0 — Szkielet

**Cel:** pusty, ale kompletny projekt, który buduje się w CI i instaluje na
telefonie.

- [x] `flutter create` w `app/` (Android, pion, `applicationId`
      `io.github.dombearx.hit10`), struktura katalogów z 05 §2
- [x] Zależności: Riverpod, Flame, `flutter_animate`, `flutter_soloud`,
      `path_provider`, l10n PL/EN (`gen-l10n`), czcionki Paytone One i Nunito
- [x] `assets/balance.json` z liczbami z 02/03 i walidacją przy starcie
      (T-5…T-7)
- [x] Atrapa `RewardedAds` (T-25)
- [x] Test architektury: `lib/model` i `lib/engine` bez Fluttera (T-3)
- [x] `Makefile`: `make check` (analyze, format, test)
- [x] GitHub Actions: `make check` i debug APK na każdy push, Release na tag
      (T-31)
- [x] `CREDITS.md` z pierwszymi wpisami (czcionki)

**Gotowe, gdy:** APK z `m0` instaluje się na twoim telefonie i pokazuje
ekran z napisem „Hit5” po polsku albo po angielsku, zależnie od języka
telefonu.

## M1 — Rdzeń

**Cel:** sama runda „kliknij w 10.00”, uczciwa i przyjemna. Bez sklepu.

- [x] Model: ocena i progi, mapowanie czasu rzeczywistego na czas gry (na
      razie bez ulepszeń), wypłata bazowa (R-RUNDA-1…9, R-PROG-*, T-11)
- [x] Pomiar dotknięcia: `Listener.onPointerDown` + `Stopwatch` (T-8…T-10)
- [x] Arena we Flame: tarcza, cyfry (tabular), pierścień postępu
- [x] Efekty PERFEKT / ŚWIETNIE / DOBRZE / PUDŁO, z dźwiękiem i wibracją
      (04 §3, U-14, U-15)
- [x] Saldo Tików z animowanym licznikiem
- [x] Tryb diagnostyczny: histogram błędów, czasy klatek (T-12)
- [x] Pierwsze dźwięki z Kenneya i jsfxr

**Testy ręczne:** M-1 (precyzja), M-2 (uczciwość pod obciążeniem), M-6
(dźwięk).

**⏸ Przerwa „czy to fajne?”:** grasz kilka dni i notujesz uwagi.
Rozstrzygamy też, czy potrzebna jest kalibracja opóźnienia ekranu (T-13).

## M2 — Ekonomia

**Cel:** pętla „zarabiam → kupuję → zarabiam więcej” działa i się zapisuje.

- [x] Model: generatory 1–12, ceny ×1/×10/×100/MAX, dochód z zyskiem okien,
      ulepszenia generatorów, synergie (02 §5, 03 §2)
- [x] Silnik: tyk ekonomii 10×/s, „trafienia generatorów” jako efekt (T-14,
      T-15)
- [x] Sklep „Zegary”: karty z emoji (04 §4.1), pasek ulepszeń, sylwetki
      „???”
- [x] Zapis: atomowy, kopia, migracje, eksport/import (T-17…T-20)
- [x] Offline z oknem „Gdy cię nie było…” (R-OFF-1…3)
- [x] Symulator w Dart (`tool/simulate.dart --check`) z tym samym kodem
      ekonomii co gra. Wyniki porównane z `design/` (06 §1.2).

**Testy ręczne:** M-4 (cykl życia), M-5 (zmiana daty).

## M3 — Umiejętności i Złota Sekunda

**Cel:** gracz ma na co wydawać i czuje, że rośnie w siłę.

- [x] Wszystkie 11 umiejętności (02 §4), sklep „Umiejętności” z „przed → po”
- [x] Przewijanie i bullet time z efektami i filtrami dźwięku
      (R-RUNDA-10…13, U-19)
- [x] Combo, Tarcza, Echo (02 §3)
- [x] Złota Sekunda z trzema efektami (02 §6)
- [x] `--check` sprawdza wszystkie cele B-1…B-10 (mediana z 5 ziaren)

**Testy ręczne:** M-3 (wydajność).

**⏸ Przerwa „czy to fajne?”:** godzina–dwie grania, uwagi do tempa
i balansu. Zmiany liczb wpisujemy do 02/03.

## M4 — Głębia

**Cel:** treść na tygodnie i przygotowane miejsca na reklamy.

- [x] Osiągnięcia, ok. 100, z warunkami generowanymi z tabeli (02 §8)
- [x] Tryby: Na ślepo, Szybki zegar (02 §7)
- [x] Prestiż, Chronony, Okruchy, drzewko perków, drugi zegar,
      generatory 13–14 (02 §9)
- [x] Statystyki (02 §12) i samouczek (02 §11)
- [x] Powiadomienie o pełnym limicie offline (R-OFF-4, R-OFF-5)
- [x] Logika 5 ofert reklamowych na atrapie, z przyciskami w UI (02 §13,
      04 §5a, T-29). `--check` sprawdza też A-1 i A-2.

**Testy ręczne:** M-8, pierwsze podejście: 3 osoby grają 15 min; M-11 (powiadomienie).

## M5 — Oprawa

**Cel:** gra wygląda i brzmi jak gotowy produkt.

- [x] Docelowa paleta i tokeny (04 §4), karty emoji dla wszystkiego (U-10…U-12)
- [x] Ikona aplikacji i złoty zegarek jako SVG (U-26, U-27)
- [x] Pełna tabela efektów z 04 §3, „Ogranicz ruch” (U-6)
- [x] Muzyka (3 pętle) i wszystkie efekty dźwiękowe (U-13, U-19…U-21)
- [x] Wszystkie teksty i humor PL/EN: 112 nazw ulepszeń, opisy, osiągnięcia
      (R-ULEP-2)
- [x] Ekran ustawień w całości (04 §2), autorzy i licencje
- [x] Kopia zapasowa Androida (T-32)

**Testy ręczne:** M-7, M-8 (ponownie), M-9.

## M6 — Wydanie

**Cel:** gra w Google Play.

- [x] Prawdziwe reklamy nagradzane `google_mobile_ads` + zgoda UMP;
      w trakcie prac tylko testowe jednostki (T-26, T-28)
- [x] Strona `https://dombearx.github.io`: polityka prywatności,
      `app-ads.txt`, strona gry (01)
- [x] Klucz podpisu (poza repo), podpisany AAB, wersjonowanie (05 §9)
- [x] Wpis w sklepie PL/EN: nazwa, opis, ikona, grafika 1024×500, zrzuty
      (U-28)
- [ ] Data Safety, kategoria wiekowa 13+, ankieta treści
- [ ] **Test zamknięty: 12 testerów przez 14 dni** (wymóg dla nowych kont
      osobistych). Uwagi testerów poprawiamy w trakcie.
- [ ] Wniosek o dostęp do produkcji, wydanie

Kod, pliki strony (`site/`), teksty i grafiki sklepu (`store/`) są gotowe;
kroki na kontach (AdMob, klucz, sekrety CI, repo strony, Play Console,
test zamknięty) opisuje `store/PLAY_CONSOLE.md`.

**Testy ręczne:** wszystkie ponownie i M-10 (reklamy).

---

## Zasady pracy

- **P-1:** Najpierw logika w `lib/model` z testami, potem ekran.
- **P-2:** Każda zmiana `balance.json` idzie razem z wynikiem symulatora (E-3).
- **P-3:** Grafika to darmowe emoji od pierwszego ekranu (04 §4.1), więc
  nic nie czeka na grafików. Grafika AI może dojść po wydaniu (04 §4.3).
- **P-4:** Wnioski z przerw „czy to fajne?” mogą zmienić liczby w 02/03.
  Zmiany wymagań wpisujemy do tych dokumentów, a nie tylko do kodu.
- **P-5:** Każdy etap to osobna gałąź i pull request do `main`, a na końcu
  tag z APK.

## Sprawy po twojej stronie (nie blokują kodu)

| Co | Do kiedy |
|---|---|
| Testy M1 na twoim telefonie (i najlepiej drugim, 120 Hz) | koniec M1 |
| Nazwa w sklepie PL/EN (robocza: Hit5); sprawdzić, czy nie jest zajęta | M5 |
| Konto Google Play Console (25 USD jednorazowo, weryfikacja tożsamości trwa kilka dni) | przed M6 |
| Konto AdMob | przed M6 |
| Repo `Dombearx/Dombearx.github.io` na stronę WWW | przed M6 |
| 12 testerów do testu zamkniętego (adresy Google) | przed M6 |

## Otwarte decyzje

| Decyzja | Kiedy |
|---|---|
| Kalibracja opóźnienia ekranu (T-13) | przerwa po M1 |
| Reklamy pełnoekranowe i zakup „Bez reklam” (01) | po wydaniu, na podstawie danych |
| Zakupy w aplikacji: Premium, skórki zegara (01) | wersja 1.1 |
| Grafika AI zamiast emoji (04 §4.3) | po wydaniu |
