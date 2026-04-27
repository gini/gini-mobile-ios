#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_cx_normal.sh
#
# Runs the CX normal scenario (results expected) on BrowserStack.
# Covers all four CX document entry points:
#
#   Camera injection → GiniCaptureFlowUITestsUsingBS/testCXCaptureFlow
#                      (Swift_AccNo_routing_DOLL.png via camera inject)
#   Gallery PNG      → GiniCaptureFlowUITestsUsingBS/testCXflowGalleryUpload
#                      (cx_invoice.png picked from Photos library)
#   Files PDF        → GiniCaptureFlowUITestsUsingBS/testCXCaptureFlowFileUpload
#                      (cx_invoice.pdf from Custom_Files)
#   Multi-page       → GiniCXMultiPageUITests/testCXMultiPageInvoiceFlowTwoSeparatePNGPages
#                      (multi_page_invoice_CX_page1.pdf from Custom_Files,
#                       multi_page_invoice_CX_page2.png from Photos library)
#
# Also runs:
#   GiniCXFeatureFlagsUITests (C1/C2) — verifies Skonto and RA are suppressed in CX mode
#   GiniCaptureFlowUITestsUsingBS/testPPCaptureFlow — SEPA camera injection smoke test
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
# Camera injection — must be in cameraInjectionMedia (not uploadMedia)
CX_CAMERA_FILE="$SAMPLES_DIR/Swift_AccNo_routing_DOLL.png"
PP_CAMERA_FILE="$SAMPLES_DIR/Photopayment_Invoice1.png"

# Gallery / Custom_Files uploads
CX_GALLERY_FILE="$SAMPLES_DIR/cx_invoice.png"          # → Photos library (gallery tests)
CX_PDF_FILE="$SAMPLES_DIR/cx_invoice.pdf"              # → Custom_Files  (Files-picker test)
SKONTO_PAST_FILE="$SAMPLES_DIR/skonto_past.pdf"        # → Custom_Files  (C1 feature flag test)
RA_FILE="$SAMPLES_DIR/return_asistant.pdf"             # → Custom_Files  (C2 feature flag test)

# ── Test suites ────────────────────────────────────────────────────────────────
ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS",
  "GiniBankSDKExampleUITests/GiniCXFeatureFlagsUITests",
  "GiniBankSDKExampleUITests/GiniProductTagSettingsUITests",
  "GiniBankSDKExampleUITests/GiniCXOnboardingUITests",
  "GiniBankSDKExampleUITests/GiniCXCameraUITests",
  "GiniBankSDKExampleUITests/GiniCXTransactionSummaryUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media CX_CAMERA_URL   "$CX_CAMERA_FILE"      "CXCameraInjection"       "Swift_AccNo_routing_DOLL.png (CX camera injection)"
upload_media PP_CAMERA_URL   "$PP_CAMERA_FILE"      "PPCameraInjection"       "Photopayment_Invoice1.png (PP camera injection)"
upload_media CX_GALLERY_URL  "$CX_GALLERY_FILE"     "CXGalleryImage"          "cx_invoice.png (gallery)"
upload_media CX_PDF_URL      "$CX_PDF_FILE"         "CXInvoicePDF"            "cx_invoice.pdf (Files picker)"
upload_media SKONTO_PAST_URL "$SKONTO_PAST_FILE"    "SkontoPastInvoice"       "skonto_past.pdf (C1 feature flag)"
upload_media RA_URL          "$RA_FILE"             "ReturnAssistantInvoice"  "return_asistant.pdf (C2 feature flag)"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:                $APP_URL"
echo "  test_suite_url:         $TEST_URL"
echo "  CX camera injection:    $CX_CAMERA_URL"
echo "  PP camera injection:    $PP_CAMERA_URL"
echo "  CX gallery:             $CX_GALLERY_URL"
echo "  CX PDF:                 $CX_PDF_URL"
echo "  Skonto past invoice:    $SKONTO_PAST_URL"
echo "  Return Assistant:       $RA_URL"

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
    \"buildName\": \"bs_run_cx_normal\",
    \"uploadMedia\": [\"$CX_GALLERY_URL\", \"$CX_PDF_URL\", \"$SKONTO_PAST_URL\", \"$RA_URL\"],
    \"enableCameraImageInjection\": \"true\",
    \"cameraInjectionMedia\": [\"$CX_CAMERA_URL\", \"$PP_CAMERA_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
