# BrowserStack Scripts (Health SDK)

Builds the `GiniHealthSDKExample` app and test runner, uploads the smoke-suite
media files to BrowserStack, and triggers a focused test run.

The suite is the automatable subset of
[`/Health SDK Test Cases/SmokeTestSuite`](https://ginis.atlassian.net/projects/HEAL?selectedItem=com.atlassian.plugins.atlassian-connect-plugin:com.xpandit.plugins.xray__testing-board#!page=test-repository&selectedFolder=69bd6123bbbfe74841ee27ae)
in Xray (25 tests, HEAL-282 → HEAL-306). Scripts share a common helper
library (`bs_shared.sh`), mirroring the Bank SDK layout.

---

## Scripts overview

| Script | Tests | Media uploaded |
|---|---|---|
| `bs_run_smoke_journeys.sh` | end-to-end journey smoke methods: image import (HEAL-282), PDF import (HEAL-284), Invoice-list entry (HEAL-285), Orders-list entry (HEAL-286), GPC flow (HEAL-287), edit → propagate (HEAL-293), payment-status lifecycle (HEAL-304) | `testMedInvoice.pdf`, `testMedInvoice.png` |
| `bs_run_smoke_screens.sh` | per-screen smoke checks: Bank Selection sheet (HEAL-288, 289, 290), More Info screen (HEAL-291, 292), Payment Review Screen edges (HEAL-294, 295, 296, 297, 298, 299, 300, 301, 306), Install App bottom sheet (HEAL-303), Open With / Share with (HEAL-305) | `testMedInvoice.pdf`, `multi-invoice.pdf` |
| `bs_run_all.sh` | both scenarios above — builds/uploads once, triggers one build per scenario, named `<scenario>_<release>` (e.g. `smoke_journeys_6.1.0`, version taken from `BS_PROJECT`) | all media files |
| `bs_shared.sh` | — shared library, sourced by all `bs_run_*.sh` scripts | — |

### Not automated — kept manual

| HEAL | Why |
|---|---|
| HEAL-283 (QR scan via camera) | Camera-only entry — out of scope. |
| HEAL-302 (no-network default error) | BrowserStack cloud devices block WiFi toggling. |
| HEAL-304 (status after payment) | Truncates at bank-app deeplink — the full round-trip through a real banking app can't complete on a BS device. |

---

## Credentials

All scripts read credentials from environment variables with a fallback placeholder:

```bash
BS_USER="${BS_USER:-<your_browserstack_user_name>}"
BS_KEY="${BS_KEY:-<your_browserstack_access_key>}"
```

Set them in your shell session to avoid editing each script:

```bash
export BS_USER="your_username"
export BS_KEY="your_access_key"
```

Or pass them inline per run:

```bash
BS_USER="your_username" BS_KEY="your_access_key" ./bs_run_smoke_journeys.sh
```

---

## Usage

Run from the `Scripts/` directory:

```bash
# Journey smoke — end-to-end flows for every automatable entry point
./bs_run_smoke_journeys.sh

# Screens smoke — per-screen checks (Bank Selection, Review edges, etc.)
./bs_run_smoke_screens.sh

# Both in sequence with license-aware pacing (the release gate)
./bs_run_all.sh
```

Add `BS_LANGUAGE="de"` to run against the German locale.

---

## What each run does

Every `bs_run_*.sh` script follows the same steps:

| Step | Description |
|---|---|
| 1 | Builds `GiniHealthSDKExample` for testing using `xcodebuild build-for-testing` |
| 2 | Packages the app as an `.ipa` |
| 3 | Zips the UI test runner |
| 4 | Uploads scenario-specific media files to BrowserStack |
| 5 | Uploads the `.ipa` and test runner zip |
| 6 | Triggers the test run on `iPhone 17-26` and `iPhone 16-18` |
| 7 | Removes local `.ipa` and `.zip` artifacts |

Results appear in the **BrowserStack App Automate dashboard**.

---

## Execution strategy & scaling

Our account has **2 parallel-test licenses** (override per run with `BS_PARALLELS`
when the plan changes), and every run covers the **standard 2-device pair**
(`DEVICE_1`/`DEVICE_2` in `bs_shared.sh`). Every *session* consumes one license:
an unsharded build uses one session **per device**, so each build takes exactly
the full 2-license budget → **builds run strictly one at a time**.

Three BrowserStack facts drive the strategy:

1. **Queued jobs are canceled after 15 minutes of waiting.** Smoke builds run
   15–25 minutes, so any build waiting in the queue behind them dies. Never fire
   more sessions than licenses — `bs_run_all.sh` enforces this by polling its
   own builds and waiting for free licenses before each trigger (license-aware
   pacing).
2. **`singleRunnerInvocation: "true"`** (set in both smoke scripts) runs all
   tests of a session in one runner process instead of one per test — saves
   ~30–60 s per test. Both smoke scripts use class-level selection, so this
   mode is safe. (It is turned off automatically when `BS_TEST` runs a
   single method, because BrowserStack ignores method-level filters in
   single-runner mode.)
3. **Sharding gives no speedup on the current plan.** With 2 licenses and
   mandatory 2-device coverage there is no headroom. Sharding becomes useful
   once **licenses ≥ shards × devices** — i.e. a plan upgrade to 4+ parallels
   unlocks 2-way sharding.

### Scaling as the suite grows

| Lever | When | How |
|---|---|---|
| Raise `BS_PARALLELS` | Plan upgraded | `BS_PARALLELS=4 ./bs_run_all.sh` — pacing adapts; both scenarios then run side by side |
| Split a scenario | `uploadMedia` would exceed 5 files | Two builds, each with its own media |

Rule of thumb: keep each build under ~30 minutes; with sequential builds the
full sweep is the sum of all builds, so the cheapest speedup is trimming slow
tests, the structural one is more licenses.

---

## Media file routing on BrowserStack

| File type | Destination on device |
|---|---|
| `.png` / `.jpg` | Photos library (gallery) |
| `.pdf` | Files app → BrowserStack Custom_Files folder |

This determines which helper the test uses to access the file:
- **Gallery**: `uploadLatestPhotoFromGallery(offset:)` — picks by recency
  (`offset: 0` = most recent, `offset: 1` = second-to-last)
- **Custom_Files**: `tapFileWithNameFromBSCustomFiles(fileName:)` — picks by filename

The smoke suite only has one PNG (`testMedInvoice.png`) and never relies on
upload order; both scenarios upload at most 2 PDFs + 0–1 PNG.

---

## `only-testing` format

`only-testing` tells BrowserStack which tests to run inside the uploaded suite.
Without it BrowserStack runs the entire bundle.

Format: `TestBundleName/TestClassName` or `TestBundleName/TestClassName/testMethodName`

| Value | What runs |
|---|---|
| `GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests` | All journey tests |
| `GiniHealthSDKExampleUITests/GiniHealthSmokeScreensUITests/testHEAL296_InvalidIBAN` | Only the invalid-IBAN test |

---

## Manual debug steps

Useful for re-triggering a test run without rebuilding. Set credentials first:

```bash
export BS_USER="your_username"
export BS_KEY="your_access_key"
```

### Upload a media file

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@/path/to/file.png" \
  -F "custom_id=MyCustomId"
```

Copy the `media_url` from the response.

### Upload app IPA

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app" \
  -F "file=@/path/to/GiniHealthSDKExample.ipa"
```

Copy the `app_url` from the response.

### Upload test suite

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
  -F "file=@/path/to/GiniHealthSDKExampleUITests.zip"
```

Copy the `test_suite_url` from the response.

### Trigger test run

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d '{
    "devices": ["iPhone 17-26", "iPhone 16-18"],
    "app": "APP_URL",
    "testSuite": "TEST_SUITE_URL",
    "only-testing": ["GiniHealthSDKExampleUITests/GiniHealthSmokeJourneysUITests"],
    "uploadMedia": ["MEDIA_URL"],
    "resignApp": "true"
  }'
```
