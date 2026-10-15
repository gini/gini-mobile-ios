#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_all.sh
#
# Runs every Health SDK BrowserStack smoke scenario in one go: builds the app
# and test runner once, uploads them and all media files once, then triggers one
# BrowserStack build per scenario. Scenario builds triggered (buildName gets the
# release version appended, taken from BS_PROJECT — e.g. smoke_journeys_6.1.0):
#
#   smoke_journeys_<v> — curated journey smoke tests (HEAL-282, 284-287, 293, 304)
#   smoke_screens_<v>  — per-screen smoke tests (HEAL-288-301, 303, 305, 306)
#
# BrowserStack credentials can be overridden via environment variables:
#   export BS_USER="your_username"
#   export BS_KEY="your_access_key"
#
# Optional:
#   BS_DEVICE    — run every scenario on a single device instead of the default pair
#   BS_LANGUAGE  — set the device language for all scenarios (e.g. "de")
#   BS_PARALLELS — the account's parallel-test license count (default 2). The script
#                  paces build triggers so active sessions never exceed it: queued
#                  BrowserStack jobs are CANCELED after 15 minutes of waiting, so
#                  relying on the queue silently kills long builds. Raise this when
#                  the plan grows — nothing else needs to change.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=bs_shared.sh
source "$SCRIPT_DIR/bs_shared.sh"

# ── Parallel licenses ──────────────────────────────────────────────────────────
BS_PARALLELS="${BS_PARALLELS:-2}"

# ── Release suffix for build names ─────────────────────────────────────────────
# Build names carry the release version (from BS_PROJECT, e.g. GiniHealthSDK-iOS-6.1.0
# → smoke_journeys_6.1.0) so runs of different releases are distinguishable at a glance.
RELEASE_VERSION="${BS_PROJECT##*-}"

# ── Optional device language ───────────────────────────────────────────────────
LANGUAGE_FIELD=""
if [ -n "${BS_LANGUAGE:-}" ]; then
    LANGUAGE_FIELD="\"language\": \"$BS_LANGUAGE\","
fi

# ── Build & package (once) ─────────────────────────────────────────────────────
bs_build

# ── Upload media (each file once, deduplicated across scenarios) ───────────────
echo "Uploading media files..."
upload_media MED_INVOICE_PDF_URL   "$SAMPLES_DIR/testMedInvoice.pdf" "MedInvoicePDF"   "testMedInvoice.pdf (Custom_Files)"
upload_media MED_INVOICE_PNG_URL   "$SAMPLES_DIR/testMedInvoice.png" "MedInvoicePNG"   "testMedInvoice.png (Photos gallery)"
upload_media MULTI_INVOICE_PDF_URL "$SAMPLES_DIR/multi-invoice.pdf"  "MultiInvoicePDF" "multi-invoice.pdf (Custom_Files)"

# ── Upload test suite (once) ───────────────────────────────────────────────────
# The app IPA is uploaded per scenario instead (see trigger_scenario): the dashboard
# derives the build display name from the uploaded IPA filename, so each scenario
# uploads the same binary under its own name to stay distinguishable.
echo "Uploading test suite..."
TEST_RESPONSE=$(bs_curl -u "$BS_USER:$BS_KEY" \
    -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
    -F "file=@$TEST_SUITE_OUTPUT")
echo "  Test suite response: $TEST_RESPONSE"
TEST_URL=$(echo "$TEST_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['test_suite_url'])" 2>/dev/null || true)
if [ -z "$TEST_URL" ]; then echo "ERROR: Failed to get test_suite_url — check response above"; exit 1; fi

echo ""
echo "Uploaded:"
echo "  test_suite_url: $TEST_URL"

# ── License-aware pacing ───────────────────────────────────────────────────────
# Every session (shard × device) consumes one parallel license. Sessions beyond the
# plan's limit are queued by BrowserStack and CANCELED after 15 minutes of waiting —
# far shorter than a scenario build's runtime — so the script never over-commits:
# before each trigger it waits until enough licenses are free, polling the status of
# builds it started earlier.
ACTIVE_IDS=()      # build_ids currently believed to be running
ACTIVE_WEIGHTS=()  # parallel sessions each of those builds consumes
ACTIVE_TOTAL=0

## Re-polls all tracked builds and drops the finished ones from the active set.
refresh_active_builds() {
    local ids=("${ACTIVE_IDS[@]}")
    local weights=("${ACTIVE_WEIGHTS[@]}")
    ACTIVE_IDS=()
    ACTIVE_WEIGHTS=()
    ACTIVE_TOTAL=0
    local i status attempt
    for i in "${!ids[@]}"; do
        ## An unreadable status must not count as "still running" — an auth or API
        ## error would otherwise keep the license wait loop spinning forever. Retry
        ## a few times for transient failures, then fail fast.
        status=""
        for attempt in 1 2 3; do
            status=$(bs_curl -u "$BS_USER:$BS_KEY" \
                "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/${ids[$i]}" \
                | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null || true)
            [ -n "$status" ] && break
            sleep 10
        done
        if [ -z "$status" ]; then
            echo "ERROR: could not read status of build ${ids[$i]} after 3 attempts — check BS_USER/BS_KEY and the BrowserStack API." >&2
            exit 1
        fi
        case "$status" in
            running|queued)
                ACTIVE_IDS+=("${ids[$i]}")
                ACTIVE_WEIGHTS+=("${weights[$i]}")
                ACTIVE_TOTAL=$((ACTIVE_TOTAL + weights[i]))
                ;;
            *)
                echo "  Build ${ids[$i]} finished with status: $status"
                ;;
        esac
    done
}

