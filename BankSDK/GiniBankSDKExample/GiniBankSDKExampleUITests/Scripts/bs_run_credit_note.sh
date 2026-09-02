#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_credit_note.sh
#
# Runs the Credit Note Warning scenario on BrowserStack:
#
#   credit_note.pdf — credit note document, picked from Files → Custom_Files
#                     (tests: testCreditNoteFlagIsEnabledByDefault,
#                      testCreditNoteWarningDialogIsDisplayedViaFiles,
#                      testCreditNoteWarningCannotBeDismissedByTappingOutside,
#                      testCreditNoteWarningCancelTransferClosesSDK,
#                      testCreditNoteWarningProceedAnywayShowsExtractions,
#                      testCreditNoteWarningNotShownWhenHintFlagDisabled,
#                      testInvoiceFlowUnaffectedWhenHintFlagDisabled,
#                      testCreditNoteWarningProceedAnywayAt200PercentFont)
#   credit_note.png — credit note image, lands in the Photos gallery
#                     (test: testCreditNoteWarningDialogIsDisplayedViaGallery —
#                      must be the most recently uploaded gallery media)
#   skonto_past.pdf — regular invoice used by the flag-off regression test
#
# Preconditions:
#   - The credit_note.pdf/.png fixtures in TestSamples/TestSamplesForBS/ must be
#     documents the backend classifies as businessDocType == "creditnote".
#   - The backend client configuration flag creditNoteHintEnabled is enabled
#     for the test client credentials.
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
#
# Optional: run the suite in German to cover the German test cases:
#   BS_LANGUAGE="de" ./bs_run_credit_note.sh
#
# Optional smoke-run overrides:
#   BS_DEVICE — run on a single device instead of the default pair, e.g.
#     BS_DEVICE="iPhone 16-18" ./bs_run_credit_note.sh
#   BS_TEST   — run a single test/class instead of all credit note classes, e.g.
#     BS_TEST="GiniBankSDKExampleUITests/GiniCreditNoteMockBackendFlagOnUITests/testWarningShownWhenSdkFlagOn" \
#       ./bs_run_credit_note.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
CREDIT_NOTE_PDF="$SAMPLES_DIR/credit_note.pdf"  # → Custom_Files
CREDIT_NOTE_PNG="$SAMPLES_DIR/credit_note.png"  # → Photos gallery
SKONTO_PAST_FILE="$SAMPLES_DIR/skonto_past.pdf" # → Custom_Files
TEST_IMAGE_FILE="$SAMPLES_DIR/test_image.pdf"   # → Custom_Files (flag matrix — mock backend, any PDF)

# ── Test suites ────────────────────────────────────────────────────────────────
# BS_TEST overrides the run with a single test/class ("Bundle/Class[/testMethod]").
if [ -n "${BS_TEST:-}" ]; then
    ONLY_TESTING="[\"$BS_TEST\"]"
else
    ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniCreditNoteScreenUITests",
  "GiniBankSDKExampleUITests/GiniCreditNoteDynamicTypeUITests",
  "GiniBankSDKExampleUITests/GiniCreditNoteMockBackendFlagOnUITests",
  "GiniBankSDKExampleUITests/GiniCreditNoteMockBackendFlagOffUITests"
]'
fi

# ── Optional device language ───────────────────────────────────────────────────
# When BS_LANGUAGE is set (e.g. "de"), the run covers that locale's Xray case.
LANGUAGE_FIELD=""
if [ -n "${BS_LANGUAGE:-}" ]; then
    LANGUAGE_FIELD="\"language\": \"$BS_LANGUAGE\","
fi

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media CREDIT_NOTE_PDF_URL "$CREDIT_NOTE_PDF"  "CreditNotePDF"     "credit_note.pdf (Files picker)"
upload_media CREDIT_NOTE_PNG_URL "$CREDIT_NOTE_PNG"  "CreditNotePNG"     "credit_note.png (Photos gallery)"
upload_media SKONTO_PAST_URL     "$SKONTO_PAST_FILE" "SkontoPastInvoice" "skonto_past.pdf (regular invoice)"
upload_media TEST_IMAGE_URL      "$TEST_IMAGE_FILE"  "TestImagePDF"      "test_image.pdf (flag matrix)"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:          $APP_URL"
echo "  test_suite_url:   $TEST_URL"
echo "  credit note PDF:  $CREDIT_NOTE_PDF_URL"
echo "  credit note PNG:  $CREDIT_NOTE_PNG_URL"
echo "  skonto invoice:   $SKONTO_PAST_URL"

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
    \"buildName\": \"bs_run_credit_note\",
    \"timeout\": 7200,
    \"singleRunnerInvocation\": \"true\",
    $LANGUAGE_FIELD
    \"uploadMedia\": [\"$CREDIT_NOTE_PDF_URL\", \"$CREDIT_NOTE_PNG_URL\", \"$SKONTO_PAST_URL\", \"$TEST_IMAGE_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
