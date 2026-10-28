# Release checklist — what only you can do (docs/07 M6)

Everything in the repo is ready: real rewarded ads with UMP consent (test
ids until you add yours), release signing, a CI-built AAB, the listing texts
(`listing.md`), icon, feature graphic, screenshots and the website files
(`../site/`). These steps need your accounts. Do them in this order.

## 1. Upload key (once, keep it forever)

On your computer (Java's `keytool`, comes with Android Studio):

```sh
keytool -genkeypair -v -keystore hit10-upload.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Keep `hit10-upload.jks` and both passwords somewhere safe (password
manager + a backup copy). Never commit it. Play App Signing (default for
new apps) keeps the real app key at Google; this is only the *upload* key,
which Google can reset if lost — but it takes days.

For local builds, create `app/android/key.properties` (gitignored):

```
storeFile=/full/path/to/hit10-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

## 2. AdMob

1. AdMob → Apps → Add app → Android, "not published yet", name Hit10.
2. Copy the **App ID** (`ca-app-pub-…~…`).
3. Ad units → Add → **Rewarded** → name "Hit10 rewarded". Copy the
   **ad unit ID** (`ca-app-pub-…/…`).
4. Privacy & messaging → **GDPR** → create a message for Hit10 (this is
   the UMP consent form the game already shows). Publish it.
5. Settings → Account information → copy the **Publisher ID**
   (`pub-…`) for `app-ads.txt`.

Never tap your own real ads (account ban risk, docs/05 T-28). The APKs CI
builds for testing always use Google's test ids; only the signed AAB gets
the real ones.

## 3. GitHub secrets (Hit10 repo → Settings → Secrets and variables → Actions)

| Secret | Value |
|---|---|
| `HIT10_KEYSTORE_B64` | `base64 -w0 hit10-upload.jks` (macOS: `base64 -i hit10-upload.jks`) |
| `HIT10_KEYSTORE_PASSWORD` | store password |
| `HIT10_KEY_ALIAS` | `upload` |
| `HIT10_KEY_PASSWORD` | key password |
| `ADMOB_APP_ID` | App ID from step 2 |
| `ADMOB_REWARDED_ID` | rewarded ad unit ID from step 2 |

After the next push, the CI run's **hit10-aab** artifact contains
`…-signed.aab`. (Without the secrets it is `…-unsigned.aab`, test ids,
not uploadable.)

## 4. Website (dombearx.github.io)

1. Create the public repo **`Dombearx/Dombearx.github.io`**.
2. Copy everything from `site/` into it.
3. Replace `pub-0000000000000000` in `app-ads.txt` with your Publisher ID
   and `CONTACT_EMAIL` in `hit10/privacy.html` with your contact address.
4. Settings → Pages → Deploy from branch `main`, `/ (root)`.
5. Check: `https://dombearx.github.io/hit10/privacy.html` and
   `https://dombearx.github.io/app-ads.txt` open.
6. In Play Console (step 5) set the **website** to
   `https://dombearx.github.io/hit10/` — AdMob finds `app-ads.txt` through it.

## 5. Play Console

1. Create app: name "Hit10", default language **Polish**, Game, Free.
2. **Store listing** (Main store listing + add translation English):
   texts from `listing.md`; graphics from this folder:
   icon `icon-512.png`, feature graphic `feature-1024x500.png`, phone
   screenshots `screens/pl/1–6.png` (PL) and `screens/en/1–6.png` (EN).
   Category: **Casual** (or Arcade). Contact email + website (step 4).
3. **App content**:
   - Privacy policy URL: `https://dombearx.github.io/hit10/privacy.html`
   - Ads: **Yes, contains ads**.
   - App access: all functionality available without special access.
   - Target audience: **13–15, 16–17, 18+** (not under 13 — the privacy
     policy says so and the ads are not configured for children).
   - Content rating questionnaire (IARC): category *Game*; no violence,
     no sexual content, no profanity, no gambling (no real money, no
     loot boxes bought with money), no user interaction or sharing, no
     location. Expect PEGI 3 / ESRB Everyone.
   - **Data safety** (from the code, docs/05 T-26, T-30):
     - Does the app collect or share user data? **Yes** — only via the
       AdMob SDK.
     - Data types: **Device or other IDs** (advertising ID) — collected
       and shared, purpose *Advertising or marketing*, *Analytics*
       (AdMob's ad measurement), not optional. Also **App activity → App
       interactions** and **App info and performance → Diagnostics** as
       AdMob declares them (Google's guide: "Prepare your app for the Data
       safety form" for the Mobile Ads SDK).
     - Data is encrypted in transit: **Yes** (AdMob uses HTTPS).
     - Users can request deletion: the game stores nothing off-device;
       answer that no account exists and data can be deleted by
       uninstalling.
     - Game progress itself stays on the device (Android backup is the
       user's own Google account) — not "collected" in Play's sense.
   - Government app / financial features / health: No.
   - News app: No.
4. **Closed testing** (required for new personal developer accounts):
   - Testing → Closed testing → create track "Testerzy".
   - Upload the signed AAB from step 3.
   - Add **at least 12 testers** (Google accounts, as an email list) and
     share the opt-in link with them.
   - They must stay opted in for **14 consecutive days**. Ask them to play
     and send feedback; fixes go out as new AABs on the same track.
5. After 14 days: Dashboard → **Apply for production access** (answers
   about the test: who tested, what changed). Approval usually takes a
   few days.
6. Production → Create release → the latest AAB → roll out.

## 6. Before each upload

- Bump `version:` in `app/pubspec.yaml` for a new public version name
  (the versionCode is the CI run number, always increasing).
- Run the manual tests from docs/06 (M-1…M-11) on a real phone, including
  **M-10: rewarded ads** with the test build: each offer grants its reward
  only after a full ad; closing early gives nothing; airplane mode greys
  the buttons out.
