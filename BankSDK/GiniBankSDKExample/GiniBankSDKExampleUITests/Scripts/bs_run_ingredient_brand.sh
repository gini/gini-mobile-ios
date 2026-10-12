#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_ingredient_brand.sh
#
# Builds, uploads, and runs the Ingredient Brand UI automation on BrowserStack.
# Suite covered:
#
#   GiniBankSDKExampleUITests/IngredientBrandFlowUITests
#     — flag off, flag on ("Analysis"), unknown value, dark theme.
#
# All tests activate `UITestMockBackend` via launch arguments, so no real Gini
# API call is made. The `test_image` PDF fixture is uploaded so the SDK's Files
# picker has a document to import — its contents are ignored by the mock.
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# Override bs_shared.sh's default project — keeps ingredient-brand runs in a
# dedicated BS bucket, separate from smoke / RA / Skonto / CX / payment hint.
# Version comes from SDK_VERSION set in bs_shared.sh so a single release bump
# updates both. Mirrors the pattern established by bs_run_payment_hint.sh.
BS_PROJECT="GiniBankSDK-iOS-IngredientBrand-$SDK_VERSION"

# ── Media files ────────────────────────────────────────────────────────────────
# PDFs are uploaded so BrowserStack surfaces them in Files.app "Custom_Files";
# every mock-backend test selects one by exact file name.
TEST_IMAGE_FILE="$SAMPLES_DIR/test_image.pdf"

# ── Test suites ────────────────────────────────────────────────────────────────

ONLY_TESTING='[
  "GiniBankSDKExampleUITests/IngredientBrandFlowUITests"
]'

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload media ───────────────────────────────────────────────────────────────
echo "Uploading media files..."
upload_media TEST_IMAGE_URL "$TEST_IMAGE_FILE" "test_image" "test_image.pdf"

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

echo ""
echo "Uploaded URLs:"
echo "  app_url:        $APP_URL"
echo "  test_suite_url: $TEST_URL"
echo "  test_image.pdf: $TEST_IMAGE_URL"

# ── Trigger test run ───────────────────────────────────────────────────────────
echo ""
echo "Triggering BrowserStack test run..."
BUILD_RESPONSE=$(curl --fail-with-body -sS -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d "{
    \"devices\": $DEVICES_JSON,
    \"app\": \"$APP_URL\",
    \"testSuite\": \"$TEST_URL\",
    \"only-testing\": $ONLY_TESTING,
    \"project\": \"$BS_PROJECT\",
    \"buildName\": \"Ingredient Brand PP-3477\",
    \"uploadMedia\": [\"$TEST_IMAGE_URL\"],
    \"resignApp\": \"true\",
    \"singleRunnerInvocation\": \"true\",
    \"timeout\": 7200
  }")
echo "Build response: $BUILD_RESPONSE"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check BrowserStack App Automate dashboard for results."
