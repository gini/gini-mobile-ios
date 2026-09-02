#!/bin/bash
set -e

# ── Usage ─────────────────────────────────────────────────────────────────────
# ./bs_run_all.sh
#
# Runs EVERY BrowserStack UI test scenario in one go: builds the app and test
# runner once, uploads them and all media files once, then triggers one
# BrowserStack build per scenario (scenarios need separate builds because media
# routing differs — gallery tests rely on photo recency and camera-injection
# tests need their own media channel).
#
# Scenario builds triggered (buildName gets the release version appended, taken
# from BS_PROJECT — e.g. smoke_tests_4.5.0):
#   smoke_tests_<v>   — Main/Error/Capture/CameraAccess/Review screens
#   cx_normal_<v>     — CX capture flows, feature flags, product tag, onboarding,
#                       camera, transaction summary (camera injection enabled)
#   cx_multipage_<v>  — CX multi-page invoice (disabled — see below)
#   cx_no_results_<v> — CX no-results screen
#   ra_<v>            — Return Assistant
#   skonto_<v>        — Skonto (past + valid invoices)
#   credit_note_<v>   — Credit Note warning (real backend + mock-backend matrix)
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
# Build names carry the release version (from BS_PROJECT, e.g. GiniBankSDK-iOS-4.5.0
# → smoke_tests_4.5.0) so runs of different releases are distinguishable at a glance.
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
upload_media TEST_IMAGE_PNG_URL   "$SAMPLES_DIR/test_image.png"                  "TestImage"               "test_image.png (gallery)"
upload_media TEST_IMAGE_PDF_URL   "$SAMPLES_DIR/test_image.pdf"                  "TestImagePDF"            "test_image.pdf (Custom_Files)"
upload_media CX_CAMERA_URL        "$SAMPLES_DIR/Swift_AccNo_routing_DOLL.png"    "CXCameraInjection"       "Swift_AccNo_routing_DOLL.png (camera injection)"
upload_media PP_CAMERA_URL        "$SAMPLES_DIR/Photopayment_Invoice1.png"       "PPCameraInjection"       "Photopayment_Invoice1.png (camera injection)"
upload_media CX_GALLERY_URL       "$SAMPLES_DIR/cx_invoice.png"                  "CXGalleryImage"          "cx_invoice.png (gallery)"
upload_media CX_PDF_URL           "$SAMPLES_DIR/cx_invoice.pdf"                  "CXInvoicePDF"            "cx_invoice.pdf (Custom_Files)"
upload_media CX_NO_RESULTS_URL    "$SAMPLES_DIR/cx_no_results_invoice.pdf"       "CXNoResultsInvoice"      "cx_no_results_invoice.pdf (Custom_Files)"
# Multipage media parked with the all_cx_multipage scenario (see below):
# upload_media CX_MULTI_PDF_URL     "$SAMPLES_DIR/cx_invoice_multi_page.pdf"       "CXMultiPageInvoicePDF"   "cx_invoice_multi_page.pdf (Custom_Files)"
# upload_media CX_PAGE1_URL         "$SAMPLES_DIR/multi_page_invoice_CX_page1.png" "CXMultiPageInvoicePage1" "multi_page_invoice_CX_page1.png (gallery, first)"
# upload_media CX_PAGE2_URL         "$SAMPLES_DIR/multi_page_invoice_CX_page2.png" "CXMultiPageInvoicePage2" "multi_page_invoice_CX_page2.png (gallery, last)"
upload_media SKONTO_PAST_URL      "$SAMPLES_DIR/skonto_past.pdf"                 "SkontoPastInvoice"       "skonto_past.pdf (Custom_Files)"
upload_media SKONTO_VALID_URL     "$SAMPLES_DIR/skonto_valid.pdf"                "SkontoValidInvoice"      "skonto_valid.pdf (Custom_Files)"
upload_media SKONTO_GALLERY_URL   "$SAMPLES_DIR/skonto_valid.png"                "SkontoGalleryImage"      "skonto_valid.png (gallery)"
upload_media RA_URL               "$SAMPLES_DIR/return_asistant.pdf"             "ReturnAssistantInvoice"  "return_asistant.pdf (Custom_Files)"
upload_media RA_GALLERY_URL       "$SAMPLES_DIR/return_asistant.png"             "ReturnAssistantGallery"  "return_asistant.png (gallery)"
upload_media CREDIT_NOTE_PDF_URL  "$SAMPLES_DIR/credit_note.pdf"                 "CreditNotePDF"           "credit_note.pdf (Custom_Files)"
upload_media CREDIT_NOTE_PNG_URL  "$SAMPLES_DIR/credit_note.png"                 "CreditNotePNG"           "credit_note.png (gallery)"

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
    local i status
    for i in "${!ids[@]}"; do
        status=$(curl -s -u "$BS_USER:$BS_KEY" \
            "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/${ids[$i]}" \
            | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null || true)
        case "$status" in
            running|queued|"")
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
# Usage: trigger_scenario BUILD_NAME ONLY_TESTING_JSON UPLOAD_MEDIA_JSON [EXTRA_FIELDS] [SHARD_COUNT]
#   EXTRA_FIELDS — optional raw JSON fields appended to the request (must end with a comma)
#   SHARD_COUNT  — number of shards in EXTRA_FIELDS (default 1); used for license pacing
TRIGGERED_SUMMARY=""
trigger_scenario() {
    local build_name="$1"
    local only_testing="$2"
    local upload_media="$3"
    local extra_fields="${4:-}"
    local shard_count="${5:-1}"

    ## Pass "-" as ONLY_TESTING_JSON to omit the top-level only-testing filter —
    ## used when the scenario selects tests through a shards mapping instead.
    local selection_field=""
    if [ "$only_testing" != "-" ]; then
        selection_field="\"only-testing\": $only_testing,"
    fi

    ## Sessions this build consumes: shards use deviceSelection "any" (one session per
    ## shard); unsharded builds run once per device.
    local weight
    if [ "$shard_count" -gt 1 ]; then
        weight=$shard_count
    else
        weight=$DEVICE_COUNT
    fi

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
            $selection_field
            \"project\": \"$BS_PROJECT\",
            \"buildName\": \"$build_name\",
            \"buildTag\": \"$build_name\",
            \"timeout\": 7200,
            \"singleRunnerInvocation\": \"true\",
            $LANGUAGE_FIELD
            $extra_fields
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

# No sharding: with 2 parallel licenses and both devices covered per build,
# every build already consumes the full license budget (1 session per device).
# Sharding only pays off once licenses >= shards × devices — see the README.
trigger_scenario "smoke_tests_${RELEASE_VERSION}" '[
  "GiniBankSDKExampleUITests/GiniMainScreenUITests",
  "GiniBankSDKExampleUITests/GiniErrorScreenUITests",
  "GiniBankSDKExampleUITests/GiniCaptureScreenUITests",
  "GiniBankSDKExampleUITests/GiniCameraAccessScreenUITests",
  "GiniBankSDKExampleUITests/GiniReviewScreenUITests"
]' "[\"$TEST_IMAGE_PNG_URL\"]"

