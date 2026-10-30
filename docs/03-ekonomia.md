# 03 — Ekonomia i balans

Tu są wzory, cele tempa rozgrywki i to, co już wiemy z symulacji. Lista
przedmiotów i ich liczby są w [02-rozgrywka.md](02-rozgrywka.md).

## 1. Waluty

| Waluta | PL / EN | Skąd | Na co |
|---|---|---|---|
| **Tiki** | Tiki / Ticks | trafienia, generatory, Fart, offline | umiejętności, generatory, ulepszenia, synergie |
| **Chronony** | Chronony / Chronons | prestiż | nie wydaje się ich: +2% na zawsze każdy |
| **Okruchy czasu** | Okruchy / Shards | prestiż (tyle, ile nowych Chrononów) | perki |

Wszystkie kwoty to liczby zmiennoprzecinkowe (`double`), co wystarcza do ok.
1e308. **E-1:** Ceny i stan konta nigdy nie są zaokrąglane w logice, tylko
przy wyświetlaniu.

## 2. Wzory

**Okna** (z umiejętnościami):

```
okno_PERFEKT  = 0.005 + 0.001 · L_magnes
okno_ŚWIETNIE = 0.020 · (1 + 0.08 · L_sokoleOko)
okno_DOBRZE   = 0.050 · (1 + 0.08 · L_sokoleOko)
```

**Szansa trafienia przy rozrzucie σ** (błąd ma rozkład normalny, średnia 0):

```
p(w, σ) = erf(w / (σ·√2))            # P(|e| < w); dla σ = 0 → 1
pP = p(okno_P, σ)
pS = p(okno_S, σ) − pP
pD = p(okno_D, σ) − pP − pS
# Szczęście (s = 0.02 · L_szczęście):
pP' = pP + s·pS ;  pS' = (1−s)·pS + s·pD ;  pD' = (1−s)·pD
EV(σ) = 10·pP' + 3·pS' + 1·pD'       # wartość oczekiwana jednej próby
```

**Dochód generatora i:**

```
zysk_okien_i = EV(σ_i, okna obecne) / EV(σ_i, okna bazowe, bez Szczęścia)   # 1 dla σ = 0
synergia_i   = Π (1 + procent · liczba_partnera)  po kupionych synergiach z i
dochód_i     = n_i · Tiki_bazowo_i · 2^(ulepszenia_i) · synergia_i · zysk_okien_i
```

**Globalny mnożnik:**

```
G = (1 + 0.02 · Chronony) · (1 + 0.01 · osiągnięcia) · (Szał aktywny ? 7 : 1) · (Turbo aktywne ? 2 : 1)
P = Σ dochód_i · G                   # dochód pasywny na sekundę
```

**Wypłata za trafienie gracza:** wzór `R-WYPLATA-1` w 02.

**Długość rundy (czas rzeczywisty, przy trafieniu w 5.00):**

```
t_rundy = 5.0 − S(L_start) + 0.7          (S z R-RUNDA-10; Zimna krew
                                            nie zmienia długości rundy)
```

**Ceny:**

```
generator:    koszt_bazowy · 1.15^n
kupno k sztuk: koszt_bazowy · 1.15^n · (1.15^k − 1) / 0.15
umiejętność:  koszt_bazowy · wzrost^L
MAX:          największe k, na które stać gracza (wzór odwrotny z logarytmem)
```

**Prestiż:** `Chronony_łącznie = floor((zarobione_łącznie / 1e8)^(1/3))`.

**Offline:** `P_bez_Szału · min(Δt, limit) · wydajność` (R-OFF-1).

## 3. Cele tempa (wymagania balansu)

Sprawdzane symulatorem (patrz 05 i 06) dla bota, który zawsze kupuje to, co
najszybciej się zwraca. Scenariusze:
- gracz wprawny (σ = 30 ms) przez 8 h,
- gracz przeciętny (σ = 60 ms),
- gracz pasywny (klika 10 min, potem tylko kupuje),
- drugi run z 20 Chrononami.

