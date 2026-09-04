#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────────
# setup_test_fixtures.sh
#
# Installs test fixture images and PDFs onto a simulator or device so that
# GiniBankSDKExampleUITests can run from Xcode without manual file setup.
#
# What it installs:
#   • PNG files  →  Photos library  (camera roll)
#   • PNG files  →  Files app       (On My iPhone › GiniBankSDKExampleBank)
#   • PDF files  →  Files app       (On My iPhone › GiniBankSDKExampleBank)
#
# Usage:
#   ./setup_test_fixtures.sh                        # auto-detect booted simulator or connected device
#   ./setup_test_fixtures.sh --simulator booted     # booted simulator
#   ./setup_test_fixtures.sh --simulator <UDID>     # specific simulator
#   ./setup_test_fixtures.sh --device <UDID>        # connected device (Xcode 15+ required)
#   ./setup_test_fixtures.sh --fixtures-dir <path>  # custom fixture folder
#   ./setup_test_fixtures.sh --list                 # list fixture files and exit
#
# Requirements:
#   Simulator: Xcode command-line tools (xcrun simctl)
#   Device:    Xcode 15+ (xcrun devicectl)
#
# The app (net.gini.banksdk.example.bank) must be installed on the target
# before running this script — build & run it in Xcode first.
# ──────────────────────────────────────────────────────────────────────────────
set -e

BUNDLE_ID="net.gini.banksdk.example.bank"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_FIXTURES_DIR="$SCRIPT_DIR/../TestSamples/TestSamplesForBS"

# ── Colour output ─────────────────────────────────────────────────────────────
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

ok()   { echo -e "  ${GREEN}✅ $*${RESET}"; }
warn() { echo -e "  ${YELLOW}⚠️  $*${RESET}"; }
err()  { echo -e "  ${RED}❌ $*${RESET}"; }
info() { echo -e "  ${CYAN}ℹ️  $*${RESET}"; }

# ── Argument parsing ──────────────────────────────────────────────────────────
TARGET_TYPE=""
TARGET_UDID=""
FIXTURES_DIR="$DEFAULT_FIXTURES_DIR"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [options]

Options:
  --simulator [booted|<UDID>]   Target a booted simulator (default: booted)
  --device <UDID>               Target a connected device (Xcode 15+)
  --fixtures-dir <path>         Path to fixture files (default: TestSamplesForBS/)
  --list                        Print detected fixture files and exit
  --help                        Show this message

Example:
  $(basename "$0") --simulator booted
  $(basename "$0") --device 00008110-001A1234567890AB
  $(basename "$0") --fixtures-dir ~/Desktop/my_invoices
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --simulator)
      TARGET_TYPE="simulator"
      TARGET_UDID="${2:-booted}"
      shift; shift
      ;;
    --device)
      TARGET_TYPE="device"
      TARGET_UDID="${2:?--device requires a UDID}"
      shift; shift
      ;;
    --fixtures-dir)
      FIXTURES_DIR="${2:?--fixtures-dir requires a path}"
      shift; shift
      ;;
    --list)
      echo "Fixture files in: $DEFAULT_FIXTURES_DIR"
      echo ""
      echo "PNGs:"
      find "$DEFAULT_FIXTURES_DIR" -maxdepth 1 -name "*.png" -exec basename {} \; | sort | sed 's/^/  /'
      echo ""
      echo "PDFs:"
      find "$DEFAULT_FIXTURES_DIR" -maxdepth 1 -name "*.pdf" -exec basename {} \; | sort | sed 's/^/  /'
      exit 0
      ;;
    --help|-h)
      usage; exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage; exit 1
      ;;
  esac
done

# ── Validate fixtures directory ───────────────────────────────────────────────
if [ ! -d "$FIXTURES_DIR" ]; then
  err "Fixtures directory not found: $FIXTURES_DIR"
  echo "     Pass --fixtures-dir <path> to specify a custom location."
  exit 1
fi

PNG_FILES=()
while IFS= read -r -d '' f; do PNG_FILES+=("$f"); done \
  < <(find "$FIXTURES_DIR" -maxdepth 1 -name "*.png" -print0 | sort -z)

PDF_FILES=()
while IFS= read -r -d '' f; do PDF_FILES+=("$f"); done \
  < <(find "$FIXTURES_DIR" -maxdepth 1 -name "*.pdf" -print0 | sort -z)
