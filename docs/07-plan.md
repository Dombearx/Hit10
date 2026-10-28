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

- [ ] `flutter create` w `app/` (Android, pion, `applicationId`
      `io.github.dombearx.hit10`), struktura katalogów z 05 §2
- [ ] Zależności: Riverpod, Flame, `flutter_animate`, `flutter_soloud`,
      `path_provider`, l10n PL/EN (`gen-l10n`), czcionki Lilita One i Fredoka
- [ ] `assets/balance.json` z liczbami z 02/03 i walidacją przy starcie
      (T-5…T-7)
- [ ] Atrapa `RewardedAds` (T-25)
- [ ] Test architektury: `lib/model` i `lib/engine` bez Fluttera (T-3)
- [ ] `Makefile`: `make check` (analyze, format, test)
- [ ] GitHub Actions: `make check` i debug APK na każdy push, Release na tag
      (T-31)
- [ ] `CREDITS.md` z pierwszymi wpisami (czcionki)

**Gotowe, gdy:** APK z `m0` instaluje się na twoim telefonie i pokazuje
ekran z napisem „Hit10” po polsku albo po angielsku, zależnie od języka
telefonu.

## M1 — Rdzeń

**Cel:** sama runda „kliknij w 10.00”, uczciwa i przyjemna. Bez sklepu.

- [ ] Model: ocena i progi, mapowanie czasu rzeczywistego na czas gry (na
      razie bez ulepszeń), wypłata bazowa (R-RUNDA-1…9, R-PROG-*, T-11)
- [ ] Pomiar dotknięcia: `Listener.onPointerDown` + `Stopwatch` (T-8…T-10)
- [ ] Arena we Flame: tarcza, cyfry (tabular), pierścień postępu
- [ ] Efekty PERFEKT / ŚWIETNIE / DOBRZE / PUDŁO, z dźwiękiem i wibracją
      (04 §3, U-14, U-15)
- [ ] Saldo Tików z animowanym licznikiem
- [ ] Tryb diagnostyczny: histogram błędów, czasy klatek (T-12)
- [ ] Pierwsze dźwięki z Kenneya i jsfxr

**Testy ręczne:** M-1 (precyzja), M-2 (uczciwość pod obciążeniem), M-6
(dźwięk).

**⏸ Przerwa „czy to fajne?”:** grasz kilka dni i notujesz uwagi.
Rozstrzygamy też, czy potrzebna jest kalibracja opóźnienia ekranu (T-13).

## M2 — Ekonomia

**Cel:** pętla „zarabiam → kupuję → zarabiam więcej” działa i się zapisuje.

- [ ] Model: generatory 1–12, ceny ×1/×10/×100/MAX, dochód z zyskiem okien,
      ulepszenia generatorów, synergie (02 §5, 03 §2)
- [ ] Silnik: tyk ekonomii 10×/s, „trafienia generatorów” jako efekt (T-14,
      T-15)
- [ ] Sklep „Zegary”: karty z emoji (04 §4.1), pasek ulepszeń, sylwetki
      „???”
- [ ] Zapis: atomowy, kopia, migracje, eksport/import (T-17…T-20)
- [ ] Offline z oknem „Gdy cię nie było…” (R-OFF-*)
- [ ] Symulator w Dart (`tool/simulate.dart --check`) z tym samym kodem
      ekonomii co gra. Wyniki porównane z `design/` (06 §1.2).

**Testy ręczne:** M-4 (cykl życia), M-5 (zmiana daty).

## M3 — Umiejętności i Złota Sekunda

**Cel:** gracz ma na co wydawać i czuje, że rośnie w siłę.

- [ ] Wszystkie 11 umiejętności (02 §4), sklep „Umiejętności” z „przed → po”
- [ ] Przewijanie i bullet time z efektami i filtrami dźwięku
      (R-RUNDA-10…13, U-19)
- [ ] Combo, Tarcza, Echo (02 §3)
- [ ] Złota Sekunda z trzema efektami (02 §6)
- [ ] `--check` sprawdza wszystkie cele B-1…B-10 (mediana z 5 ziaren)

**Testy ręczne:** M-3 (wydajność).

**⏸ Przerwa „czy to fajne?”:** godzina–dwie grania, uwagi do tempa
i balansu. Zmiany liczb wpisujemy do 02/03.

## M4 — Głębia

**Cel:** treść na tygodnie i przygotowane miejsca na reklamy.

- [ ] Osiągnięcia, ok. 100, z warunkami generowanymi z tabeli (02 §8)
- [ ] Tryby: Na ślepo, Szybki zegar (02 §7)
- [ ] Prestiż, Chronony, Okruchy, drzewko perków, drugi zegar,
      generatory 13–14 (02 §9)
- [ ] Statystyki (02 §12) i samouczek (02 §11)
- [ ] Logika 5 ofert reklamowych na atrapie, z przyciskami w UI (02 §13,
      04 §5a, T-29). `--check` sprawdza też A-1 i A-2.

**Testy ręczne:** M-8, pierwsze podejście: 3 osoby grają 15 min.

## M5 — Oprawa

**Cel:** gra wygląda i brzmi jak gotowy produkt.

- [ ] Docelowa paleta i tokeny (04 §4), karty emoji dla wszystkiego (U-10…U-12)
- [ ] Ikona aplikacji i złoty zegarek jako SVG (U-26, U-27)
- [ ] Pełna tabela efektów z 04 §3, „Ogranicz ruch” (U-6)
- [ ] Muzyka (3 pętle) i wszystkie efekty dźwiękowe (U-13, U-19…U-21)
- [ ] Wszystkie teksty i humor PL/EN: 112 nazw ulepszeń, opisy, osiągnięcia
      (R-ULEP-2)
- [ ] Ekran ustawień w całości (04 §2), autorzy i licencje
- [ ] Kopia zapasowa Androida (T-32)

**Testy ręczne:** M-7, M-8 (ponownie), M-9.

## M6 — Wydanie

**Cel:** gra w Google Play.

- [ ] Prawdziwe reklamy nagradzane `google_mobile_ads` + zgoda UMP;
      w trakcie prac tylko testowe jednostki (T-26, T-28)
- [ ] Strona `https://dombearx.github.io`: polityka prywatności,
      `app-ads.txt`, strona gry (01)
- [ ] Klucz podpisu (poza repo), podpisany AAB, wersjonowanie (05 §9)
- [ ] Wpis w sklepie PL/EN: nazwa, opis, ikona, grafika 1024×500, zrzuty
      (U-28)
- [ ] Data Safety, kategoria wiekowa 13+, ankieta treści
- [ ] **Test zamknięty: 12 testerów przez 14 dni** (wymóg dla nowych kont
      osobistych). Uwagi testerów poprawiamy w trakcie.
- [ ] Wniosek o dostęp do produkcji, wydanie

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
| Nazwa w sklepie PL/EN (robocza: Hit10); sprawdzić, czy nie jest zajęta | M5 |
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
