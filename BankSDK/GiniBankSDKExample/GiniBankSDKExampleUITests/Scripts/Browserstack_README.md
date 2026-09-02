# BrowserStack Scripts

Builds the `GiniBankSDKExample` app and test runner, uploads the relevant media files to BrowserStack, and triggers a focused test run.

The original monolithic script has been split into scenario-focused scripts that share a common helper library.

---

## Scripts overview

| Script | Tests | Media uploaded |
|---|---|---|
| `bs_run_cx_normal.sh` | `GiniCaptureFlowUITestsUsingBS`, `GiniCXFeatureFlagsUITests` | `Swift_AccNo_routing_DOLL.png`, `Photopayment_Invoice1.png`, `cx_invoice.png`, `cx_invoice.pdf` |
| `bs_run_cx_multipage.sh` | `GiniCXMultiPageUITests/testCXMultiPageInvoiceFlowTwoSeparatePNGPages` | `multi_page_invoice_CX_page1.png`, `multi_page_invoice_CX_page2.png` |
| `bs_run_cx_no_results.sh` | `GiniCXNoResultsUITests`, `GiniReturnAssistantScreenUITests/testReturnAssistantBS`, `GiniSkontoScreenUITests` | `cx_no_results_invoice.pdf`, `skonto_past.pdf`, `return_asistant.pdf` |
| `bs_run_ra.sh` | `GiniReturnAssistantScreenUITests/testReturnAssistantBS` | `return_asistant.pdf` |
| `bs_run_skonto.sh` | `GiniSkontoScreenUITests` | `skonto_past.pdf`, `skonot_valid.pdf` |
| `bs_run_credit_note.sh` | `GiniCreditNoteScreenUITests`, `GiniCreditNoteDynamicTypeUITests`, `GiniCreditNoteMockBackendFlagOnUITests`, `GiniCreditNoteMockBackendFlagOffUITests` | `credit_note.pdf`, `credit_note.png`, `skonto_past.pdf`, `test_image.pdf` |
| `bs_run_all.sh` | every scenario above — builds/uploads once, triggers one build per scenario, named `<scenario>_<release>` (e.g. `smoke_tests_4.5.0`, version taken from `BS_PROJECT`) | all media files |
| `bs_shared.sh` | — shared library, sourced by all `bs_run_*.sh` scripts | — |

> ⚠️ `bs_run_cx_no_results.sh` and `bs_run_skonto.sh` require `GiniCXNoResultsUITests` and `GiniSkontoScreenUITests` to be updated to use `tapFileWithNameFromBSCustomFiles()` instead of `tapFileWithName()` before they will pass on BrowserStack.

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
BS_USER="your_username" BS_KEY="your_access_key" ./bs_run_cx_normal.sh
```

---

## Usage

Run from the `Scripts/` directory:

```bash
# CX results — camera inject, gallery, PDF, feature flags
./bs_run_cx_normal.sh

# CX multi-page — two PNGs from Photos gallery
./bs_run_cx_multipage.sh

# CX no-results + Skonto (past) + Return Assistant
./bs_run_cx_no_results.sh

# Return Assistant only
./bs_run_ra.sh

# Skonto only (past + valid invoices)
./bs_run_skonto.sh

