#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_cx_multipage.sh
#
# Runs the CX multi-page invoice test on BrowserStack.
#
#   GiniCXMultiPageUITests/testCXMultiPageInvoiceFlowTwoSeparatePNGPages
#     — uploads two PNG pages to the Photos library and picks each via
#       uploadLatestPhotoFromGallery():
#         page 1 (multi_page_invoice_CX_page1.png) uploaded FIRST
#         page 2 (multi_page_invoice_CX_page2.png) uploaded SECOND → most recent → picked first
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Media files ────────────────────────────────────────────────────────────────
# Upload order matters: page1 first, page2 second (most recent = picked first by gallery)
CX_MULTI_PAGE1_FILE="$SAMPLES_DIR/multi_page_invoice_CX_page1.png" # → Photos library (uploaded first)
CX_MULTI_PAGE2_FILE="$SAMPLES_DIR/multi_page_invoice_CX_page2.png" # → Photos library (uploaded last = most recent)

# ── Test suites ────────────────────────────────────────────────────────────────
ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniCXMultiPageUITests/testCXMultiPageInvoiceFlowTwoSeparatePNGPages"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
# page1 must be uploaded BEFORE page2 so page2 is the most recent photo in the gallery
upload_media CX_PAGE1_URL "$CX_MULTI_PAGE1_FILE" "CXMultiPageInvoicePage1" "multi_page_invoice_CX_page1.png (uploaded first)"
upload_media CX_PAGE2_URL "$CX_MULTI_PAGE2_FILE" "CXMultiPageInvoicePage2" "multi_page_invoice_CX_page2.png (uploaded last = most recent)"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:               $APP_URL"
echo "  test_suite_url:        $TEST_URL"
echo "  CX multi-page page 1:  $CX_PAGE1_URL"
echo "  CX multi-page page 2:  $CX_PAGE2_URL"

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
    \"uploadMedia\": [\"$CX_PAGE1_URL\", \"$CX_PAGE2_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
