#!/bin/bash
set -e

# ── Usage ────────────────────────────────────────────────────────────────────────
# ./bs_build_and_upload.sh [MEDIA_FILENAME]
#
# MEDIA_FILENAME  File inside TestSamples/TestSamplesForBS/ used for uploadMedia.
#                 Defaults to Photopayment_Invoice1.png if not provided.
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
# If not set, the script falls back to the default credentials.
#
# Examples:
#   ./bs_build_and_upload.sh
#   ./bs_build_and_upload.sh Photopayment_Invoice1.png
#   BS_USER="myuser" BS_KEY="mykey" ./bs_build_and_upload.sh
#   BS_USER="myuser" BS_KEY="mykey" ./bs_build_and_upload.sh Photopayment_Invoice2.png

# ── Configuration ────────────────────────────────────────────────────────────────
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

MEDIA_FILENAME="${1:-Photopayment_Invoice1.png}"
MEDIA_FILE_PNG="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/$MEDIA_FILENAME"

# Both files are always uploaded — each test picks its injection file by name via injectImage(imageName:)
PP_CAPTURE_MEDIA_FILE="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/Photopayment_Invoice1.png"
CX_CAPTURE_MEDIA_FILE="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/Swift_AccNo_routing_DOLL.png"
PP_UPLOAD_MEDIA_FILE_PDF="$SCRIPT_DIR/../TestSamples/TestSamplesForBS/return_asistant.pdf"

DEVICE_1="iPhone 15-17"
# Runs all three tests in GiniCaptureFlowUITestsUsingBS
<!-- TEST_IDENTIFIER="GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS/testCXCaptureFlow"--->
TEST_IDENTIFIER="GiniBankSDKExampleUITests/GiniReturnAssistantScreenUITests/testReturnAssistant"

# ── Validate media files ─────────────────────────────────────────────────────────
if [ ! -f "$MEDIA_FILE_PNG" ]; then
  echo "Upload media file not found: $MEDIA_FILE_PNG"
  echo "   Place the file inside TestSamples/TestSamplesForBS/ or pass a different filename as the first argument."
  exit 1
fi
echo "Using upload media file:              $MEDIA_FILE_PNG"

if [ ! -f "$PP_CAPTURE_MEDIA_FILE" ]; then
  echo "Camera injection file not found: $PP_CAPTURE_MEDIA_FILE"
  exit 1
fi
echo "Using PP capture injection file:      $PP_CAPTURE_MEDIA_FILE"

if [ ! -f "$CX_CAPTURE_MEDIA_FILE" ]; then
  echo "ERROR: Camera injection file not found: $CX_CAPTURE_MEDIA_FILE"
  exit 1
fi
echo "Using CX capture injection file:      $CX_CAPTURE_MEDIA_FILE"

<!-- PDF Upload-->

if [ ! -f "$PP_UPLOAD_MEDIA_FILE_PDF" ]; then
  echo "ERROR: PDF upload file not found: $PP_UPLOAD_MEDIA_FILE_PDF"
  exit 1
fi
echo "Using upload PDF file: $PP_UPLOAD_MEDIA_FILE_PDF"


# ── Create signing override xcconfig (applies to all targets incl. extensions) ──
mkdir -p "$DERIVED_DATA"
cat > "$SIGNING_CONFIG" <<'XCCONFIG'
CODE_SIGN_STYLE = Automatic
CODE_SIGN_IDENTITY = Apple Development
DEVELOPMENT_TEAM = JA825X8F7Z
PROVISIONING_PROFILE_SPECIFIER =
PROVISIONING_PROFILE =
XCCONFIG

# ── Step 1: Build for testing ───────────────────────────────────────────────────
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

# ── Step 2: Package app as IPA ──────────────────────────────────────────────────
echo "[2/5] Packaging app as IPA..."
PAYLOAD_DIR="$DERIVED_DATA/Payload"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -r "$BUILD_PRODUCTS/GiniBankSDKExample.app" "$PAYLOAD_DIR/"
cd "$DERIVED_DATA"
zip -r "$IPA_OUTPUT" Payload -q
rm -rf "$PAYLOAD_DIR"
echo "IPA saved: $IPA_OUTPUT"

