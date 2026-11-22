# 16 — Fabuła

Biblia fabuły: o czym jest historia, kto w niej mówi i jak, gdzie i kiedy
się pojawia. Teksty są w `app/lib/l10n/app_{pl,en}.arb`. Ten plik mówi,
jak je pisać i zmieniać.

Skąd ta wersja (11.2026): poprzednia fabuła (Chronos na półce sklepu
z metką, Dziadek chce go kupić) była naciągana. Postacie mówiły jednym
głosem i językiem interfejsu („Tarczy nie było”), a między prologiem
a rozdziałem 1 przez ok. 13 dni nic się nie działo. Teksty sprawdzono
kryteriami ze skilli `dialogue` i `joke-engineering` (jwynia/agent-skills):
każda kwestia robi co najmniej dwie rzeczy naraz, pod słowami jest
podtekst, a żart bierze się z rozjazdu „ogromny wysiłek, drobny cel”.

## 1. O czym to jest

**Dziadek wiecznie się spóźnia.** Babcia od pięćdziesięciu lat podaje
podwieczorek punktualnie o piątej, a Dziadek zawsze wpada po czasie.
Uparł się, że to wina zegarka, więc kupuje coraz dokładniejsze zegary:
kukułkę, zegar atomowy, satelitę. Na końcu postanawia zdobyć sam Czas,
czyli Chronosa.

- Drabina zegarów w grze (02 §6) to kolejne podejścia Dziadka.
- Główny żart na całą grę: satelity i pulsary po to, żeby zdążyć na
  sernik.
- Babcia ma podtekst, bo wie, że problem nie leży w zegarku.

**Tajemnica.** Na stole zawsze stoją cztery filiżanki. W 1974 roku
Dziadek biegł spóźniony na pierwszą randkę, a Babcia już wychodziła.
Chronos zatrzymał wtedy czas na pięć sekund i Dziadek zdążył. Dziadek
o tym nie wie, Babcia wie. Od tamtej pory nakrywa dla Chronosa, a on,
dumny, nigdy nie przychodzi. Stąd 5.00.

**Temat** (nigdy nie mówiony wprost): czasu się nie kupuje, czas się
komuś poświęca. Jedyne miejsce, gdzie pada to zdanie, to opis Chronosa
w karcie zegara, z ust Babci.

## 2. Postacie i ich głos

Test: zasłoń imię. Ma być jasne, kto mówi.

| Postać | Kim jest | Jak mówi | Czego nigdy nie robi |
|---|---|---|---|
| **Dziadek** | spóźnialski, uparty, wynalazca z garażu | dużo, z entuzjazmem, tłumaczy się; do gracza szeptem, jak do wspólnika | nie przyznaje, że to jego wina; nie pamięta dat |
| **Babcia** | punktualna, spokojna, wie więcej, niż mówi | mało, krótko, sucho; ma ostatnie słowo | nie podnosi głosu; nie mówi o Chronosie wprost |
| **Chronos** | bóg czasu, dumny, samotny, w gruncie rzeczy miękki | wyniośle, krótko, w trzeciej osobie o bogach („Bogowie nie wpadają”); wymyka mu się więcej, niż chce | nie przyznaje się do sentymentu; nie przychodzi na herbatę (do finału) |
| **Gracz** | wnuczę z wyczuciem czasu („Po Babci”) | nie mówi nic | — |

## 3. Zasady pisania

1. **Gracz nigdy nic nie mówi** i nie odpowiada na pytania. Postacie nie
   zadają mu pytań, które czekają na odpowiedź.
2. **Bez rodzaju gramatycznego wobec gracza.** Nie „trafiłeś”, tylko
   „Widziałem to 5.00”. Babcia mówi do gracza „dziecko”, Dziadek nie
   używa zwrotów do gracza. W liczbie mnogiej („wy”) wolno.
3. **Do gracza rzadko, między sobą często.** Najwyżej jedna, dwie kwestie
   na scenę skierowane do gracza (szeptem).
4. **Postacie nie nazywają mechanik.** Nie mówią „Tarcza”, „seria”,
   „Złota Sekunda”. Mechanikę wyjaśnia interfejs (opis zasady pod
   cytatem), postać tylko reaguje.
5. **Emocję pokazuje portret i didaskalia**, nie narrator.
   Didaskalia w nawiasie są krótkie: „(szeptem, do ciebie)”, „(cicho)”.
6. **Jedno zdanie na dymek**, do ok. 80 znaków. Scena: 4–12 dymków.
7. **Żart przez charakter, nie kalambur.** Zapowiedź i puenta mogą być
   daleko od siebie (kukułka w opisie zegara → kukułka w scenie zegara
   atomowego).
8. **Wersja EN to lokalizacja**, nie tłumaczenie słowo w słowo.
9. **Czytaj na głos.** Jeśli się nie da powiedzieć, przepisz.

## 4. Gdzie i kiedy fabuła się pojawia

Zasada: w pierwszej godzinie gry nic poza prologiem. Pierwsze zegary
wpadają co kilka minut, więc scenka przy każdym byłaby przeszkodą.

| Co | Kiedy | Forma |
|---|---|---|
| Prolog | po pierwszym Tiku nowej gry (02 R-TUT-0) | okno z ilustracją, scena dymek po dymku, na końcu cel |
| Opisy zegarów | zawsze, w karcie zegara | dwie kwestie: Dziadek tłumaczy, Babcia dopowiada |
| Scena „Zegar atomowy” | pierwszy zegar atomowy (ok. 3,5 h) | okno ze sceną |
| Scena „Do tyłu” | pierwszy paradoks (dzień 1–2) | okno ze sceną |
| Scena „Siedemdziesiąty czwarty” | pierwsza Maszyna czasu | okno ze sceną |
| Scena „Ołtarz” | kupiony perk Ołtarz Chronosa | okno ze sceną |
| Kwestia dnia | okno „Witaj z powrotem” z dzienną premią, raz dziennie | jedna kwestia z portretem; 7 kwestii po kolei |
| Rozdziały 1–7 | zakończenie pętli (02 R-PETLA-2) | scena w oknie „Czas pokonany!”, potem w Kronice do przeczytania |
| Cytat Chronosa | zapowiedź zasady pętli | jedno zdanie nad opisem zasady |

