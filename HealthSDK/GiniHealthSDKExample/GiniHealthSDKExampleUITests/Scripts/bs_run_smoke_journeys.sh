#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_smoke_journeys.sh
#
# Runs the journey smoke tests on BrowserStack as ONE build — the automatable
# subset of HEAL SmokeTestSuite (Xray folder /Health SDK Test Cases/SmokeTestSuite),
# mapped to end-to-end flows that walk entry → extraction → Payment Review → bank:
#
#   HEAL-282  Image import (gallery) → extraction → Payment Review → Black bank
#   HEAL-284  PDF import (Files app) → extraction → Payment Review → Black bank
#   HEAL-285  Invoice list from main entry point
#   HEAL-286  Orders list entry point
#   HEAL-287  GPC flow with Black bank
#   HEAL-293  Edit IBAN/Recipient/Amount/Reference → propagate to bank
#   HEAL-304  Payment status updated after bank app payment (truncated at deeplink)
#
# All seven live in GiniHealthSmokeJourneysUITests. Class-level selection runs
# them in one runner process (singleRunnerInvocation: "true").
#
# NOT automated — these smoke cases stay manual:
#   - HEAL-283  Live camera QR scan (camera-only entry — out of scope by design)
#   - HEAL-302  No-network default error (BrowserStack cloud blocks WiFi toggling)
#
# The per-screen UI checks live in bs_run_smoke_screens.sh — run both for the
# full smoke suite (sequentially: with 2 parallel licenses and the default
# 2-device pair, both together would exceed the license budget and queued
# sessions are canceled after 15 minutes).
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
#
# Optional: BS_DEVICE (single device or comma-separated list), BS_LANGUAGE.
#
# Single-test mode: set BS_TEST to run exactly one test (or class) instead of
# the whole journeys class — the fast path for reproducing a flake:
#   BS_TEST="GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests/testHEAL282_ImageImport" ./bs_run_smoke_journeys.sh
# ⚠️ BrowserStack matches only-testing METHOD entries by NAME PREFIX — the method
# name must be no other test's prefix. Single runner is disabled in this mode.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Optional device language ───────────────────────────────────────────────────
LANGUAGE_FIELD=""
if [ -n "${BS_LANGUAGE:-}" ]; then
    LANGUAGE_FIELD="\"language\": \"$BS_LANGUAGE\","
fi

# ── Media files ────────────────────────────────────────────────────────────────
MED_INVOICE_PDF="$SAMPLES_DIR/testMedInvoice.pdf"  # → Custom_Files (HEAL-284, 285, 286, 287, 293, 304)
MED_INVOICE_PNG="$SAMPLES_DIR/testMedInvoice.png"  # → Photos gallery (HEAL-282)

# ── Test selection ─────────────────────────────────────────────────────────────
ONLY_TESTING='[
  "GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests"
]'
SINGLE_RUNNER="true"
if [ -n "${BS_TEST:-}" ]; then
    ONLY_TESTING="[\"$BS_TEST\"]"
    ## Method-level entry possible in BS_TEST — keep the filter honored.
    SINGLE_RUNNER="false"
fi

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media MED_INVOICE_PDF_URL "$MED_INVOICE_PDF" "MedInvoicePDF" "testMedInvoice.pdf (Custom_Files)"
upload_media MED_INVOICE_PNG_URL "$MED_INVOICE_PNG" "MedInvoicePNG" "testMedInvoice.png (Photos gallery)"

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
    \"singleRunnerInvocation\": \"$SINGLE_RUNNER\",
    $LANGUAGE_FIELD
    \"uploadMedia\": [\"$MED_INVOICE_PDF_URL\", \"$MED_INVOICE_PNG_URL\"],
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
