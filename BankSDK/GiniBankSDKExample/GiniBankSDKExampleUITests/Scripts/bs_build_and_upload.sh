#!/bin/bash
set -e

# ── Usage ────────────────────────────────────────────────────────────────────
# ./bs_build_and_upload_clean.sh
#
# Cleaned-up version of bs_build_and_upload.sh (original kept as reference).
# For new runs prefer the focused scripts in this directory:
#   bs_run_cx_normal.sh      — CX results (camera, gallery, PDF, multi-page)
#   bs_run_cx_no_results.sh  — CX no-results + Skonto (past) + RA
#   bs_run_ra.sh             — Return Assistant standalone
#   bs_run_skonto.sh         — Skonto standalone (past + valid invoices)
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

# ── Configuration ────────────────────────────────────────────────────────────
BS_USER="${BS_USER:-<your_browserstack_user_name>}"
BS_KEY="${BS_KEY:-<your_browserstack_access_key>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

WORKSPACE="$REPO_ROOT/GiniMobile.xcworkspace"
SCHEME="GiniBankSDKExample"
DERIVED_DATA="$REPO_ROOT/BankSDK/GiniBankSDKExample/build"
BUILD_PRODUCTS="$DERIVED_DATA/Build/Products/Debug-iphoneos"
SIGNING_CONFIG="$DERIVED_DATA/BrowserStackSigning.xcconfig"

IPA_OUTPUT="$SCRIPT_DIR/GiniBankSDKExample.ipa"
TEST_SUITE_OUTPUT="$SCRIPT_DIR/GiniBankSDKExampleUITests.zip"

# cx_invoice.png is searched by name in the gallery via uploadLatestPhotoFromGallery(photoName:).
CX_GALLERY_MEDIA_FILE="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/cx_invoice.png"
# cx_invoice.pdf appears in Custom_Files for the Files-picker based CX test.
CX_PDF_FILE="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/cx_invoice.pdf"
# G2 test (testCXMultiPageInvoiceFlowTwoSeparatePNGPages):
# - Page 1: uploaded to Photos library — uploadLatestPhotoFromGallery() picks it.
# - Page 2: uploaded to BrowserStack — PNG files land in Custom_Files, searchable by name.
CX_MULTI_PAGE1_FILE="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/multi_page_invoice_CX_page1.pdf"
CX_MULTI_PAGE2_FILE="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/multi_page_invoice_CX_page2.png"

DEVICE_1="iPhone 16-18"
# DEVICE_2="iPhone 13 Pro Max-18"

ONLY_TESTING='[
  "GiniBankSDKExampleUITests/GiniCXMultiPageUITests/testCXMultiPageInvoiceFlowTwoSeparatePNGPages"
]'

# ── Validate media files ─────────────────────────────────────────────────────
if [ ! -f "$CX_GALLERY_MEDIA_FILE" ]; then
  echo "ERROR: CX gallery image not found: $CX_GALLERY_MEDIA_FILE"
  exit 1
fi
echo "Using CX gallery image:               $CX_GALLERY_MEDIA_FILE"

if [ ! -f "$CX_PDF_FILE" ]; then
  echo "ERROR: CX PDF file not found: $CX_PDF_FILE"
  exit 1
fi
echo "Using CX PDF file:                    $CX_PDF_FILE"

if [ ! -f "$CX_MULTI_PAGE1_FILE" ]; then
  echo "ERROR: CX multipage page 1 not found: $CX_MULTI_PAGE1_FILE"
  exit 1
fi
echo "Using CX multipage page 1:            $CX_MULTI_PAGE1_FILE"

if [ ! -f "$CX_MULTI_PAGE2_FILE" ]; then
  echo "ERROR: CX multipage page 2 not found: $CX_MULTI_PAGE2_FILE"
  exit 1
fi
echo "Using CX multipage page 2:            $CX_MULTI_PAGE2_FILE"

# ── Create signing override xcconfig (applies to all targets incl. extensions) ──
mkdir -p "$DERIVED_DATA"
cat > "$SIGNING_CONFIG" <<'XCCONFIG'
CODE_SIGN_STYLE = Automatic
CODE_SIGN_IDENTITY = Apple Development
DEVELOPMENT_TEAM = JA825X8F7Z
PROVISIONING_PROFILE_SPECIFIER =
PROVISIONING_PROFILE =
XCCONFIG

# ── Step 1: Build for testing ────────────────────────────────────────────────
echo "[1/5] Building for testing..."
xcodebuild build-for-testing \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_DATA" \
  -xcconfig "$SIGNING_CONFIG" \
  -allowProvisioningUpdates
echo "Build complete"

# ── Step 2: Package app as IPA ───────────────────────────────────────────────
echo "[2/5] Packaging app as IPA..."
PAYLOAD_DIR="$DERIVED_DATA/Payload"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -r "$BUILD_PRODUCTS/GiniBankSDKExample.app" "$PAYLOAD_DIR/"
cd "$DERIVED_DATA"
zip -r "$IPA_OUTPUT" Payload -q
rm -rf "$PAYLOAD_DIR"
echo "IPA saved: $IPA_OUTPUT"

