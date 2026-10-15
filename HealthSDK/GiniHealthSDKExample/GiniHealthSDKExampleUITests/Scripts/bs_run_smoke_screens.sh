#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_smoke_screens.sh
#
# Runs the per-screen smoke UI checks on BrowserStack as ONE build — the HEAL
# SmokeTestSuite cases that verify a single screen's behaviour rather than a
# full end-to-end journey:
#
#   Bank Selection sheet          HEAL-288, 289, 290  (3 tests)
#   More Info / Payment Feature   HEAL-291, 292       (2 tests)
#   Payment Review Screen         HEAL-294, 295, 296, 297, 298, 299, 300, 301, 306
#                                                     (9 tests)
#   Install App bottom sheet      HEAL-303            (1 test)
#   Open With / Share with        HEAL-305            (1 test)
#   No-network error (skipped)    HEAL-302            (1 skip-with-reason)
#
# All live in GiniHealthSmokeScreensUITests. Class-level selection, so
# singleRunnerInvocation stays on (one runner process, ~30–60 s saved per test).
#
# The journey smoke tests live in bs_run_smoke_journeys.sh — run both for the
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
# the whole screens class — the fast path for reproducing a flake:
#   BS_TEST="GiniHealthSDKExampleUITests/GiniHealthSmokeScreensUITests/testHEAL296_InvalidIBAN" ./bs_run_smoke_screens.sh
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
MED_INVOICE_PDF="$SAMPLES_DIR/testMedInvoice.pdf"  # → Custom_Files (most screen tests)
MULTI_INVOICE_PDF="$SAMPLES_DIR/multi-invoice.pdf" # → Custom_Files (HEAL-294 pagination dots)

# ── Test selection ─────────────────────────────────────────────────────────────
ONLY_TESTING='[
  "GiniHealthSDKExampleUITests/GiniHealthSmokeScreensUITests"
]'
SINGLE_RUNNER="true"
if [ -n "${BS_TEST:-}" ]; then
    ONLY_TESTING="[\"$BS_TEST\"]"
    SINGLE_RUNNER="false"
fi

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media MED_INVOICE_PDF_URL   "$MED_INVOICE_PDF"   "MedInvoicePDF"   "testMedInvoice.pdf (Custom_Files)"
upload_media MULTI_INVOICE_PDF_URL "$MULTI_INVOICE_PDF" "MultiInvoicePDF" "multi-invoice.pdf (Custom_Files)"

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
    \"buildName\": \"smoke_screens\",
    \"timeout\": 7200,
    \"singleRunnerInvocation\": \"$SINGLE_RUNNER\",
    $LANGUAGE_FIELD
    \"uploadMedia\": [\"$MED_INVOICE_PDF_URL\", \"$MULTI_INVOICE_PDF_URL\"],
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
