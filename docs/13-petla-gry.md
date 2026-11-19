# 13 — Gra po końcu treści: analiza i plan

Analiza z 16.11.2026, po uwagach z własnej gry: wszystko odblokowane po
ok. 2 tygodniach i 8 h, dalej brak celu, Sprężyny nic nie znaczą wobec
paradoksu, gra zrobiła się chaotyczna. **Nic z tego nie jest jeszcze
zrobione.** To propozycja do decyzji (§7). Zastępuje etap 2 z
[12-pozna-gra.md](12-pozna-gra.md) (wyzwania w ramach paradoksu), bo
symulacja pokazała, że nie zadziałają (§2.4).

Liczby pochodzą z `app/tool/late_game_report.dart` (nowe narzędzie, liczy
na kodzie gry). Gracz w symulacji: 3 sesje dziennie po 11 min, σ = 40 ms,
reklama ×2 do dochodu offline, bez Turbo.

## 1. W skrócie

1. **Treść kończy się po ok. 3 tygodniach** (symulacja: 21 dni i 11.6 h
   gry; u ciebie z Turbo ok. 14 dni i 8 h). W kolejnych 24 dniach gra daje
   5 poziomów zegarów, 5 osiągnięć, 1 tytuł, 1 tarczę i 2 paradoksy.
2. **Początek działał, bo każdy zakup coś odkrywał** (nowy zegar, nowy
   żart, nowa zasada). Wszystko, co dołożyliśmy później, płaci procentami
   do tej samej liczby, a nie odkryciami.
3. **Sprężyny są źle wyskalowane w obie strony.** Następny poziom to +4.8%
   dochodu za 9 Sprężyn (tydzień). Wszystkie poziomy wszystkich zegarów
   (770 Sprężyn, ok. 1.7 roku) dają razem ×2. Jeden paradoks daje ×1.8 za
   darmo.
4. **Dzienny limit dokręcania wybija się w jednej sesji** (7–9 minut gry).
   Kolejne sesje tego dnia nic nie dokręcają.
5. **Wyzwania w ramach paradoksu nie zadziałają.** Przy 44K Chrononów nowe
   przejście odkupuje wszystkie bonusy w ok. 15 minut gry, niezależnie od
   ograniczeń.
6. **Rekomendacja: Pętla czasu.** Gra dostaje cel („kup Chronosa”)
   i zakończenie. Potem nowa pętla: od zera, razem z Chrononami i perkami,
   z jedną zmienioną zasadą. Przez pętle przechodzi tylko mistrzostwo
   zegarów kupowane za Sprężyny. Dzięki temu każda waluta ma jeden zasięg,
   a Sprężyny wreszcie mają sens. Symulacja: druga pętla trwa 8–14 dni,
   kolejne 5–6.

## 2. Co pokazała symulacja

### 2.1 Kiedy kończy się treść

| | Pierwsze 21 dni | Kolejne 24 dni |
|---|---|---|
| Nowe zegary | 14 | 0 |
| Bonusy zegarów (nazwa i żart) | 112 | 0 |
| Perki | 18 | 0 |
| Osiągnięcia | 110 | 5 |
| Paradoksy | 10 | 2 |
| Poziomy zegarów | 17 | 5 |
| Tytuły mistrzowskie | 0 | 1 |
| Tarcze | 8 | 1 |
| Chronony (na koniec) | 10.6K | 44.2K |

Pierwszy Chronos: dzień 16.7 (9.2 h gry). Wszystkie perki: dzień 16.
Wszystkie bonusy: dzień 21. Po 21. dniu dochód rośnie dalej (2.09aa →
17.7aa na sekundę), ale gracz widzi tylko większą liczbę.

### 2.2 Ile wart jest każdy bonus (dzień 45)

| Źródło | Wartość |
|---|---|
| Chronony (44.2K) | ×885 |
| Osiągnięcia (115) | ×2.15 |
| Kupione poziomy zegarów (22 poziomy, 55 Sprężyn) | ×1.71 |
| Następny najlepszy poziom (Chronos 9., 9 Sprężyn) | +4.8% |
| Wszystkie poziomy wszystkich zegarów (770 Sprężyn) | ×2.00 |
| Jedno osiągnięcie | +0.5% |
| Paradoks teraz (+35.8K Chrononów) | ×1.81, za darmo |

- **Chronos daje 87% dochodu**, Kot Schrödingera 9.6%, zegary 1–10 razem
  poniżej 0.5%. Wybór „który zegar podnieść” ma więc jedną dobrą
  odpowiedź. Poziom na pierwszych dziesięciu zegarach nic nie zmienia.
- Chronony dają więcej niż wszystko inne razem, a paradoks nic nie
  kosztuje. Stąd wrażenie, że Sprężyny i osiągnięcia są bez znaczenia.
