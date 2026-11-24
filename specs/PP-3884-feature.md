# PP-3884: [iOS] UI Automation for Xray Onboarding Screens Test Suite

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3884
Related: PP-3883 (Android twin, PR gini/gini-mobile-android#1039, base `release/bank-sdk-4.10.0`) ·
PP-2671 (epic "Mobile Automation Expansion - UI") ·
Xray folder `/Banking Project/Onboarding Screens` (5 tests, PP-3410..PP-3414)

## Problem

The Xray folder "Onboarding Screens" holds five manual cases for the GiniCaptureSDK onboarding
(`OnboardingViewController`, four pages in a paging `UICollectionView`). The PM wants every case run
as UI automation on BrowserStack, aligned with Android.

The ticket's coverage table says iOS already automates all five. Reading the code on `main`
(2026-11-23) shows that this is not true:

1. **Three cases have no iOS test.**
   - PP-3411 (swipe back and forth): `testOnboardingSwipeAction` and `testOnboardingSwipePages` in
     `GiniOnboardingScreenUITest.swift` are identical. Both tap Next twice, swipe left once and tap
     Get Started. Neither swipes back.
   - PP-3412 (Skip on the first page): no test.
   - PP-3414 (Skip on the third page): no test.
2. **Only one onboarding test runs on BrowserStack.** `bs_run_all.sh` lists only
   `GiniOnboardingScreenUITest/testOnboardingGetStartedButton` (in `smoke_journeys`), and
   `bs_run_smoke_journeys.sh` the same. No script runs the class's other four tests.
3. **The five Xray cases have titles only**, with no steps or description. Their wording matches the
   smoke case PP-3415, which has full steps. The tests follow the titles and PP-3415, as on Android.
4. **The UI tests skip themselves on the simulator.** `GiniBankSDKExampleUITests.setUpWithError`
   throws `XCTSkip` under `targetEnvironment(simulator)`. They run only on a real iPhone or on
   BrowserStack.

## Xray case mapping (the deliverable table)

| Xray | Case (title) | Decision | iOS test (`GiniOnboardingScreenUITest`) | Android (PP-3883) |
| --- | --- | --- | --- | --- |
| PP-3410 | View every onboarding screen | automated (**existing**) | `testOnboardingGetStartedButton` | `OnboardingScreenTests.test1`–`test7` + `OnboardingNavigationTests.test5` |
| PP-3411 | Slide through the 4 screens back and forth | automated (**new**) | `testOnboardingSwipeForwardAndBackThroughAllPages` | `OnboardingNavigationTests.test1` |
| PP-3412 | Skip after the first screen | automated (**new**) | `testOnboardingSkipOnFirstPageOpensCamera` | `OnboardingNavigationTests.test2` |
| PP-3413 | Skip after the second screen | automated (**existing**) | `testOnboardingSkipButton` | `OnboardingNavigationTests.test3` |
| PP-3414 | Skip after the third screen | automated (**new**) | `testOnboardingSkipOnThirdPageOpensCamera` | `OnboardingNavigationTests.test4` |

No case stays manual. All five run on BrowserStack through the new `bs_run_onboarding.sh` and the
new `onboarding` scenario in `bs_run_all.sh`.

## Decisions taken (confirmed with the user on 2026-11-23)

1. **Base branch:** `main`.
2. **Keep both existing swipe tests** (`testOnboardingSwipeAction`, `testOnboardingSwipePages`)
   unchanged, and add a new back-and-forth test.
3. **A new BrowserStack script** `bs_run_onboarding.sh` for this Xray folder, plus an `onboarding`
   scenario in `bs_run_all.sh`.
4. **Jira bookkeeping:** a mapping-table comment on PP-3884 that corrects the ticket's coverage table,
   and the label `ios-automated` on PP-3410..PP-3414. Drafted first, posted only after the user
   confirms.
5. **Steps come from the titles plus PP-3415.** Xray is not edited.
6. **The camera-permission pop-up is answered** with the existing
   `mainScreen.handleCameraPermission(answer: true)`, like every neighbouring onboarding test.

## Requirements

Page titles are matched by their English or German text from
`GiniCaptureSDK/Resources/{en,de}.lproj/Localizable.strings`, the way `OnboardingScreen` already
matches Next/Skip/Get Started per locale:

| Page | Key | en | de |
| --- | --- | --- | --- |
| 1 | `ginicapture.onboarding.flatPaper.title` | Flat paper within the frame | Dokument flach ausrichten |
| 2 | `ginicapture.onboarding.goodLighting.title` | Good lighting | Gute Lichtverhältnisse |
| 3 | `ginicapture.onboarding.multiPages.title` | Add multiple pages | Mehrere Seiten |
| 4 | `ginicapture.onboarding.qrCode.title` | QR codes supported | QR-Codes scannen |

"Page N is shown" means that page's title `staticText` exists **and** is hittable within
`Constants.pageTimeout` (5 s). The neighbour pages of the paging collection view may exist in the
accessibility tree while they are off screen, but an off-screen element is never hittable.
"The camera is shown" means `captureScreen.captureButton` exists within 10 s and is hittable
(the check the existing tests use).

- **R1 (MUST, entry):** Given a real iPhone (the suite skips on the simulator), when
  `GiniOnboardingScreenUITest` is run from Xcode or with `xcodebuild test` on that device, then the
  three new tests run next to the five existing ones, and the class builds with
  `xcodebuild build-for-testing -workspace GiniMobile.xcworkspace -scheme GiniBankSDKExample -configuration Debug -destination "generic/platform=iOS"`
  (the command `bs_build` in `Scripts/bs_shared.sh` uses).
- **R2 (MUST, entry – script):** Given `BS_USER`/`BS_KEY`, when `Scripts/bs_run_onboarding.sh` is run,
  then one BrowserStack build runs the whole `GiniOnboardingScreenUITest` class on the default device
  pair (`iPhone 17-26`, `iPhone 16-18` from `bs_shared.sh`). The script honours `BS_DEVICE`,
  `BS_LANGUAGE` and `BS_TEST` like `bs_run_credit_note.sh`, and its header names the Xray case of each
  test.
- **R3 (MUST, entry – full run):** Given `bs_run_all.sh`, when it runs, then it triggers an
  `onboarding_<version>` scenario with `GiniBankSDKExampleUITests/GiniOnboardingScreenUITest`, and its
  usage header lists that scenario. `testOnboardingGetStartedButton` stays in `smoke_journeys` as well.
- **R4 (MUST, happy – PP-3411, forward):** Given the onboarding opened from the photo-payment button
  and page 1 shown, when the test swipes left three times, then pages 2, 3 and 4 are shown in that
  order. On page 4, Get Started exists and the Skip button does not exist
  (`OnboardingViewController.configureNavigationButtons` removes it on the last page).
- **R5 (MUST, happy – PP-3411, back):** Given page 4 reached in R4 (same test), when the test swipes
  right three times, then pages 3, 2 and 1 are shown in that order. Right after reaching page 3, the
  Skip button exists again and Get Started does not exist.
- **R6 (MUST, happy – PP-3412):** Given page 1 shown, when the test taps Skip, then the camera is shown.
- **R7 (MUST, happy – PP-3414):** Given page 1 shown, when the test taps Next, waits for page 2, taps
  Next, waits for page 3 and then taps Skip, then the camera is shown.
- **R8 (MUST, error – no vacuous pass):** Given the app opens without the onboarding, when any new
  test runs, then it **fails** at its first page check with a message that names the missing page
  title. No new test reaches a camera assertion without first proving the expected page was shown.
- **R9 (MUST, error – lost tap):** Given `nextPage()` reads `dataSource.currentPageIndex`, which is
  only updated when the scroll animation ends (`OnboardingDataSource.scrollViewDidEndScrollingAnimation`),
  when a test taps Next more than once, then it waits for the next page to be shown before each
  further tap. A tap during the animation would move to the same page again, and R7 would then tap
  Skip on the wrong page.
- **R10 (MUST, async):** Given a page change is an animated collection-view scroll, when a test checks
  a page after a swipe or a Next tap, then it waits with an `XCTNSPredicateExpectation`
  (`exists == true AND isHittable == true`, timeout `Constants.pageTimeout`), never with `sleep`.
- **R11 (MUST, entry – Jira):** Given the mapping table above, when the implementation is done, then
  (a) the table is posted as a comment on PP-3884, saying the ticket's "5 already automated" was
  wrong and listing the three new tests and the new script; (b) PP-3410..PP-3414 get the label
  `ios-automated`, merged with existing labels. Both are shown to the user first and posted only
  after the user confirms.

## Affected modules

- `GiniBankSDKExample` UI test target (`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/`) only:
  one test class extended, one page object extended, one new script, `bs_run_all.sh` and
  `Scripts/Browserstack_README.md` updated.
- `GiniCaptureSDK` — read only (`Core/Screens/Onboarding/OnboardingViewController.swift`,
  `OnboardingDataSource.swift`). No change.

Minimum deployment target is not touched (example-app UI tests only).

## Public API impact

None. No SDK source changes; nothing `public`/`open` is added.

## Technical conventions

1. **Language and access control:** Swift, in the UI test target. New helpers are `internal` (the
   default), like the existing page objects. Doc comments use `/** */` on new helpers, matching the
   base class (`GiniBankSDKExampleUITests.swift`).
2. **UI:** no UI is added or changed. No SwiftUI, no UIKit, no Liquid Glass impact.
3. **Architecture (test code):** the Page Object pattern of the suite. New selectors go into
   `Screens/OnboardingScreen.swift`, never as raw queries in the test class. The new tests go into
   the existing `GiniOnboardingScreenUITest` (subclass of `GiniBankSDKExampleUITests`), which already
   holds the case's neighbours and is what the new script selects.
4. **Wiring / async:** no DI. Waits use `waitForExistence(timeout:)` and `XCTWaiter` with
   `XCTNSPredicateExpectation`. No `sleep`.
5. **Localization:** no new strings. The page-title texts above are added for `en` and `de` in
   `OnboardingScreen.init(app:locale:)`, in the same `switch locale` as the existing buttons.
6. **Quality gates:** no SDK sources change, so `make lint scheme=GiniBankSDK` (the SDK compile gate)
   is not needed. The `/gini-build` platform file says to run UI tests on the CI simulator, but this
   suite throws `XCTSkip` on any simulator, so a simulator run proves nothing. The gate is R1's
   `build-for-testing` command, a run on a real iPhone (verification step 2), and the BrowserStack
   run (R2).
7. **Method names and the BrowserStack prefix rule:** BrowserStack matches `only-testing` method
   entries by name prefix (`bs_run_smoke_screens.sh` header). No new method name may be a prefix of
   another method in the class, or have one as its prefix. The three names in the mapping table are
   checked against the existing five; none is a prefix of another. (`testOnboardingSkipButton` is
   already a prefix of `testOnboardingSkipButtonIsTopNavOnly` — existing, out of scope; the new script
   selects at class level, so it is not affected.)
8. **Multi-parameter formatting** per `.claude/rules/mandatory-rules.md`.

## Design

### `OnboardingScreen` page object (extend) — `Screens/OnboardingScreen.swift`

A new `struct OnboardingPageTitle { let text: String; let element: XCUIElement }` keeps each title's
text (for failure messages) next to its element. The element is
`app.staticTexts.matching(NSPredicate(format: "label == %@", text)).firstMatch`: matched by label
only, because `OnboardingDataSource` also sets the title as the illustration's accessibility value
(self-review finding).

Add, inside the existing `switch locale` (en/de):

- `flatPaperTitle`, `goodLightingTitle`, `multiPagesTitle`, `qrCodeTitle`: `OnboardingPageTitle` values
  with the texts from the table above.

Add methods:

- `func waitForPage(_ title: OnboardingPageTitle, timeout: TimeInterval = Constants.pageTimeout, file: StaticString = #filePath, line: UInt = #line)` —
  waits with `XCTWaiter().wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true AND isHittable == true"), object: title.element)], timeout: timeout)`.
  When the result is not `.completed`, it calls `XCTFail("Onboarding page '<title.text>' not shown within <timeout> s", file: file, line: line)`.
  `continueAfterFailure = false` in the base class stops the test there (R8, R10).
- `func tapNextAndWaitFor(_ title: OnboardingPageTitle, file:line:)` — `nextButton.tap()`, then
  `waitForPage(title)` (R9).
- `func tapSkip()` — `skipButton.tap()`. Unlike `skipOnboardingScreens()`, a missing Skip button
  fails the test.
- `func swipeToNextPage()` / `func swipeToPreviousPage()` — `app.collectionViews.firstMatch.swipeLeft()` /
  `.swipeRight()`. Swiping on the collection view, not on `app`, keeps the gesture away from the
  screen edge (the navigation back gesture starts at the edge). The onboarding is presented
  `.overCurrentContext`, but neither the camera nor the main screen has a collection view.
- `enum Constants { static let pageTimeout: TimeInterval = 5; static let firstPageTimeout: TimeInterval = 10 }`
  (internal, so it can be a default argument and the test can pass `firstPageTimeout`).

The page-1 to page-4 order and the Skip/Get Started switch come from
`OnboardingViewController.configureNavigationButtons(for:)`: the last page sets
`navigationItem.rightBarButtonItem = nil` and shows Get Started; every other page shows Skip and Next.

### `GiniOnboardingScreenUITest` (extend) — `GiniOnboardingScreenUITest.swift`

A private helper `openOnboarding()` does the shared start of the three new tests, copied from the
existing tests' preconditions: open settings (`mainScreen.configurationButton.tap()`), switch
"Onboarding screens at every launch" on and "Onboarding screens at first launch" off
(`mainScreen.tapSwitchNextToTextElement`), close settings, tap `mainScreen.photoPaymentButton`, call
`mainScreen.handleCameraPermission(answer: true)`, then `onboadingScreen.waitForPage(onboadingScreen.flatPaperTitle, timeout: OnboardingScreen.Constants.firstPageTimeout)`
(the first wait also covers the modal presentation after the permission alert).
The five existing tests are not changed (decision 2).

| New test | Steps after `openOnboarding()` | Requirements |
| --- | --- | --- |
| `testOnboardingSwipeForwardAndBackThroughAllPages` | `swipeToNextPage` + `waitForPage` for pages 2, 3, 4; on page 4 assert `getStartedButton.exists` and `!skipButton.exists`; `swipeToPreviousPage` + `waitForPage` for pages 3, 2, 1; right after page 3 assert `skipButton.exists` and `!getStartedButton.exists` | R4, R5, R8, R10 |
| `testOnboardingSkipOnFirstPageOpensCamera` | `tapSkip()`; `XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10))`, `XCTAssertTrue(captureScreen.captureButton.isHittable)` | R6, R8 |
| `testOnboardingSkipOnThirdPageOpensCamera` | `tapNextAndWaitFor(goodLightingTitle)`, `tapNextAndWaitFor(multiPagesTitle)`, `tapSkip()`; camera asserts as above | R7, R8, R9 |

Each new test gets a one-line comment naming its Xray case (`// PP-3411: …`), matching the
`//` step comments of the existing tests.

### BrowserStack — `Scripts/`

- **`bs_run_onboarding.sh` (new, executable).** Modelled on `bs_run_credit_note.sh` without media:
  `source bs_shared.sh`; `ONLY_TESTING='["GiniBankSDKExampleUITests/GiniOnboardingScreenUITest"]'`,
  or `["$BS_TEST"]` when `BS_TEST` is set (then `singleRunnerInvocation` is `false`, as in
  `bs_run_smoke_screens.sh`); `LANGUAGE_FIELD` from `BS_LANGUAGE`; `bs_build`;
  `bs_upload_app_and_suite`; trigger with `buildName` `onboarding` and **no `uploadMedia` field**
  (the onboarding needs no files); print the dashboard URL; `bs_cleanup`. The header lists each
  test with its Xray case.
- **`bs_run_all.sh`:** `trigger_scenario` always sends `"uploadMedia": $upload_media`. Give it the same
  `-` convention it already has for `only_testing`: when the third argument is `-`, the field is left
  out. Then add, after `smoke_screens`:
  `trigger_scenario "onboarding_${RELEASE_VERSION}" '["GiniBankSDKExampleUITests/GiniOnboardingScreenUITest"]' "-"`,
  and list `onboarding_<v>` in the usage header.
- **`Scripts/Browserstack_README.md`:** a short entry for `bs_run_onboarding.sh` next to the other
  scenario scripts.

### Jira (R11, after user confirmation)

Comment on PP-3884 with the mapping table; label `ios-automated` on PP-3410..PP-3414 (merge with the
existing `android-automated` label if PP-3883's labels are posted first).

## Test plan

The deliverable *is* the UI tests. No ViewModel or Service is added, so no unit test is added.
Stack: XCTest/XCUITest with the suite's Page Objects, matching `GiniOnboardingScreenUITest`.

| Test class | New / extends | Tests | Requirements |
| --- | --- | --- | --- |
| `GiniOnboardingScreenUITest` | extends (existing class) | +3 (5 existing unchanged) | R1, R4–R10 |

Three new tests, one per missing Xray case. PP-3410 and PP-3413 stay on their existing tests.

Verification steps for `/gini-build`, in this order:

1. R1's `build-for-testing` command succeeds.
2. On a real iPhone connected to this Mac (the suite skips on the simulator): run
   `GiniOnboardingScreenUITest` from Xcode (`GiniBankSDKExample` scheme). All 8 tests pass.
3. Negative check for R8 (not committed): comment out `tapSkip()` in
   `testOnboardingSkipOnFirstPageOpensCamera`; the test must fail at the camera check. Restore it.
4. BrowserStack: `bs_run_onboarding.sh`; both devices pass all 8 tests (R2). If the user's shell has
   no `BS_USER`/`BS_KEY`, the user runs it.
5. Jira drafts (R11) are shown to the user and posted only after confirmation.

### Not tested

- Page illustrations, descriptions and the page control's dots — the Xray titles ask only for page
  order and where Skip lands.
- The "Onboarding screens at first launch" path on a truly fresh install. Every onboarding test in
  this class uses the "every launch" switch; changing that is out of scope.
- Analytics events (`skipTapped`, `nextStepTapped`).
- German copy on BrowserStack: covered only when the user runs with `BS_LANGUAGE="de"`.

## Out of scope

- Any change to `GiniCaptureSDK` or `GiniBankSDK` sources.
- Changing or removing the five existing onboarding tests, including the duplicate swipe tests.
- `GiniCXOnboardingUITests` (cross-border onboarding) and the WCAG / QAlity onboarding folders.
- The `testOnboardingSkipButton` / `testOnboardingSkipButtonIsTopNavOnly` prefix overlap.
- The Android side (PP-3883, already in review).

## Open questions

None.

## Implementation plan
- [x] 1. Extend `OnboardingScreen` page object (`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Screens/OnboardingScreen.swift`): page titles (en/de), `waitForPage`, `tapNextAndWaitFor`, `tapSkip`, `swipeToNextPage`/`swipeToPreviousPage` (requirements 8, 9, 10)
- [x] 2. Add `openOnboarding()` and the three new tests to `GiniOnboardingScreenUITest.swift` (requirements 1, 4, 5, 6, 7, 8, 9, 10)
- [x] 3. BrowserStack (`Scripts/`): new `bs_run_onboarding.sh`; `uploadMedia` `-` convention + `onboarding_<v>` scenario in `bs_run_all.sh`; README entry (requirements 2, 3)
- [x] 4. Verify: `build-for-testing`; real-iPhone run of `GiniOnboardingScreenUITest` if one is attached; R8 negative check; BrowserStack `bs_run_onboarding.sh` (run by the user) (requirements 1, 2, 8) — BrowserStack build 748a3fa63956e9a925f1e71d33e490245317ac92 passed on iPhone 17 (iOS 26.5) and iPhone 16 (iOS 18.6); no local iPhone run and no R8 negative check
- [x] 5. Jira drafts (PP-3884 mapping comment + `ios-automated` labels on PP-3410..PP-3414) shown to the user; posted only after confirmation (requirement 11) — posted 2026-11-24 (mapping table only, at the user's request)
