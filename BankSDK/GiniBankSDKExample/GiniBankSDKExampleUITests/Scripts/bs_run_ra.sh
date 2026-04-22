#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_ra.sh
#
# Runs the Return Assistant scenario on BrowserStack.
#
#   GiniReturnAssistantScreenUITests/testReturnAssistantBS
#     — uploads return_asistant.pdf via Custom_Files, verifies the full RA flow
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
RA_FILE="$SAMPLES_DIR/return_asistant.pdf"  # → Custom_Files

# ── Test suites ────────────────────────────────────────────────────────────────
ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniReturnAssistantScreenUITests/testReturnAssistantBS"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media RA_URL "$RA_FILE" "ReturnAssistantInvoice" "return_asistant.pdf"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:                  $APP_URL"
echo "  test_suite_url:           $TEST_URL"
echo "  Return Assistant invoice: $RA_URL"

# ── Trigger test run ───────────────────────────────────────────────────────────
echo ""
echo "Triggering BrowserStack test run..."
BUILD_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": [\"$DEVICE_1\", \"$DEVICE_2\"],
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": $ONLY_TESTING,
    \"uploadMedia\": [\"$RA_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