- Po paradoksie następne podwojenie Chrononów wymaga 8× więcej Tików
  zarobionych łącznie. Jeden dzień dochodu offline dodaje teraz 5.8%, więc
  to miesiące czekania.

### 2.3 Dokręcanie Sprężyn

Limit z trafień to 6 h dziennie, 15 min za każde „równo 5.00”.

| Gracz | „Równo 5.00” na sesję | Minut gry do limitu 6 h | Sprężyn dziennie |
|---|---|---|---|
| 1 × 2 min, σ = 80 ms | 3.2 | 15 | 1.03 |
| 3 × 3 min, σ = 50 ms | 7.7 | 9 | 1.24 |
| 6 × 2 min, σ = 50 ms | 5.1 | 9 | 1.25 |
| 1 × 30 min, σ = 40 ms | 96 | 7 | 1.25 |
| 3 × 11 min, σ = 40 ms | 35 | 7 | 1.25 |

Każdy, kto gra ponad ok. 9 minut dziennie, dostaje to samo: 1.25
Sprężyny. Limit nie odróżnia jednej długiej sesji od kilku krótkich,
więc nie zachęca do powrotu w ciągu dnia. Przy 1.25 dziennie wszystkie
poziomy (770) to ok. 620 dni.

### 2.4 Nowe przejście z zachowanymi Chrononami

Stan z dnia 45 (44.2K Chrononów, wszystkie perki), paradoks i gra od nowa.
Dni (w nawiasie godziny gry) do celu:

| Przejście | 1ab zarobione | 1ac zarobione | Wszystkie bonusy |
|---|---|---|---|
| zwykłe | 0.0 (0.1) | 0.3 (0.2) | 0.3 (0.2) |
| bez Złotej Sekundy | 0.0 (0.1) | 0.7 (0.4) | 0.3 (0.2) |
| na ślepo (σ ×1.5) | 0.0 (0.1) | 0.3 (0.2) | 0.3 (0.2) |
| ceny zegarów ×1.25 zamiast ×1.15 | 0.0 (0.1) | 1.0 (0.5) | nie pada |
| tylko zegary 1–6 | nie pada | nie pada | 1.3 (0.7) |
| Chronony nie działają | nie pada w 10 dni | nie pada | nie pada (Maszyna czasu po 1.7 dnia, 1aa po 3.7) |

Całe przejście to kwadrans. Ograniczenia dotyczące klikania nic nie
zmieniają, bo ok. 90% Tików przychodzi offline. Z wyłączonymi Chrononami
przejście trwa ponad 10 dni, ale bez paradoksów po drodze, więc jest
samym czekaniem. Wniosek: żeby „przejść grę od nowa” coś znaczyło,
Chronony muszą wrócić do zera i trzeba je zdobywać od nowa, paradoksami.

### 2.5 Nowa pętla: wszystko od zera, paradoksy jak zwykle

Zerowane: Tiki, zegary, umiejętności, Chronony, Okruchy, perki. Zostają
osiągnięcia i trwały mnożnik zegarów (mistrzostwo). Dni (godziny gry):

| Co zostaje | Pierwszy Chronos | Wszystkie perki | Wszystkie bonusy |
|---|---|---|---|
| pierwsza pętla (dla porównania, §2.1) | 16.7 (9.2) | 16.0 | 21 (11.6) |
| osiągnięcia | 14.0 (7.7) | 13.7 (7.5) | 18.7 (10.3) |
| osiągnięcia + obecne poziomy zegarów | 13.3 (7.3) | 12.7 (7.0) | 16.7 (9.2) |
| osiągnięcia + każdy zegar ×2 | 8.3 (4.6) | 8.0 (4.4) | 11.0 (6.1) |
| osiągnięcia + każdy zegar ×4 | 5.3 (2.9) | 5.0 (2.8) | 7.0 (4.0) |
| osiągnięcia + każdy zegar ×8 | 3.3 (1.8) | 3.0 (1.6) | 4.0 (2.2) |
| ×4 i ceny zegarów ×1.20 | 6.3 (3.5) | 6.0 (3.3) | 31.7 (17.4) |
| ×4 i ceny zegarów ×1.25 | 7.7 (4.2) | 7.3 (4.0) | nie pada w 40 dni |
| ×4 i bez Złotej Sekundy | 6.3 (3.5) | 6.0 (3.3) | 7.7 (4.2) |
| ×4 i na ślepo (σ ×1.5) | 5.3 (2.9) | 5.0 (2.8) | 7.3 (4.0) |

- Pętla od zera to znowu dni gry z paradoksami, a nie kwadrans.
- Trwały mnożnik zegarów skraca ją w przewidywalny sposób: ×2 to ok. 8
  dni, ×4 ok. 5, ×8 ok. 3.
- Zmieniona zasada wydłuża pętlę o 0–45%. Cel pętli nie może być
  „wszystkie bonusy”, bo przy droższych zegarach to miesiąc.
