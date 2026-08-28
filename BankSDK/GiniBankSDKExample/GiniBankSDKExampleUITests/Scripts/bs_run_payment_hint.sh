#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_payment_hint.sh
#
# Builds, uploads, and runs the payment-hint bottom sheet UI automation on
# BrowserStack. Suite covered:
#
#   GiniBankSDKExampleUITests/PaymentHintFlowUITests
#     — Due Date Hint + Schedule Payment bottom sheet, all flag combinations,
#       boundary threshold, dynamic-type AXXXL, backdrop-tap suppression,
#       and capture-suggestions suppression.
#
# Media uploaded to the device's Photos library (upload order matters for
# gallery offset semantics — see PaymentHintFlowUITests docstring):
#   1. invoice_no_due_date.jpeg  → offset 1 (used only by R6)
#   2. invoice_future_due.jpeg   → offset 0 (used by R1–R5, R7–R13)
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
INVOICE_NO_DUE_DATE_FILE="$SAMPLES_DIR/invoice_no_due_date.jpeg"
INVOICE_FUTURE_DUE_FILE="$SAMPLES_DIR/invoice_future_due.jpeg"

# ── Test suites ────────────────────────────────────────────────────────────────

ONLY_TESTING='[
  "GiniBankSDKExampleUITests/PaymentHintFlowUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
# Upload order defines the gallery offset the tests select. Do NOT reorder
# these two lines without updating the offsets in
# PaymentHintFlowUITests.swift.
echo "Uploading media files..."
upload_media INVOICE_NO_DUE_DATE_URL "$INVOICE_NO_DUE_DATE_FILE" "PaymentHintNoDueDate" "invoice_no_due_date.jpeg"
upload_media INVOICE_FUTURE_DUE_URL "$INVOICE_FUTURE_DUE_FILE" "PaymentHintFutureDue" "invoice_future_due.jpeg"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:                       $APP_URL"
echo "  test_suite_url:                $TEST_URL"
echo "  invoice_no_due_date.jpeg:      $INVOICE_NO_DUE_DATE_URL"
echo "  invoice_future_due.jpeg:       $INVOICE_FUTURE_DUE_URL"

# ── Trigger test run ───────────────────────────────────────────────────────────
echo ""
echo "Triggering BrowserStack test run..."
BUILD_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": [\"$DEVICE_1\"],
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": $ONLY_TESTING,
    \"project\": \"$BS_PROJECT\",
    \"buildName\": \"Payment Hints PP-3302\",
    \"uploadMedia\": [\"$INVOICE_NO_DUE_DATE_URL\", \"$INVOICE_FUTURE_DUE_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
