# Edytor tekstów PL

Strona w przeglądarce z makietą każdego ekranu i okienka gry oraz
wszystkimi polskimi tekstami (`app/lib/l10n/app_pl.arb`) do edycji.
Kliknięcie tekstu na makiecie otwiera jego pole po prawej; makieta zmienia
się na bieżąco. „Zapisz do kodu” (Ctrl+S) zapisuje zmienione teksty do
`app_pl.arb`. Pliki w `lib/l10n/gen/` odświeży każde polecenie Fluttera
(w CI robi to `flutter pub get`).

Potrzebny jest tylko Python 3 (bez dodatkowych paczek).

## Uruchomienie

Lokalnie (Windows): dwuklik `start.cmd` albo

```
py -3 tools/teksty/serwer.py
```

Strona otwiera się sama pod <http://localhost:8765>.

Na serwerze (słucha w sieci, więc hasło jest wymagane; nazwa użytkownika
dowolna):

```
TEKSTY_HOST=0.0.0.0 TEKSTY_PORT=8765 TEKSTY_PASSWORD='…' python3 tools/teksty/serwer.py
```

Hasło idzie zwykłym HTTP Basic, więc wystawiony na zewnątrz serwer najlepiej
schować za reverse proxy z HTTPS (proxy musi przekazać nagłówek `Host`).

## Co i gdzie się zapisuje

- `app/lib/l10n/app_pl.arb`: zmienione teksty (tylko te linie). Commit
  i PR robisz sam z tej kopii repo.
- `tools/teksty/kopie/`: kopia `app_pl.arb` sprzed pierwszego zapisu
  w każdym uruchomieniu serwera (poza gitem).
- `tools/teksty/sprawdzone.json`: które teksty oznaczono jako sprawdzone
  (poza gitem).

Serwer odrzuca tekst, w którym brakuje zmiennej (`{count}`, `{name}`…)
albo pojawiła się nieznana, oraz tekst zmieniony w pliku przez kogoś innego
od otwarcia strony.

## Pliki

- `serwer.py`: serwer HTTP i zapis do `app_pl.arb`.
- `core.js`: renderowanie tekstów (ICU, liczba mnoga), panel edycji,
  wyszukiwarka, „sprawdzone”.
- `ekrany.js`: definicje makiet. Nowy klucz w `app_pl.arb` bez makiety
  trafia sam do „Pozostałe teksty”; żeby miał własne miejsce, dopisz go
  w odpowiednim `screen(...)`.
- `style.css`, `index.html`.