- **Bonusy samego Chronosa** (8 progów, ostatni przy 50 sztukach) padają
  niedługo po pierwszym Chronosie: ostatni 1–2.3 dnia później (14.0 →
  16.3 dnia z samymi osiągnięciami, 5.3 → 6.3 przy ×4), a przy droższych
  zegarach 2.4–3.6 dnia później (6.3 → 8.7 i 7.7 → 11.3).

Czego symulacja nie liczy: Turbo (będzie szybciej), mnożnika ×3 trybu na
ślepo, różnych poziomów na różnych zegarach (mnożnik jest ten sam dla
wszystkich).

## 3. Diagnoza

**Dlaczego początek był spójny.** Jedna czynność (traf 5.00), jedna
waluta, jeden sklep. Każdy zakup coś pokazywał: następny zegar był „???”,
próg miał śmieszną nazwę, umiejętność zmieniała sposób gry.

**Co się zmieniło.**

1. **Zabrakło odkryć, zostały liczby.** Po 21. dniu nie ma ani jednego
   „???” wśród zegarów, bonusów i perków. Sprężyny, Chronony
   i osiągnięcia dokładają procenty do tej samej liczby. Tarcze są odkryciem, ale przychodzą same za
   czekanie i nic nie zmieniają.
2. **Cztery waluty bez podziału ról.** Tiki, Chronony, Okruchy i Sprężyny,
   do tego +1% za osiągnięcie. Wszystko mnoży ten sam dochód, więc
   liczy się tylko największy mnożnik (Chronony ×885), a reszta wygląda
   jak szum. Okruchy po kupieniu perków są bezużyteczne.
3. **Liczby nieporównywalne dla gracza.** Chronony pokazujemy jako sumę
   („+88 400% na zawsze”), poziom zegara jako „+10%”. Poziom wygląda
   przy tym na nic niewart, nawet tam, gdzie coś daje.
4. **Rdzeń (celność) prawie się nie liczy.** Ok. 90% Tików przychodzi
   offline. Trafienie 5.00 ma znaczenie tylko dla 15 minut Sprężyny,
   a ta jest warta mało.
5. **Brak definicji końca.** Nie ma momentu „przeszedłem grę”. Zostają
   osiągnięcia typu 100 h gry i 100K rund, czyli czekanie.
6. **Paradoksy są takie same.** Każdy to te same zakupy w tej samej
   kolejności, coraz szybciej.

## 4. Jak to robią inne gry

Opisy częściowo z pamięci. Wiki tych gier nie dało się otworzyć z tej
sesji, więc sprawdzone w wyszukiwarce są tylko pozycje ze źródłem w §9.

| Gra | Co robi | Wniosek dla nas |
|---|---|---|
| Cookie Clicker, kostki cukru | poziom budynku daje +1%, ale pierwsza kostka na Farmie, Banku, Świątyni i Wieży odblokowuje minigrę. Pełne poziomy to ok. 1255 kostek, czyli lata | skopiowaliśmy tempo i +%, ale nie powód, dla którego gracze chcą kostek: odblokowanie czegoś nowego |
| Cookie Clicker, „Born again” | tryb wybierany przy prestiżu: gra od zera bez niebiańskich bonusów, osobne osiągnięcia (1M ciastek w 15 min, bez ulepszeń, najwyżej 15 kliknięć) | wyzwanie = przejście od zera bez mocy z prestiżu, z własnymi trofeami |
| Clicker Heroes, Transcendence | drugi, głębszy reset. Kasuje walutę i ulepszenia pierwszego prestiżu, daje walutę na osobne, małe drzewko (Outsiders). Jeden cykl to kilka zwykłych prestiży | dokładnie to, o co pytasz: „przejdź grę od nowa, z resetami po drodze i z bonusami” |
| Antimatter Dimensions (z pamięci) | wyzwania: przejście z jedną zmienioną zasadą, nagrodą jest nowa możliwość (automat), nie procent. Ukończenie wszystkich otwiera następny etap. Gra ma zakończenie | nagroda za wyzwanie ma zmieniać sposób gry. Zakończenie nie przeszkadza grze idle |
| Trimps, Challenge² | wyzwanie można powtarzać, trwały bonus rośnie z najlepszym wynikiem | powtarzalność na później, gdy lista wyzwań się skończy |
| Universal Paperclips | gra idle z końcem po 6–10 h, jedna z najbardziej cenionych w gatunku | wyraźny koniec daje satysfakcję |
| Egg, Inc., AdVenture Capitalist (z pamięci) | kolejne jajka i planety to ta sama pętla od zera z nowym wyglądem i nazwami | powtórkę da się lubić, jeśli jest krótsza i coś odkrywa |
| Wordle | jedna próba dziennie, wynik do porównania, seria dni | dzienny rytuał oparty na umiejętności, nie na czekaniu (§5.6, na później) |

Zasady, które z tego wynikają:

