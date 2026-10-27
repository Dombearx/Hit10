# 07 — Plan implementacji

Każdy etap kończy się grywalną wersją na telefon. Kolejność jest ustawiona
tak, żeby jak najwcześniej sprawdzić to, co najbardziej ryzykowne: czy
klikanie w 10.00 jest uczciwe i czy daje frajdę.

| Etap | Zakres | Wymagania | Testy ręczne |
|---|---|---|---|
| **M0 — Szkielet** | `flutter create`, struktura z 05 §2, Riverpod, Flame, l10n PL/EN, `Makefile`/`make check`, pusty `balance.json` z walidacją, atrapa `RewardedAds` | T-1…T-7, T-24, T-25 | – |
| **M1 — Rdzeń** | runda, ocena, progi, mapowanie czasu, pomiar dotknięcia, podstawowe efekty PERFEKT/ŚWIETNIE/DOBRZE/PUDŁO, dźwięk, wibracje, tryb diagnostyczny, saldo Tików | R-RUNDA-1…9, R-PROG-*, T-8…T-13, U-14, efekty rundy z 04 §3 | **M-1**, M-2, M-6 |
| **M2 — Ekonomia** | generatory 1–12, sklep, ×1/×10/×100/MAX, dochód pasywny, ulepszenia generatorów, synergie, zapis, offline, symulator Dart + testy balansu | R-GEN-*, R-ULEP-*, 02 §5.2, R-OFF-*, T-14…T-20, 03 §2–3 | M-4, M-5 |
| **M3 — Umiejętności i Złota Sekunda** | wszystkie 11 umiejętności, Przewijanie i bullet time z efektami, combo, Tarcza, Echo, Złota Sekunda | 02 §3–4, 02 §6, R-RUNDA-10…13 | M-3 |
| **M4 — Głębia** | osiągnięcia, tryby ryzyka, prestiż, perki, drugi zegar, generatory 13–14, statystyki, samouczek | 02 §7–12 | M-8 (pierwsze podejście) |
| **M5 — Oprawa** | docelowa paleta, czcionki, grafiki AI, muzyka, pełna tabela efektów, Ogranicz ruch, wszystkie teksty i humor PL/EN, ustawienia | 04 w całości | M-7, M-8, M-9 |
| **M6 — Wydanie** | reklamy nagradzane + UMP, polityka prywatności, ikona, zrzuty i opis w sklepie, podpisany AAB, Data Safety | T-25…T-27, 05 §9 | wszystkie ponownie |

## Zasady pracy

- **P-1:** Najpierw logika w `lib/model` z testami, potem ekran.
- **P-2:** Każda zmiana `balance.json` idzie razem z wynikiem symulatora (E-3).
- **P-3:** Brak grafiki nie blokuje pracy, bo są zastępniki (U-12). Grafika AI
  może powstawać równolegle od M2.
- **P-4:** Po M1 i po M3 jest przerwa na „czy to jest fajne?” (właściciel
  gra na swoim telefonie). Wnioski mogą zmienić liczby w 02/03. Zmiany
  wymagań wpisujemy do tych dokumentów, a nie tylko do kodu.

## Otwarte decyzje (przed etapem, którego dotyczą)

| Decyzja | Do kiedy |
|---|---|
| Biblioteka dźwięku (`flame_audio` vs `audioplayers`) | M1 |
| Czy dodać kalibrację opóźnienia ekranu (T-13) | po M-1 i M-8 |
| Jak spełnić B-8 (gracz pasywny) — wybór dźwigni | M2 |
| Reklamy pełnoekranowe: tak/nie, jak często | M6 |
| `applicationId`, nazwa w sklepie, domena dla polityki prywatności | M6 |
