# 09 — Generowanie grafik AI (ikony, skórki)

Research z 29.10.2026. **Aktualny plan generowania przez RunPod: `10-grafika-runpod.md`.** Cel: lokalny model na **RTX 3060 Ti (8 GB VRAM)**,
wystawiony przez API, którym Claude generuje ikony, skórki tarczy i grafiki
eventów, a potem sam je ogląda i odrzuca niespójne. Warunek: licencja
pozwala na komercyjne użycie (gra idzie do Sklepu Play z reklamami).

## Rekomendacja

**Główny model: FLUX.2 [klein] 4B** (Black Forest Labs, styczeń 2026).

- **Licencja Apache 2.0** dla wersji 4B (uwaga: wersja **9B** jest
  *niekomercyjna* — jej nie używamy).
- Jeden model robi **tekst → obraz** i **edycję z obrazami referencyjnymi**
  (kilka obrazów na wejściu). To klucz do spójności: dajemy mu nasze
  obecne ikony jako wzór stylu i prosimy o nową w tym samym stylu.
- Na 8 GB: wersja **GGUF Q4_K_M/Q5** (ok. 2,6 GB modelu, ok. 5 GB razem z
  enkoderem tekstu) albo **FP8** z odciążaniem na RAM. Źródła podają od
  ~8 do ~13 GB dla pełnej precyzji — na 3060 Ti trzymamy się GGUF/FP8.
- Szybki (kilka kroków), więc można generować dziesiątki wariantów i
  wybierać najlepsze.

**Zapasowy / do porównania: Z-Image Turbo** (Alibaba Tongyi, 6B, Apache 2.0).
Bardzo dobra jakość w 8 krokach; na 8 GB tylko jako GGUF (~6 GB) albo FP8
na styk. Warto puścić te same prompty na obu i wybrać styl, który lepiej
pasuje.

**Do treningu własnego stylu (później): SDXL + LoRA.** Najdojrzalszy
ekosystem i trening LoRA mieści się na 8 GB. Przyda się, jeśli
referencje w FLUX.2 [klein] nie utrzymają spójności przy dużej liczbie
ikon (np. kolekcja tarcz).

**Odrzucone:**

| Model | Dlaczego nie |
|---|---|
| FLUX.2 [klein] 9B, FLUX.1 [dev] | licencja niekomercyjna |
| Qwen-Image (20B) | świetny tekst w obrazie, ale ~24 GB; GGUF na 8 GB niepewny |
| Stable Diffusion 3.5 Large | działa jako GGUF, ale licencja ma próg przychodu i gorsza zgodność z promptem niż FLUX.2 |
| RMBG-2.0 (usuwanie tła) | CC BY-NC — niekomercyjna |

**Przezroczyste tło: BiRefNet** (licencja MIT, gotowy węzeł w ComfyUI).
Generujemy na jednolitym tle, BiRefNet wycina, my skalujemy do 160 px
(jak obecne ikony) i 512 px (sklep, powiadomienia).

## Jak to wystawić

1. **ComfyUI** na komputerze z 3060 Ti, uruchomiony z `--listen` i (jeśli
   trzeba) `--lowvram`. Modele: FLUX.2 [klein] 4B (GGUF przez węzły
   ComfyUI-GGUF), jego enkoder tekstu, VAE, BiRefNet.
2. API ComfyUI: `POST /prompt` (workflow w JSON), `GET /history/{id}`,
   `GET /view?filename=…`. Workflowy trzymamy w repo (`tools/art/*.json`),
   więc każdą grafikę da się odtworzyć (model, seed, prompt).
3. Dostęp z mojej sesji: tunel (np. Cloudflare Tunnel albo Tailscale
   Funnel) z tokenem — ComfyUI nie ma własnej autoryzacji, więc nie
   wystawiać go gołego do internetu. Adres tunelu trzeba będzie dodać do
   listy dozwolonych hostów w ustawieniach sieci tego środowiska.

## Jak pilnujemy spójności

- **Jeden opis stylu** jako stały początek każdego promptu, dopasowany do
  obecnych ikon (Fluent Emoji 3D): „glossy 3D cartoon icon, soft studio
  lighting, rounded shapes, pastel palette, subtle outline-free shading,
  centered, plain light background”.