1. **Jedna waluta, jeden zasięg.** W grach, które się nie rozłażą, każda
   waluta żyje w jednej pętli: bieżące przejście, prestiż, drugi prestiż.
2. **Nowa warstwa płaci nowymi zasadami i odkryciami**, nie kolejnym
   procentem do tej samej liczby.
3. **Powtórka musi być krótsza i trochę inna.**
4. **Gra ma mieć koniec, który widać**, i coś po nim.
5. **Systemy pokazywać po kolei**, gdy poprzedni się kończy
   (r/incremental_games, bugnet).

## 5. Rekomendacja

### 5.1 Zasada porządkująca: trzy pętle, trzy zasięgi

| Pętla | Trwa | Waluta | Co zeruje |
|---|---|---|---|
| Runda | 5 sekund | – | – |
| Przejście (do paradoksu) | godziny, 1–3 dni | **Tiki** | Tiki, zegary, umiejętności |
| Pętla czasu (do Chronosa) | 1–2 tygodnie, potem dni | **Chronony i Okruchy** | to co wyżej + Chronony, Okruchy, perki |
| Cała gra | miesiące | **Sprężyny** | nic |

Nie dochodzi żadna nowa waluta. Zmienia się to, że Chronony przestają
rosnąć bez końca, a Sprężyny stają się jedyną mocą, która zostaje na
zawsze. Odpowiedź na „po co dokręcać Sprężyny”: bo tylko one przechodzą
do następnej pętli.

### 5.2 Pętla czasu (nowe)

- **R-PETLA-1 (cel):** Pętla kończy się, gdy gracz kupi pierwszego
  Chronosa. To jest „przejście gry”. Pasek celu (§5.5) prowadzi do niego
  od początku: następny zegar, perk „Pudełko z kotem”, „Ołtarz Chronosa”,
  Chronos.
- **R-PETLA-2 (zakończenie):** Po zakupie Chronosa scena „Czas pokonany”:
  czas pętli, liczba paradoksów, celność, najlepsza seria. Potem przycisk
  „Nowa pętla”. Gracz może zostać w starej pętli, jak długo chce. Nic nie
  wymusza resetu.
- **R-PETLA-2a (bonusy Chronosa):** Każdy bonus Chronosa zdobyty w tej
  pętli (8 progów: 5, 10 … 50 sztuk) daje **+1 Sprężynę**, najwyżej 8 na
  pętlę. Bez tego bonusy Chronosa nie miałyby sensu: przyspieszałyby
  tylko pętlę, którą gracz zaraz opuści. Tak płacą w jedynej walucie,
  która przechodzi dalej, i dają decyzję „wychodzę teraz czy zostaję po
  więcej”. W zwykłej pętli komplet to 1–2 dni dłużej, przy droższych
  zegarach 2–4 dni (§2.5), więc tam warto wyjść wcześniej. Pasek celu po
  Chronosie pokazuje następny próg („Chronos 7/10 → +1 Sprężyna”).
- **R-PETLA-3 (reset):** Nowa pętla zeruje Tiki, zegary, umiejętności,
  Chronony, Okruchy i perki. **Zostają:** Sprężyny i mistrzostwo zegarów,
  pieczęcie, osiągnięcia, tarcze, motywy, statystyki. Ekran przed resetem
  pokazuje obie listy.
- **R-PETLA-4 (zasada pętli):** Każda pętla od drugiej ma jedną zmienioną
  zasadę, w stałej kolejności (tabela niżej, od najłagodniejszej). Gracz
  jej nie wybiera: ogłasza ją Chronos na ekranie zakończenia poprzedniej
  pętli. Dalsze zasady są w Kronice widoczne jako „???”. Stała kolejność
  jest prostsza, pozwala stroić każdą pętlę, wiedząc, jakie pieczęcie
  gracz już ma, i daje co pętlę jedno „co będzie dalej?”. Wybór pojawia
  się po ostatniej pętli (R-PETLA-8).
- **R-PETLA-5 (co daje ukończenie):** Każda ukończona pętla daje cztery
  rzeczy, pokazane po kolei na ekranie „Czas pokonany”:
  1. **rozdział Kroniki** (R-PETLA-7): kilka zdań historii z żartem;
  2. **pieczęć**: trwałą, małą zmianę zasady (nie procent), która działa
     we wszystkich następnych pętlach;
  3. **tarczę zegara** w motywie tej pętli;
  4. **zapowiedź następnej zasady**: nazwa, co zmienia i jaką pieczęć
     daje (nazwa pieczęci jako „???” do zdobycia).

  Sprężyny za pętlę są tylko z bonusów Chronosa (R-PETLA-2a).
