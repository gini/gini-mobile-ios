# PP-3477: iOS UI Automation on BrowserStack for the Ingredient Brand feature

Status: implementation ready — pending regression sweep (AC #3) + 3 consecutive nightly runs (AC #4)
Ticket: https://ginis.atlassian.net/browse/PP-3477
Test cases (Xray): https://ginis.atlassian.net/browse/PP-3476
Test Set: https://ginis.atlassian.net/browse/PP-3740
Test Plan: https://ginis.atlassian.net/browse/PP-3785
Test Execution: https://ginis.atlassian.net/browse/PP-3787
Epic: PP-2568 (Ingredient Brand in Photo Payment SDK — phase 1)
SDK implementation spec (branded loading indicator): [PP-3511-feature.md](./PP-3511-feature.md)

## Problem

The Ingredient Brand feature — the "Powered by Gini" badge and the
animated branded loading indicator on `AnalysisViewController` — shipped
via PP-2570 (badge) and PP-3511 (branded indicator). Both are gated by the
backend's `ClientConfiguration.ingredientBrandScreens` list, delivered
through the `/configurations` REST endpoint and cached in
`GiniCaptureUserDefaultsStorage.ingredientBrandScreens`.

Today the feature is covered only by SDK-side unit tests
(`CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/AnalysisViewControllerTests.swift`
+ the brand-view tests under
`GiniComponents/Utilities/GiniUtilites/Tests/GiniUtilitesTests/`). Nothing
exercises the actual capture-and-analysis flow end-to-end on real
devices, so a regression that only reproduces on iOS 18/26 hardware — say
the branded indicator disappearing across a rotation, the badge failing
to hide when a capture-suggestions banner appears, or an integrator's
custom loading indicator winning when the flag is on — would only surface
at manual regression time.

PP-3477 closes that gap: add XCUITest cases in `GiniBankSDKExampleUITests`
that drive the Photopayment flow to the Analysis screen, override the
backend's `ingredientBrandScreens` value per-test, and assert on the
badge, branded indicator, and their interactions with other Analysis-screen
UI. Tests run on the same BrowserStack device matrix as the existing
smoke and Payment-Hint suites (DEVICE_1 `iPhone 17-26`, DEVICE_2
`iPhone 16-18`), driven by a new `bs_run_ingredient_brand.sh` script that
lands its builds in a dedicated `GiniBankSDK-iOS-IngredientBrand-4.6.0`
BrowserStack project bucket — mirroring PP-3302's per-feature bucket
convention.

**Data-driving strategy — differs from PP-3302.** Payment Hint drove
show/no-show cases by overriding `paymentDueHintThresholdDays` at
runtime, an SDK knob that already existed on `GiniBankConfiguration`.
Ingredient Brand has no equivalent knob — `ingredientBrandScreens` is
populated exclusively from the backend's `/configurations` response, and
mutating `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` directly
from the example app would race the SDK's async config fetch (documented
under PP-3511 Q10).

Instead PP-3477 introduces a UI-test-only mock networking layer,
`UITestMockBackend`, that plugs into the SDK's public custom-networking
entry point and returns a canned `ClientConfiguration` with a
launch-arg-overridable `ingredientBrandScreens`, plus a bounded analysis
delay that keeps the Analysis screen visible long enough for assertions.
The mock is `#if DEBUG`-gated and activated only when the
`-UITestMockScenario` launch argument is present, so production runs are
unchanged.

## AC → automation mapping

PP-3477's four acceptance criteria + Mozhgan's PP-3476 review additions
(Sep-25) → the automated tests that cover them.

