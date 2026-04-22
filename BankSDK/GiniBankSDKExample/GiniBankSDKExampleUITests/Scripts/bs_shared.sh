#!/bin/bash
# bs_shared.sh — Shared build, upload, and media-upload helpers.
#
# Source this file from each bs_run_*.sh script — do not execute directly.
#
#   SCRIPT_DIR must be set in the calling script before sourcing, e.g.:
#     SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#     source "$SCRIPT_DIR/bs_shared.sh"
#
# Provides:
#   Variables : BS_USER, BS_KEY, REPO_ROOT, WORKSPACE, SCHEME, DERIVED_DATA,
#               BUILD_PRODUCTS, SIGNING_CONFIG, SAMPLES_DIR, IPA_OUTPUT,
#               TEST_SUITE_OUTPUT, DEVICE_1, DEVICE_2
#   Functions : upload_media, bs_build, bs_upload_app_and_suite, bs_cleanup

# ── Credentials ───────────────────────────────────────────────────────────────
# Override via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
BS_USER="${BS_USER:-<your_browserstack_user_name>}"
BS_KEY="${BS_KEY:-<your_browserstack_access_key>}"

# ── Paths ─────────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
WORKSPACE="$REPO_ROOT/GiniMobile.xcworkspace"
SCHEME="GiniBankSDKExample"
DERIVED_DATA="$REPO_ROOT/BankSDK/GiniBankSDKExample/build"
BUILD_PRODUCTS="$DERIVED_DATA/Build/Products/Debug-iphoneos"
SIGNING_CONFIG="$DERIVED_DATA/BrowserStackSigning.xcconfig"
SAMPLES_DIR="$SCRIPT_DIR/../TestSamples/TestSamplesForBS"

IPA_OUTPUT="$SCRIPT_DIR/GiniBankSDKExample.ipa"
TEST_SUITE_OUTPUT="$SCRIPT_DIR/GiniBankSDKExampleUITests.zip"

# ── Devices ───────────────────────────────────────────────────────────────────
DEVICE_1="iPhone 16-18"
DEVICE_2="iPhone 13 Pro Max-18"

# ── upload_media ──────────────────────────────────────────────────────────────
# Uploads a media file to BrowserStack and stores the returned media_url in a
# named bash variable.
#
# Usage: upload_media VAR_NAME FILE_PATH CUSTOM_ID [LABEL]
#   VAR_NAME  — variable to receive the media_url
#   FILE_PATH — absolute path to the local file
#   CUSTOM_ID — BrowserStack custom_id tag for the uploaded asset
#   LABEL     — optional human-readable label (defaults to CUSTOM_ID)
upload_media() {
    local var_name="$1"
    local file_path="$2"
    local custom_id="$3"
    local label="${4:-$custom_id}"

    if [ ! -f "$file_path" ]; then
        echo "ERROR: Media file not found: $file_path"
        exit 1
    fi
    echo "  Uploading $label..."
    local response
    response=$(curl -s -u "$BS_USER:$BS_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
        -F "file=@$file_path" \
        -F "custom_id=$custom_id")
    echo "  Response: $response"
    local url
    url=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || true)
    if [ -z "$url" ]; then
        echo "ERROR: Failed to get media_url for $label — check response above"
        exit 1
    fi
    printf -v "$var_name" '%s' "$url"
}

# ── bs_build ──────────────────────────────────────────────────────────────────
# Builds the app for testing, packages it as an IPA, and zips the test runner.
# Outputs: IPA at $IPA_OUTPUT, test runner at $TEST_SUITE_OUTPUT.
bs_build() {
    mkdir -p "$DERIVED_DATA"
    cat > "$SIGNING_CONFIG" <<'XCCONFIG'
CODE_SIGN_STYLE = Automatic
CODE_SIGN_IDENTITY = Apple Development
DEVELOPMENT_TEAM = JA825X8F7Z
PROVISIONING_PROFILE_SPECIFIER =
PROVISIONING_PROFILE =
XCCONFIG

    echo "[1/3] Building for testing..."
    xcodebuild build-for-testing \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration Debug \
        -destination "generic/platform=iOS" \
        -derivedDataPath "$DERIVED_DATA" \
        -xcconfig "$SIGNING_CONFIG" \
        -allowProvisioningUpdates
    echo "Build complete"

    echo "[2/3] Packaging app as IPA..."
    local payload_dir="$DERIVED_DATA/Payload"
    rm -rf "$payload_dir"
    mkdir -p "$payload_dir"
    cp -r "$BUILD_PRODUCTS/GiniBankSDKExample.app" "$payload_dir/"
    pushd "$DERIVED_DATA" > /dev/null
    zip -r "$IPA_OUTPUT" Payload -q
    popd > /dev/null
    rm -rf "$payload_dir"
    echo "IPA saved: $IPA_OUTPUT"

    echo "[3/3] Zipping test runner..."
    local runner_app
    runner_app=$(find "$DERIVED_DATA/Build/Products" -name "GiniBankSDKExampleUITests-Runner.app" \
        ! -path "*simulator*" | head -1)
    if [ -z "$runner_app" ]; then
        echo "ERROR: GiniBankSDKExampleUITests-Runner.app not found"
        exit 1
    fi
    pushd "$(dirname "$runner_app")" > /dev/null
    zip -r "$TEST_SUITE_OUTPUT" "GiniBankSDKExampleUITests-Runner.app" -q
    popd > /dev/null
    echo "Test suite saved: $TEST_SUITE_OUTPUT"
}

# ── bs_upload_app_and_suite ───────────────────────────────────────────────────
# Uploads the built IPA and test runner zip to BrowserStack.
# Sets APP_URL and TEST_URL in the calling scope.
bs_upload_app_and_suite() {
    echo "  Uploading app IPA..."
    local app_response
    app_response=$(curl -s -u "$BS_USER:$BS_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app" \
        -F "file=@$IPA_OUTPUT")
    echo "  App response: $app_response"
    APP_URL=$(echo "$app_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['app_url'])" 2>/dev/null || true)
    if [ -z "$APP_URL" ]; then echo "ERROR: Failed to get app_url — check response above"; exit 1; fi

    echo "  Uploading test suite..."
    local test_response
    test_response=$(curl -s -u "$BS_USER:$BS_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
        -F "file=@$TEST_SUITE_OUTPUT")
    echo "  Test suite response: $test_response"
    TEST_URL=$(echo "$test_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['test_suite_url'])" 2>/dev/null || true)
    if [ -z "$TEST_URL" ]; then echo "ERROR: Failed to get test_suite_url — check response above"; exit 1; fi
}

# ── bs_cleanup ────────────────────────────────────────────────────────────────
# Removes IPA and test runner zip artifacts after upload.
bs_cleanup() {
    echo "Cleaning up build artifacts..."
    rm -f "$IPA_OUTPUT" "$TEST_SUITE_OUTPUT"
    echo "Removed: $IPA_OUTPUT"
    echo "Removed: $TEST_SUITE_OUTPUT"
}