- **R-PETLA-7 (fabuła i Kronika):** Ramą jest Chronos. Gracz kupuje boga
  czasu za Tiki, a ten się obraża i cofa wszystko do zera, za każdym
  razem psując jedną zasadę („Zabieram ci cyferki”). Każda ukończona
  pętla to chwila, w której Chronos musi coś oddać (pieczęć). Opowiada
  Dziadek, który prowadzi już samouczek. Wątek na całość: dlaczego akurat
  5.00, z odpowiedzią w ostatnim rozdziale. Kronika to jeden ekran
  (ikona w nagłówku od pierwszego Chronosa): 7 rozdziałów, pieczęcie
  i tarcze, niezdobyte jako „???”. Zastępuje osobne listy, więc nie
  dochodzi kolejne miejsce do sprawdzania. Teksty PL/EN, po 3–5 zdań,
  ton jak w opisach zegarów.
- **R-PETLA-8 (po ostatniej pętli):** Siódma pętla kończy historię:
  ostatni rozdział, tytuł „Zegarmistrz czasu” i tryb dowolny. W nim
  gracz sam wybiera zasadę następnej pętli albo kilka naraz, a Kronika
  zapisuje najkrótszy czas każdej (wzór: Challenge² w Trimps).
- **R-PETLA-6 (tempo):** Druga pętla ma trwać 50–65% czasu pierwszej
  (ok. 9–11 dni), kolejne 5–6 dni, nie mniej niż ok. 3 dni przy pełnym
  mistrzostwie (§2.5). Sprawdza `late_game_report.dart`, potem
  `idle_sim.dart`.

Zasady na start (wszystkie korzystają z istniejących mechanik; lista
z 12 §3.2 po przesianiu symulacją):

| id | Nazwa | Zmieniona zasada | Pieczęć (na zawsze) |
|---|---|---|---|
| `blindfold` | Zepsuty stoper | Na ślepo jest zawsze włączone | Na ślepo płaci +1 (×4, ze Śmiałkiem ×5) |
| `inflation` | Drożyzna | cena zegara rośnie ×1.20 za sztukę zamiast ×1.15 | pierwsze 10 sztuk każdego zegara za pół ceny |
| `noGold` | Pochmurny dzień | brak Złotej Sekundy | Złota Sekunda przylatuje w 30 s po powrocie po co najmniej 1 h (11 §3.3) |
| `shortFuse` | Krótki lont | combo najwyżej 5, bez Tarczy | +1 ładunek Tarczy od początku przejścia |
| `precision` | Szwajcarska precyzja | DOBRZE nic nie płaci graczowi | okno PERFEKT +0.001 s |
| `insomnia` | Bezsenność | dochód offline 25% | limit offline +12 h |

Sześć zasad to razem z pierwszą pętlą siedem pętli, czyli według §2.5
ok. 2 miesięcy celów. Kolejność jak w tabeli: `blindfold` jest pierwszy,
bo nie wydłuża pętli (§2.5), dotyczy celowania i płaci ×3, więc jest
bardziej odmianą niż karą. `insomnia` jest jedyną zasadą, która wymusza
granie zamiast czekania, więc idzie na koniec i ma łagodną wersję (25%,
nie 0). Bez wariantu „bez dochodu pasywnego”.

Jak wygląda koniec pętli:

1. Zakup Chronosa: animacja jak przy paradoksie, potem ekran „Czas
   pokonany” z wynikiem pętli (dni, godziny gry, paradoksy, celność).
2. Rozdział Kroniki, np. po pierwszej pętli: „— Kupiłeś mnie? MNIE? Za
   Tiki? — Chronos poprawił togę. — Dobrze. Zobaczymy, jak ci pójdzie bez
   cyferek. — Nie przejmuj się — mruknął Dziadek. — On tak zawsze przed
   piątą.”
3. Pieczęć i tarcza z fanfarą (od drugiej pętli; pierwsza nie miała
   zasady, więc daje tylko rozdział i zapowiedź).
4. Zapowiedź: „Następna pętla: Zepsuty stoper. Cyfry znikają na ostatnią
   sekundę. Pieczęć: ???”.
5. Dwa przyciski: „Zostaję jeszcze” (pasek celu pokazuje „Chronos 1/5 →
   +1 Sprężyna”) i „Nowa pętla” (ekran z listami „zeruje się” i „zostaje”,
   potwierdzenie jak przy paradoksie).

W nagłówku jest numer pętli i ikona jej zasady. Dotknięcie przypomina,
co zasada zmienia.

**Dlaczego to nie komplikuje gry.** Gracz zna już wszystko, czego pętla
używa: zegary, paradoks, perki. Dochodzi jeden ekran zakończenia i jedna
Kronika. Pojawia się dopiero po Chronosie, czyli wtedy, gdy stara treść
się kończy.

**Ryzyko.** Utrata Chrononów może boleć. Dlatego reset jest dobrowolny,
ekran pokazuje, co zostaje, a druga pętla jest wyraźnie szybsza.
Clicker Heroes ma to od lat.