ALL_FILES=("${PNG_FILES[@]}" "${PDF_FILES[@]}")

if [ "${#ALL_FILES[@]}" -eq 0 ]; then
  warn "No PNG or PDF files found in: $FIXTURES_DIR"
  exit 0
fi

echo ""
echo "Fixture files to install (${#PNG_FILES[@]} PNG, ${#PDF_FILES[@]} PDF):"
for f in "${ALL_FILES[@]}"; do printf "  %s\n" "$(basename "$f")"; done
echo ""

# ── Auto-detect target ────────────────────────────────────────────────────────
if [ -z "$TARGET_TYPE" ]; then
  BOOTED=$(xcrun simctl list devices booted 2>/dev/null \
    | grep -E '\(([A-F0-9-]{36})\)' \
    | head -1 \
    | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}')

  if [ -n "$BOOTED" ]; then
    TARGET_TYPE="simulator"
    TARGET_UDID="$BOOTED"
    SIM_NAME=$(xcrun simctl list devices booted 2>/dev/null \
      | grep "$TARGET_UDID" | sed 's/ (Booted).*//' | xargs)
    info "Auto-detected booted simulator: $SIM_NAME ($TARGET_UDID)"
  else
    # Try xcrun devicectl for a connected device (Xcode 15+)
    if xcrun devicectl list devices &>/dev/null 2>&1; then
      DEVICE_LINE=$(xcrun devicectl list devices 2>/dev/null \
        | grep -v "^Name\|^---\|^$" | head -1)
      TARGET_UDID=$(echo "$DEVICE_LINE" | awk '{print $NF}')
      if [ -n "$TARGET_UDID" ]; then
        TARGET_TYPE="device"
        DEVICE_NAME=$(echo "$DEVICE_LINE" | awk '{print $1}')
        info "Auto-detected connected device: $DEVICE_NAME ($TARGET_UDID)"
      fi
    fi
  fi

  if [ -z "$TARGET_TYPE" ]; then
    err "No booted simulator or connected device found."
    echo "     Boot a simulator in Xcode, or connect a device, then retry."
    echo "     Or pass --simulator booted / --device <UDID> explicitly."
    exit 1
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# SIMULATOR
# ══════════════════════════════════════════════════════════════════════════════
install_to_simulator() {
  echo -e "${CYAN}Target: simulator $TARGET_UDID${RESET}"
  echo ""

  # ── Step 1: Photos ──────────────────────────────────────────────────────────
  echo "[1/2] Installing PNGs to Photos library..."
  PHOTOS_OK=0
  for f in "${PNG_FILES[@]}"; do
    if xcrun simctl addmedia "$TARGET_UDID" "$f" 2>/dev/null; then
      ok "Photos ← $(basename "$f")"
      ((PHOTOS_OK++)) || true
    else
      warn "Failed to add to Photos: $(basename "$f")"
    fi
  done
  [ $PHOTOS_OK -eq 0 ] && warn "No PNGs were added to Photos (is the simulator booted?)"

  # ── Step 2: Files app ───────────────────────────────────────────────────────
  echo ""
  echo "[2/2] Installing files to Files app (On My iPhone › GiniBankSDKExampleBank)..."

  # The app must be installed before its data container exists
  if ! xcrun simctl get_app_container "$TARGET_UDID" "$BUNDLE_ID" data &>/dev/null 2>&1; then
    warn "App '$BUNDLE_ID' is not installed on this simulator."
    info "Build and run the app in Xcode (⌘R) once, then re-run this script."
    echo ""
    return 1
  fi

  CONTAINER=$(xcrun simctl get_app_container "$TARGET_UDID" "$BUNDLE_ID" data)
  DOCS_DIR="$CONTAINER/Documents"
  mkdir -p "$DOCS_DIR"

  FILES_OK=0
  for f in "${ALL_FILES[@]}"; do
    cp "$f" "$DOCS_DIR/"
    ok "Files ← $(basename "$f")"
    ((FILES_OK++)) || true
  done

  echo ""
  info "Documents folder: $DOCS_DIR"
  info "In iOS: Files › On My iPhone › GiniBankSDKExampleBank"
  echo ""

  # Restart the File Provider daemon so the simulator indexes the new files.
  # Without this, newly-copied PDFs may not appear in the document picker's Recents tab.
  echo "Refreshing Files app index on simulator..."
  xcrun simctl spawn "$TARGET_UDID" \
    /usr/bin/killall -9 "com.apple.FileProvider.LocalStorage" 2>/dev/null || true
  sleep 2

  # Open the app's folder in the Files app to register all files in Recents.
  # The document picker's Recents tab (used by tapFileWithName) only shows files
  # that iOS has seen at least once through the Files UI or file provider.
  xcrun simctl openurl "$TARGET_UDID" \
    "shareddocuments://${DOCS_DIR}" 2>/dev/null || true
  sleep 1

  info "If files are still missing from Recents: open Files app on the simulator,"
  info "tap Browse › On My iPhone › GiniBankSDKExampleBank, then re-run your tests."

  ok "Done — $PHOTOS_OK PNG(s) in Photos, $FILES_OK file(s) in Files app."
}

