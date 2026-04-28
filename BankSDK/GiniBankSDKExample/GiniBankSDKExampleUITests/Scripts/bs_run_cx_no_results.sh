#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_cx_no_results.sh
#
# Runs the CX no-results, Skonto (past), and Return Assistant scenarios on
# BrowserStack. Groups covered:
#
#   GiniCXNoResultsUITests              — E1/E2: No-Results screen when CX backend
#                                         returns no extractions (cx_no_results_invoice.pdf)
#   GiniReturnAssistantScreenUITests    — testReturnAssistantBS only (return_asistant.pdf)
#   GiniSkontoScreenUITests             — past Skonto invoice (skonto_past.pdf)
#
# ⚠️  BS ADAPTATION NEEDED:
#   GiniCXNoResultsUITests and GiniSkontoScreenUITests use tapFileWithName()
#   which looks in the device Downloads folder. On BrowserStack, uploaded PDFs
#   appear in the Custom_Files folder. Replace tapFileWithName() calls in those
#   test classes with tapFileWithNameFromBSCustomFiles() before running this script.
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
CX_NO_RESULTS_FILE="$SAMPLES_DIR/cx_no_results_invoice.pdf"  # → Custom_Files
SKONTO_PAST_FILE="$SAMPLES_DIR/skonto_past.pdf"              # → Custom_Files
RA_FILE="$SAMPLES_DIR/return_asistant.pdf"                   # → Custom_Files

# ── Test suites ────────────────────────────────────────────────────────────────
# NOTE: GiniCXNoResultsUITests and GiniSkontoScreenUITests require tapFileWithNameFromBSCustomFiles
# adaptation before they will pass on BrowserStack (see ⚠️ above).
ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniCXNoResultsUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media CX_NO_RESULTS_URL "$CX_NO_RESULTS_FILE" "CXNoResultsInvoice"   "cx_no_results_invoice.pdf"
upload_media SKONTO_PAST_URL   "$SKONTO_PAST_FILE"   "SkontoPastInvoice"    "skonto_past.pdf"
upload_media RA_URL            "$RA_FILE"            "ReturnAssistantInvoice" "return_asistant.pdf"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:                  $APP_URL"
echo "  test_suite_url:           $TEST_URL"
echo "  CX no-results invoice:    $CX_NO_RESULTS_URL"
echo "  Skonto past invoice:      $SKONTO_PAST_URL"
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
    \"project\": \"$BS_PROJECT\",
    \"buildName\": \"bs_run_cx_no_results\",
    \"uploadMedia\": [\"$CX_NO_RESULTS_URL\", \"$SKONTO_PAST_URL\", \"$RA_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
