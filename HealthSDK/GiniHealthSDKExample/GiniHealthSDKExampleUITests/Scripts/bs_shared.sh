#!/bin/bash
# bs_shared.sh — Shared build, upload, and media-upload helpers for the Health SDK.
#
# Source this file from each bs_run_*.sh script — do not execute directly.
#
#   SCRIPT_DIR must be set in the calling script before sourcing, e.g.:
#     SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#     source "$SCRIPT_DIR/bs_shared.sh"
#
# Provides:
#   Variables : BS_USER, BS_KEY, BS_PROJECT, REPO_ROOT, WORKSPACE, SCHEME, DERIVED_DATA,
#               BUILD_PRODUCTS, SIGNING_CONFIG, SAMPLES_DIR, IPA_OUTPUT,
#               TEST_SUITE_OUTPUT, DEVICE_1, DEVICE_2
#   Functions : bs_curl, upload_media, bs_build, bs_upload_app_and_suite, bs_cleanup

# ── HTTP helper ───────────────────────────────────────────────────────────────
# curl wrapper for BrowserStack API calls: fails on HTTP 4xx/5xx while keeping the
# error body (--fail-with-body), reports transport errors on stderr (-S), and never
# aborts the calling script under `set -e` — every call site checks the parsed
# response and reports its own actionable error.
bs_curl() {
    curl -sS --fail-with-body "$@" || true
}

# ── Credentials ───────────────────────────────────────────────────────────────
# Override via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
BS_USER="${BS_USER:-<your_browserstack_user_name>}"
BS_KEY="${BS_KEY:-<your_browserstack_access_key>}"

# ── Paths ─────────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
WORKSPACE="$REPO_ROOT/GiniMobile.xcworkspace"
SCHEME="GiniHealthSDKExample"
DERIVED_DATA="$REPO_ROOT/HealthSDK/GiniHealthSDKExample/build"
BUILD_PRODUCTS="$DERIVED_DATA/Build/Products/Debug-iphoneos"
SIGNING_CONFIG="$DERIVED_DATA/BrowserStackSigning.xcconfig"
SAMPLES_DIR="$SCRIPT_DIR/../TestSamples/TestSamplesForBS"

SCRIPT_NAME="$(basename "$0" .sh)"
case "$SCRIPT_NAME" in
    bs_run_smoke_journeys) BUILD_LABEL="SmokeJourneys" ;;
    bs_run_smoke_screens)  BUILD_LABEL="SmokeScreens" ;;
    *)                     BUILD_LABEL="$SCRIPT_NAME" ;;
esac
IPA_OUTPUT="$SCRIPT_DIR/${BUILD_LABEL}.ipa"
TEST_SUITE_OUTPUT="$SCRIPT_DIR/${BUILD_LABEL}-Tests.zip"

# ── Devices ───────────────────────────────────────────────────────────────────
# Health SDK deployment target is iOS 17+, but iOS 17 devices on BrowserStack
# are blocked by the Xcode 26-built runner referencing symbols iOS 17's XCTest
# doesn't export (same cause as Bank SDK's iPhone 15-17 exclusion). Device pair
# matches Bank for a single smoke-ops contract across both SDKs.
DEVICE_1="iPhone 17-26"
DEVICE_2="iPhone 16-18"

# BS_DEVICE overrides the default pair with one device or a comma-separated list,
# e.g. BS_DEVICE="iPhone 17-26" or BS_DEVICE="iPhone 17-26,iPhone 16-18".
# Scripts use $DEVICES_JSON in the build request; $DEVICE_COUNT feeds license pacing.
if [ -n "${BS_DEVICE:-}" ]; then
    DEVICES_JSON=$(python3 -c "import sys, json; print(json.dumps([d.strip() for d in sys.argv[1].split(',') if d.strip()]))" "$BS_DEVICE")
    DEVICE_COUNT=$(python3 -c "import sys; print(len([d for d in sys.argv[1].split(',') if d.strip()]))" "$BS_DEVICE")
else
    DEVICES_JSON="[\"$DEVICE_1\", \"$DEVICE_2\"]"
    DEVICE_COUNT=2