# ══════════════════════════════════════════════════════════════════════════════
# DEVICE
# ══════════════════════════════════════════════════════════════════════════════
install_to_device() {
  echo -e "${CYAN}Target: device $TARGET_UDID${RESET}"
  echo ""

  # Require xcrun devicectl (Xcode 15+)
  if ! xcrun devicectl --version &>/dev/null 2>&1; then
    err "xcrun devicectl not found — Xcode 15 or later is required."
    exit 1
  fi

  # ── Step 1: Photos ──────────────────────────────────────────────────────────
  echo "[1/2] Installing PNGs to Photos library..."
  PHOTOS_OK=0
  for f in "${PNG_FILES[@]}"; do
    if xcrun devicectl device install media \
         --device "$TARGET_UDID" "$f" &>/dev/null 2>&1; then
      ok "Photos ← $(basename "$f")"
      ((PHOTOS_OK++)) || true
    else
      warn "Failed: $(basename "$f") (device locked or iOS < 17?)"
    fi
  done

  # ── Step 2: Files app ───────────────────────────────────────────────────────
  echo ""
  echo "[2/2] Installing files to Files app (On My iPhone › GiniBankSDKExampleBank)..."

  # Resolve the app's data container UUID via xcrun devicectl
  APP_CONTAINER_UUID=$(xcrun devicectl device info apps \
    --device "$TARGET_UDID" \
    --bundle-id "$BUNDLE_ID" 2>/dev/null \
    | grep -oE '"containerURL".*?[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' \
    | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' \
    | head -1)

  FILES_OK=0
  if [ -n "$APP_CONTAINER_UUID" ]; then
    DEVICE_DOCS_PATH="/private/var/mobile/Containers/Data/Application/$APP_CONTAINER_UUID/Documents"

    for f in "${ALL_FILES[@]}"; do
      DEST="$DEVICE_DOCS_PATH/$(basename "$f")"
      if xcrun devicectl device copy to \
           --device "$TARGET_UDID" \
           --source "$f" \
           --destination "$DEST" &>/dev/null 2>&1; then
        ok "Files ← $(basename "$f")"
        ((FILES_OK++)) || true
      else
        warn "Copy failed: $(basename "$f")"
      fi
    done

    if [ $FILES_OK -gt 0 ]; then
      info "In iOS: Files › On My iPhone › GiniBankSDKExampleBank"
    fi
  else
    # Fallback: Xcode Devices window instructions
    warn "Could not resolve app container UUID."
    warn "App '$BUNDLE_ID' may not be installed — build & run it in Xcode first."
    echo ""
    echo "  Alternatively, add files manually via Xcode:"
    echo "    1. Window › Devices and Simulators (⇧⌘2)"
    echo "    2. Select your device › Installed Apps"
    echo "    3. Select 'GiniBankSDKExampleBank' › click the settings gear › Download Container"
    echo "       (or use the + button to add files directly)"
    echo ""
    echo "  Files to add from: $FIXTURES_DIR"
    for f in "${ALL_FILES[@]}"; do printf "    %s\n" "$(basename "$f")"; done
  fi

  echo ""
  ok "Done — $PHOTOS_OK PNG(s) in Photos, $FILES_OK file(s) in Files app."
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
case "$TARGET_TYPE" in
  simulator) install_to_simulator ;;
  device)    install_to_device ;;
esac