| AC / review point | Automated test | Notes |
|---|---|---|
| AC1: Flag off — no brand element, default loading indicator | `testFlagOffShowsDefaultLoadingIndicator` | Base case, no `extraLaunchArguments` overrides |
| AC2: Flag on — brand element visible + branded loading indicator | `testFlagOnShowsBrandedLoadingIndicatorAndBadge` | Positive existence + negative `defaultLoadingIndicator.exists == false` |
| AC3: Other SDK screens still pass with the flag on | **Not covered in this suite** — regression sweep against Skonto / CreditNote / Capture / PaymentHint / ReturnAssistant / Onboarding suites with `-UITestMockIngredientBrandScreens Analysis` prepended. Tracked as follow-up | See "Follow-ups" |
| AC4: Consistent across repeated BS runs | Enable nightly cron on this suite. Baseline v7 (build `14fdaf8c…`) = 15 pass + 3 skip. Definition of "green" here: 3 consecutive nightly runs with the same outcome | See "Follow-ups" |
| PP-3476 R1: Empty `ingredientBrandScreens` | `testFlagOffShowsDefaultLoadingIndicator` | ✅ |
| PP-3476 R2: `["Analysis"]` | `testFlagOnShowsBrandedLoadingIndicatorAndBadge` | ✅ |
| PP-3476 R3: Unknown value ignored | `testUnknownScreenValueRendersWithoutBrand` | ✅ |
| PP-3476 R4: Light + dark theme | `testBrandedElementsAppearInDarkTheme` + `testBrandedElementsAppearInLightTheme` | ✅ Both themes explicit |
| Mozhgan review 2: Custom loading indicator interaction (Case A + Case B) | `testFlagOnBeatsCustomLoadingIndicator` + `testFlagOffKeepsCustomLoadingIndicator` | ✅ Both directions asserted |
| Mozhgan review 3: PDF loading text = filename on a new line | `testBrandedLoadingIndicatorAccessibilityLabelMatchesLoadingText` | ✅ Asserts `hasPrefix("Analyzing")` + `contains(".pdf")` |
| Mozhgan review 4: VoiceOver announcement for the Gini indicator | `testBrandedLoadingIndicatorAccessibilityLabelMatchesLoadingText` | ✅ **Fills a gap Mozhgan explicitly flagged as missing from the manual test cases** |
| Mozhgan review — Portrait + landscape check | `testBrandedElementsPersistAcrossOrientations` | ✅ **First XCUITest in this repo that rotates the device.** Includes `.isLandscape` / `.isPortrait` guards so a portrait-lock fails loudly rather than silently no-op'ing |
| Mozhgan review 5: QR overlay cases (not Analysis screen) | ⏭ Deferred to follow-up — aligned with Android's `IngredientBrandQrOverlayTests` skip | See "Follow-ups" |

## Extra assertions (not requested by PP-3476, added defensively)

| Test | Why |
|---|---|
| `testCaseInsensitiveAnalysisEnablesBrand` | PP-3511 Q1 documents case-insensitive membership; this test locks it in behaviourally |
| `testNonAnalysisScreenValueDoesNotEnableAnalysisBrand` | "Analysis is the only supported value" — guards against a future value in the list leaking into Analysis UI |
| `testFlagValuePersistsPerLaunchOnly` | Guards against a UserDefaults value silently persisting across relaunch |
| `testCancelFromAnalysisFiresDidCancelCapturingCallback` | Cancel callback correctness while branded UI is active (positive path) |
| `testAnalysisCompletionFiresDidFinishCallback` | Completion callback correctness while branded UI is active (positive path) |
| `testCancelDuringDelayedAnalysisSquelchesCompletionCallback` | Negative assertion — after cancel, the finish callback must NOT fire. Ports Android `IngredientBrandTests.test10_closeDuringDelayedAnalysis_callbackNeverArrives`. Guards a real bug class where in-flight completions leak past cancellation |

## Skipped tests + rationale

| Test | XCTSkip reason | Depends on |
|---|---|---|
| `testCaptureSuggestionsBannerHidesBadgeButKeepsBrandedIndicator` | Banner is image-path only (`AnalysisViewController` gates it on `document is GiniImageDocument`); current PDF fixture never triggers it | Image path via camera injection helper |
| `testFlagOnDuringEducationFlowKeepsBadgeVisible` | Education flow requires `!document.isImported`; Files-import fixture always sets `isImported = true` | Camera-injection helper |
| `testFlagOffDuringEducationFlowShowsNoBrand` | Same as above | Camera-injection helper |

All three unblock together once an `injectImage()`-based camera helper
(mirror of `GiniCaptureFlowUITestsUsingBS.injectImage()`) is added. Tracked
as a follow-up story.

## Test matrix — v7 baseline (2026-09-29)

