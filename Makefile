# Run from the repo root. Requires Flutter on PATH (docs/05-technika.md T-24).
APP := app

.PHONY: check analyze format test web web-qa apk

## Everything CI runs before building: analyze, format, tests.
check: analyze format test

analyze:
	cd $(APP) && flutter analyze

format:
	cd $(APP) && dart format --output=none --set-exit-if-changed lib test

test:
	cd $(APP) && flutter test

## Web build used for local QA in a browser.
web-qa:
	cd $(APP) && flutter build web --release --no-web-resources-cdn --dart-define=QA=true -o build/web-qa

web:
	cd $(APP) && flutter build web --release --no-web-resources-cdn

## Release-mode APK signed with the debug key, for installing on a phone.
apk:
	cd $(APP) && flutter build apk --release
