# dombearx.github.io

The game's public site (docs/01 "Strona WWW bez domeny", docs/05 T-26):
the privacy policy Play and AdMob require, `app-ads.txt`, and a game page.

GitHub Pages serves a *user site* only from a repository named
`Dombearx/Dombearx.github.io`, and AdMob reads `app-ads.txt` only from the
domain's root. So this folder is the content of that repository:

```
app-ads.txt          → https://dombearx.github.io/app-ads.txt
hit10/index.html     → https://dombearx.github.io/hit10/
hit10/privacy.html   → https://dombearx.github.io/hit10/privacy.html
```

Before publishing, replace the two placeholders:

- `pub-0000000000000000` in `app-ads.txt` — your AdMob publisher id
  (AdMob → Settings → Account information);
- `CONTACT_EMAIL` in `hit10/privacy.html` — the address shown on the
  Play listing.

Then copy the folder into the `Dombearx.github.io` repository and enable
Pages (Settings → Pages → Deploy from branch `main`, folder `/`).
