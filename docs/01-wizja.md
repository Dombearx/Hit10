# 01 — Wizja

## Jednym zdaniem

**Hit10** to mobilna gra typu idle/clicker, w której trzeba dotknąć ekranu,
gdy stoper pokaże **równo 10.00 s**. Za trafienia dostajesz **Tiki**, za Tiki
kupujesz umiejętności i coraz dokładniejsze „zegary”, które grają za ciebie.
Wzorem jest Cookie Clicker. Różnica: tutaj liczy się wyczucie czasu, a nie
szybkość klikania.

## Filary (każda decyzja ma je wspierać)

1. **Jedno dotknięcie, maksimum napięcia.** Rdzeń da się zrozumieć w 3 sekundy,
   a perfekcyjne trafienie ma dawać prawdziwą satysfakcję.
2. **Tryska.** Każde trafienie to fajerwerk: cząsteczki, wstrząs, dźwięk,
   wibracja, lecące liczby. Gra ma wyglądać i brzmieć jak topowe gry mobilne.
3. **Zawsze jest coś do kupienia.** Następny cel jest zawsze w zasięgu kilku
   minut, a ostateczny w zasięgu tygodni (prestiż).
4. **Umiejętność się opłaca, ale nie jest wymagana.** Gracz precyzyjny zarabia
   więcej, a gracz przeciętny i tak awansuje. Pasywny dochód działa też
   offline.
5. **Śmieszne.** Dziadek z zegarkiem, babcia z minutnikiem do jajek, zegar
   dworcowy, który „ma opóźnienie”. Humor w nazwach i opisach.

## Odbiorca i platforma

- Gracze casual na telefonach, sesje 1–5 minut kilka razy dziennie i dłuższe
  posiedzenia.
- **Android (Google Play)** jako cel pierwszego wydania. Kod nie może blokować
  późniejszego iOS.
- Tylko orientacja pionowa. Obsługa ekranów od ok. 5" do tabletów, 60 i 120 Hz.
- **Języki: polski i angielski** od pierwszej wersji. Domyślnie język
  systemu, z przełącznikiem w ustawieniach.

## Zakres

**W wersji 1.0:** wszystko z [02-rozgrywka.md](02-rozgrywka.md), czyli rundy,
progi, combo, 11 umiejętności, 14 generatorów, ulepszenia i synergie, Złota
Sekunda, tryby ryzyka, osiągnięcia, prestiż, dochód offline, zapis stanu,
samouczek, ustawienia. Do tego oprawa z [04-ekrany-i-oprawa.md](04-ekrany-i-oprawa.md).

**Poza zakresem 1.0 (świadomie):**
- Żadnego backendu, kont, logowania ani synchronizacji w chmurze. Gra działa
  w 100% offline na telefonie.
- Rankingi, wydarzenia, zakupy w aplikacji.
- Analityka i zbieranie danych. Jedyny wyjątek to reklamy w M6, ze zgodą
  użytkownika.

**Monetyzacja (etap M6, przed wydaniem):** wyłącznie **reklamy nagradzane**,
oglądane z wyboru gracza:
- ×2 dochodu offline,
- 2 minuty Szału,
- dodatkowa Złota Sekunda.

Reklama nigdy nie pojawia się w trakcie rundy. Reklamy pełnoekranowe
(interstitial) są nierozstrzygnięte; jeśli będą, to tylko poza rundą i nie
częściej niż co kilka minut. Decyzja przy M6.

## Kierunek graficzny

**Decyzja: jasny, „cukierkowy” cartoon.**
- Nasycone kolory, grube kontury, miękkie cienie i lekki efekt 3D.
- Grube, zaokrąglone fonty.
- Postacie (dziadek, babcia, kukułka…) z charakterem.

**Dlaczego ten, a nie ciemny neon:**
- Najlepiej zarabiające gry idle (Idle Miner, AdVenture Capitalist, Egg, Inc.
  i podobne) mają właśnie taki styl.
- Jasne zrzuty ekranu lepiej wyglądają w sklepie Google Play.
- Humor gry opiera się na postaciach, a kreskówka niesie postacie, a neon nie.

Neon i poświaty zostają jako **efekty specjalnych stanów**: Szał, bullet
time, Złota Sekunda. Kontrast „jasna gra → świecący moment” dodatkowo je
podkreśla.

Jak dzielimy grafikę:
- **Kodem** (Flutter/Flame): zegar, tarcza, cyfry, tła z gradientów, przyciski,
  panele, wszystkie cząsteczki i efekty. Nie ma do tego plików graficznych,
  a całość skaluje się do każdego ekranu.
- **Grafika generowana AI** (jeden szablon stylu, patrz 04): portrety 14
  generatorów, ikony 11 umiejętności, ikony ulepszeń, odznaki osiągnięć,
  ikona aplikacji, grafiki do sklepu.
- **Darmowe zasoby:** czcionki z Google Fonts (licencja OFL), dźwięki z
  Kenney.nl (CC0) albo generowane (jsfxr). Każdy zasób z zewnątrz trafia z licencją
  do pliku `CREDITS.md` (powstaje w M0).

## Zasady przewodnie dla implementacji

- **Gra działa bez sieci.** Uprawnienie do internetu dochodzi dopiero
  z reklamami.
- **Wszystkie liczby balansu są w jednym pliku danych** (patrz 05). Gra
  i symulator czytają ten sam plik. Żadnych liczb wpisanych na sztywno w kodzie
  ekranów.
- **Logika gry to czysty Dart, bez Fluttera.** Da się ją testować
  i symulować bez telefonu.
- Pomiar czasu dotknięcia ma pierwszeństwo przed wszystkim innym. Niesprawiedliwy
  pomiar zabija tę grę (patrz 05).
