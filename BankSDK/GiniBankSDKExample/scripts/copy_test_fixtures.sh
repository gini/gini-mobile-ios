#!/bin/bash
# Copies PDF test fixtures into the booted simulator's app Documents folder.
# Can be run manually or invoked automatically via the Xcode scheme pre-action.
#
# Usage: bash BankSDK/GiniBankSDKExample/scripts/copy_test_fixtures.sh

BUNDLE_ID="net.gini.banksdk.example"

# Locate TestFixturePDFs — use SRCROOT when invoked from Xcode pre-action,
# otherwise resolve relative to this script's location.
if [ -n "$SRCROOT" ]; then
    SRC="$SRCROOT/TestFixturePDFs"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    SRC="$SCRIPT_DIR/../TestFixturePDFs"
fi

# Wait up to 30 seconds for the app to be installed on the booted simulator.
# The pre-action may fire before Xcode finishes installing the app.
CONTAINER=""
for i in $(seq 1 30); do
    CONTAINER=$(xcrun simctl get_app_container booted "$BUNDLE_ID" data 2>/dev/null)
    if [ -n "$CONTAINER" ]; then break; fi
    sleep 1
done

if [ -z "$CONTAINER" ]; then
    echo "WARNING: App '$BUNDLE_ID' not found on booted simulator after 30s. Skipping fixture copy."
    exit 0
fi

DEST="$CONTAINER/Documents"
mkdir -p "$DEST"

COPIED=0
for f in "$SRC"/*.pdf; do
    [ -f "$f" ] || continue
    cp "$f" "$DEST/"
    echo "Copied: $(basename "$f")"
    COPIED=$((COPIED + 1))
done

if [ "$COPIED" -eq 0 ]; then
    echo "WARNING: No PDFs found in $SRC"
    echo "Place fixture PDFs there first. See TestFixturePDFs/README.md"
    exit 0
fi

echo "Done. $COPIED file(s) copied to simulator."