trigger_scenario "cx_normal_${RELEASE_VERSION}" '[
  "GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS",
  "GiniBankSDKExampleUITests/GiniCXFeatureFlagsUITests",
  "GiniBankSDKExampleUITests/GiniProductTagSettingsUITests",
  "GiniBankSDKExampleUITests/GiniCXOnboardingUITests",
  "GiniBankSDKExampleUITests/GiniCXCameraUITests",
  "GiniBankSDKExampleUITests/GiniCXTransactionSummaryUITests"
]' "[\"$CX_GALLERY_URL\", \"$CX_PDF_URL\", \"$SKONTO_PAST_URL\", \"$RA_URL\"]" \
   "\"enableCameraImageInjection\": \"true\", \"cameraInjectionMedia\": [\"$CX_CAMERA_URL\", \"$PP_CAMERA_URL\"],"

# all_cx_multipage is disabled: GiniCXMultiPageUITests currently contains only
# manualTest* methods (parked pending an Extractor bug fix — see the TODO in the
# class), so the only-testing filter matches nothing and the build reports
# "unknown". Re-enable once the tests are renamed back to test*.
# trigger_scenario "cx_multipage_${RELEASE_VERSION}" '[
#   "GiniBankSDKExampleUITests/GiniCXMultiPageUITests"
# ]' "[\"$CX_MULTI_PDF_URL\", \"$CX_PAGE1_URL\", \"$CX_PAGE2_URL\"]"

trigger_scenario "cx_no_results_${RELEASE_VERSION}" '[
  "GiniBankSDKExampleUITests/GiniCXNoResultsUITests"
]' "[\"$CX_NO_RESULTS_URL\"]"

trigger_scenario "ra_${RELEASE_VERSION}" '[
  "GiniBankSDKExampleUITests/GiniReturnAssistantScreenUITests"
]' "[\"$RA_URL\", \"$RA_GALLERY_URL\"]"

trigger_scenario "skonto_${RELEASE_VERSION}" '[
  "GiniBankSDKExampleUITests/GiniSkontoScreenUITests"
]' "[\"$SKONTO_PAST_URL\", \"$SKONTO_VALID_URL\", \"$SKONTO_GALLERY_URL\"]"

trigger_scenario "credit_note_${RELEASE_VERSION}" '[
  "GiniBankSDKExampleUITests/GiniCreditNoteScreenUITests",
  "GiniBankSDKExampleUITests/GiniCreditNoteDynamicTypeUITests",
  "GiniBankSDKExampleUITests/GiniCreditNoteMockBackendFlagOnUITests",
  "GiniBankSDKExampleUITests/GiniCreditNoteMockBackendFlagOffUITests"
]' "[\"$CREDIT_NOTE_PDF_URL\", \"$CREDIT_NOTE_PNG_URL\", \"$SKONTO_PAST_URL\", \"$TEST_IMAGE_PDF_URL\"]"

# ── Cleanup ────────────────────────────────────────────────────────────────────
bs_cleanup

echo ""
echo "Done! Scenario builds triggered:"
echo "$TRIGGERED_SUMMARY"