- **Referencje:** 2–4 obecne ikony jako obrazy wejściowe przy każdej nowej.
- **Stałe seedy** dla serii (np. wszystkie skórki tarczy z jednego seeda,
  różne motywy).
- **Moja kontrola** każdej grafiki przed użyciem: obejrzę ją obok
  istniejących ikon w docelowym rozmiarze (160 px i na tarczy) i sprawdzę
  sylwetkę czytelną w małym rozmiarze, paletę i oświetlenie zgodne z
  resztą, brak tekstu i artefaktów, czyste krawędzie po wycięciu tła.
  Odrzucone generuję ponownie z poprawionym promptem.
- Jeśli po pierwszej serii styl się rozjeżdża — trenujemy LoRA na
  zaakceptowanych ikonach (SDXL albo FLUX.2 [klein] Base 4B).

## Co generujemy najpierw

1. Ikony 14 zegarów i 11 umiejętności we wspólnym stylu (zamiast emoji).
2. Skórki tarczy na eventy (Halloween, Boże Narodzenie, Sylwester…) —
   nagrody z wydarzeń.
3. Grafika promocyjna do sklepu (1024×500) i ikona aplikacji.

Obecne ikony to Fluent Emoji (MIT) — można je dalej mieszać, ale spójniej
będzie podmienić całe grupy naraz (np. wszystkie zegary).

## Źródła

- [FLUX.2 [klein] — blog Black Forest Labs](https://bfl.ai/blog/flux2-klein-towards-interactive-visual-intelligence)
- [FLUX.2 [klein] 4B — karta modelu (kopia)](https://huggingface.co/bi1o/FLUX.2-klein-4B)
- [FLUX.2 [klein] 9B GGUF (Unsloth)](https://huggingface.co/unsloth/FLUX.2-klein-9B-GGUF)
- [Flux.2 Klein 4B/9B: GGUF/FP8/BF16](https://www.stablediffusiontutorials.com/2026/01/flux2-klein.html)
- [Local Image Generation 2026: Ultra-Low VRAM Models](https://local-ai-zone.github.io/blog/local-image-generation-2026.html)
- [Best Local AI Image Models 2026: FLUX vs SDXL vs Qwen](https://localaimaster.com/blog/best-local-image-models-compared)
- [Local image models in 2026: Qwen vs FLUX vs SDXL on VRAM](https://botmonster.com/ai/best-local-image-generation-models-2026/)
- [Qwen-Image vs FLUX.2](https://simplismart.ai/comparisons/qwen-image-vs-flux-2-which-open-weight-image-model-should-you-deploy)
- [Z-Image Turbo VRAM Requirements](https://willitrunai.com/image-models/z-image-turbo)
- [Z-Image Turbo w ComfyUI: instalacja i VRAM](https://www.thundercompute.com/blog/z-image-turbo-comfyui)
- [Z-Image-Turbo vs FLUX.2 Klein na 16 GB](https://runaihome.com/blog/z-image-turbo-16gb-vram-home-lab-image-gen-2026/)
- [Best Open-Source Image Generation Models](https://www.thundercompute.com/blog/best-open-source-image-generation-models)
- [Benchmark 5 generatorów na laptopie (DEV)](https://dev.to/lucylll/i-benchmarked-5-open-source-ai-image-generators-on-my-laptop-heres-what-actually-works-in-2026-35m4)
- [ComfyUI: usuwanie tła BiRefNet (MIT)](https://docs.comfy.org/tutorials/utility/remove-background-birefnet)
- [RMBG-2.0 — karta modelu (CC BY-NC)](https://huggingface.co/camenduru/rmbg-2.0)
- [ComfyUI for Game Asset Pipelines (2026)](https://www.strayspark.studio/blog/comfyui-game-asset-pipeline-indie-2026)
- [AI Asset Pipeline 2026: SD + ComfyUI](https://altheragames.com/en/blog/ai-asset-pipeline-stable-diffusion-ue5)
- [Game assets z przezroczystym tłem (LayerDiffuse)](https://www.apatero.com/blog/generate-game-assets-consistency-transparent-backgrounds-2025)
