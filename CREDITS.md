# Credits and licences

Every third-party asset shipped in the game is listed here (docs/01-wizja.md).

## Fonts

| Asset | Author | Licence | Source |
|---|---|---|---|
| Paytone One | Vernon Adams | SIL Open Font License 1.1 (`app/assets/fonts/OFL-PaytoneOne.txt`) | [Google Fonts](https://fonts.google.com/specimen/Paytone+One) |
| Nunito | Vernon Adams, Cyreal, Jacques Le Bailly | SIL Open Font License 1.1 (`app/assets/fonts/OFL-Nunito.txt`) | [Google Fonts](https://fonts.google.com/specimen/Nunito) |

Both are subset to Latin and Latin Extended (Polish included) with
`pyftsubset`; the OFL allows this.

## Art

| Asset | Author | Licence | Source |
|---|---|---|---|
| Clock (generator) art, `app/assets/art/` | generated for this project with Qwen-Image (Alibaba Qwen team) via RunPod Public Endpoints; background removed with BiRefNet | Qwen-Image: Apache 2.0; BiRefNet: MIT | prompts and seeds in `tools/art/prompts.json`, picks in `tools/art/picks.json` |
| Fluent Emoji (3D style), `app/assets/emoji/` | Microsoft | MIT (`app/assets/emoji/LICENSE-fluentui-emoji.txt`) | [microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji) |

## Sounds and music

All sound effects and the three music loops in `app/assets/audio/` are
synthesised for this project by `tools/sfx/generate.py` and
`tools/sfx/music.py`; no third-party audio is used.
