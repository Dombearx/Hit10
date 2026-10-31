# 10 — Grafiki AI przez RunPod Public Endpoints

Brief na 31.10.2026. Uzupełnia `09-grafika-ai.md`: zamiast stawiać własny
ComfyUI na 3060 Ti, generujemy przez **gotowe publiczne endpointy RunPod**
(płatność za obraz, bez zarządzania GPU). Plik jest napisany tak, żeby
sesja Claude'a na komputerze z kluczem API mogła od razu ruszyć.

## Stan (31.10.2026)

Pipeline działa, zegary (14) podmienione w `playtest18`:

```
python3 tools/art/generate.py [--only id,id] [--model qwen|zimage|qwen-edit]   # → tools/art/out/<model>/
python3 tools/art/sheet.py qwen /tmp/cand.png        # arkusz kandydatów do wyboru seeda
# wpisać wybrane do tools/art/picks.json
tools/art/.venv/bin/python tools/art/process.py [id] # wycięcie tła + 160 px → app/assets/art/
```

- Endpointy: `qwen-image-t2i`, `qwen-image-edit-2511` (referencje tylko jako
  URL — bierzemy raw.githubusercontent z publicznego repo), `z-image-turbo`.
  Wynik: `output.result` (URL, ważny 7 dni), `output.cost`.
- **Test modeli:** Qwen t2i najlepiej trzyma się promptu; Qwen Edit z
  ikonami Fluent jako referencją kopiuje ich kształty (atomowy wyszedł jako
  stoper); Z-Image Turbo przyzwoity i 4× tańszy, ale blady i z małym
  obiektem. Finały: **Qwen t2i**, 2 seedy na ikonę, wybór ręczny.
- Wycinanie: `rembg` z `birefnet-general-lite` (pełny BiRefNet nie mieści się
  w 7 GB RAM na CPU). Venv: `python3 -m venv tools/art/.venv &&
  tools/art/.venv/bin/pip install "rembg[cpu]" pillow`.
- `generatorArt` używa nazw `art/<id>` (`EmojiArt.file` rozróżnia
  `art/…` i emoji Fluent). Bez ikonek w rogu — nowe grafiki same pokazują
  zegar.
- Koszt zegarów razem z testem: ~$0.75.

## Cel

Zastąpić gotowe ikony Fluent Emoji (Microsoft, MIT) własnymi, spójnymi
grafikami w stylu gry. Warunki z docs/09 dalej obowiązują:

- **Licencja modelu musi pozwalać na użycie komercyjne** (Sklep Play +
  reklamy).
- **Spójność stylu** ważniejsza niż efektowność pojedynczej ikony.
- **Każda grafika jest odtwarzalna**: zapisujemy model, prompt, seed,
  referencje.

## Klucz API i bezpieczeństwo

- Klucz w zmiennej środowiskowej **`RUNPOD_API_KEY`**. Nigdy nie wpisywać go
  do plików w repo, logów ani commitów.
- RunPod działa na przedpłaconych kredytach — przed startem sprawdzić saldo.
- Nieudane generacje nie są naliczane.

## Modele (ceny z dokumentacji/cennika RunPod, zweryfikować w konsoli)

| Model | Cena | Licencja | Do czego |
|---|---|---|---|
| **Qwen-Image Edit (2511)** | $0.02 / obraz | Apache 2.0 | **Główny.** Przyjmuje obrazy referencyjne → nowe ikony w stylu istniejących |
| **Qwen-Image** | $0.02 / obraz | Apache 2.0 | Tekst → obraz, gdy nie potrzeba referencji |
| **Z-Image Turbo** | ~$0.005 / obraz | Apache 2.0 | Tanie szkice i dużo wariantów; porównanie stylu z Qwen |
| Qwen-Image (Edit) LoRA | $0.025 / obraz | Apache 2.0 | Później, jeśli wytrenujemy własny styl |
| FLUX.1 [schnell] | $0.0024 / MP | Apache 2.0 | Awaryjnie; słabsza jakość |

**Nie używamy:** FLUX.1 [dev] i FLUX.1 Kontext [dev] (licencja
niekomercyjna — patrz docs/09), Seedream i Nano Banana (modele zamknięte,
droższe; warunki użycia wymagałyby osobnej analizy).

