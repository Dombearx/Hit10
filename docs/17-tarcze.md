# 17 — Tarcze: kiedy i za co

Stan: **propozycja** (24.11.2026). Nic z tego nie jest jeszcze w grze ani
w zasadach 02. Obecne zasady: 02 R-TARCZA-1/2, R-PETLA-5. Powód: progi
tarcz z 03 §4.3 policzono symulacją bez Pętli czasu. Z pętlami dwie z nich
wypadają w innym miejscu niż zakładano. Przy nowej szacie graficznej
(interaktywne tarcze, sceny fabuły) to dobry moment, żeby ułożyć
kolekcję od nowa.

## 1. Problem w liczbach

Obecne progi za Tiki zarobione w całej grze (`lifetime.earnedEver`):
0, 1M, 10B, 1T, 100aa, 100ac. Cel z 03 §4.3: D1, D2, D7, ok. D21,
ok. D45. Tak wypadają z pętlami (§3, gracz „3 × 3 min”):

| Tarcza | Próg | Cel | Z pętlami |
|---|---|---|---|
| Drewniak | 1M | D1 | D1 |
| Porcelana babci | 10B | D2 | D2 |
| Mosiądz | 1T | D7 | D5 |
| Dworcowa | 100aa | ok. D21 | **D15** |
| Szwajcarka | 100ac | ok. D45 | **nigdy** (D25 bez nowych pętli) |

**Dlaczego.** Nowa pętla zeruje Tiki zarobione łącznie, więc od D15 suma
z całej gry rośnie już tylko liniowo: ok. 1–3 · 10¹⁹ na pętlę zamiast
wykładniczo. Po roku gracz, który gra fabułę, ma 1–30ac (1e21–3e22).
Gracz, który został w pierwszej pętli, ma 65–78ad (6e25–8e25), a 100ac
przekracza w 25.–32. dniu.

Tarcze za zarobki ponad ok. 1ab (1e18) nagradzają więc **niegranie
fabuły**, a gracza, który idzie dalej, karzą. Do końca pierwszej pętli
(ok. D11–D37 zależnie od gracza) zarobki działają dobrze, bo wtedy
wszyscy są w tej samej sytuacji.

Druga dziura: **pierwsza pętla nie daje tarczy** (R-PETLA-5: pętla bez
zasady nie ma pieczęci). Najważniejszy moment gry, pierwszy Chronos i
rozdział 1, nie dodaje nic do kolekcji.

## 2. Jak to robią inne gry

| Gra | Za co kosmetyk | Czego się uczymy |
|---|---|---|
| Cookie Clicker | **mleko** (kolor dołu ekranu) zmienia się co 25 osiągnięć. Sezony (Boże Narodzenie, Halloween i inne) wracają co roku, mają własne ciastka i osiągnięcia, a Walentynki włączają się same według daty | kosmetyk za **liczbę osiągnięć** nie zależy od prestiżu, a sezony wracające co roku zdejmują presję FOMO |
| Egg, Inc. | każde nowe jajko ma nowy wygląd farmy i jajka. Okrągły wskaźnik pokazuje postęp do następnego, rośnie z rzędem wielkości wartości farmy | „następna rzecz” widoczna z postępem. To samo robi nasza galeria (R-TARCZA-2) |
| Melvor Idle (za RuneScape) | **peleryna umiejętności** za poziom 99 | kosmetyk za **mistrzostwo**, czyli długi, pewny cel, którego nie zabiera reset |
| Clash Royale, Brawl Stars | skórki wież i zadymiarzy głównie na płatnej ścieżce przepustki, sezony co miesiąc. Darmowa ścieżka daje walutę i drobiazgi | darmowych kosmetyków jest mało i przychodzą rzadko (ok. raz w miesiącu). U nas wszystkie są darmowe, więc mogą przychodzić częściej |
| Idle Human | skórki za progi komórek (1M, 1B), **tracone przy prestiżu** | antywzór: kosmetyk zabrany przez reset przestaje być nagrodą |
| Get Rich Quick, inne małe idle | skórki kupowane za walutę prestiżu | konkurują z ulepszeniami o tę samą walutę, więc gracz musi wybierać między wyglądem a postępem. U nas niepotrzebne |

