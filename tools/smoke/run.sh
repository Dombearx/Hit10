#!/usr/bin/env bash
# Device smoke test (CI, on an emulator): install the APK, launch it, play a
# round, and fail if the app dies. Leaves logcat, crash buffer and screenshots
# for the artifact.
set -u
PKG=io.github.dombearx.hit10
APK=$(ls hit5-*.apk | head -1)
out=smoke-out
mkdir -p "$out"

# The package manager comes up a moment after boot_completed: an install
# right away can fail with an empty error ("failed to install: \x02").
# Wait for it and retry a few times; a real install error still fails.
for i in 1 2 3 4 5; do
  if adb shell pm path android >/dev/null 2>&1 && adb install -r "$APK"; then
    break
  fi
  if [ "$i" = 5 ]; then exit 1; fi
  echo "install attempt $i failed, retrying in 5 s"
  sleep 5
done
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
