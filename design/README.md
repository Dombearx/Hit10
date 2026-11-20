# design/ — symulator projektowy

Narzędzie do strojenia balansu na etapie projektu. Gra z niego **nie
korzysta**. W M2 powstaje port w Dart (`app/tool/simulate.dart`), który liczy
na tym samym kodzie co gra. Ten katalog zostaje jako punkt odniesienia do
sprawdzenia portu (docs/06 §1.2).

| Plik | Co robi |
|---|---|
| `balance.json` | liczby z docs/02 i 03 w wersji, która przeszła symulację; punkt startowy dla `app/assets/balance.json` |
| `sim.py` | bot grający 8 h (kupuje to, co najszybciej się zwraca); `--check` sprawdza cele B-1…B-10 z docs/03 §3 |
| `ads_test.py` | gracz biorący każdą ofertę reklamową; cele A-1 i A-2 z docs/03 §5 |
| `combo_sim.py` | propozycje nowego combo (drabinka mnożnika): ile rund gracz spędza na maksimum i ile traci względem dziś, na czterech etapach gry; czyta `app/assets/balance.json` |

```bash
python3 design/sim.py --check        # cele tempa, ~30 s
python3 design/sim.py --sigma 0.06   # pełny raport dla gracza przeciętnego
python3 design/ads_test.py           # wpływ reklam, kilka minut
python3 design/combo_sim.py          # warianty combo, kilka sekund
```

Tylko biblioteka standardowa Pythona 3.
