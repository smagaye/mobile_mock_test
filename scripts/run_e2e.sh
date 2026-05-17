#!/bin/bash
# ─────────────────────────────────────────────
# scripts/run_e2e.sh
# Lancé par GitHub Actions via android-emulator-runner
# ─────────────────────────────────────────────
set -e

APP_ID="com.example.account_manager"
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
MAESTRO="$HOME/.maestro/bin/maestro"

# ── 1. Fix device offline ──────────────────
echo "════ Fix device offline ════"
adb kill-server
sleep 2
adb start-server
sleep 3
adb devices -l

# ── 2. Attendre que le device soit online ──
echo "════ Attente device online ════"
TIMEOUT=120
ELAPSED=0
while true; do
  STATUS=$(adb devices | grep "emulator" | grep -v "offline" | grep -w "device" || true)
  if [ -n "$STATUS" ]; then
    echo "Device online ✓"
    break
  fi
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "❌ Timeout device offline (${TIMEOUT}s)"
    adb devices
    exit 1
  fi
  echo "  ${ELAPSED}s — en attente..."
  sleep 3
  ELAPSED=$((ELAPSED + 3))
done

# ── 3. Attendre boot complet ───────────────
echo "════ Attente boot complet ════"
TIMEOUT=180
ELAPSED=0
while true; do
  BOOT=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n' || true)
  if [ "$BOOT" = "1" ]; then
    echo "Boot complet ✓"
    break
  fi
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "❌ Timeout boot (${TIMEOUT}s)"
    exit 1
  fi
  echo "  ${ELAPSED}s — boot en cours..."
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

# Attendre la fin des animations de démarrage
ANIM=$(adb shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r\n' || true)
while [ "$ANIM" != "stopped" ]; do
  echo "  Animations en cours..."
  sleep 2
  ANIM=$(adb shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r\n' || true)
done

echo "Animations stoppées ✓"

# ── 4. Désactiver animations ───────────────
# Fix screenshot error -1
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
echo "Animations désactivées ✓"

# GPU renderer init
sleep 10

# ── 5. Installer APK ──────────────────────
echo "════ Installation APK ════"
adb install -r "$APK_PATH"
echo "APK installé ✓"

# Lancer l'app
adb shell monkey -p "$APP_ID" --pct-syskeys 0 1
sleep 5

# ── 6. Vérifier Maestro ───────────────────
echo "════ Vérification Maestro ════"
$MAESTRO hierarchy

# ── 7. Tests ──────────────────────────────
echo "════ Lancement des tests ════"
mkdir -p results/videos results/screenshots

# Tous les tests + rapport HTML
$MAESTRO  test maestro/flows/ -e TEST_EMAIL=$TEST_EMAIL -e TEST_PASSWORD=$TEST_PASSWORD --test-output-dir results/screenshots

# Vidéo flow complet
$MAESTRO record maestro/flows/ --local --output results/videos/ -e TEST_EMAIL=$TEST_EMAIL -e TEST_PASSWORD="$TEST_PASSWORD

echo "════ Tests terminés ✓ ════"