**E-5:** Złota Sekunda wprowadza dużą losowość, więc każdy cel jest
sprawdzany na **medianie z 5 ziaren losowania**, a nie na jednym przebiegu.
Testy balansu w CI pilnują tych przedziałów:

| id | Cel | Przedział |
|---|---|---|
| **B-1** | Pierwszy Dziadek | ≤ 2 min |
| **B-2** | Pierwszy Zegarmistrz (5.) | 15–40 min |
| **B-3** | Pierwszy Zegar atomowy (9.) | 1.5–4 h |
| **B-4** | Pierwsza Maszyna czasu (12.) | > 6 h w pierwszym runie (cel na kolejne runy) |
| **B-5** | Chronony możliwe po 6 h pierwszego runu | 15–30 |
| **B-6a** | 1. godzina: dochód z klikania / dochód pasywny | ≥ 1× |
| **B-6b** | Godziny 2–8: dochód z klikania / dochód pasywny | 1.5–5× |
| **B-7** | Gracz przeciętny po 8 h ma ≥ 40% Tików gracza wprawnego | ≥ 40% |
| **B-8** | Gracz pasywny po 8 h ma ≥ 1% Tików gracza wprawnego… | ≥ 1% |
| **B-8b** | …i w każdej godzinie coś kupuje | ≥ 1 zakup / h |
| **B-9** | Drugi run z 20 Chrononami (bez perków) dochodzi do Tików z 6 h pierwszego runu | ≤ 4.5 h (po playteście 08: 4.49 — na granicy) |
| **B-10** | Każda umiejętność (oprócz Tykania) ma ≥1 poziom po 8 h | wszystkie |

## 4. Wyniki symulacji projektowej

Liczby w 02 przeszły symulację w Pythonie (wzory z §2, bot jak w §3).
Wszystkie cele są spełnione na medianie z 4 ziaren.

**Gracz wprawny (σ = 30 ms), ziarno 10:**

| Generator | Pierwszy po | | Generator | Pierwszy po |
|---|---|---|---|---|
| Dziadek | 1.4 min | | Sędzia sprintu | 42 min |
| Babcia | 5.5 min | | Zegar dworcowy | 61 min |
| Kukułka | 14 min | | Zegar kwarcowy | 1.9 h |
| Metronom | 23 min | | Zegar atomowy | 3.5 h |
| Zegarmistrz | 30 min | | GPS | 6.4 h |

Pulsar i Maszyna czasu nie pojawiają się w pierwszych 8 h. To treść na
kolejne runy, co spełnia życzenie, żeby gracz miał do czego dążyć.

| Godzina | Pasywny/s | Klikanie/s | Klikanie : pasywny | Zarobione | Chronony |
|---|---|---|---|---|---|
| 1 | 840K | 1.04M | 1.2× | 134M | 1 |
| 2 | 17.3M | 39.1M | 2.3× | 8.2B | 4 |
| 3 | 50.1M | 152M | 3.0× | 53B | 8 |
| 4 | 107M | 398M | 3.7× | 216B | 12 |
| 6 | 281M | 1.09B | 3.9× | 1.02T | 21 |
| 8 | 436M | 2.06B | 4.7× | 2.71T | 30 |

Umiejętności: każdą ktoś kupuje. Pierwsze poziomy pojawiają się między 9.
a 45. minutą. Start później osiąga max po ok. 3–4 h, a Sokole oko po ok. 3.5 h.
Magnes, Combo i Echo dochodzą do max dopiero pod koniec 8 h, więc są
dobrym celem na długo.

**Cele na 4 ziarnach (10, 1, 2, 3):**

| Cel | Wyniki | Mediana |
|---|---|---|
| B-5 Chronony po 6 h | 21, 20, 24, 20 | 20.5 ✓ |
| B-6b klikanie : pasywny, h2–8 | 2.2–4.7 we wszystkich | ✓ |
| B-7 przeciętny / wprawny | 0.48, 0.44, 0.30, 0.48 | 0.46 ✓ |
| B-8 pasywny / wprawny | 0.046, 0.044, 0.038, 0.053 | 0.045 ✓ |
| B-9 drugi run (h) | 4.45, 3.69, 4.89, 3.91 | 4.2 ✓ |

