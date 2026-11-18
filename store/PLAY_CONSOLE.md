# Release checklist — what only you can do (docs/07 M6)

Everything in the repo is ready: real rewarded ads with UMP consent (test
ids until you add yours), release signing, a CI-built AAB, the listing texts
(`listing.md`), icon, feature graphic, screenshots and the website files
(`../site/`). These steps need your accounts. Do them in this order.

## 1. Upload key (once, keep it forever)

On your computer (Java's `keytool`, comes with Android Studio):

```sh
keytool -genkeypair -v -keystore hit5-upload.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Keep `hit5-upload.jks` and both passwords somewhere safe (password
manager + a backup copy). Never commit it. Play App Signing (default for
new apps) keeps the real app key at Google; this is only the *upload* key,
which Google can reset if lost — but it takes days.

For local builds, create `app/android/key.properties` (gitignored):

```
storeFile=/full/path/to/hit5-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

## 2. AdMob

1. AdMob → Apps → Add app → Android, "not published yet", name Hit5.
2. Copy the **App ID** (`ca-app-pub-…~…`).
3. Ad units → Add → **Rewarded** → name "Hit5 rewarded". Copy the
   **ad unit ID** (`ca-app-pub-…/…`).
4. Privacy & messaging → **GDPR** → create a message for Hit5 (this is
   the UMP consent form the game already shows). Publish it.
5. Settings → Account information → copy the **Publisher ID**
   (`pub-…`) for `app-ads.txt`.

Never tap your own real ads (account ban risk, docs/05 T-28). The APKs CI
builds for testing always use Google's test ids; only the signed AAB gets
the real ones.

## 2a. Firebase (game statistics, docs/05 §8a)

Free (Spark plan, no card needed).

1. <https://console.firebase.google.com> → Add project "Hit5" → enable
   Google Analytics (create a new Analytics account, location Poland).
2. Project settings → General → Add app → **Android**, package
   `io.github.dombearx.hit10`, nickname Hit5. Skip downloading
   `google-services.json` and skip the SDK steps (the code is done).
3. From the same page copy: **App ID** (`1:…:android:…`), **Web API
   key** (`AIza…`), **Project ID**, **Project number** (= sender ID).
4. Analytics → Admin (Google Analytics) → Data settings → **Data
   retention: 2 months** (the privacy policy says so). Leave **Google
   signals off**.
5. AdMob → Apps → Hit5 → App settings → **Link to Firebase** (shows ad
   revenue next to player behaviour; optional).
6. Privacy & messaging → GDPR message (step 2.4): make sure Google
   Analytics for Firebase is not blocked by the chosen vendor list. In the
   EEA/UK the game also asks its own question about statistics and crash
   reports after the tutorial and holds them on the phone until then
   (docs/05 T-33).
7. **Crashlytics** (crash reports, docs/05 T-30): Firebase console →
   Crashlytics → *Enable*. Nothing else: the game sends Dart errors only,
   so the Crashlytics Gradle plugin is not needed (the app tells the SDK
   so in `res/values/crashlytics.xml`). The first report shows up after
   the first error on a phone whose player said yes.

## 2b. Play Games Services (cloud save, docs/05 T-35)

Free. Needed only for the cloud save; without it the game simply has no
"Cloud save" row.

Done 18.11.2026 (steps 1–6); the console no longer matches the older
description, so this is what it took:

1. Play Console → Hit5 → **Grow users → Play Games Services → Setup and
   management → Configuration** → *Create a new Play Games Services
   project* → Cloud project **hit5-8d33e** (the Firebase project; Spark
   plan, no billing) → Use.
2. **OAuth consent screen** (Google Cloud → Google Auth Platform → Get
   started): app name Hit5, support and contact e-mail = the account,
   audience External. It stays in *Testing*; if testers cannot sign in,
   Audience → *Publish app* (the games scope needs no verification).
3. Google Cloud → Google Auth Platform → **Clients → Create client →
   Android**, package `io.github.dombearx.hit10`, twice: with the SHA-1 of
   the **app signing key** and of the **upload key** (Play Console → App
   integrity → App signing, copy buttons only; the upload key one also
   via `keytool -printcert -jarfile <signed>.aab`). Then Play Console
   **Credentials → Add credential → Android** for each, anti-piracy off:
   "Hit5 Android (Play signing)" and "Hit5 Android (upload key)".
4. **Properties → Saved Games: On** (cannot be turned off once published).
5. **Testers → Release tracks → Add tracks → Testerzy**: the closed-test
   testers can sign in while the configuration is a draft.
6. **Project ID** 895817652558 → secret `PLAY_GAMES_APP_ID` (step 3).
   Only the Play upload (`aab` job) gets it; the test APK from CI has no
   cloud save, so test M-12 on the closed-test build.
7. When the closed test is happy (M-12): **Review and publish** the Play
   Games configuration (separate from the app release) and update Data
   safety (App activity → Other actions; sign-in with outside accounts:
   Yes).

## 3. GitHub secrets (Hit5 repo → Settings → Secrets and variables → Actions)

| Secret | Value |
|---|---|
| `HIT10_KEYSTORE_B64` | `base64 -w0 hit5-upload.jks` (macOS: `base64 -i hit5-upload.jks`) |
| `HIT10_KEYSTORE_PASSWORD` | store password |
| `HIT10_KEY_ALIAS` | `upload` |
| `HIT10_KEY_PASSWORD` | key password |
| `ADMOB_APP_ID` | App ID from step 2 |
| `ADMOB_REWARDED_ID` | rewarded ad unit ID from step 2 |
| `FIREBASE_APP_ID` | App ID from step 2a |
| `FIREBASE_API_KEY` | Web API key from step 2a |
| `FIREBASE_PROJECT_ID` | Project ID from step 2a |
| `FIREBASE_SENDER_ID` | Project number from step 2a |
| `PLAY_GAMES_APP_ID` | Play Games Project ID from step 2b (optional: no cloud save without it) |

After the next push, the CI run's **hit5-aab** artifact contains
`…-signed.aab`. (Without the secrets it is `…-unsigned.aab`, test ids,
not uploadable.)

## 3a. Automatic upload to the testers (after the first manual upload)

Every merge to `main` uploads the signed AAB to the closed test, once the
smoke test passed (CI job `play`). To upload without a merge, run it by
hand: GitHub → Actions → CI → **Run workflow** → branch `main` (other
branches build and test but skip the upload). It needs a service account
once:

1. Google Cloud Console → the project linked to Play Console (or a new
   one) → APIs & Services → enable **Google Play Android Developer API**.
2. IAM & Admin → Service accounts → **Create service account** (no roles
   needed) → Keys → Add key → JSON → download.
3. Play Console → **Users and permissions** → Invite new users → the
   service account's email → App permissions: Hit5 → **Release to testing
   tracks** (and *View app information*) → Invite.
4. GitHub secret **`PLAY_SERVICE_ACCOUNT_JSON`** = the whole JSON file.
   Delete the downloaded file afterwards.
5. The job uploads to the track **`Testerzy`**. If the closed test track
   is named differently (the default one is `alpha` in the API), set the
   repo **variable** `PLAY_TRACK` (Settings → Secrets and variables →
   Actions → Variables).

Once Google approves a release, the game offers it itself at the next
start (Google Play in-app update, flexible: Play's dialog, download in the
background, then a "Restart" snackbar), so testers need not wait for the
Play Store's own auto-update. It works only for installs from Google Play
and from the first version that has it (1.0.0 build after 183).

The versionCode is the CI run number: an AAB uploaded by hand with a
higher versionCode blocks the next uploads until the run number passes it.

## 4. Website (dombearx.github.io)

1. Create the public repo **`Dombearx/Dombearx.github.io`**.
2. Copy everything from `site/` into it.
3. Replace `pub-0000000000000000` in `app-ads.txt` with your Publisher ID
   and `CONTACT_EMAIL` in `hit5/privacy.html` with your contact address.
4. Settings → Pages → Deploy from branch `main`, `/ (root)`.
5. Check: `https://dombearx.github.io/hit5/privacy.html` and
   `https://dombearx.github.io/app-ads.txt` open.
6. In Play Console (step 5) set the **website** to
   `https://dombearx.github.io/hit5/` — AdMob finds `app-ads.txt` through it.

## 5. Play Console

1. Create app: name "Hit5", default language **Polish**, Game, Free.
2. **Store listing** (Main store listing + add translation English):
   texts from `listing.md`; graphics from this folder:
   icon `icon-512.png`, feature graphic `feature-pl.png` (PL) /
   `feature-en.png` (EN), phone screenshots `screens/pl/1–7.png` (PL) and
   `screens/en/1–7.png` (EN), in that order (the first three show in
   search results). Tablet screenshots (same order): **7-inch** from
   `screens-tablet7/pl|en/1–7.png`, **10-inch** from
   `screens-tablet10/pl|en/1–7.png` — they let Play show and recommend
   the game on tablets and Chromebooks.
   Category: **Casual** (or Arcade). Contact email + website (step 4).
3. **App content**:
   - Privacy policy URL: `https://dombearx.github.io/hit5/privacy.html`
   - Ads: **Yes, contains ads**.
   - App access: all functionality available without special access.
   - Target audience: **13–15, 16–17, 18+** (not under 13 — the privacy
     policy says so and the ads are not configured for children).
   - Content rating questionnaire (IARC): category *Game*; no violence,
     no sexual content, no profanity, no gambling (no real money, no
     loot boxes bought with money), no user interaction or sharing, no
     location. Expect PEGI 3 / ESRB Everyone.
   - **Data safety** (from the code, docs/05 T-26, T-30, T-35):
     - Does the app collect or share user data? **Yes** — via the
       AdMob SDK, Firebase Analytics and Crashlytics, and Play Games
       Services (docs/05 §8a).
     - Data types: **Device or other IDs** (advertising ID via AdMob;
       Firebase app instance ID) — collected and shared, purpose
       *Advertising or marketing*, *Analytics*, not optional for ads.
       **App activity → App interactions** (Firebase game events, AdMob)
       — collected, purpose *Analytics*, **optional** (the statistics
       question / setting "Send game statistics"). **App info and
       performance → Crash logs** and **Diagnostics** (Crashlytics) —
       collected, purpose *Analytics*, **optional** (same choice). **App
       activity → Other actions** (the saved game in Play Games, only when
       the player signs in) — collected, purpose *App functionality*,
       **optional**. Follow Google's guides "Prepare your app for the Data
       safety form" for the Mobile Ads SDK, Firebase and Play Games
       Services.
     - Data is encrypted in transit: **Yes** (HTTPS).
     - Users can request deletion: no account exists; statistics are tied
       to a random install ID only and expire after 2 months; game data is
       deleted by uninstalling.
     - Game progress stays on the device (Android backup is the user's
       own Google account); the cloud copy lives in the player's own Play
       Games account (the "Other actions" entry above).
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
