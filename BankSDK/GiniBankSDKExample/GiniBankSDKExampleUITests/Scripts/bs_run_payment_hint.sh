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
# Fixtures uploaded to the device's Files.app "Custom_Files" folder (BS surfaces
# uploadMedia PDFs there); tests pick them by exact filename via
# `tapFileFromBestAvailableSource(fileName:)` — no offset semantics.
#   1. invoice_no_due_date.pdf   (used only by R6)
#   2. invoice_future_due.pdf    (used by R1–R5, R7–R13)
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# Override bs_shared.sh's default project — keeps payment-hint runs in a
# dedicated BS bucket, separate from smoke / RA / Skonto / CX.
BS_PROJECT="GiniBankSDK-iOS-PaymentHints-4.5.0"

# ── Media files ────────────────────────────────────────────────────────────────
# Uploaded as PDFs so BrowserStack surfaces them in the Files.app "Custom_Files"
# folder, letting the tests select each fixture by its exact file name (see
# `tapFileFromBestAvailableSource`). JPEG uploads only reliably land in Photos —
# not selectable by name from the file picker.
INVOICE_NO_DUE_DATE_FILE="$SAMPLES_DIR/invoice_no_due_date.pdf"
INVOICE_FUTURE_DUE_FILE="$SAMPLES_DIR/invoice_future_due.pdf"

# ── Test suites ────────────────────────────────────────────────────────────────

ONLY_TESTING='[
  "GiniBankSDKExampleUITests/PaymentHintFlowUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media INVOICE_NO_DUE_DATE_URL "$INVOICE_NO_DUE_DATE_FILE" "invoice_no_due_date" "invoice_no_due_date.pdf"
upload_media INVOICE_FUTURE_DUE_URL "$INVOICE_FUTURE_DUE_FILE" "invoice_future_due" "invoice_future_due.pdf"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:                       $APP_URL"
echo "  test_suite_url:                $TEST_URL"
echo "  invoice_no_due_date.pdf:       $INVOICE_NO_DUE_DATE_URL"
echo "  invoice_future_due.pdf:        $INVOICE_FUTURE_DUE_URL"

# ── Trigger test run ───────────────────────────────────────────────────────────
echo ""
echo "Triggering BrowserStack test run..."
# --fail-with-body: exit non-zero on HTTP 4xx/5xx (print body first).
BUILD_RESPONSE=$(curl --fail-with-body -sS -u "$BS_USER:$BS_KEY" \
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
    \"resignApp\": \"true\",
    \"singleRunnerInvocation\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
