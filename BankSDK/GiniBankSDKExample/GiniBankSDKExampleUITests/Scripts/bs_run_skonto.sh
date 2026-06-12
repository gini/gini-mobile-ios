#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_skonto.sh
#
# Runs the Skonto scenario on BrowserStack with both invoice types:
#
#   skonto_past.pdf  — invoice with an expired Skonto discount date
#                      (switch starts disabled, tests: testSkonto, testSkontoBackButton,
#                       testSkontoSwitch, testSkontoInPast, testSkontoHelpButton)
#   skonto_valid.pdf — invoice with a future/valid Skonto discount date
#                      (switch starts enabled, test: testSkontoInFuture)
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
SKONTO_PAST_FILE="$SAMPLES_DIR/skonto_past.pdf"   # → Custom_Files
SKONTO_VALID_FILE="$SAMPLES_DIR/skonto_valid.pdf" # → Custom_Files

# ── Test suites ────────────────────────────────────────────────────────────────
# NOTE: These tests require tapFileWithNameFromBSCustomFiles adaptation (see ⚠️ above).
ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniSkontoScreenUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media SKONTO_PAST_URL  "$SKONTO_PAST_FILE"  "SkontoPastInvoice"  "skonto_past.pdf (expired discount)"
upload_media SKONTO_VALID_URL "$SKONTO_VALID_FILE" "SkontoValidInvoice" "skonto_valid.pdf (future/valid discount)"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:              $APP_URL"
echo "  test_suite_url:       $TEST_URL"
echo "  Skonto past invoice:  $SKONTO_PAST_URL"
echo "  Skonto valid invoice: $SKONTO_VALID_URL"

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
    \"project\": \"$BS_PROJECT\",
    \"buildName\": \"bs_run_skonto\",
    \"uploadMedia\": [\"$SKONTO_PAST_URL\", \"$SKONTO_VALID_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