Dobre praktyki z badań i poradników:

1. **Pierwsza nagroda w pierwszych minutach**, potem w punktach
   kontrolnych retencji D1, D7, D30 (D1 sprawdza wejście w grę, D7 czy
   gra się podoba, D30 głębię progresji; 03 §4.3). Mocne nagrody
   rozkładać po całej progresji, a nie zbierać na końcu.
2. **Efekt gradientu celu** (Hull 1932) i **obdarowany postęp** (Nunes
   i Drèze 2006): ludzie przyspieszają, gdy cel jest blisko i gdy pasek
   nie startuje od zera. Cel, który wydaje się za daleki, nie motywuje.
   U nas każda ścieżka pokazuje najbliższą tarczę z postępem.
3. **Nie karać za granie dalej.** Kosmetyk nie może zależeć od
   licznika, który zeruje główna pętla gry (antywzór z Idle Human,
   a u nas: zarobki po pętli 1).
4. **Czas rzeczywisty wyrównuje graczy.** Licznik oparty na dniach
   (kostki cukru w Cookie Clickerze, u nas Sprężyny) daje podobne tempo
   graczowi 2-minutowemu i 50-minutowemu. Licznik oparty na grze
   (PERFEKTY, godziny) rozjeżdża ich kilkukrotnie (§3).
5. **Sezony wracają co roku.** Kto przegapił, zdobędzie za rok. Trzeba to
   napisać w opisie wydarzenia.

Źródła są na końcu pliku. Strony wiki Cookie Clickera i Egg, Inc. były
niedostępne z sesji, więc szczegóły pochodzą z opisów w wynikach
wyszukiwania i z forów.

## 3. Symulacje

`app/tool/dial_report.dart` (gracz z `late_game_report.dart` część 5,
na kodzie gry, 365 dni, jeden wiersz CSV dziennie ze wszystkimi
licznikami, za które mogłaby być tarcza). Siedmiu graczy:

| Gracz | Sesje | σ | Pętle |
|---|---|---|---|
| A przypadkowy | 1 × 2 min | 80 ms | nowa pętla po bonusach Chronosa |
| B lekki (odniesienie, jak 03 §4.3) | 3 × 3 min | 50 ms | jw. |
| C zaangażowany (jak 03 §4.4) | 3 × 11 min | 40 ms | jw. |
| D intensywny | 5 × 10 min | 35 ms | jw. |
| E zostający | 3 × 11 min | 40 ms | zostaje tydzień po każdym Chronosie |
| F bez pętli | 3 × 11 min | 40 ms | nigdy nie zaczyna nowej pętli |
| G lekki bez pętli | 3 × 3 min | 50 ms | jw. |

Dzień, w którym licznik pierwszy raz osiąga próg:

| Licznik, próg | A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|---|
| Zarobki 1T | 13 | 5 | 4 | 3 | 4 | 4 | 5 |
| Zarobki 1aa (1e15) | 29 | 12 | 9 | 8 | 9 | 9 | 12 |
| Zarobki 100aa | 34 | 15 | 12 | 10 | 12 | 12 | 15 |
| Zarobki 1ac (1e21) | 253 | 89 | 43 | 47 | 17 | 16 | 21 |
| Zarobki 100ac | – | – | – | – | 48 | 25 | 32 |
| Pętla 1 ukończona (Chronos) | 37 | 16 | 14 | 11 | 14 | 13 | 17 |
| Pętla 4 ukończona | 106 | 52 | 42 | 32 | 54 | – | – |
| Pętla 7 ukończona | 165 | 76 | 58 | 43 | 85 | – | – |
| Stopnie mistrzostwa 5 | 10 | 7 | 6 | 5 | 6 | 6 | 7 |
| Stopnie 30 | 60 | 44 | 42 | 33 | 44 | 57 | 56 |
| Stopnie 50 | 125 | 76 | 66 | 51 | 79 | 111 | 108 |
| Stopnie 70 (wszystkie) | 180 | 104 | 84 | 65 | 111 | 161 | 163 |
| Osiągnięcia 75 | 38 | 16 | 14 | 10 | 14 | 12 | 16 |
| Osiągnięcia 100 | 105 | 53 | 29 | 21 | 20 | 20 | 24 |
| Osiągnięcia 125 | 187 | 95 | 73 | 58 | 45 | 61 | 75 |
| PERFEKTY 10K | – | 110 | 26 | 17 | 26 | 24 | 86 |
| Godziny gry 10 | 300 | 67 | 19 | 12 | 19 | 19 | 67 |
| Paradoksy 25 | 104 | 43 | 36 | 26 | 39 | – | – |
| Chronosy w jednej pętli 100 | – | – | – | – | 34 | 20 | 27 |
| Chronosy w jednej pętli 150 | – | – | – | – | – | 208 | 226 |

