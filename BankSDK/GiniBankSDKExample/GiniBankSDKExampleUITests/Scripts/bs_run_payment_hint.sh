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
# PDFs are uploaded so BrowserStack surfaces them in Files.app "Custom_Files"; the
# R1–R13 tests select each by exact file name via `tapFileFromBestAvailableSource`.
# The JPEG variant of `invoice_future_due` is also uploaded — it lands in Photos and
# is the fixture the single gallery-smoke test (`…ViaGallery`) picks with
# `uploadLatestPhotoFromGallery(offset: 0)`.
INVOICE_NO_DUE_DATE_FILE="$SAMPLES_DIR/invoice_no_due_date.pdf"
INVOICE_FUTURE_DUE_FILE="$SAMPLES_DIR/invoice_future_due.pdf"
INVOICE_FUTURE_DUE_JPEG="$SAMPLES_DIR/invoice_future_due.jpeg"

# ── Test suites ────────────────────────────────────────────────────────────────

ONLY_TESTING='[
  "GiniBankSDKExampleUITests/PaymentHintFlowUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media INVOICE_NO_DUE_DATE_URL   "$INVOICE_NO_DUE_DATE_FILE" "invoice_no_due_date"      "invoice_no_due_date.pdf"
upload_media INVOICE_FUTURE_DUE_URL    "$INVOICE_FUTURE_DUE_FILE"  "invoice_future_due"       "invoice_future_due.pdf"
upload_media INVOICE_FUTURE_DUE_JPEG_URL "$INVOICE_FUTURE_DUE_JPEG" "invoice_future_due_jpeg" "invoice_future_due.jpeg"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:                       $APP_URL"
echo "  test_suite_url:                $TEST_URL"
echo "  invoice_no_due_date.pdf:       $INVOICE_NO_DUE_DATE_URL"
echo "  invoice_future_due.pdf:        $INVOICE_FUTURE_DUE_URL"
echo "  invoice_future_due.jpeg:       $INVOICE_FUTURE_DUE_JPEG_URL"

# ── Trigger test run ───────────────────────────────────────────────────────────
# Cover the latest iPhone on each iOS major we can run on BS today (18 / 26).
# BS auto-picks the minor version from its pool.
# iOS 17 excluded: the runner built with Xcode 26 links against a newer XCTest
# that references `_OBJC_CLASS_$_XCTCommandLineToolHelper`; iOS 17.x devices
# ship an older XCTest without that symbol, so the runner crashes at launch
# before any test executes. Re-add once we can build with an SDK compatible
# with iOS 17's XCTest.
DEVICE_IPHONE_17_IOS_26="iPhone 17-26"
DEVICE_IPHONE_16_IOS_18="iPhone 16-18"

echo ""
echo "Triggering BrowserStack test run..."
# --fail-with-body: exit non-zero on HTTP 4xx/5xx (print body first).
BUILD_RESPONSE=$(curl --fail-with-body -sS -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": [\"$DEVICE_IPHONE_17_IOS_26\", \"$DEVICE_IPHONE_16_IOS_18\"],
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": $ONLY_TESTING,
    \"project\": \"$BS_PROJECT\",
    \"buildName\": \"Payment Hints PP-3302\",
    \"uploadMedia\": [\"$INVOICE_NO_DUE_DATE_URL\", \"$INVOICE_FUTURE_DUE_URL\", \"$INVOICE_FUTURE_DUE_JPEG_URL\"],
    \"resignApp\": \"true\",
    \"singleRunnerInvocation\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