**Co zmieniło się po drodze i dlaczego** (już wpisane do 02):

| Zmiana | Było → jest | Powód |
|---|---|---|
| Combo mnoży też Echo (R-COMBO-3) | – | combo bez tego przestawało się liczyć po ~30 min (kupione 2 poziomy w 8 h) |
| Krok combo | 0.10 → 0.05 | z Echem i limitem 55 klikanie dawało 12–50× więcej niż generatory |
| Limit combo | 5 + 5·L (55) → 5 + 2·L (25) | jw. |
| Echo na poziom | 2 s → 0.5 s | jw. |
| Złota Sekunda co | 3–7 min → 5–15 min | Szał zbyt często podwajał klikanie; teraz jak w Cookie Clickerze |
| Złoty dotyk na poziom | 10% → 5% | jw. |
| Tarcza | 100K ×100 → 2K ×50 | przy starej cenie nikt jej nie kupował (B-10) |
| Dzielnik prestiżu | 1e12 → 1e8 | 2 Chronony po 8 h; teraz ~20 po 6 h |
| Premia za Chronon | 1% → 2% | prestiż ma dawać odczuwalnie szybszy drugi run (B-9) |

Rezultat dla gracza pasywnego (B-8): przed zmianami miał ~150× mniej niż
gracz aktywny, teraz ok. 22× mniej (4.5%). Wystarczyło osłabić przewagę
klikania. Żadna osobna „dźwignia” dla pasywnych nie była potrzebna.

**Czego symulacja nie modeluje** (gra będzie przez to nieco szybsza;
sprawdzi to symulator w Dart w M2–M4):
- premii z osiągnięć,
- perków prestiżu,
- Gorącej ręki,
- trybów ryzyka,
- drugiego zegara,
- generatorów 13–14,
- dochodu offline,
- realnych przerw gracza.

Symulacja zakłada też, że gracz klika bez przerwy przez 8 h.

**Do obserwacji przy testach z ludźmi (M-8):** najszybszy wzrost jest
w godzinach 1–2 (×60), potem tempo spada do ×1.5–2 na godzinę. To celowa
„ściana” przed prestiżem. Trzeba sprawdzić, czy nie nudzi.

### 4.1 Port do Darta (M2)

Symulator w Darcie (`app/tool/simulate.dart --check`) liczy na kodzie gry.
Wyszedł przy tym błąd w projektowym symulatorze w Pythonie: wywołany bez
czasu liczył Szał (×7) jako trwały po pierwszej Złotej Sekundzie. Zawyżało
to raportowany dochód pasywny i decyzje bota, ale nie faktyczne zarobki
(poprawione w `design/sim.py`). Na poprawionym modelu dwa cele wypadły tuż
pod progiem: B-6a (0,95) i B-7 (0,399). Korekta:

| Zmiana | Było → jest | Efekt (mediana z 5 ziaren) |
|---|---|---|
| Siła trafienia na poziom | +100% → **+150%** | B-6a 0,95 → 1,13 |
| Wzrost ceny Sokolego oka | ×6 → **×5** | B-7 0,40 → 0,49; B-8 0,043 → 0,049 |

Wszystkie cele B-1…B-10, A-1 i A-2 przechodzą. Aktualne wyniki zawsze
pokazuje `dart run tool/simulate.dart --check`.

## 5. Reklamy a balans

Cele tempa B-1…B-10 są liczone **bez reklam**. Reklamy mają osobne cele:

| id | Cel | Przedział |
|---|---|---|
| **A-1** | Gracz biorący każdą ofertę dochodzi do Tików gracza bez reklam z 8 h po… | 3–4 h (2–2.7× szybciej) |
| **A-2** | Liczba reklam przy ciągłej grze i braniu wszystkiego | ≤ 6 na godzinę |
| **A-3** | Typowy dzień (3 sesje po ~15 min), gracz biorący wszystko | ≤ 10 reklam; przeciętny gracz 2–6 |