Wnioski:

- **Zarobki** są dobrym licznikiem tylko do ok. 1ab. Dalej rozjazd między
  graczem z pętlami a bez nich sięga lat.
- **Stopnie mistrzostwa** (Sprężyny, czas rzeczywisty) mają najmniejszy
  rozrzut: przy 30 stopniach między D33 a D60 dla wszystkich siedmiu
  graczy, czyli niecałe 2×. Nie zależą od tego, czy ktoś gra pętle.
- **Pętle** są dobre jako trofea fabuły (rozrzut ok. 3.5× między A i D),
  ale gracz bez pętli ich nie dostaje. Tak ma być: to nagroda za fabułę.
- **Liczniki gry** (PERFEKTY, godziny) rozjeżdżają graczy 5–25×.
  Nadają się na wyczyny, nie na kolekcję.
- **50 Chronosów** to dokładnie ostatni bonus Chronosa (5, 10, 15, 20,
  25, 30, 40, 50; każdy daje +1 Sprężynę raz na pętlę, R-PETLA-2a).
  Gracz z pętlami dochodzi do 50 i od razu zaczyna nową pętlę, więc
  tarcza za 50 wypadałaby razem z pierwszym Chronosem i niczego nie
  zmienia. **100 Chronosów** w jednej pętli to prawdziwy wybór: zostać
  ok. tydzień (F: D20, G: D27, E: D34) albo iść dalej po fabułę.
- Powyżej 50 Chronosów nie ma już Sprężyn. Zostawanie dłużej daje tylko
  osiągnięcia, a teraz też tarczę.

## 4. Ile tarcz

| | Teraz | Propozycja |
|---|---|---|
| Na start gry | 12 | **18** (sezony dają motywy, nie tarcze, §6) |
| Gracz B po D7 / D30 / D90 / D365 | 5 / 6 / 11 / 11 | 5 / 7 / 14 / 17 |
| Gracz bez pętli po D365 | 6 | 12 |
| Ostatnia tarcza gracza B | D76 | D104, potem 100 i 365 dni gry |

Dlaczego ok. 18:
- W pierwszym tygodniu nowa tarcza co 1–3 dni, potem co ok. 2 tygodnie
  do D90, potem raz na kwartał. Między nimi motywy sezonowe (§6). To zgodne z praktyką 1 (§2).
- Każda tarcza w nowej szacie to rysunek i animacja. 18 to rozsądny
  koszt na premierę, a aktualizacje (np. nowe pętle, ścieżka osiągnięć)
  dokładają po kilka. Kolekcja może rosnąć po premierze, a zmniejszyć
  się nie może.
- Mniej niż ok. 15 zostawia dziurę między D16 a D44 albo kończy kolekcję
  na D76 dla większości graczy (tak jest teraz).

## 5. Rekomendacja: pięć ścieżek

Galeria (R-TARCZA-2) dzieli się na ścieżki: Start, Mistrzostwo, Fabuła,
Wyczyn, Wierność. **Każda ścieżka pokazuje
swoją najbliższą tarczę z postępem** (praktyka 2), a nie jedną „następną”
dla całej gry, bo ścieżki idą równolegle.