### 5.3 Sprężyny: z poziomów w mistrzostwo

- **R-SPR-5 (zmiana):** 5 stopni mistrzostwa na zegar zamiast 10
  poziomów. Stopień N kosztuje N Sprężyn (1–5, razem 15 na zegar, 210 na
  wszystkie zamiast 770). Każdy stopień mnoży dochód zegara **×1.5**
  (×7.6 przy pięciu) zamiast +10%.
- **R-SPR-6 (zmiana):** Tytuły mistrzowskie (28 gotowych nazw i żartów)
  przechodzą na stopnie 3 i 5. Stopnie 1, 2 i 4 pokazują na karcie zegara
  nowy mnożnik.
- **Magazyn:** 10, bez zmian (najdroższy stopień kosztuje 5).
- **Migracja:** kupione poziomy zwracamy w Sprężynach (bez limitu magazynu
  na ten jeden raz) i gracz wydaje je od nowa.

Dlaczego tak:

- W nowej pętli Chronony startują od zera, więc mistrzostwo jest wtedy
  największym mnożnikiem w grze i od razu je widać.
- Pojawia się prawdziwy wybór. Mistrzostwo wczesnych zegarów
  przyspiesza start każdej pętli, późnych jej koniec. Dziś jedyna dobra
  odpowiedź to Chronos (§2.2).
- Tempo: przy 1.25–1.5 Sprężyny dziennie pierwszy stopień wszystkich
  zegarów to ok. 10 dni, wszystko ok. 5 miesięcy. Pierwsze stopnie
  przychodzą co dzień, ostatnie co kilka dni. To nadal długi cel, ale nie
  lata.
- Pełne mistrzostwo (×7.6) daje pętle po ok. 3 dni (§2.5, wiersz ×8), więc
  gra nie zwija się do kwadransa.

### 5.4 Dokręcanie i reklama

- **Jak to działa dziś:** Sprężyna jest gotowa, gdy jej pasek dojdzie do
  24 h. Pasek rośnie sam z czasem (także gdy gra jest zamknięta), a każde
  „równo 5.00” dorzuca do niego 15 min. Trafieniami można dorzucić
  najwyżej 6 h na dobę.
- **R-SPR-3 (zmiana):** zamiast „6 h na dobę” zapas dokręcania **2 h,
  który odnawia się 30 min na godzinę** (pełny po 4 h). Zapas to limit
  tego, ile trafienia mogą dorzucić naraz: każde trafienie zabiera z
  niego tyle, ile dokręca. Pusty zapas: trafienia nic nie dokręcają,
  dopóki nie wróci. W grze: mały pasek przy Sprężynie i jedno zdanie
  „Trafieniami dokręcisz 2 h naraz. Zapas wraca w 4 godziny.” Trzy sesje
  dziennie dają tyle co dziś (6 h), pięć daje 10 h. Jedna długa sesja
  daje 2 h i 30 min za każdą kolejną godzinę gry, czyli mniej niż dziś
  (1.09 zamiast 1.25 Sprężyny dziennie). To celowe: nagradzamy powroty.
- **R-SPR-3a (nowe):** **pierwsze „równo 5.00” po przerwie co najmniej
  1 h dokręca 1 h**, kolejne po 15 min. Powód do wejścia na minutę:
  jedno dobre trafienie i godzina Sprężyny. Wzmacnia rdzeń gry.
- **`adSpring` (nowa oferta):** „Dokręć” odnawia zapas od razu, najwyżej
  2 razy na dobę. Rekomenduję reset zapasu, a nie gotowe +2 h: po
  reklamie gracz musi jeszcze trafić, więc reklama prowadzi do gry, a nie
  ją zastępuje. Oferta pojawia się pod tarczą, gdy zapas jest pusty.
- Efekt (zrobione, policzone na kodzie gry, 03 §4.3): 1.25 Sprężyny
  dziennie dla gracza „3 sesje”, 1.42 przy 5–6 krótkich wejściach, do
  1.52 z reklamami. Gracz przypadkowy 1.06. Wcześniejszy szacunek „do
  1.5 i 1.65” był liczony ręcznie i za wysoki.

Przykład dnia (zapas pełny rano):

| Godzina | Zapas przed | Co robi gracz | Dokręcone | Zapas po |
|---|---|---|---|---|
| 8:00 | 2 h | pierwsze „równo 5.00” po przerwie (+1 h), potem cztery kolejne (4 × 15 min) | 2 h | 0 |
| 8:05 | 0 | trafia dalej | 0 (albo reklama: zapas znów 2 h) | 0 |
| 12:00 | 2 h (minęły 4 h) | to samo co rano | 2 h | 0 |
| 14:00 | 1 h (minęły 2 h) | wchodzi na minutę, jedno „równo 5.00” po przerwie | 1 h | 0 |
| 20:00 | 2 h | to samo co rano | 2 h | 0 |