fi

# ── BrowserStack project ──────────────────────────────────────────────────────
# Convention: GiniHealthSDK-iOS-<release version>. Bump SDK_VERSION here once
# per release — the default BS_PROJECT below picks it up.
# Override per run via the BS_PROJECT environment variable.
SDK_VERSION="6.1.0"
BS_PROJECT="${BS_PROJECT:-GiniHealthSDK-iOS-$SDK_VERSION}"

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
    response=$(bs_curl -u "$BS_USER:$BS_KEY" \
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
    # Entitlements are stripped on purpose. The host app's
    # `GiniHealthSDKExample.entitlements` claims the `iCloud.net.gini.healthsdk.example`
    # container (CloudDocuments + CloudKit + ubiquity-kvstore). BrowserStack re-signs
    # every uploaded IPA with its enterprise cert (`"resignApp": "true"` in the build
    # trigger); that cert cannot fulfil the iCloud capability, so SpringBoard refuses
    # to start the app on the device and the test runner reports "Application does
    # not have a process ID" after XCTest's 60-second launch timeout. The smoke suite
    # never exercises iCloud, so a BS build with no entitlements is functionally
    # identical to a signed one for the smoke scenarios — but it launches.
    #
    # Automatic signing is used rather than a manual AdHoc profile because the
    # workspace's SPM dependencies (nanopb via Firebase) reject manually-specified
    # provisioning profiles at build time with "<target> does not support
    # provisioning profiles". xcconfig has no per-target scoping syntax, so the only
    # way to combine manual signing on the host app with automatic signing on the
    # SPM targets is a pbxproj surgery that permanently alters what every developer
    # sees in Xcode locally — not worth it for a BrowserStack-only workaround.
    #
    # Keep local-app development on the signed entitlements file; this override only
    # applies to the BS build (xcodebuild picks the xcconfig up for this invocation).
    cat > "$SIGNING_CONFIG" <<'XCCONFIG'
CODE_SIGN_STYLE = Automatic
CODE_SIGN_IDENTITY = Apple Development
DEVELOPMENT_TEAM = JA825X8F7Z
PROVISIONING_PROFILE_SPECIFIER =
PROVISIONING_PROFILE =
CODE_SIGN_ENTITLEMENTS =
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
    cp -r "$BUILD_PRODUCTS/GiniHealthSDKExample.app" "$payload_dir/"
    pushd "$DERIVED_DATA" > /dev/null
    zip -r "$IPA_OUTPUT" Payload -q
    popd > /dev/null
    rm -rf "$payload_dir"
    echo "IPA saved: $IPA_OUTPUT"

    echo "[3/3] Zipping test runner..."
    local runner_app
    runner_app=$(find "$DERIVED_DATA/Build/Products" -name "GiniHealthSDKExampleUITests-Runner.app" \
        ! -path "*simulator*" | head -1)
    if [ -z "$runner_app" ]; then
        echo "ERROR: GiniHealthSDKExampleUITests-Runner.app not found"
        exit 1
    fi
    pushd "$(dirname "$runner_app")" > /dev/null
    zip -r "$TEST_SUITE_OUTPUT" "GiniHealthSDKExampleUITests-Runner.app" -q
    popd > /dev/null
    echo "Test suite saved: $TEST_SUITE_OUTPUT"
}

# ── bs_upload_app_and_suite ───────────────────────────────────────────────────
# Uploads the built IPA and test runner zip to BrowserStack.
# Sets APP_URL and TEST_URL in the calling scope.
bs_upload_app_and_suite() {
    echo "  Uploading app IPA..."
    local app_response
    app_response=$(bs_curl -u "$BS_USER:$BS_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app" \
        -F "file=@$IPA_OUTPUT")
    echo "  App response: $app_response"
    APP_URL=$(echo "$app_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['app_url'])" 2>/dev/null || true)
    if [ -z "$APP_URL" ]; then echo "ERROR: Failed to get app_url — check response above"; exit 1; fi

    echo "  Uploading test suite..."
    local test_response
    test_response=$(bs_curl -u "$BS_USER:$BS_KEY" \
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