# Credit Note Warning — English run; add BS_LANGUAGE="de" for the German case
./bs_run_credit_note.sh
```

> ⚠️ `bs_run_credit_note.sh` needs `credit_note.pdf` and `credit_note.png` in
> `TestSamples/TestSamplesForBS/` — documents the Gini backend classifies as
> `businessDocType == "creditnote"`. The backend client-configuration flag
> `creditNoteHintEnabled` must also be enabled for the test client.

---

## What each run does

Every `bs_run_*.sh` script follows the same steps:

| Step | Description |
|---|---|
| 1 | Builds `GiniBankSDKExample` for testing using `xcodebuild build-for-testing` |
| 2 | Packages the app as an `.ipa` |
| 3 | Zips the UI test runner |
| 4 | Uploads scenario-specific media files to BrowserStack |
| 5 | Uploads the `.ipa` and test runner zip |
| 6 | Triggers the test run on `iPhone 17-26` and `iPhone 16-18` |
| 7 | Removes local `.ipa` and `.zip` artifacts |

Results appear in the **BrowserStack App Automate dashboard**.

---

## Execution strategy & scaling

Our account has **2 parallel-test licenses** (override per run with `BS_PARALLELS` when the plan changes), and every run covers the **standard 2-device pair** (`DEVICE_1`/`DEVICE_2` in `bs_shared.sh`). Every *session* consumes one license: an unsharded build uses one session **per device**, so each build takes exactly the full 2-license budget → **builds run strictly one at a time**.

Three BrowserStack facts drive the strategy:

1. **Queued jobs are canceled after 15 minutes of waiting.** Our scenario builds run 10–40 minutes, so any build waiting in the queue behind them dies. Never fire more sessions than licenses — `bs_run_all.sh` enforces this by polling its own builds and waiting for free licenses before each trigger (license-aware pacing).
2. **`singleRunnerInvocation: "true"`** (set in every script) runs all tests of a session in one runner process instead of one per test — saves ~30–60 s per test. Trade-off: the retry-failed-tests API doesn't work in this mode.
3. **Sharding gives no speedup on the current plan.** With 2 licenses and mandatory 2-device coverage there is no headroom: `deviceSelection: "any"` runs each shard on one random device (coverage lost), `"all"` needs shards × 2 licenses (overflow queues and dies). Sharding becomes useful once **licenses ≥ shards × devices** — i.e. a plan upgrade to 4+ parallels unlocks 2-way sharding. `trigger_scenario` in `bs_run_all.sh` already supports it (pass `"-"` as the test filter, a `shards` block as the 4th argument, shard count as the 5th).

### Scaling as the suite grows

| Lever | When | How |
|---|---|---|
| Raise `BS_PARALLELS` | Plan upgraded | `BS_PARALLELS=4 ./bs_run_all.sh` — pacing adapts; two builds then run side by side |
| Shard heavy scenarios | Plan ≥ shards × 2 devices (e.g. 4 parallels) | Convert the `trigger_scenario` call to a `shards` block with `deviceSelection: "all"` for full device coverage |
| Split a scenario | `uploadMedia` would exceed 5 files | Two builds, each with its own media |

Rule of thumb: keep each build under ~30 minutes; with sequential builds the full sweep is the sum of all builds, so the cheapest speedup is trimming slow tests, the structural one is more licenses.

---

## Media file routing on BrowserStack

| File type | Destination on device |
|---|---|
| `.png` / `.jpg` | Photos library (gallery) |
| `.pdf` | Files app → BrowserStack Custom_Files folder |

This determines which helper the test uses to access the file:
- **Gallery**: `uploadLatestPhotoFromGallery(offset:)` — picks by recency (`offset: 0` = most recent, `offset: 1` = second-to-last)
- **Custom_Files**: `tapFileWithNameFromBSCustomFiles(fileName:)` — picks by filename

---

## bs_run_cx_multipage.sh — upload order

Upload order matters because `uploadLatestPhotoFromGallery()` picks by recency:

| Upload order | File | Gallery position | Picked by |
|---|---|---|---|
| 1st | `multi_page_invoice_CX_page1.png` | Second-to-last | `uploadLatestPhotoFromGallery(offset: 1)` |
| 2nd | `multi_page_invoice_CX_page2.png` | Last (most recent) | `uploadLatestPhotoFromGallery(offset: 0)` |

---

## `only-testing` format

`only-testing` tells BrowserStack which tests to run inside the uploaded suite. Without it BrowserStack runs the entire bundle.

Format: `TestBundleName/TestClassName` or `TestBundleName/TestClassName/testMethodName`

| Value | What runs |
|---|---|
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS` | All tests in the class |
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS/testCXCaptureFlow` | Only `testCXCaptureFlow` |
| `GiniBankSDKExampleUITests/GiniCXMultiPageUITests/testCXMultiPageInvoiceFlowTwoSeparatePNGPages` | Only the two-PNG multipage test |

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
  -F "file=@/path/to/GiniBankSDKExample.ipa"
```

Copy the `app_url` from the response.

### Upload test suite

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
  -F "file=@/path/to/GiniBankSDKExampleUITests.zip"
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
    "only-testing": ["GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS"],
    "uploadMedia": ["MEDIA_URL"],
    "resignApp": "true"
  }'
```

For camera injection tests add:
```json
"enableCameraImageInjection": "true",
"cameraInjectionMedia": ["INJECTION_MEDIA_URL"]
```
