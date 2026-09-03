#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_smoke_journeys.sh
#
# Runs the journey smoke tests on BrowserStack as ONE build — the automatable
# subset of the manual smoke test cases (smoke tests.csv), as a curated
# method-level selection:
#
#   Onboarding walk + camera permission → GiniOnboardingScreenUITest/testOnboardingGetStartedButton
#   Upload PDF SEPA invoice → extractions → GiniSmokeUITests/testUploadPDFSEPAInvoiceShowsExtractions
#   Upload picture SEPA invoice → extractions → GiniSmokeUITests/testUploadPictureSEPAInvoiceShowsExtractions
#   Upload PDF non-invoice → No-Results → GiniSmokeUITests/testUploadPDFNoResultsScreen
#   RA: full flow + item editing → GiniReturnAssistantScreenUITests (testReturnAssistantFullFlow, testReturnAssistantEditName)
#   Skonto: flow + toggle switching → GiniSkontoScreenUITests (testSkontoFullFlowWithDiscountViaFiles, testSkontoToggleSwitch)
#
# ⚠️ BrowserStack matches only-testing METHOD entries by NAME PREFIX, not exactly.
# Every method entry below must be NO OTHER TEST'S PREFIX — tests were renamed to
# guarantee it (testSkontoToggleSwitch, testReturnAssistantFullFlow). Check this
# before adding a selection entry. singleRunnerInvocation stays OFF for the same
# reason: method-level filtering.
#
# The per-screen UI checks live in bs_run_smoke_screens.sh — run both for the
# full smoke suite (sequentially: with 2 parallel licenses and the default
# 2-device pair, both together would exceed the license budget and queued
# sessions are canceled after 15 minutes).
#
# NOT automatable on BrowserStack — these smoke cases stay manual:
#   - "Open with" / share-sheet flows (picture, PDF, XML e-invoice)
#   - Live camera capture cases (remmslip photo, multi-page capture, >10 pages,
#     QR code scanning, IBAN detection) — require camera injection media per case
#   - Error screen via WiFi off (no network toggling mid-test)
#   - >10 gallery pictures (BrowserStack media upload cap is 5 files)
#   - Save-to-Photos toggle verification in the Photos app
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
#
# Optional: BS_DEVICE (single device or comma-separated list), BS_LANGUAGE.
#
# Single-test mode: set BS_TEST to run exactly one test (or class) instead of
# the curated selection — the fast path for reproducing a flake:
#   BS_TEST="GiniBankSDKExampleUITests/GiniCameraAccessScreenUITests/testCameraAccessScreenHelpButton" ./bs_run_smoke_journeys.sh
# The build carries this script's media set, so file/gallery-based tests work too.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Optional device language ───────────────────────────────────────────────────
LANGUAGE_FIELD=""
if [ -n "${BS_LANGUAGE:-}" ]; then
    LANGUAGE_FIELD="\"language\": \"$BS_LANGUAGE\","
fi

# ── Media files ────────────────────────────────────────────────────────────────
SEPA_PDF_FILE="$SAMPLES_DIR/sepa_invoice.pdf"     # → Custom_Files (PDF upload smoke)
SEPA_PNG_FILE="$SAMPLES_DIR/sepa_invoice.png"     # → Photos gallery (picture upload smoke)
NO_RESULTS_FILE="$SAMPLES_DIR/no_results_invoice.pdf" # → Custom_Files (No-Results smoke)
RA_FILE="$SAMPLES_DIR/return_asistant.pdf"        # → Custom_Files (Return Assistant smoke)
SKONTO_PAST_FILE="$SAMPLES_DIR/skonto_past.pdf"   # → Custom_Files (Skonto smoke)

# ── Test selection ─────────────────────────────────────────────────────────────
ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniOnboardingScreenUITest/testOnboardingGetStartedButton",
  "GiniBankSDKExampleUITests/GiniSmokeUITests/testUploadPDFSEPAInvoiceShowsExtractions",
  "GiniBankSDKExampleUITests/GiniSmokeUITests/testUploadPictureSEPAInvoiceShowsExtractions",
  "GiniBankSDKExampleUITests/GiniSmokeUITests/testUploadPDFNoResultsScreen",
  "GiniBankSDKExampleUITests/GiniReturnAssistantScreenUITests/testReturnAssistantFullFlow",
  "GiniBankSDKExampleUITests/GiniReturnAssistantScreenUITests/testReturnAssistantEditName",
  "GiniBankSDKExampleUITests/GiniSkontoScreenUITests/testSkontoFullFlowWithDiscountViaFiles",
  "GiniBankSDKExampleUITests/GiniSkontoScreenUITests/testSkontoToggleSwitch"
]'
if [ -n "${BS_TEST:-}" ]; then
    ONLY_TESTING="[\"$BS_TEST\"]"
fi

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media SEPA_PDF_URL       "$SEPA_PDF_FILE"       "SepaInvoicePDF"         "sepa_invoice.pdf (Custom_Files)"
upload_media SEPA_PNG_URL       "$SEPA_PNG_FILE"       "SepaInvoicePNG"         "sepa_invoice.png (Photos gallery)"
upload_media NO_RESULTS_URL     "$NO_RESULTS_FILE"     "NoResultsInvoice"       "no_results_invoice.pdf (Custom_Files)"
upload_media RA_URL             "$RA_FILE"             "ReturnAssistantInvoice" "return_asistant.pdf (Custom_Files)"
upload_media SKONTO_PAST_URL    "$SKONTO_PAST_FILE"    "SkontoPastInvoice"      "skonto_past.pdf (Custom_Files)"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:        $APP_URL"
echo "  test_suite_url: $TEST_URL"

# ── Trigger test run ───────────────────────────────────────────────────────────
echo ""
echo "Triggering BrowserStack test run..."
BUILD_RESPONSE=$(bs_curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": $DEVICES_JSON,
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": $ONLY_TESTING,
    \"project\": \"$BS_PROJECT\",
    \"buildName\": \"smoke_journeys\",
    \"timeout\": 7200,
    \"singleRunnerInvocation\": \"false\",
    $LANGUAGE_FIELD
    \"uploadMedia\": [\"$SEPA_PDF_URL\", \"$SEPA_PNG_URL\", \"$NO_RESULTS_URL\", \"$RA_URL\", \"$SKONTO_PAST_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

BUILD_ID=$(echo "$BUILD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('build_id',''))" 2>/dev/null || true)
if [ -z "$BUILD_ID" ]; then
    echo "ERROR: build trigger failed — see response above"
    exit 1
fi
echo "  https://app-automate.browserstack.com/dashboard/v2/builds/$BUILD_ID"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