# ── Step 3: Zip test runner ─────────────────────────────────────────────────────
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

# ── Step 4: Upload to BrowserStack ─────────────────────────────────────────────
echo "[4/5] Uploading to BrowserStack..."

echo "  Uploading upload media (gallery upload file)..."
MEDIA_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$MEDIA_FILE_PNG" \
  -F "custom_id=UploadMedia")
echo "  Upload media response: $MEDIA_RESPONSE"
MEDIA_PNG_URL=$(echo "$MEDIA_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$MEDIA_PNG_URL" ]; then echo "ERROR: Failed to get media_url — check response above"; exit 1; fi

echo "  Uploading PP capture injection media (Photopayment_Invoice1.png)..."
PP_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$PP_CAPTURE_MEDIA_FILE" \
  -F "custom_id=PPCaptureInjection")
echo "  PP capture injection response: $PP_RESPONSE"
PP_INJECTION_URL=$(echo "$PP_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$PP_INJECTION_URL" ]; then echo "ERROR: Failed to get PP injection media_url — check response above"; exit 1; fi

echo "  Uploading CX capture injection media (Swift_AccNo_routing_DOLL.jpg)..."
CX_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$CX_CAPTURE_MEDIA_FILE" \
  -F "custom_id=CXCaptureInjection")
echo "  CX capture injection response: $CX_RESPONSE"
CX_INJECTION_URL=$(echo "$CX_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$CX_INJECTION_URL" ]; then echo "ERROR: Failed to get CX injection media_url — check response above"; exit 1; fi

<!--PDF upload-->
echo "  Uploading PDF file (return_assistant.pdf)..."
UPLOAD_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@$PP_UPLOAD_MEDIA_FILE_PDF" \
  -F "custom_id=UploadPDFInjection")
echo "  Upload PDF response: $UPLOAD_RESPONSE"
UPLOAD_URL=$(echo "$UPLOAD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
if [ -z "$UPLOAD_URL" ]; then echo "ERROR: Failed to get PDF media_url — check response above"; exit 1; fi

<!--end pdf upload-->

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
echo "  media_url (gallery upload):    $MEDIA_PNG_URL"
echo "  media_url (PP injection):      $PP_INJECTION_URL"
echo "  media_url (CX injection):      $CX_INJECTION_URL"
echo "  media_url (PDF Injection:      $UPLOAD_URL"

# ── Step 5: Trigger test run ────────────────────────────────────────────────────
echo "[5/5] Triggering test build on BrowserStack..."
echo ""
echo "  Running command:"
echo "  curl -u \"$BS_USER:$BS_KEY\" \\"
echo "    -X POST \"https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build\" \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{"
echo "      \"devices\": [\"$DEVICE_1\"],"
echo "      \"app\": \"$APP_URL\","
echo "      \"testSuite\": \"$TEST_URL\","
echo "      \"only-testing\": [\"$TEST_IDENTIFIER\"],"
echo "      \"uploadMedia\": [\"$MEDIA_PNG_URL\", \"$PP_INJECTION_URL\", \"$CX_INJECTION_URL\", \"$UPLOAD_URL\"],"
echo "      \"resignApp\": \"true\","
echo "      \"enableCameraImageInjection\": \"true\","
echo "      \"cameraInjectionMedia\": [\"$PP_INJECTION_URL\", \"$CX_INJECTION_URL\"]"
echo "    }'"
echo ""
BUILD_RESPONSE=$(curl -s -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": [\"$DEVICE_1\"],
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": [\"$TEST_IDENTIFIER\"],
    \"uploadMedia\": [\"$MEDIA_PNG_URL\", \"$PP_INJECTION_URL\", \"$CX_INJECTION_URL\", \"$UPLOAD_URL\"],
    \"resignApp\": \"true\",
    \"enableCameraImageInjection\": \"true\",
    \"cameraInjectionMedia\": [\"$PP_INJECTION_URL\", \"$CX_INJECTION_URL\"]
  }")
echo "Build response: $BUILD_RESPONSE"
echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