Razem 7 h z trafień i 24 h z samego czasu, czyli 31 h paska: jedna
Sprężyna i 7 h zapasu na następną (1.29 Sprężyny). Bez trafień byłaby
dokładnie jedna na dobę.

### 5.4a Zmiana po wdrożeniu: 30 min za trafienie zamiast premii

Premię R-SPR-3a usunęliśmy, a każde „równo 5.00” dokręca 30 min zamiast
15. Powód: przy 15 min za trafienie zapas 2 h opróżnia się po 8
trafieniach (ok. 5 min gry), więc bez premii krótkie wejścia nic nie
dają. Premia to łatała, ale była dodatkową zasadą („pierwsze po
godzinie”), znaczkiem i pomarańczowymi kropkami. Przy 30 min za
trafienie wystarczą 4 trafienia (2–3 min), więc efekt jest ten sam bez
dodatkowej zasady.

Policzone na kodzie gry (03 §4.3): bez reklam liczby są takie jak
z premią (1.25 przy 3 × 3 min, 1.42 przy 6 × 2 min, 1.09 przy 1 × 30
min). Różnica jest w reklamie `adSpring`: pokazuje się tylko przy
pustym zapasie, a przy 15 min bez premii w krótkich sesjach zapas
prawie nigdy się nie opróżnia. Przy 30 min oferta pojawia się po 2–3
minutach gry i daje ok. 45 min paska zamiast ok. 18 min z premią
(uproszczony model, nie kod gry).

### 5.5 Porządki (małe, tanie)

- **Pasek celu przez całą grę** (dziś R-TUT-7 znika po pierwszym
  paradoksie). Zawsze jeden cel: następny zegar, perk, Chronos, stopień
  mistrzostwa, na który stać gracza. To bezpośrednia odpowiedź na „nie
  mam celu”.
- **Ekran „Mnożniki”** w statystykach: Chronony ×21, osiągnięcia ×1.6,
  mistrzostwo zegara ×3.4, Turbo ×2. Wszystko jako mnożnik, żeby dało się
  porównać. Chronony na ekranie paradoksu też jako „×21 → ×38”.
- **Tarcze jako trofea.** Nieodblokowane tarcze przenosimy z progów
  zarobków na pieczęcie pętli i mistrzostwo. Odblokowane zostają.
- **Okruchy** bez zmian. W pętli mają sens do ostatniego perku, a wtedy
  pętla i tak się kończy.
- **Wzór na Chronony** bez zmian. Zastój po 75. dniu przestaje być
  problemem, bo pętla kończy się wcześniej.

### 5.6 Na później: Próba dnia

Zamiast biernej dziennej premii (R-DZIEN): raz dziennie 5 rund na
wynik (suma błędów), te same warunki dla wszystkich danego dnia, rekord
własny i seria dni. Nagroda: dokręcenie Sprężyny zależne od wyniku. Wzór:
Wordle. Robimy dopiero, gdy pętle działają i dane pokażą, że brakuje
powodu do codziennego wejścia.

### 5.7 Czego nie robić

- **Wyzwań w ramach paradoksu** (12 §3.2): kwadrans gry (§2.4).
- **Ulepszeń bez końca za Okruchy:** kolejny procent do tej samej liczby.
- **Nowych walut, minigier, kolekcji.**
- **Większych liczb w Sprężynach bez pętli:** poziom ×1.5 przy Chrononach
  ×885 dalej byłby tylko procentem.

## 6. Kolejność

**Stan (16.11.2026):** etapy 1–4 są zrobione: dokręcanie, oferta
`adSpring`, pasek celu, mnożniki; mistrzostwo zegarów (5 stopni, ×1.5,
zwrot Sprężyn); Pętla czasu z sześcioma zasadami, pieczęciami,
zakończeniem i Kroniką; tarcze jako trofea. Zasady w 02 §11–§16, pomiar
tempa na kodzie gry w 03 §4.4 (historia: ok. 57 dni). Zostaje etap 5
(Próba dnia), tylko jeśli dane pokażą potrzebę.

| Etap | Co | Wielkość | Po co najpierw |
|---|---|---|---|
| 1 | §5.4 dokręcanie i oferta `adSpring`, §5.5 pasek celu i ekran mnożników | mała | od razu poprawia codzienne sesje i daje cel, nie rusza balansu |
| 2 | §5.3 mistrzostwo (5 stopni, ×1.5, migracja) | mała do średniej | musi być przed pętlą, żeby gracz miał co do niej wnieść |
| 3 | §5.2 Pętla czasu: cel, zakończenie, reset, druga pętla bez zmiany zasady, trzy zasady (`blindfold`, `inflation`, `noGold`) | duża (szacunkowo dwa razy tyle co Sprężyny) | główna zmiana |
| 4 | pozostałe zasady, tarcze jako trofea | średnia | treść na kolejne tygodnie |
| 5 | §5.6 Próba dnia | średnia | tylko jeśli dane pokażą potrzebę |

