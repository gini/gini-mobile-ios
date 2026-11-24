#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_onboarding.sh
#
# Runs the Xray folder "Onboarding Screens" (PP-3410…PP-3414, ticket PP-3884) on
# BrowserStack as ONE build — the whole GiniOnboardingScreenUITest class:
#
#   testOnboardingGetStartedButton                    — PP-3410 every page, then Get Started
#   testOnboardingSwipeForwardAndBackThroughAllPages  — PP-3411 swipe back and forth
#   testOnboardingSkipOnFirstPageOpensCamera          — PP-3412 Skip on the first page
#   testOnboardingSkipButton                          — PP-3413 Skip on the second page
#   testOnboardingSkipOnThirdPageOpensCamera          — PP-3414 Skip on the third page
#   testOnboardingSwipeAction, testOnboardingSwipePages, testOnboardingSkipButtonIsTopNavOnly
#                                                     — come along with the class
#
# The full case → test table is in specs/PP-3884-feature.md. The onboarding needs no
# media files, so nothing is uploaded besides the app and the test suite.
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
#
# Optional: BS_DEVICE (single device or comma-separated list), BS_LANGUAGE ("de" for
# the German page titles).
#
# Single-test mode: set BS_TEST to run exactly one test (or class) instead of the class:
#   BS_TEST="GiniBankSDKExampleUITests/GiniOnboardingScreenUITest/testOnboardingSkipOnFirstPageOpensCamera" ./bs_run_onboarding.sh
# ⚠️ BrowserStack matches only-testing METHOD entries by NAME PREFIX — the method
# name must be no other test's prefix. Single runner is disabled in this mode.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Optional device language ───────────────────────────────────────────────────
LANGUAGE_FIELD=""
if [ -n "${BS_LANGUAGE:-}" ]; then
    LANGUAGE_FIELD="\"language\": \"$BS_LANGUAGE\","
fi

# ── Test selection ─────────────────────────────────────────────────────────────
ONLY_TESTING='["GiniBankSDKExampleUITests/GiniOnboardingScreenUITest"]'
SINGLE_RUNNER="true"
if [ -n "${BS_TEST:-}" ]; then
    ONLY_TESTING="[\"$BS_TEST\"]"
    ## Method-level entry possible in BS_TEST — keep the filter honored.
    SINGLE_RUNNER="false"
fi

# ── Build & package ────────────────────────────────────────────────────────────
bs_build

# ── Upload app & test suite ────────────────────────────────────────────────────
echo "Uploading app and test suite..."
bs_upload_app_and_suite

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
    \"buildName\": \"onboarding\",
    \"timeout\": 7200,
    \"singleRunnerInvocation\": \"$SINGLE_RUNNER\",
    $LANGUAGE_FIELD
    \"resignApp\": \"true\"
  }")
echo "Build response: $BUILD_RESPONSE"

BUILD_ID=$(echo "$BUILD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('build_id',''))" 2>/dev/null || true)
if [ -z "$BUILD_ID" ]; then
    echo "ERROR: build trigger failed — see response above"
    exit 1
fi
echo "  https://app-automate.browserstack.com/dashboard/v2/builds/$BUILD_ID"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Check the \"$BS_PROJECT\" project in the BrowserStack App Automate dashboard."