**Wyniki symulacji** (8 h gry, gracz σ = 30 ms, mediana z 5 ziaren;
`adOffline` i `adRescue` nie są tu liczone: offline nie jest modelowany,
a Ratunek prawie się nie włączał, bo przy pełnych umiejętnościach pudła są
rzadkie i łapie je Tarcza):

| Wariant | Turbo | Worek | Złota na żądanie | Stan z 8 h osiągnięty po | Reklam / h |
|---|---|---|---|---|---|
| pierwsza propozycja | ×2 / 15 min, zapas 2 h | 20 min dochodu co 10 min | co 15 min | **1.3 h** (6× szybciej) | 14 |
| tylko Turbo | ×2 / 15 min | – | – | 4.0 h | 4 |
| **A — przyjęty** | **×2 / 30 min, zapas 4 h** | **5 min co 30 min** | **co 30 min** | **3.3 h** (2.4×) | **6** |
| B | ×2 / 30 min, zapas 4 h | 10 min co 30 min | co 30 min | 2.8 h | 6 |
| C | ×2 / 30 min, zapas 4 h | 5 min co 30 min | co 60 min | 3.4 h | 5 |

Wnioski:
- Pierwsza propozycja była za hojna. Worek „20 min dochodu co 10 min”
  potraja dochód, a efekt się kumuluje. Ktoś z reklamami przeszedłby grę
  6× szybciej, co odbiera sens grania bez reklam.
- W wariancie A prawie całą przewagę (×2) daje Turbo. Pozostałe oferty
  dokładają ok. 20%: są miłym bonusem, a nie przymusem.

**Na tle rynku:**
- W AdVenture Capitalist reklama daje ×2 dochodu na 4 h, do 5 razy dziennie,
  więc ×2 jest prawie zawsze aktywne. Nasze Turbo daje ten sam mnożnik, ale
  za mniej „gry na reklamę”: 30 min czasu w grze zamiast 4 h zegarowych.
  Przy krótkich sesjach mobilnych w praktyce wychodzi podobnie, 1–3 reklamy
  dziennie, żeby mieć Turbo cały czas.
- Wskaźniki branżowe dla reklam nagradzanych to ok. 2–6 wyświetleń na
  aktywnego gracza dziennie, przy 15–25% graczy oglądających. Nasz typowy
  dzień daje 8–10 reklam dla kogoś, kto bierze wszystko (2 Turbo, 3× offline,
  1–3 Worki, 1–2 Złote), więc średnia wśród wszystkich graczy powinna
  wpaść w 2–6.
- Przychód na aktywnego gracza dziennie w grach idle to ok. 0.05–0.30 USD,
  zależnie od kraju (PL jest w dolnej części) i od tego, ilu graczy wraca.
  To dane z blogów firm reklamowych, więc tylko orientacyjnie.

Źródła: [AdVenture Capitalist Wiki — Opt-In Boosts](https://adventure-capitalist.fandom.com/wiki/Opt-In_Boosts),
[AdReact — Rewarded Video Ads](https://adreact.com/blog/rewarded-video-ads-mobile-game-monetization/),
[Game Ace — Idle game development](https://game-ace.com/blog/idle-game-development/),
[Coinis — Rewarded Video](https://coinis.com/glossary/rewarded-video),
[Playio — Rewarded Ad Benchmarks 2026](https://blog.playio.co/rewarded-ad-benchmarks-2026).

## 6. Zasady strojenia

- **E-2:** Wszystkie liczby z 02 i 03 leżą w jednym pliku balansu (05).
  Zmiana balansu nie wymaga zmian w kodzie.
- **E-3:** Każda zmiana pliku balansu musi przejść testy B-1…B-10. Wynik
  symulatora (tabele jak w sekcji 4) jest wklejany do opisu commita albo PR.
- **E-4:** Najpierw stroimy koszty i mnożniki ulepszeń. Bazowe wartości
  generatorów zmieniamy na końcu, bo pociągają za sobą wszystko inne.