Grafika (osobna sesja): ikony zasad pętli i pieczęci (6 + 6), osobne
grafiki bonusów zegarów zamiast powtórzonych ikon. Żadna z nich nie
blokuje etapów 1–3.

## 7. Decyzje do podjęcia

1. **Cel pętli:** pierwszy Chronos, a bonusy Chronosa płacą Sprężynami
   (rekomendacja, R-PETLA-2a), czy prościej: celem jest ostatni bonus
   Chronosa (50 sztuk; pętla dłuższa o 1–4 dni, bez decyzji „zostać czy
   wyjść”).
2. **Mnożnik stopnia mistrzostwa:** ×1.5 (rekomendacja, pełne ×7.6) czy
   ×2 (pełne ×32, pętle spadną poniżej 2 dni).
3. **Zwrot kupionych poziomów w Sprężynach:** tak (rekomendacja) czy
   przeliczenie 2 poziomy → 1 stopień.
4. **Reklama:** reset zapasu dokręcania (rekomendacja) czy gotowe +2 h.
5. **Kolejność zasad:** stała, ogłaszana przez Chronosa, druga pętla od
   razu z „Zepsutym stoperem” (rekomendacja po rozmowie o fabule;
   wcześniej: druga pętla bez zasady) czy wybór z kilku odkrytych.

## 8. Jak sprawdzić

Przed kodem gry, w symulatorach (03 E-3):

| Cel | Przedział | Narzędzie |
|---|---|---|
| Pierwsza pętla, gracz 3 × 11 min | pierwszy Chronos w 14–20 dni (dziś 16.7) | `late_game_report.dart` |
| Druga pętla z pierwszym stopniem na 14 zegarach | 50–65% czasu pierwszej | jw., po dodaniu stopni |
| Pętla z dowolną zasadą | najwyżej +50% do pętli bez zasady | jw. |
| Pętla przy pełnym mistrzostwie | co najmniej 3 dni | jw. |
| Sprężyny, gracz 3 × 3 min | 1.2–1.3 dziennie; 6 krótkich sesji 1.4–1.5 | jw., część 3 |
| B-1…B-10, A-1, A-2 | bez zmian | `simulate.dart --check` |

Po wydaniu (zdarzenia do dodania w T-34): `loop_done` (`loop`, `rule`,
`days`, `play_min`), `loop_start` (`rule`), `mastery` (`clock`, `tier`),
`spring_wind` (minuty z trafień),
`ad_reward` dla `adSpring`. Patrzymy, ilu graczy po Chronosie zaczyna
drugą pętlę, które zasady wybierają i czy liczba sesji dziennie rośnie.

## 9. Źródła

- [Cookie Clicker Wiki – Sugar Lumps](https://cookieclicker.wiki.gg/wiki/Sugar_Lumps)
- [Pocket Gamer – Cookie Clicker: Sugar Lumps](https://www.pocketgamer.com/cookie-clicker/sugar-lumps)
- [Cookie Clicker Wiki – Challenge Mode (Born again)](https://cookieclicker.fandom.com/wiki/Challenge_Mode)
- [Clicker Heroes – kiedy robić Transcendence](https://blog.clickerheroes.com/best-time-to-transcend-when-to-hit-zone-300-and-beyond/)
- [Clicker Heroes – Ancient Souls i Outsiders](https://blog.clickerheroes.com/ancient-souls-per-transcension-how-to-maximize-your-gain/)
- [Trimps Wiki – Challenge²](https://trimps.fandom.com/wiki/Challenge%C2%B2)
- [Universal Paperclips – Wikipedia](https://www.wikipedia.org/wiki/Universal_Paperclips)
- [Incremental game – Wikipedia (gry z zakończeniem i bez)](https://en.wikipedia.org/wiki/Incremental_game)
- [bugnet – How to design an idle or incremental game](https://bugnet.io/blog/how-to-design-an-idle-or-incremental-game)
- [A. Pecorella – The Math of Idle Games, Part III](https://www.gamedeveloper.com/design/the-math-of-idle-games-part-iii)
- [r/incremental_games – na co zwrócić uwagę, projektując grę](https://redlib.hbubli.cc/r/incremental_games/comments/1e8gl1c/key_considerations_for_creating_an_incremental)
- [Axios – serie w Wordle](https://www.axios.com/2022/02/11/snapping-wordle-streak)
- [GameRefinery – mechaniki reklam nagradzanych](https://gamerefinery.com/how-to-build-better-mechanics-for-rewarded-in-game-ads)
- [Unity – rewarded video](https://unity.com/blog/how-to-level-up-your-rewarded-video-monetization)

Antimatter Dimensions, Egg, Inc. i AdVenture Capitalist są opisane
z pamięci, bez sprawdzonego źródła. Liczby z innych gier są orientacyjne.
