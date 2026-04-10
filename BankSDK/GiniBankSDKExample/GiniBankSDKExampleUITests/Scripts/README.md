# bs_build_and_upload.sh

Builds the `GiniBankSDKExample` app and test runner, uploads them to BrowserStack along with media files, and triggers a test run. By default runs `testCXCaptureFlow`; change `TEST_IDENTIFIER` in the script to run the full class or a different test. 

---

## Parameters

### Positional arguments

| Argument | Default | Description |
|---|---|---|
| `$1` — `MEDIA_FILENAME` | `Photopayment_Invoice1.png` | Filename inside `TestSamples/TestSamplesForBS/` used for `uploadMedia` (gallery upload flow) |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `BS_USER` | `<your_browserstack_user_name>` | BrowserStack username |
| `BS_KEY` | `<your_browserstack_access_key>` | BrowserStack access key |

### Fixed (not parameterised)

| Value | Description |
|---|---|
| `Photopayment_Invoice1.png` | Camera injection file for `testPPCaptureFlow` (`PPCaptureInjection`) |
| `Swift_AccNo_routing_DOLL.png` | Camera injection file for `testCXCaptureFlow` and `testCXflowGalleryUpload` (`CXCaptureInjection`) |
| `iPhone 15-17` | Target BrowserStack device |
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS/testCXCaptureFlow` | Default test run by the script (single test). Change to class level to run all three. |

Both camera injection files are always uploaded. BrowserStack matches each file to the test that calls `injectImage(imageName:)` with the matching filename.

---

## Output files

Both are written inside the `BSScripts/` folder:

- `GiniBankSDKExample.ipa` — packaged app
- `GiniBankSDKExampleUITests.zip` — zipped test runner

---

## Usage examples

### Run with all defaults
```bash
cd BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/BSScripts
./bs_build_and_upload.sh
```

### Run with a custom upload media file
```bash
./bs_build_and_upload.sh Photopayment_Invoice2.png
```

### Run with custom BrowserStack credentials
```bash
BS_USER="my_bs_username" BS_KEY="my_bs_key" ./bs_build_and_upload.sh
```

### Run with custom credentials and a custom upload media file
```bash
BS_USER="my_bs_username" BS_KEY="my_bs_key" ./bs_build_and_upload.sh Photopayment_Invoice2.png
```

### Export credentials for the session, then run multiple times
```bash
export BS_USER="my_bs_username"
export BS_KEY="my_bs_key"

./bs_build_and_upload.sh Photopayment_Invoice1.png
./bs_build_and_upload.sh Photopayment_Invoice2.png
```

---

## What the script does

| Step | Description |
|---|---|
| 1 | Validates that all three media files exist before starting the build |
| 2 | Builds `GiniBankSDKExample` for testing using `xcodebuild` |
| 3 | Packages the app as an `.ipa` |
| 4 | Zips the UI test runner |
| 5 | Uploads `MEDIA_FILENAME` to BrowserStack as `uploadMedia` (gallery upload) |
| 6 | Uploads `Photopayment_Invoice1.png` to BrowserStack as `PPCaptureInjection` (camera injection for `testPPCaptureFlow`) |
| 7 | Uploads `Swift_AccNo_routing_DOLL.png` to BrowserStack as `CXCaptureInjection` (camera injection for `testCXCaptureFlow` and `testCXflowGalleryUpload`) |
| 8 | Uploads the `.ipa` and test runner zip |
| 9 | Triggers `testCXCaptureFlow` on BrowserStack by default with `enableCameraImageInjection: true` (change `TEST_IDENTIFIER` in the script to run the full class or a different test) |

---

## Manual Debug Steps

Use these commands to upload and trigger tests individually from Terminal - useful when debugging a single step without re-running the full script.

Set your credentials first:
```bash
export BS_USER="your_browserstack_username"
export BS_KEY="your_browserstack_access_key"
```

---

### Step 1 - Upload media file (gallery upload)

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@/path/to/Photopayment_Invoice1.png" \
  -F "custom_id=UploadMedia"
```

Copy the `media_url` from the response (e.g. `media://abc123...`). You will need it in Step 6.

---

### Step 2 - Upload PP camera injection file

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@/path/to/Photopayment_Invoice1.png" \
  -F "custom_id=PPCaptureInjection"
```

Copy the `media_url`. You will need it in Step 6.

---

### Step 3 - Upload CX camera injection file

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/upload-media" \
  -F "file=@/path/to/Swift_AccNo_routing_DOLL.png" \
  -F "custom_id=CXCaptureInjection"
```

Copy the `media_url`. You will need it in Step 6.

---

### Step 4 - Upload app IPA

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/app" \
  -F "file=@/path/to/GiniBankSDKExample.ipa"
```

Copy the `app_url` from the response (e.g. `bs://abc123...`). You will need it in Step 6.

> The script outputs the IPA to `BSScripts/GiniBankSDKExample.ipa`.

---

### Step 5 - Upload test suite

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/test-suite" \
  -F "file=@/path/to/GiniBankSDKExampleUITests.zip"
```

Copy the `test_suite_url` from the response (e.g. `bs://def456...`). You will need it in Step 6.

> The script outputs the zip to `BSScripts/GiniBankSDKExampleUITests.zip`.

---

### Step 6 - Trigger test build

Replace `APP_URL`, `TEST_SUITE_URL`, `MEDIA_URL`, `PP_INJECTION_URL`, and `CX_INJECTION_URL` with the values copied from the steps above.

```bash
curl -u "$BS_USER:$BS_KEY" \
  -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/build" \
  -H "Content-Type: application/json" \
  -d '{
    "devices": ["iPhone 15-17"],
    "app": "APP_URL",
    "testSuite": "TEST_SUITE_URL",
    "only-testing": ["GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS"],
    "uploadMedia": ["MEDIA_URL", "PP_INJECTION_URL", "CX_INJECTION_URL"],
    "resignApp": "true",
    "enableCameraImageInjection": "true",
    "cameraInjectionMedia": ["PP_INJECTION_URL", "CX_INJECTION_URL"]
  }'
```

> **Note:** If the build fails when `uploadMedia` is included, try removing that key - the build command without `uploadMedia` runs successfully.

---

### `only-testing` explained

`only-testing` tells BrowserStack which tests to run inside the uploaded test suite. Without it, BrowserStack runs every test in the bundle.

The value follows the format: `TestBundleName/TestClassName` or `TestBundleName/TestClassName/testMethodName`

| Value | What runs |
|---|---|
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS` | All three tests in the class |
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS/testPPCaptureFlow` | Only `testPPCaptureFlow` |
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS/testCXCaptureFlow` | Only `testCXCaptureFlow` |
| `GiniBankSDKExampleUITests/GiniCaptureFlowUITestsUsingBS/testCXflowGalleryUpload` | Only `testCXflowGalleryUpload` |

Multiple entries can be passed in the array to run a subset of tests.
