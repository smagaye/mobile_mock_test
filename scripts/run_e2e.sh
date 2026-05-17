#!/bin/bash
# ─────────────────────────────────────────────────────────────
# scripts/run_e2e.sh
# E2E test runner — called by GitHub Actions android-emulator-runner
#
# Environment variables injected by the workflow:
#   TEST_EMAIL        test account email
#   TEST_PASSWORD     test account password
#   APP_PACKAGE       Android app package ID
#   APK_PATH          path to the debug APK
#   FLOWS_DIR         Maestro flows directory
#   RESULTS_DIR       root results directory
#   VIDEOS_DIR        MP4 videos output directory
#   SCREENSHOTS_DIR   screenshots output directory
#   REPORT_FILE       HTML report output path
# ─────────────────────────────────────────────────────────────
set -e

MAESTRO="$HOME/.maestro/bin/maestro"

# ── 1. Fix device offline ──────────────────────────────────
echo "==== Fix device offline ===="
adb kill-server
sleep 2
adb start-server
sleep 3
adb devices -l

# ── 2. Wait for device to come online ─────────────────────
echo "==== Waiting for device online ===="
TIMEOUT=120
ELAPSED=0
while true; do
  STATUS=$(adb devices | grep "emulator" | grep -v "offline" | grep -w "device" || true)
  if [ -n "$STATUS" ]; then
    echo "Device online ✓"
    break
  fi
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "ERROR: device still offline after ${TIMEOUT}s"
    adb devices
    exit 1
  fi
  echo "  ${ELAPSED}s — waiting..."
  sleep 3
  ELAPSED=$((ELAPSED + 3))
done

# ── 3. Wait for full boot ──────────────────────────────────
echo "==== Waiting for boot completion ===="
TIMEOUT=180
ELAPSED=0
while true; do
  BOOT=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n' || true)
  if [ "$BOOT" = "1" ]; then
    echo "Boot complete ✓"
    break
  fi
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "ERROR: boot not completed after ${TIMEOUT}s"
    exit 1
  fi
  echo "  ${ELAPSED}s — booting..."
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

# Wait for boot animation to finish
ANIM=$(adb shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r\n' || true)
while [ "$ANIM" != "stopped" ]; do
  echo "  Boot animation running..."
  sleep 2
  ANIM=$(adb shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r\n' || true)
done
echo "Boot animation stopped ✓"

# ── 4. Disable animations ──────────────────────────────────
# Required to fix: "Could not take screenshot, error: -1"
echo "==== Disabling system animations ===="
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
echo "Animations disabled ✓"

# Wait for GPU renderer to fully initialize
sleep 10

# ── 5. Install APK ────────────────────────────────────────
echo "==== Installing APK ===="
# -r flag replaces existing install to avoid conflicts
adb install -r "$APK_PATH"
echo "APK installed ✓"

# Launch the app
adb shell monkey -p "$APP_PACKAGE" --pct-syskeys 0 1
sleep 5

# ── 6. Verify Maestro can see the app ─────────────────────
echo "==== Maestro hierarchy check ===="
$MAESTRO hierarchy

# ── 7. Create output directories ──────────────────────────
mkdir -p "$VIDEOS_DIR" "$SCREENSHOTS_DIR"

# ── 8. Record a video for each flow ───────────────────────
echo "==== Recording videos ===="
for FLOW in "$FLOWS_DIR"/*.yaml; do
  FLOW_NAME=$(basename "$FLOW" .yaml)
  echo "  Recording: $FLOW_NAME..."
  $MAESTRO record --local \
    -e TEST_EMAIL="$TEST_EMAIL" \
    -e TEST_PASSWORD="$TEST_PASSWORD" \
    "$FLOW" \
    "$VIDEOS_DIR/${FLOW_NAME}.mp4" \
    || echo "  WARNING: $FLOW_NAME recording failed — continuing"
done
echo "Videos recorded ✓"

# ── 9. Run all tests + HTML report ────────────────────────
echo "==== Running all tests ===="
$MAESTRO test "$FLOWS_DIR/" \
  -e TEST_EMAIL="$TEST_EMAIL" \
  -e TEST_PASSWORD="$TEST_PASSWORD" \
  --format html \
  --output "$REPORT_FILE" \
  --test-output-dir "$SCREENSHOTS_DIR"

echo "==== All tests completed ✓ ===="