Przed pierwszym wywołaniem **sprawdzić w dokumentacji RunPod**
(<https://docs.runpod.io/public-endpoints/reference>) dokładne ID
endpointów i schemat `input` każdego modelu (nazwy pól na prompt, obrazy
referencyjne, rozmiar, seed) — w tym briefie ich nie zgadujemy.

## Jak wywoływać

Ogólny wzór publicznych endpointów RunPod:

```
POST https://api.runpod.ai/v2/<endpoint-id>/runsync
Authorization: Bearer $RUNPOD_API_KEY
Content-Type: application/json

{"input": { ...pola zgodne z dokumentacją modelu... }}
```

Dla dłuższych zadań: `/run` + odpytywanie `/status/<job-id>`.

Skrypt i konfiguracja w repo (do napisania): **`tools/art/`**

- `tools/art/generate.py` — czyta klucz z `RUNPOD_API_KEY`, wysyła prompt
  (+ referencje jako base64/URL, zależnie od modelu), zapisuje wynik.
- `tools/art/prompts.json` — dla każdej ikony: id, prompt, seed, model,
  referencje. To jest „źródło” grafik, commitujemy je.
- Surowe wyniki i warianty do `tools/art/out/` (**w `.gitignore`**); do
  `app/assets/` trafiają tylko zaakceptowane, przeskalowane pliki.

## Styl

Stały początek każdego promptu (dopasowany do obecnych ikon Fluent 3D):

> glossy 3D cartoon icon, soft studio lighting, rounded shapes, pastel
> palette, subtle outline-free shading, centered, single object, plain
> flat light-grey background, no text

- **Referencje:** 2–4 obecne ikony z `app/assets/emoji/` przy każdej
  generacji w Qwen-Image Edit (np. `stopwatch`, `mantelpiece_clock`,
  `trophy`, `gem_stone`). Po zaakceptowaniu pierwszych własnych ikon —
  używać już ich jako referencji.
- **Stałe seedy** w obrębie serii.
- Jeśli styl się rozjeżdża po pierwszej serii → LoRA (Qwen-Image LoRA na
  RunPod albo trening lokalny, patrz docs/09).

## Tło i format

- Endpointy zwracają obraz **z tłem** — generujemy na jednolitym jasnym
  tle i wycinamy lokalnie **BiRefNet** (MIT; działa też na CPU).
  **Nie używać RMBG-2.0** (CC BY-NC).
- Wynik: PNG RGBA, **160×160** (jak obecne `app/assets/emoji/*.png`),
  plus 512×512 do sklepu/powiadomień. Obiekt wyśrodkowany, z marginesem.
- Ikony są wyświetlane na kolorowym tle karty (`EmojiArt.background` w
  `app/lib/ui/catalog.dart`), czasem z małą ikoną w rogu (`corner`) —
  muszą być czytelne w małym rozmiarze.

## Gdzie to się podpina w kodzie

- `app/lib/ui/catalog.dart`: `generatorArt` (14 zegarów), `skillArt`
  (11 umiejętności), `perkArt` (16 perków) — mapują id na nazwę pliku w
  `app/assets/emoji/`.
- `app/lib/ui/achievement_text.dart`, `app/lib/ui/seasons_ui.dart`,
  `app/lib/ui/season_dialog.dart` — odznaki osiągnięć i sezonów.
- Nowe grafiki najlepiej w osobnym katalogu (np. `app/assets/art/`), a w
  `catalog.dart` podmieniać całe grupy naraz (wszystkie zegary, potem
  wszystkie umiejętności) — mieszanie stylów w jednej grupie wygląda źle.
- Po podmianie: zaktualizować **`CREDITS.md`** (sekcja Art: grafiki
  wygenerowane dla projektu, model + licencja) i usunąć nieużywane emoji
  Fluent (licencję MIT zostawić, dopóki jakiekolwiek zostają).
- Sprawdzić: `make check`, a wizualnie `make web-qa` i obejrzeć ekrany.

## Kolejność prac

1. **Test (< $1):** 3–4 zegary (np. `grandpa`, `cuckoo`, `quartz`,
   `atomic`) na Qwen-Image Edit z referencjami i te same prompty na
   Z-Image Turbo. Porównać obok obecnych ikon w 160 px → wybrać model.
2. **Zegary:** wszystkie 14 z `generatorArt`.
3. **Umiejętności:** 11 z `skillArt`, potem perki.
4. **Skórki tarczy na eventy** (Halloween, Boże Narodzenie, Sylwester…).
5. **Grafika do sklepu** 1024×500 i ewentualnie ikona aplikacji.

## Kontrola jakości (każda grafika przed użyciem)

- Obejrzeć obok istniejących ikon w docelowym rozmiarze (160 px, na
  kolorowym tle karty).
- Sylwetka czytelna w małym rozmiarze, paleta i światło zgodne z resztą.
- Brak tekstu, liter, artefaktów, ucięć; czyste krawędzie po wycięciu.
- Odrzucone → poprawić prompt/seed i wygenerować ponownie.

## Budżet

Szacunek: 25 ikon (zegary + umiejętności) × ~10 wariantów × 2–3 rundy
≈ 500–750 generacji:

- tylko Qwen-Image Edit: **~$10–15**,
- szkice na Z-Image Turbo + finały na Qwen Edit: **~$5**,
- wymiana wszystkich ~60 obecnych emoji: **~$20–40**.

Jeśli wydatki przekroczą ~$50, zatrzymać się i zapytać.

## Źródła

- [Runpod Public Endpoints — przegląd](https://docs.runpod.io/public-endpoints/overview)
- [Runpod — dostępne modele i ceny](https://docs.runpod.io/public-endpoints/reference)
- [Flux Schnell](https://docs.runpod.io/public-endpoints/models/flux-schnell)
- [Cennik Runpod](https://www.runpod.io/pricing)
