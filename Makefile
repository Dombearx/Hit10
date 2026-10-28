# Run from the repo root. Requires Flutter on PATH (docs/05-technika.md T-24).
APP := app

.PHONY: check analyze format test sim web web-qa apk aab store icon

## Everything CI runs before building: analyze, format, tests.
check: analyze format test

analyze:
	cd $(APP) && flutter analyze

format:
	cd $(APP) && dart format --output=none --set-exit-if-changed lib test tool

test:
	cd $(APP) && flutter test

## Pacing targets B-1…B-10, A-1, A-2 on the real economy code (~30 s).
sim:
	cd $(APP) && dart run tool/simulate.dart --check

## Web build used for local QA in a browser.
web-qa:
	cd $(APP) && flutter build web --release --no-web-resources-cdn --dart-define=QA=true -o build/web-qa

web:
	cd $(APP) && flutter build web --release --no-web-resources-cdn

## Release-mode APK signed with the debug key, for installing on a phone.
apk:
	cd $(APP) && flutter build apk --release

# Play upload bundle (docs/05 §9); signed when android/key.properties exists.
aab:
	cd $(APP) && flutter build appbundle --release

# Store graphics from the QA build (docs/04 U-28); serves it on :8713.
store: web-qa icon
	cd $(APP)/build/web-qa && (python3 -m http.server 8713 >/dev/null 2>&1 & echo $$! > /tmp/hit10-store.pid)
	sleep 1; node tools/store/render.js; kill $$(cat /tmp/hit10-store.pid)

# Launcher and store icons from tools/icon/icon.svg (docs/04 U-26).
icon:
	node tools/icon/render.js
