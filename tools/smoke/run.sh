#!/usr/bin/env bash
# Device smoke test (CI, on an emulator): install the APK, launch it, play a
# round, and fail if the app dies. Leaves logcat, crash buffer and screenshots
# for the artifact.
set -u
PKG=io.github.dombearx.hit10
APK=$(ls hit10-*.apk | head -1)
out=smoke-out
mkdir -p "$out"

adb install -r "$APK" || exit 1
adb logcat -c
adb shell am start -W -n "$PKG/.MainActivity"
sleep 25
adb exec-out screencap -p > "$out/1-start.png"
# Tap the dial twice: start a round, then stop it.
adb shell input tap 540 900
sleep 10
adb shell input tap 540 900
sleep 3
adb exec-out screencap -p > "$out/2-round.png"
adb logcat -d > "$out/logcat.txt"
adb logcat -d -b crash > "$out/crash.txt"

echo "---- crash buffer ----"
cat "$out/crash.txt"
echo "---- fatal lines ----"
grep -E "FATAL|AndroidRuntime|F DEBUG|Fatal signal|flutter.*(Error|Exception)" "$out/logcat.txt" | head -80

if adb shell pidof "$PKG" >/dev/null; then
  echo "SMOKE: app alive"
else
  echo "SMOKE: app is NOT running"
  exit 1
fi
if [ -s "$out/crash.txt" ]; then
  echo "SMOKE: crash buffer not empty"
  exit 1
fi