| # | Tarcza | Ścieżka | Za co | A | B | D | G |
|---|---|---|---|---|---|---|---|
| 1 | Klasyczna | Start | na start | 0 | 0 | 0 | 0 |
| 2 | Drewniak | Start | zarobki 1M | 2 | 1 | 1 | 1 |
| 3 | Porcelana babci | Start | zarobki 10B | 4 | 2 | 1 | 2 |
| 4 | Mosiądz | Start | zarobki 1T | 13 | 5 | 3 | 5 |
| 5 | **nowa** | Mistrzostwo | 5 stopni mistrzostwa | 10 | 7 | 5 | 7 |
| 6 | Dworcowa | Fabuła | **ukończona pętla 1** (pierwszy Chronos, rozdział 1) | 37 | 16 | 11 | 17 |
| 7–12 | Kwarcówka … Pęknięta czasoprzestrzeń | Fabuła | pieczęcie pętli 2–7 (bez zmian) | 62–165 | 29–76 | 18–43 | – |
| 13 | Szwajcarka | Mistrzostwo | **30 stopni** | 60 | 44 | 33 | 56 |
| 14 | **nowa** | Mistrzostwo | 50 stopni | 125 | 76 | 51 | 108 |
| 15 | **nowa** | Mistrzostwo | wszystkie 70 stopni (wszystkie tytuły) | 180 | 104 | 65 | 163 |
| 16 | **nowa** | Wyczyn | **100 Chronosów w jednej pętli** | – | – | – | 27 |
| 17 | **nowa** | Wierność | 100 dni z odebraną dzienną premią | 100+ | 100+ | 100+ | 100+ |
| 18 | **nowa** | Wierność | 365 dni z odebraną dzienną premią | 365+ | 365+ | 365+ | 365+ |

(E, gracz zostający, dostaje 100 Chronosów w D34, F w D20.)

Uzasadnienie po kolei:
- **1–4 bez zmian.** Zarobki działają do końca pierwszej pętli,
  a pierwsza tarcza przychodzi w pierwszej sesji.
- **5: mistrzostwo na D7.** Wypada w punkcie D7 u wszystkich graczy
  (5–10 dni) i przy okazji uczy systemu Sprężyn.
- **6: Dworcowa za pierwszą pętlę.** Łata dziurę z §1 i nagradza
  najważniejszy moment fabuły. Liczy się tak jak R-PETLA-1, więc gracz
  bez nowych pętli też ją dostaje.
- **13–15: mistrzostwo zamiast zarobków.** Ten licznik ma najmniejszy
  rozrzut i nie przepada. Szwajcarka trafia w zakładany D45
  (D33–D60 dla wszystkich). Gracz bez pętli dostaje te tarcze trochę
  później, bo zbiera mniej Sprężyn (brak bonusów Chronosa w kolejnych
  pętlach), ale je dostaje.
- **16: odpowiedź na „grinduję albo idę dalej”.** Opcjonalna, widoczna
  od pierwszego Chronosa jako „Zostań w pętli: 100 Chronosów”. Bez kary
  za pominięcie: gracz może po nią wrócić w dowolnej pętli.
- **17–18: czas rzeczywisty, nie dni z rzędu.** Liczą się dni z odebraną
  premią, bez wymogu serii, więc przerwa niczego nie zabiera (jak
  R-SPR-4). Kolekcja ma koniec po roku, a nie po D104.

**Odrzucone:**
- Zarobki powyżej 1ab: patrz §1.
- PERFEKTY, godziny gry, równe 5.00: rozrzut 5–25× (§3). Lepiej nadają
  się na osiągnięcia.
- Liczba osiągnięć, jak mleko w Cookie Clickerze: rozrzut między A i D
  ok. 3–5×, a gracz bez pętli dostaje je szybciej. Do rozważenia jako
  ścieżka po premierze, gdy przybędzie osiągnięć.
- Paradoksy: gracz bez pętli kończy na 15–16, więc dalsze progi są dla
  niego martwe.
- 50 Chronosów: wypada razem z pierwszą pętlą (§3).
- Tarcze za walutę: konkurowałyby z perkami i Sprężynami.

## 6. Tarcza a motyw (nowa szata)

Do ustalenia razem z nową grafiką:
- **Dwie warstwy:** tarcza (zegar, elementy rozgrywki, czytelność cyfr
  i kolorów wyników) i motyw (tło, wygląd Złotej Sekundy, efekty
  trafień). Każda tarcza ma motyw w parze jako zestaw, a przełącznik
  „dopasuj motyw do tarczy” jest domyślnie włączony.
