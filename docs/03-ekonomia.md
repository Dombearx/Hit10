# 03 — Ekonomia i balans

Tu są wzory, cele tempa rozgrywki i to, co już wiemy z symulacji. Lista
przedmiotów i ich liczby są w [02-rozgrywka.md](02-rozgrywka.md).

## 1. Waluty

| Waluta | PL / EN | Skąd | Na co |
|---|---|---|---|
| **Tiki** | Tiki / Ticks | trafienia, generatory, Fart, offline | umiejętności, generatory, ulepszenia, synergie |
| **Chronony** | Chronony / Chronons | prestiż | nie wydaje się ich: +1% na zawsze każdy |
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
G = (1 + 0.01 · Chronony) · (1 + 0.01 · osiągnięcia) · (Szał aktywny ? 7 : 1)
P = Σ dochód_i · G                   # dochód pasywny na sekundę
```

**Wypłata za trafienie gracza:** wzór `R-WYPLATA-1` w 02.

**Długość rundy (czas rzeczywisty, przy trafieniu w 10.00):**

```
t_rundy = 9.0 / (1 + 0.5·L_przew) + 0.8 + 0.2 / (1 − 0.06·L_bullet) + 0.7
```

**Ceny:**

```
generator:    koszt_bazowy · 1.15^n
kupno k sztuk: koszt_bazowy · 1.15^n · (1.15^k − 1) / 0.15
umiejętność:  koszt_bazowy · wzrost^L
MAX:          największe k, na które stać gracza (wzór odwrotny z logarytmem)
```

**Prestiż:** `Chronony_łącznie = floor((zarobione_łącznie / 1e9)^(1/3))`.

**Offline:** `P_bez_Szału · min(Δt, limit) · wydajność` (R-OFF-1).

## 3. Cele tempa (wymagania balansu)

Sprawdzane symulatorem (patrz 05 i 06) dla bota, który zawsze kupuje to, co
najszybciej się zwraca. Testy balansu w CI pilnują tych przedziałów:

| id | Cel | Przedział |
|---|---|---|
| **B-1** | Pierwszy Dziadek | ≤ 2 min |
| **B-2** | Pierwszy Zegarmistrz (5.) | 15–40 min |
| **B-3** | Pierwszy Zegar atomowy (9.) | 1.5–4 h |
| **B-4** | Pierwsza Maszyna czasu (12.) | > 6 h w pierwszym runie (cel na drugi run) |
| **B-5** | Chronony możliwe po 6 h pierwszego runu | 15–30 |
| **B-6** | Mid-game (1–4 h): dochód aktywny / pasywny | 1.5–4× |
| **B-7** | Gracz przeciętny (σ = 60 ms) po 8 h ma ≥ 40% Tików gracza wprawnego (σ = 30 ms) | ≥ 40% |
| **B-8** | Gracz tylko pasywny (klika 10 min, potem tylko kupuje): co godzinę ma na coś nowego, a po 8 h ma ≥ 1% Tików gracza aktywnego | ≥ 1% |
| **B-9** | Drugi run z 20 Chrononami dochodzi do poziomu z 6 h pierwszego runu w ≤ 3 h | ≤ 3 h |
| **B-10** | Żadna umiejętność nie zostaje bez zakupu przez cały pierwszy run (każda ma ≥1 poziom po 8 h) | wszystkie |

## 4. Co już wiemy (wstępna symulacja, wersja projektowa)

Szybki symulator w Pythonie na liczbach z 02, ale jeszcze **bez** zmian
z R-COMBO-3 i ze starszą wersją Echa (2 s na poziom). Gracz σ = 30 ms:

| Generator | Pierwszy po |
|---|---|
| Dziadek | 1.4 min |
| Babcia | 5.3 min |
| Kukułka | 9.6 min |
| Zegarmistrz | 19 min |
| Zegar dworcowy | 41 min |
| Zegar kwarcowy | 65 min |
| Zegar atomowy | 1.8 h |
| GPS | 3 h |
| Pulsar | 5.5 h |
| Maszyna czasu | nie w 8 h |

| Godzina | Pasywny/s | Aktywny/s | Zarobione | Chronony |
|---|---|---|---|---|
| 1 | 5.7M | 12.2M | 3.0B | 1 |
| 2 | 114M | 423M | 257B | 6 |
| 4 | 449M | 1.98B | 2.64T | 13 |
| 6 | 863M | 3.91B | 8.79T | 20 |
| 8 | 1.50B | 7.53B | 19.2T | 26 |

Wnioski, które **już weszły do wymagań**:
- Dzielnik prestiżu `1e9` (był 1e12, co dawało 2 Chronony po 8 h).
- Combo mnoży całą wypłatę, razem z Echem (R-COMBO-3). Wcześniej było prawie
  bezużyteczne: kupione tylko 2 poziomy w 8 h.
- Echo osłabione do 1 s na poziom. Przy 2 s klikanie dawało 4–5× tyle co
  generatory (cel B-6 to 1.5–4×).
- Gracz przeciętny (σ = 60 ms) miał 44% Tików wprawnego. Spełnia B-7.

Do sprawdzenia przy implementacji (M2/M3):
- **B-8:** Gracz tylko pasywny miał ~150× mniej niż aktywny po 8 h (130B
  vs 19T). Trzeba to podnieść. Możliwe dźwignie: tańsze pierwsze ulepszenia
  generatorów, wyższa wydajność offline albo mały bazowy dochód pasywny bez
  umiejętności.
- **B-6** po zmianie Echa i Combo.
- **B-10:** Tarcza i Złoty dotyk nie były modelowane w symulacji.
- Najszybszy wzrost jest w godzinach 1–2 (×87), potem tempo spada do
  ×1.5–2 na godzinę. To celowa „ściana”, która zachęca do prestiżu.
  Sprawdzić, czy ok. 4 h ściany przed pierwszym prestiżem nie nudzi.

## 5. Zasady strojenia

- **E-2:** Wszystkie liczby z 02 i 03 leżą w jednym pliku balansu (05).
  Zmiana balansu nie wymaga zmian w kodzie.
- **E-3:** Każda zmiana pliku balansu musi przejść testy B-1…B-10. Wynik
  symulatora (tabele jak w sekcji 4) jest wklejany do opisu commita albo PR.
- **E-4:** Najpierw stroimy koszty i mnożniki ulepszeń. Bazowe wartości
  generatorów zmieniamy na końcu, bo pociągają za sobą wszystko inne.