Rzadkie sceny (wiersze 3–6) pokazują się tylko w pierwszej pętli, po
samouczku, w przerwie między rundami, najwyżej jedna na przerwę,
w kolejności fabuły (`GameController.storyScenes`). Gracz, który ma już
kilka warunków spełnionych, dostaje je w kolejnych przerwach. Widziane
sceny zapisują się w `tipsSeen` jako `story_<id>`.

## 5. Łuk fabuły

- **Prolog „Siedem minut”:** kuchnia, 17:00, cztery filiżanki. Babcia
  daje graczowi stoper: „Zmierz mu, dziecko”. Dziadek wpada 17:07.
  Postanawia zdobyć zegar, który się nie myli. Babcia: „Przy stole się
  o nim nie mówi”.
- **Pętla 1:** opisy zegarów i cztery rzadkie sceny. „Ktoś ci pomógł”
  (Maszyna czasu) zasiewa tajemnicę, „Przy gościach nie chodzi się
  rozczochranym” (Ołtarz) zapowiada, że Babcia zna Chronosa.
- **Rozdział 1 „Wezwany”:** Chronos: „Wezwałeś boga czasu, żeby zdążyć
  na herbatę”. Słyszy głos Babci, zastyga i cofa czas do tamtego
  podwieczorku. „Zegary nie będą pamiętać. Wy tak.” To fabularne
  wyjaśnienie pętli: zeruje się postęp (zegary), zostaje to, co gracz
  „pamięta” (Sprężyny, pieczęcie, mistrzostwo).
- **Rozdziały 2–6:** każda zasada pętli to lekcja punktualności od
  Chronosa (tabela niżej). Tajemnica odsłania się po kawałku: zaproszenie
  („Bogowie nie wpadają”), data rocznicy, którą Chronos zna, czwarta
  filiżanka, pięć sekund dla „spóźnialskiego z kwiatami” (Dziadek: „Głupek”,
  Chronos: „Mhm”), Babcia przez drzwi: „Wiem, że tam jesteś”.
- **Rozdział 7 „Punkt piąta”:** Dziadek pierwszy raz przychodzi sam,
  o 16:59. Chronos puka równo o piątej. Babcia nalewa do czwartej
  filiżanki. „Wy się znacie?” „Od pięciu sekund. W siedemdziesiątym
  czwartym.” Chronos siada: „…Sernik?”.

| Pętla | Zasada | Lekcja Chronosa |
|---|---|---|
| 2 | Zepsuty stoper | naucz się czuć czas, bez cyferek |
| 3 | Drożyzna | czas kosztuje |
| 4 | Pochmurny dzień | na herbatę się nie trafia, na herbatę się przychodzi |
| 5 | Krótki lont | jedno krzywe trafienie i od zera („tak jest z randkami”) |
| 6 | Szwajcarska precyzja | byle jakie trafienie się nie liczy |
| 7 | Bezsenność | kto śpi, ten się spóźnia |

Rozdział n kończy pętlę n i zapowiada zasadę pętli n+1.

Świadoma umowność: w grze kupuje się wielu Dziadków, wiele Babć i do 50
Chronosów jako zegary. Fabuła tego nie tłumaczy, tak jak Cookie Clicker
nie tłumaczy setek babć.

## 6. Format scen w plikach tłumaczeń

Scena to jeden tekst, jedna kwestia w wierszu:

```
*: Kuchnia Babci. Stół nakryty na cztery filiżanki.
grandma (podaje ci stoper): Zmierz mu, dziecko.
grandpa: Niemożliwe. Mój zegarek pokazuje piątą.
```

- Mówiący: `grandpa`, `grandma`, `chronos` albo `*` (podpis pod kadrem,
  bez portretu). Identyfikatory zostają po angielsku w każdym języku.
- Didaskalia w nawiasie są opcjonalne.
- Wiersz, który nie pasuje do formatu, pokazuje się jako podpis (literówka
  w tłumaczeniu nie ukrywa tekstu). Test `test/story_test.dart` pilnuje,
  żeby każdy wiersz bez `*` miał znanego mówiącego.
- Klucze: `prologue`, `chapter_1` … `chapter_7`, `story_atomic`,
  `story_paradox`, `story_timeMachine`, `story_altar` (tytuły z
  przyrostkiem `_t`), `welcomeLine_1` … `welcomeLine_7`.

Odtwarza je `StoryPlayer` (`app/lib/ui/widgets/story_scene.dart`, 04
U-33a). W Kronice ta sama scena jest do przeczytania w całości
(`StoryTranscript`).

## 7. Co dalej (poza tą zmianą)

- Ilustracje: prompty scen w nowym miejscu akcji (kuchnia, garaż) są
  w `tools/art/story_prompts.json` (docs/10).
- Portrety z minami: dziś w scenach są ikony postaci z gry. Docelowo
  3–4 miny na postać (np. Chronos: obrażony, zaskoczony, wzruszony mimo
  woli), wybierane didaskaliami.
- Kwestie dnia i opisy zegarów można dopisywać bez zmian w kodzie
  (kwestie dnia: zmienić liczbę w `welcomeLine` w `catalog.dart`).