- **Ustalone (24.11.2026): sezony dają motywy, nie tarcze.** W czasie
  wydarzenia motyw sezonowy idzie na wierzch (R-SEZ-1) i nie zabiera
  wybranej tarczy. Za cel wydarzenia (R-SEZ-2) motyw zostaje na stałe
  do włączenia w każdej chwili. Kto przegapi, zdobędzie go za rok.
- Złota Sekunda w każdym motywie zachowuje sylwetkę, złoty blask
  i dźwięk.

## 7. Co trzeba zmienić przy wdrożeniu

- `balance.json` `dials`: nowe typy warunków (`tiers`, `loopsDone`,
  `chronosInLoop`, `dailyClaims`, `season`) obok `earned` i `seal`.
- 02 R-TARCZA-1/2: ścieżki i najbliższa tarcza na każdej ścieżce.
  Odblokowana tarcza zostaje na zawsze (już jest w R-TARCZA-1), więc
  gracze, którzy mają Dworcową i Szwajcarkę z obecnych progów, ich
  nie tracą.
- 03 §4.3: stare dni tarcz zastąpić tabelą z §3.
- Testy: każda tarcza osiągalna dla graczy A–G. Wyjątkami są trofea
  pętli dla F i G oraz 100 Chronosów dla A–D, bo wymagają wyboru gracza.

Do sprawdzenia po premierze: rzeczywisty rozkład dni ukończenia pętli 1
(D11–D37 w symulacji) oraz to, ilu graczy zostaje po 100 Chronosów.

## Źródła

- Cookie Clicker, mleko co 25 osiągnięć:
  [Steam](https://steamcommunity.com/app/1454400/discussions/0/3044984779771578736),
  [wiki: osiągnięcia](https://cookieclicker.wiki.gg/wiki/Achievement).
- Cookie Clicker, sezony:
  [wiki: Seasons](https://cookieclicker.wiki.gg/wiki/Seasons),
  [Valentine's Day](https://cookieclicker.wiki.gg/wiki/Valentine%27s_Day_Season).
- Egg, Inc., jajka i wskaźnik postępu:
  [Wikipedia](https://en.wikipedia.org/wiki/Egg,_Inc.),
  [wiki: Eggs](https://egg-inc.fandom.com/wiki/Eggs?oldid=2165).
- Melvor Idle, peleryny za poziom 99:
  [wiki: Farming](https://wiki.melvoridle.com/w/Farming).
- Clash Royale i Brawl Stars, przepustki:
  [Pass Royale](https://support.clashroyale.com/hc/en-us/articles/49484915388443-Pass-Royale),
  [Brawl Pass](https://supercell.com/en/games/brawlstars/blog/news/incoming-changes-to-the-brawl-pass/).
- Idle Human, skórki tracone przy prestiżu:
  [AppGamer](https://www.appgamer.com/idle-human/strategy-guide/how-to-play-idle-human).
- Get Rich Quick, skórki za walutę prestiżu:
  [itch.io](https://ledoc.itch.io/get-rich-quick/devlog/525770/skins-shop-with-prestige-points-save-is-now-kept-between-updates).
- Retencja i rozkład nagród:
  [Game Growth Advisor 2026](https://gamegrowthadvisor.com/blog/2026-03-17-mobile-game-retention-strategies-2026/),
  [DEV: reward economy](https://dev.to/hiroshi_takamura_c851fe71/how-to-build-a-reward-economy-for-a-mobile-game-2e3f),
  [PocketGamer: D30](https://www.pocketgamer.biz/from-click-to-commitment-a-d30-strategy).
- Gradient celu i obdarowany postęp:
  [Laws of UX](https://lawsofux.com/goal-gradient-effect/),
  [Nunes i Drèze 2006](https://msbfile03.usc.edu/digitalmeasures/jnunes/intellcont/Endowed%20Progress%20Effect-1.pdf),
  [Game Developer](https://gamedeveloper.com/game-platforms/the-psychology-of-games-the-endowed-progress-effect-and-game-quests).