## Blocks until at least `needed` licenses are free (BS_PARALLELS - active sessions).
wait_for_capacity() {
    local needed="$1"
    ## A build needing more sessions than the license count can never be satisfied —
    ## without this guard the loop below would sleep forever.
    if [ "$needed" -gt "$BS_PARALLELS" ]; then
        echo "ERROR: scenario needs $needed parallel sessions but BS_PARALLELS=$BS_PARALLELS." >&2
        echo "       Raise BS_PARALLELS or reduce the device list (BS_DEVICE)." >&2
        exit 1
    fi
    while true; do
        refresh_active_builds
        if [ $((ACTIVE_TOTAL + needed)) -le "$BS_PARALLELS" ]; then
            return
        fi
        echo "  Waiting for licenses: $ACTIVE_TOTAL/$BS_PARALLELS in use, need $needed — recheck in 60s..."
        sleep 60
    done
}

# ── trigger_scenario ───────────────────────────────────────────────────────────
# Triggers one BrowserStack build and records its build_id for the end summary.
# Usage: trigger_scenario BUILD_NAME ONLY_TESTING_JSON UPLOAD_MEDIA_JSON [SINGLE_RUNNER]
#   SINGLE_RUNNER — singleRunnerInvocation value (default "true"). MUST be "false"
#                   for scenarios whose only-testing selection is method-level:
#                   BrowserStack ignores method filters in single-runner mode and
#                   runs the whole class.
TRIGGERED_SUMMARY=""
trigger_scenario() {
    local build_name="$1"
    local only_testing="$2"
    local upload_media="$3"
    local single_runner="${4:-true}"

    local weight=$DEVICE_COUNT

    echo ""
    echo "Triggering $build_name ($weight session(s))..."
    wait_for_capacity "$weight"

    ## Upload the shared IPA under the scenario's filename — the dashboard names the
    ## build after the uploaded IPA, so this is what makes builds distinguishable.
    local scenario_ipa="$SCRIPT_DIR/${build_name}.ipa"
    cp "$IPA_OUTPUT" "$scenario_ipa"
    local app_response
    app_response=$(bs_curl -u "$BS_USER:$BS_KEY" \
        -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app" \
        -F "file=@$scenario_ipa")
    rm -f "$scenario_ipa"
    local scenario_app_url
    scenario_app_url=$(echo "$app_response" | python3 -c "import sys,json; print(json.load(sys.stdin)['app_url'])" 2>/dev/null || true)
    if [ -z "$scenario_app_url" ]; then
        echo "  App upload failed for $build_name: $app_response"
        TRIGGERED_SUMMARY="$TRIGGERED_SUMMARY
  $build_name
    TRIGGER FAILED — app upload error, see response above"
        return
    fi

    ## BrowserStack rejects new builds when the account's queue is full; retry a few
    ## times so scenarios triggered late are not silently dropped.
    local attempts=0
    local build_id=""
    local response=""
    while [ $attempts -lt 8 ]; do
        response=$(bs_curl -u "$BS_USER:$BS_KEY" \
          -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
          -H "Content-Type: application/json" \
          -d "{
            \"devices\": $DEVICES_JSON,
            \"app\": \"$scenario_app_url\",
            \"testSuite\": \"$TEST_URL\",
            \"only-testing\": $only_testing,
            \"project\": \"$BS_PROJECT\",
            \"buildName\": \"$build_name\",
            \"buildTag\": \"$build_name\",
            \"timeout\": 7200,
            \"singleRunnerInvocation\": \"$single_runner\",
            $LANGUAGE_FIELD
            \"uploadMedia\": $upload_media,
            \"resignApp\": \"true\"
          }")
        build_id=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('build_id',''))" 2>/dev/null || true)
        if [ -n "$build_id" ]; then
            break
        fi
        attempts=$((attempts + 1))
        echo "  Attempt $attempts failed (queue full or error): $response"
        echo "  Retrying in 120s..."
        sleep 120
    done
    echo "  Response: $response"

    if [ -n "$build_id" ]; then
        ACTIVE_IDS+=("$build_id")
        ACTIVE_WEIGHTS+=("$weight")
        ACTIVE_TOTAL=$((ACTIVE_TOTAL + weight))
        TRIGGERED_SUMMARY="$TRIGGERED_SUMMARY
  $build_name
    https://app-automate.browserstack.com/dashboard/v2/builds/$build_id"
    else
        TRIGGERED_SUMMARY="$TRIGGERED_SUMMARY
  $build_name
    TRIGGER FAILED after $attempts attempts — see responses above"
    fi
}

# ── Scenario builds ────────────────────────────────────────────────────────────

trigger_scenario "smoke_journeys_${RELEASE_VERSION}" '[
  "GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests"
]' "[\"$MED_INVOICE_PDF_URL\", \"$MED_INVOICE_PNG_URL\"]"

trigger_scenario "smoke_screens_${RELEASE_VERSION}" '[
  "GiniHealthSDKExampleUITests/GiniHealthSmokeScreensUITests"
]' "[\"$MED_INVOICE_PDF_URL\", \"$MULTI_INVOICE_PDF_URL\"]"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Scenario builds triggered:"
echo "$TRIGGERED_SUMMARY"