# ── Step 3: Zip test runner ──────────────────────────────────────────────────
echo "[3/5] Zipping test runner..."
RUNNER_APP=$(find "$DERIVED_DATA/Build/Products" -name "GiniBankSDKExampleUITests-Runner.app" \
  ! -path "*simulator*" | head -1)
if [ -z "$RUNNER_APP" ]; then
  echo "ERROR: GiniBankSDKExampleUITests-Runner.app not found"
  exit 1
fi
pushd "$(dirname "$RUNNER_APP")" > /dev/null
zip -r "$TEST_SUITE_OUTPUT" "GiniBankSDKExampleUITests-Runner.app" -q
popd > /dev/null
echo "Test suite saved: $TEST_SUITE_OUTPUT"

# ── Step 4: Upload to BrowserStack ──────────────────────────────────────────
echo "[4/5] Uploading to BrowserStack..."

echo "  Uploading CX gallery image (cx_invoice.png)..."
CX_GALLERY_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$CX_GALLERY_MEDIA_FILE" \
  -F "custom_id=CXGalleryImage")
echo "  CX gallery image response: $CX_GALLERY_RESPONSE"
CX_GALLERY_URL=$(echo "$CX_GALLERY_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$CX_GALLERY_URL" ]; then echo "ERROR: Failed to get CX gallery media_url — check response above"; exit 1; fi

echo "  Uploading CX PDF file (cx_invoice.pdf)..."
CX_PDF_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$CX_PDF_FILE" \
  -F "custom_id=CXInvoicePDF")
echo "  CX PDF response: $CX_PDF_RESPONSE"
CX_PDF_URL=$(echo "$CX_PDF_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$CX_PDF_URL" ]; then echo "ERROR: Failed to get CX PDF media_url — check response above"; exit 1; fi

echo "  Uploading CX multipage page 1 (multi_page_invoice_CX_page1.png)..."
CX_MULTI_PAGE1_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$CX_MULTI_PAGE1_FILE" \
  -F "custom_id=CXMultiPageInvoicePage1")
echo "  CX multipage page 1 response: $CX_MULTI_PAGE1_RESPONSE"
CX_MULTI_PAGE1_URL=$(echo "$CX_MULTI_PAGE1_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$CX_MULTI_PAGE1_URL" ]; then echo "ERROR: Failed to get CX multipage page 1 media_url — check response above"; exit 1; fi

echo "  Uploading CX multipage page 2 (multi_page_invoice_CX_page2.png)..."
CX_MULTI_PAGE2_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$CX_MULTI_PAGE2_FILE" \
  -F "custom_id=CXMultiPageInvoicePage2")
echo "  CX multipage page 2 response: $CX_MULTI_PAGE2_RESPONSE"
CX_MULTI_PAGE2_URL=$(echo "$CX_MULTI_PAGE2_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$CX_MULTI_PAGE2_URL" ]; then echo "ERROR: Failed to get CX multipage page 2 media_url — check response above"; exit 1; fi

echo "  Uploading app IPA..."
APP_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app" \
  -F "file=@$IPA_OUTPUT")
echo "  App response: $APP_RESPONSE"
APP_URL=$(echo "$APP_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['app_url'])" 2>/dev/null || true)
if [ -z "$APP_URL" ]; then echo "ERROR: Failed to get app_url — check response above"; exit 1; fi

echo "  Uploading test suite..."
TEST_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
  -F "file=@$TEST_SUITE_OUTPUT")
echo "  Test suite response: $TEST_RESPONSE"
TEST_URL=$(echo "$TEST_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['test_suite_url'])" 2>/dev/null || true)
if [ -z "$TEST_URL" ]; then echo "ERROR: Failed to get test_suite_url — check response above"; exit 1; fi

echo "All files uploaded"
echo "  app_url:                       $APP_URL"
echo "  test_suite_url:                $TEST_URL"
echo "  media_url (CX gallery):        $CX_GALLERY_URL"
echo "  media_url (CX PDF):            $CX_PDF_URL"
echo "  media_url (CX multi-page 1):   $CX_MULTI_PAGE1_URL"
echo "  media_url (CX multi-page 2):   $CX_MULTI_PAGE2_URL"

# ── Step 5: Trigger test run ─────────────────────────────────────────────────
echo "[5/5] Triggering test build on BrowserStack..."
#\"devices\": [\"$DEVICE_1\", \"$DEVICE_2\"],
BUILD_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": [\"$DEVICE_1\"],
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": $ONLY_TESTING,
    \"uploadMedia\": [\"$CX_GALLERY_URL\", \"$CX_PDF_URL\", \"$CX_MULTI_PAGE1_URL\", \"$CX_MULTI_PAGE2_URL\"],
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"
echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."

# ── Cleanup ──────────────────────────────────────────────────────────────────
echo "Cleaning up build artifacts..."
rm -f "$IPA_OUTPUT" "$TEST_SUITE_OUTPUT"
echo "Removed: $IPA_OUTPUT"
echo "Removed: $TEST_SUITE_OUTPUT"