BrowserStack build [`14fdaf8c2ad8b4d3185a187036a5721c366da25c`](https://app-automate.browserstack.com/dashboard/v2/builds/14fdaf8c2ad8b4d3185a187036a5721c366da25c),
15 pass + 3 skip + 0 fail on both devices, 11m 38s. v7 landed in the
shared default project `GiniBankSDK-iOS-4.6.0` — the per-feature
`GiniBankSDK-iOS-IngredientBrand-4.6.0` bucket takes effect from the next
run onward (see Implementation plan step 6).

| Test | iPhone 17 (iOS 26.6) | iPhone 16 (iOS 18.6) |
|---|---|---|
| `testFlagOffShowsDefaultLoadingIndicator` | ✅ | ✅ |
| `testFlagOnShowsBrandedLoadingIndicatorAndBadge` | ✅ | ✅ |
| `testUnknownScreenValueRendersWithoutBrand` | ✅ | ✅ |
| `testBrandedElementsAppearInDarkTheme` | ✅ | ✅ |
| `testBrandedElementsAppearInLightTheme` | ✅ | ✅ |
| `testBrandedElementsPersistAcrossOrientations` | ✅ | ✅ |
| `testCaseInsensitiveAnalysisEnablesBrand` | ✅ | ✅ |
| `testNonAnalysisScreenValueDoesNotEnableAnalysisBrand` | ✅ | ✅ |
| `testBrandedLoadingIndicatorAccessibilityLabelMatchesLoadingText` | ✅ | ✅ |
| `testFlagOnBeatsCustomLoadingIndicator` | ✅ | ✅ |
| `testFlagOffKeepsCustomLoadingIndicator` | ✅ | ✅ |
| `testFlagOnDuringEducationFlowKeepsBadgeVisible` | ⏭ | ⏭ |
| `testFlagOffDuringEducationFlowShowsNoBrand` | ⏭ | ⏭ |
| `testCaptureSuggestionsBannerHidesBadgeButKeepsBrandedIndicator` | ⏭ | ⏭ |
| `testCancelFromAnalysisFiresDidCancelCapturingCallback` | ✅ | ✅ |
| `testAnalysisCompletionFiresDidFinishCallback` | ✅ | ✅ |
| `testCancelDuringDelayedAnalysisSquelchesCompletionCallback` | ✅ | ✅ |
| `testFlagValuePersistsPerLaunchOnly` | ✅ | ✅ |

## Android parity

Android's `IngredientBrandTests` (10) + `IngredientBrandEducationTests`
(4) + `IngredientBrandQrOverlayTests` (4, skipped) ran on BrowserStack
2026-09-28 (builds `39ffc2181…`, `4c99b5f2e…`). Android UI test source is
**not committed** to any pushed branch on `gini-mobile-android` — the
runs were triggered from a developer's local machine. Coverage overlap:

| Android test method | iOS equivalent |
|---|---|
| `test1_pdf_brandOn_showsBadgeInPositionAndGiniMark` | `testFlagOnShowsBrandedLoadingIndicatorAndBadge` |
| `test2_pdf_brandOn_giniMarkHasTalkBackDescription` | `testBrandedLoadingIndicatorAccessibilityLabelMatchesLoadingText` |
| `test3_pdf_brandOff_showsDefaultIndicatorAndNoBadge` | `testFlagOffShowsDefaultLoadingIndicator` |
| `test4_pdf_unknownValue_behavesLikeBrandOff` | `testUnknownScreenValueRendersWithoutBrand` |
| `test5_pdf_lowercaseAnalysis_showsBrand` | `testCaseInsensitiveAnalysisEnablesBrand` |
| `test6_image_brandOn_badgeHidesWhenFirstTipAppears` | ⏭ Skipped — camera-injection follow-up |
| `test7_image_brandOff_tipsWithoutBadge` | Not ported — camera-injection follow-up |
| `test8_customIndicator_brandOn_giniMarkWins` | `testFlagOnBeatsCustomLoadingIndicator` |
| `test9_customIndicator_brandOff_customIndicatorShown` | `testFlagOffKeepsCustomLoadingIndicator` |
| `test10_closeDuringDelayedAnalysis_callbackNeverArrives` | `testCancelDuringDelayedAnalysisSquelchesCompletionCallback` |
| Education 1–4 | ⏭ Skipped — camera-injection follow-up |
| QR overlay 1–4 | ⏭ Skipped — aligned with Android's own skip |

## Affected modules

New files (this ticket):

- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/IngredientBrandFlowUITests.swift` — 18 tests
- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Screens/IngredientBrandScreen.swift` — page object
- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/AccessibilityIdentifiers/IngredientBrandScreenAccessibilityIdentifiers.swift` — mirrors SDK identifiers verbatim
- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Scripts/bs_run_ingredient_brand.sh` — dedicated BS project bucket

Modified (this ticket):

- `BankSDK/GiniBankSDKExample/GiniBankSDKExample/UITestSupport/UITestMockBackend.swift` — extended with `ingredientBrandScreens` + `analysisDelay` parsing, `UITestCustomLoadingIndicator` (`CustomLoadingIndicatorAdapter` conformance), and the `UITestDelegateObservers` bridge; all `#if DEBUG`
- `BankSDK/GiniBankSDKExample/GiniBankSDKExample/AppDelegate.swift` — three new launch-arg hooks under `applyUITestCleanStateLaunchArguments`: `-UITestMockResetEducationCount`, `-UITestInjectCustomLoadingIndicator`, `-UITestInstallDelegateObservers`
- `BankSDK/GiniBankSDKExample/GiniBankSDKExample/Screen API/ScreenAPICoordinator.swift` — DEBUG-gated observer marker calls in `giniCaptureAnalysisDidFinishWith(result:)`, `didCancelCapturing()`, and `giniCaptureDidCancelAnalysis()`
- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/GiniBankSDKExampleUITests.swift` — base class extended with `ingredientBrandScreen: IngredientBrandScreen!` property
- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Scripts/Browserstack_README.md` — table row added
- `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Scripts/bs_shared.sh` — one-line addition (`BUILD_LABEL` case entry for `bs_run_ingredient_brand`)
- `BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj/project.pbxproj` — file registration

Test fixtures — reuses `TestFixtures.Files.testImage` (`test_image.pdf`); mock backend ignores content.

Also modified on this branch but **outside PP-3477's scope** (belongs to PP-3511 — see [PP-3511-feature.md](./PP-3511-feature.md)):

- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Analysis/AnalysisViewController.swift` — branded loading indicator + badge implementation on the Analysis screen (SDK feature side)

## Public API impact

None. All added surface area is `#if DEBUG`-gated in the example app.

## Technical conventions

- **Test class naming.** `<Feature>FlowUITests` — aligned with `PaymentHintFlowUITests` (PP-3302). Implementation-detail suffixes ("MockBackend") stay out of the class name.
- **Method signatures.** Every test is `func testX() throws {}` uniformly so `XCTSkip` can be thrown without a per-method signature change. Matches PP-3302.
- **Page object.** All `let` properties initialized in `init(app:)`. No computed properties for query lookups. Matches PP-3302.
- **A11y identifiers.** Feature-scoped struct with nested state substructs. Values duplicated verbatim from the SDK's `AccessibilityIdentifiers` struct because the UITest target can't import the SDK.
- **BS project bucket.** Per-feature: `GiniBankSDK-iOS-IngredientBrand-$SDK_VERSION`. `SDK_VERSION` sourced from `bs_shared.sh` so a single release bump updates every per-feature bucket. Matches PP-3302.
- **XCUITest queries.** `app.images[…]` for the two branded views because they set `accessibilityTraits = .image` (correct for VoiceOver); `app.otherElements[…]` for observer markers and the custom loading indicator.

## Design

### Mock backend (`UITestMockBackend`)

`#if DEBUG` only. Instantiated in `ScreenAPICoordinator.makeUITestMockViewControllerIfRequested()` when the `-UITestMockScenario` launch argument is present. Plugs into the SDK's public custom-networking entry point (`GiniBank.viewController(importedDocuments:configuration:resultsDelegate:networkingService:configurationService:)`) and returns:

- A canned analysis outcome selected by scenario name (`invoice`, `creditNote`, `analysisError`).
- A `ClientConfiguration` assembled from an all-false baseline with per-flag overrides via `-UITestMockClientConfig "flagA=true,flagB=false"`.
- `ingredientBrandScreens` populated from `-UITestMockIngredientBrandScreens "Analysis"` (comma-separated).
- An analysis-completion delay from `-UITestMockAnalysisDelaySeconds "8.0"` so the Analysis screen stays visible long enough for XCUITest to observe it.

Unknown scenario names or flag keys trap via `preconditionFailure` — typos fail loudly.

### Custom loading indicator stand-in (`UITestCustomLoadingIndicator`)

`#if DEBUG` only. Manual `CustomLoadingIndicatorAdapter` conformance (no third-party mocking framework, per `.claude/rules/mandatory-rules.md`). Installed via `-UITestInjectCustomLoadingIndicator` on `GiniBankConfiguration.shared.customLoadingIndicator` in `AppDelegate`. Non-zero `intrinsicContentSize` so XCUITest can find it (the SDK pins only centerX/Y to the loading container — a plain zero-sized view collapses out of the a11y snapshot).

### Delegate observer bridge (`UITestDelegateObservers`)

`#if DEBUG` only. Attaches 1×1 marker views to the key window under known identifiers when `didCancelCapturing` / `giniCaptureAnalysisDidFinishWith(result:)` fire. XCUITest resolves the transition via `waitForExistence(timeout:)`. Fresh (not pre-installed) so `waitForExistence` observes a real absent → present transition; `isHidden = true` on a pre-installed marker removes it from XCUITest's accessibility tree entirely.

**Delegate routing correction.** The default-networking path routes cancellation through `resultsDelegate.giniCaptureDidCancelAnalysis()`, not `GiniCaptureDelegate.didCancelCapturing()`. The observer records both, so the cancel assertion is delegate-path agnostic. `giniCaptureAnalysisDidFinishWith(result:)` is the results-delegate completion callback used by all default-networking configurations.

### BrowserStack script

`bs_run_ingredient_brand.sh` follows the same shape as `bs_run_payment_hint.sh`:

- Sources `bs_shared.sh` for `bs_build`, `upload_media`, `bs_upload_app_and_suite`, `bs_cleanup`, and the credentials + device defaults.
- Overrides `BS_PROJECT="GiniBankSDK-iOS-IngredientBrand-$SDK_VERSION"` so daily runs land in a dedicated bucket.
- `only-testing` limited to `GiniBankSDKExampleUITests/IngredientBrandFlowUITests`.
- Uploads `test_image.pdf` — the mock backend ignores its content, but iOS needs a real document to trigger the analysis pipeline.

## Test plan

### Automated tests to add

Covered above in the "AC → automation mapping" and "Extra assertions" tables. Total: 18 tests — 15 passing on both devices, 3 XCTSkipped with documented follow-up conditions.

### BrowserStack runs

Baseline established: v7 (`14fdaf8c…`) 2026-09-29, 15/15 targeted tests passing on iPhone 17 (iOS 26.6) and iPhone 16 (iOS 18.6). v7 ran in the shared `GiniBankSDK-iOS-4.6.0` project; the dedicated `GiniBankSDK-iOS-IngredientBrand-4.6.0` bucket takes effect from the next BS run once the aligned code is triggered.

### Not tested

- **Camera / image path** (banner interaction + education flow) — requires the camera-injection helper. Follow-up story.
- **QR overlay** (branded UI on QR code camera overlay) — Android also defers this; aligned. Follow-up story.
- **iPad size class** — no iPad in the current 2-device BrowserStack matrix; `AnalysisViewController` has size-class-branched constraints that iPad exercises differently. Follow-up story.
- **iOS 15 baseline** — Swift Testing back-deploy bundling in `bs_build` targets iOS 15/16 compatibility; not currently exercised on a real iOS 15 device. Follow-up story.
- **Regression sweep** — other UI suites with the flag on. PP-3477 AC #3. Follow-up run.
- **Visual regression** (Figma-spec-conformance of badge / indicator positioning) — no Percy or image-hash assertion. Assertions currently prove "element exists," not "at the right pixel." Follow-up story.
- **End-to-end extraction with branded UI active** — tests stop at Analysis screen. Not verified: branded UI completes cleanly and the results screen renders correct extractions. Follow-up story.
- **Dynamic Type XXL / accessibility settings** — not exercised.
- **VoiceOver announcement flow** (rotor navigation, custom actions) — only `.label` is asserted, not the announcement flow. Manual QA scope per PP-3476 Mozhgan review point 4.

## Out of scope

- Changes to the SDK's ingredient-brand implementation itself — see PP-3511 for the branded loading indicator, PP-2570 for the badge.
- Percy / visual regression tooling — separate follow-up.
- iOS Test Plan / Test Execution ticket updates in Xray — Yuliia's tickets PP-3785 / PP-3787.
- Android UI tests — separate ticket PP-3478; iOS/Android are currently structurally divergent (Android has 18 test methods executed on BrowserStack from an unpushed local branch, iOS has 18 methods committed here).

## Follow-ups (separate stories)

Link as blocked-by / unblocks on PP-3477:

- **[iOS] Ingredient Brand — camera-injection helper for image + education-flow UI tests** — un-skips 3 XCTSkipped tests, ports Android tests 6/7 and Education 1–4. Mirror of `GiniCaptureFlowUITestsUsingBS.injectImage()`.
- **[iOS] Ingredient Brand — QR overlay UI tests** — aligned with Android's `IngredientBrandQrOverlayTests` skip.
- **[iOS] Ingredient Brand — iPad + iOS 15 on BS device matrix** — closes the Test Plan (PP-3785) device gap.
- **[iOS] Ingredient Brand — regression sweep with flag on** — satisfies PP-3477 AC #3. One run per existing suite (Skonto, CreditNote, Capture, PaymentHint, ReturnAssistant, Onboarding) with `-UITestMockIngredientBrandScreens Analysis` in `additionalLaunchArguments`.
- **[iOS] Ingredient Brand — nightly cron for flakiness proof** — satisfies PP-3477 AC #4. Three consecutive green runs before the ticket moves to Done.
- **[iOS] Visual regression via Percy on the branded Analysis screen** — Portrait × landscape × light × dark = 4 snapshots. Catches all future layout drift.
- **[iOS] End-to-end assertion — flag on all the way to results screen** — uses `.creditNote` scenario; asserts extractions render correctly with branded UI in the pipeline.

## Open questions

None outstanding as of 2026-09-29 v7 baseline. Historical decisions:

- **Q1 (data-driving mechanism):** Chose mock-backend layer over runtime UserDefaults mutation because `ingredientBrandScreens` is delivered exclusively via the async `/configurations` fetch — a launch-arg-then-read pattern would race the SDK. Deviation from PP-3302's launch-arg-to-knob approach documented in the Problem section.
- **Q2 (test class naming):** Went with `IngredientBrandFlowUITests` (renamed from `IngredientBrandMockBackendUITests`) to match `PaymentHintFlowUITests` and keep implementation-detail suffixes out of class names.
- **Q3 (a11y query type):** SDK views set `accessibilityTraits = .image` for correct VoiceOver semantics. XCUITest maps `.image` → `XCUIElement.ElementType.image`, so page-object queries use `app.images[…]` for both `poweredByGiniLoadingIndicator` and `poweredByGiniBadge`. First iteration used `app.otherElements[…]` and every flag-on assertion silently timed out.
- **Q4 (observer marker install strategy):** Fresh marker views (installed on callback fire) rather than pre-installed markers whose `isHidden` flips to `false`. `isHidden = true` removes a view from XCUITest's a11y tree entirely; a `waitForExistence` on it always times out. First iteration used the flip-strategy and every callback assertion failed on BS.
- **Q5 (accessibility label assertion):** Assert `.label.hasPrefix("Analyzing")` + `.label.contains(".pdf")` rather than `XCTAssertEqual`. `AnalysisViewController` sets the label to `"Analyzing\n<filename>.pdf"`, which changes per fixture — a full-string equality check would break on any fixture rename.
- **Q6 (orientation guards):** Added `.isLandscape` / `.isPortrait` assertions immediately after `XCUIDevice.shared.orientation = …` so a portrait-lock (missing `UISupportedInterfaceOrientations` entry, force-portrait `AnalysisViewController.supportedInterfaceOrientations`) fails loudly rather than silently passing. This is the first XCUITest in this repo that rotates the device — no prior precedent, so the extra guard is load-bearing.
- **Q7 (delegate cancel routing):** Default-networking cancel path goes through `resultsDelegate.giniCaptureDidCancelAnalysis()`, not `GiniCaptureDelegate.didCancelCapturing()`. Observer records both to be delegate-path agnostic.

## Implementation plan

1. **[done]** Add mock backend + page object + a11y identifiers + first 4 tests covering PP-3477 AC1–AC4.
2. **[done]** Port Android's `IngredientBrandTests` coverage where the file-import PDF path is sufficient (custom indicator precedence, case-insensitivity, non-Analysis value, delegate observers, flag scope, cancel-during-analysis negative assertion).
3. **[done]** Address Mozhgan's PP-3476 review — explicit light-mode assertion, portrait ↔ landscape rotation, PDF filename in the a11y label.
4. **[done]** Align file layout + class naming + BS project bucket + `throws` uniformity + page-object structure with PP-3302 conventions.
5. **[todo]** Trigger the next BS run against the aligned code to confirm the class rename + per-feature BS project bucket work end-to-end, and log its build URL on PP-3477.
6. **[todo]** File the follow-up stories listed above under epic PP-2568.
7. **[todo]** Enable nightly cron; wait for 3 consecutive green runs to satisfy PP-3477 AC #4.
8. **[todo]** Move PP-3477 → In Review with a comment linking the latest green BS build. Comment on PP-3476 acknowledging which of Mozhgan's review points are automated (especially the Gini-indicator VoiceOver label she flagged as missing from manual cases).
