# PP-3302: iOS UI Automation on BrowserStack for the Payment-Hint bottom sheet

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3302

## Problem

The Due Date Redesign shipped for iOS in `release/GiniBankSDK-4.5` — PP-3261
(Due Date Hint state) and PP-3263 (Schedule Payment state) — is covered
today only by SDK-side unit tests
(`CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/PaymentHintBottomSheetViewControllerTests.swift`,
`BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+DueDateHint.swift`,
`BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+SchedulePaymentHint.swift`).
Nothing exercises the actual capture-and-analysis flow end-to-end on real
devices, so a regression that only reproduces on iOS 18/26 hardware — say a
sheet that presents but has an untappable button, or `paymentDueDate` not
propagating through the extraction pipeline — will only surface at manual
regression time.

PP-3302 closes that gap: add XCUITest cases in
`GiniBankSDKExampleUITests` that drive the Photopayment flow with a
future-dated invoice fixture, toggle the two feature flags via the example
app's Settings screen, and assert on the sheet in both states plus its
CTAs. Tests run against the real Gini backend on the same BrowserStack
device matrix as the existing smoke suite
(`Scripts/bs_run_smoke_tests.sh` — DEVICE_1 `iPhone 17-26`, DEVICE_2
`iPhone 16-18`), driven by a new `bs_run_payment_hint.sh` script.
Automation coverage is functional + Dynamic Type; VoiceOver order,
contrast, and external-keyboard operability stay in manual QA per the
Q3 test-scope decision.

**Fixture-staleness strategy (mirrors Android PP-3301).** Rather than
periodically regenerate the invoice to keep its `paymentDueDate` more
than 5 days in the future, this spec drives show/no-show cases by
overriding `paymentDueHintThresholdDays` at runtime per-test against a
fixed far-future invoice: sheet-shown cases use the default threshold
(≤ `remainingDays`); the boundary case uses `threshold ==
remainingDays`; sheet-not-shown cases use `threshold == remainingDays
+ 1`. The invoice never goes stale as long as its extracted due date
stays in the future. A midnight-skip guard on the boundary case
avoids date-rollover flakes.

## Flag-combination mapping (CSV → automation)

The coordinator checks the schedule state before the due-date state
and both are gated by their own client-side flag on
`GiniBankConfiguration`
(`BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift`;
see also unit-test coverage in
`NetworkingScreenApiCoordinatorTests+SchedulePaymentHint.swift` /
`+DueDateHint.swift`). The manual PP-3300 CSVs use Charles to
manipulate the server `/configurations` flags; the automation
replaces that with the example app's client-side switches
(`paymentDueHintEnabled` / `paymentScheduleHintEnabled` under the
"Feature toggles" section of the Settings screen).

| Manual (server flags via Charles) | Automated (client switches) | Expected sheet |
| --- | --- | --- |
| due=true, schedule=false | due ON, schedule OFF | Due Date Hint |
| due=true, schedule=true | due ON, schedule ON | Schedule Payment (priority) |
| due=false, schedule=true | due OFF, schedule ON | Schedule Payment |
| due=false, schedule=false | due OFF, schedule OFF | none |

The server flags are assumed enabled for `gini-mobile-test` /
`gini-mobile-ci` per PP-3260 (Done). If either server flag is
off, every sheet-shown test fails uniformly — that is the expected
diagnostic signal.

## Requirements

Field convention for test assertions: XCUI-visible elements are looked up
by `accessibilityIdentifier` (added to the SDK in requirement R0), not by
localized label, so tests are locale-independent.

Threshold arithmetic (used by R1, R3, R4): tests compute
`remainingDays = Calendar.current.dateComponents([.day], from: Date(),
to: FIXTURE_DUE_DATE).day!` at test setup, and pass the resulting
integer as `-paymentDueHintThresholdDaysOverride <N>` in
`app.launchArguments` (see Design). The example app reads that launch
argument at startup and applies it to
`GiniBankConfiguration.shared.paymentDueHintThresholdDays` before the
capture flow begins.

**Entry**

1. **R0 (MUST, entry):** Given the `PaymentHintBottomSheetViewController`
   in either state, when the sheet lays out, then its container view,
   title label, description label, primary button, and secondary button
   each carry a stable, state-scoped `accessibilityIdentifier`
   (`paymentHint.dueDate.*` for the `.dueDate` state,
   `paymentHint.schedule.*` for the `.schedulePayment` state — exact
   values in "Technical conventions"). Every subsequent requirement
   looks up elements by these identifiers.

2. **R1 (MUST, entry — Due Date Hint sheet appears):** Given the
   example app is launched under BrowserStack with `paymentDueHintEnabled
   = true` and `paymentScheduleHintEnabled = false` (both toggled via
   the Settings screen using new a11y identifiers on those switches
   before the Photopayment flow starts) and
   `-paymentDueHintThresholdDaysOverride 5` in launch arguments (default
   threshold), when the user completes the capture flow with the
   `sepa_due_date` fixture (Files-app import), then within 60 s of
   processing an element with `accessibilityIdentifier ==
   "paymentHint.dueDate.container"` is visible on screen and the
   sheet's title label contains the fixture's due date rendered as
   `dd.MM.yyyy` (asserted via `title.label.contains(<dd.MM.yyyy of
   FIXTURE_DUE_DATE>)` where `FIXTURE_DUE_DATE` is the constant defined
   next to the tests — see Design → Test document). *(CSV PP-3261
   TC-001..003, TC-016)*

3. **R2 (MUST, entry — Schedule Payment sheet appears with priority):**
   Given `paymentScheduleHintEnabled = true` toggled via Settings and
   threshold override of 5, when the flow reaches Analysis with the
   `sepa_due_date` fixture, then within 60 s an element with
   `accessibilityIdentifier == "paymentHint.schedule.container"` is
   visible — independently of the `paymentDueHintEnabled` value
   (per PP-3263 priority order: schedule > due-date). This is
   covered by two parameterized test methods: one with
   `paymentDueHintEnabled = true` and one with `false`, both showing
   the Schedule state. *(CSV PP-3263 TC-001..003, TC-026..027)*

**Threshold & boundary**

4. **R3 (MUST, happy — boundary case: `remainingDays == threshold`):**
   Given `paymentDueHintEnabled = true` and
   `-paymentDueHintThresholdDaysOverride <remainingDays>` — the
   threshold set to *exactly* the number of days between today and
   the fixture's due date — when the flow reaches Analysis, then the
   Due Date Hint sheet still appears (matches PP-3261's `Date.isDueSoon(within:)`
   inclusive boundary). **Midnight-skip guard:** the test computes
   `remainingDays` at setup; if a date rollover between setup and the
   coordinator's own computation would decrement it, the boundary
   flips. The test skips (`XCTSkipIf`) when the current local time is
   within 30 minutes of midnight (before 00:30 or after 23:30 local),
   so date-rollover cannot flake this case on a night run. *(CSV
   PP-3261 TC-003 "exactly threshold days")*

5. **R4 (MUST, error — below threshold):** Given
   `paymentDueHintEnabled = true` and
   `-paymentDueHintThresholdDaysOverride <remainingDays + 2>`, when the
   flow reaches Analysis, then neither `paymentHint.dueDate.container`
   nor `paymentHint.schedule.container` appears within 30 s and the
   extraction screen (Done button in navigation bar) is reached within
   60 s. The `+ 2` offset (rather than `+ 1`) is required because
   `Date.isDueSoon(within: N)` fires when `daysUntilDue + 1 >= N`, so
   the largest firing threshold is `remainingDays + 1`; the first
   strictly-non-firing threshold is `remainingDays + 2`. Same
   midnight-skip guard as R3 (a rollover here would flip the outcome
   the other way). *(CSV PP-3261 TC-004 "less than threshold")*

**Negative cases**

6. **R5 (MUST, error — flags-off suppression):** Given
   `paymentDueHintEnabled = false` and `paymentScheduleHintEnabled =
   false` toggled via Settings (any threshold value), when the flow
   reaches Analysis with the `sepa_due_date` fixture, then no
   `paymentHint.dueDate.container` and no
   `paymentHint.schedule.container` appear within 30 s, and the
   extraction screen is reached (Done button visible) within 60 s.
   *(CSV PP-3261 TC-026..029)*

7. **R6 (SHOULD, error — no `paymentDueDate` extracted):** Given a
   fixture whose extractions contain no `paymentDueDate` (candidate:
   `TestFixtures.Files.sepaInvoice` — see Open questions for
   validation), when the flow reaches Analysis with
   `paymentDueHintEnabled = true` and `paymentScheduleHintEnabled =
   true`, then no sheet appears within 30 s and the extraction screen
   is reached within 60 s. SHOULD, not MUST — dropped to manual QA if
   the candidate fixture cannot be confirmed empty of `paymentDueDate`.

**Button actions**

8. **R7 (MUST, happy — Due Date "Proceed Anyway"):** Given R1's sheet
   is visible, when the test taps
   `accessibilityIdentifier == "paymentHint.dueDate.proceedButton"`,
   then the sheet dismisses within 3 s and the extraction screen (Done
   button in navigation bar) appears within 15 s.

9. **R8 (MUST, happy — Due Date "Cancel Transfer"):** Given R1's sheet
   is visible, when the test taps
   `accessibilityIdentifier == "paymentHint.dueDate.cancelButton"`,
   then the sheet dismisses within 3 s and the flow returns to the
   main screen (`MainScreen.photoPaymentButton` visible) within 10 s.
   The extraction screen must NOT have been reached (assert Done
   button never appeared during the wait).

10. **R9 (MUST, happy — Schedule "Schedule Payment" CTA):** Given R2's
    sheet is visible, when the test taps
    `accessibilityIdentifier == "paymentHint.schedule.scheduleButton"`,
    then a UIAlertController with title `"Schedule Payment requested"`
    appears within 5 s — verbatim string emitted by
    `BankSDK/GiniBankSDKExample/GiniBankSDKExample/Screen API/ScreenAPICoordinator.swift:296`.
    Presence of that alert uniquely proves
    `giniCaptureDidRequestSchedulePayment(result:)` fired end-to-end
    (the Success / Proceed-Anyway paths do NOT open this alert). The
    extraction screen must NOT be visible.

11. **R10 (MUST, happy — Schedule "Proceed Anyway" negative alert):**
    Given R2's sheet is visible, when the test taps
    `accessibilityIdentifier == "paymentHint.schedule.proceedButton"`,
    then the sheet dismisses within 3 s and the extraction screen
    (Done button) appears within 15 s, AND the alert `"Schedule Payment
    requested"` never appeared during the wait — differentiating this
    CTA from R9 in both directions. Without this negative assertion, a
    button mis-wired to fire the schedule callback would pass R10 as
    written otherwise (both CTAs would land on the same screen).

**Dismissal & environment**

12. **R11 (MUST, error — backdrop tap does NOT dismiss):** Given R1's
    sheet is visible, when the test taps at
    `coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))` on
    the application window (well below the status bar to avoid
    accidentally pulling Control Center or the notification shade),
    then `paymentHint.dueDate.container` remains visible for at least
    3 s after the tap. Repeat the same assertion for R2's schedule
    sheet with `paymentHint.schedule.container`.

13. **R12 (MUST, error — capture-suggestions suppressed):** Given R1's
    sheet has been visible for ≥ 5 s (the analysis capture-suggestions
    banner shows after 4 s), when the test queries the app for any
    element containing text from
    `ginicapture.analysis.suggestion.header` (localized), then no
    such element is `isHittable`. Same assertion for R2's schedule
    sheet.

    > **Automation deferred.** The `PaymentHintFlowUITests` suite imports
    > PDFs (Files.app → Custom_Files) and `AnalysisViewController` only
    > creates `CaptureSuggestionsView` for `GiniImageDocument`, so the
    > banner never appears via this flow and the assertion would pass
    > vacuously. Additionally, the SDK does not attach a stable
    > accessibility identifier to the suggestions container. R12 remains
    > covered by manual test; automation requires (a) a stable identifier
    > on the suggestions container and (b) an image-import path in the
    > fixture pipeline. Tracked as a follow-up.

**Accessibility**

14. **R13 (MUST, happy — Dynamic Type largest AX size):** Given the
    app is launched with additional launch argument
    `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL`
    on top of R1's setup, when R1's sheet appears, then the title,
    description, and both CTA buttons for the Due Date state are all
    `isHittable == true` and the sheet's title label's text is fully
    rendered — asserted via `titleLabel.frame.origin.y +
    titleLabel.frame.height <= container.frame.origin.y +
    container.frame.height` (no clipping). Same assertion for the
    Schedule state (R2). Two XCTests total.

**BrowserStack pipeline**

15. **R14 (MUST, entry — BrowserStack pipeline):** Given the new
    `PaymentHintFlowUITests` test class, when the operator runs
    `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Scripts/bs_run_payment_hint.sh`,
    then the script sources `bs_shared.sh`, calls `bs_build`, uploads
    the IPA and test runner via `bs_upload_app_and_suite`, uploads the
    `invoice_future_due.pdf` and `invoice_no_due_date.pdf` fixtures
    via `upload_media` (with `custom_id` matching the exact file base
    name so the fixtures appear in Files.app "Custom_Files" under
    those names), and triggers a BrowserStack build restricted to
    `only-testing == ["GiniBankSDKExampleUITests/PaymentHintFlowUITests"]`
    across three devices — `iPhone 17-26`, `iPhone 16-18`,
    `iPhone 15-17` — with `singleRunnerInvocation: "true"`. The script
    exits non-zero on any curl failure or missing
    `media_url`/`app_url`/`test_suite_url`, matching the error
    contract in `bs_shared.sh`.

16. **R15 (SHOULD, async — no flaky tests left enabled):** Given the
    new tests are merged onto `release/GiniBankSDK-4.5`, when
    `bs_run_payment_hint.sh` is executed 5 times against the same
    commit, then every test in `PaymentHintFlowUITests` passes on
    every device in the matrix (iPhone 17-26, iPhone 16-18,
    iPhone 15-17) — no `.disabled` or `.skip` annotations left in
    the file, no unrelated `XCTSkipIf` on the happy paths, only the
    R3/R4 midnight-skip guards are permitted. Any case that cannot
    meet this bar is deleted from this PR and refiled as a follow-up
    ticket — an enabled flaky test would violate the ticket's second
    AC.

## Affected modules

- **GiniCaptureSDK** (`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/`)
  — SDK change: minimum footprint. Two access-modifier tweaks on
  `InfoBottomSheetViewController` subview declarations
  (`headerLabel`, `descriptionLabel`: `private let` → `let`). No
  change to `InfoBottomSheetViewModel` (public protocol) or
  `InfoBottomSheetButtonsViewModel` (internal class).
  `PaymentHintBottomSheetViewController` gains an override
  `viewDidLoad()` that sets state-scoped `accessibilityIdentifier`
  strings on the base class's subviews plus its own `view`.
- **GiniBankSDKExample** (`BankSDK/GiniBankSDKExample/GiniBankSDKExample/`)
  — example-app change: additive. Two changes: (1) Settings switches
  for `paymentDueHintEnabled` and `paymentScheduleHintEnabled` gain
  accessibility identifiers so the Page Object can flip them; (2) at
  app startup, the example app reads a new
  `-paymentDueHintThresholdDaysOverride <Int>` launch argument (via
  `ProcessInfo.processInfo.arguments`) and applies its value to
  `GiniBankConfiguration.shared.paymentDueHintThresholdDays` before
  the first `GiniBank` factory call runs. The argument is honored only
  in `#if DEBUG` builds so it cannot affect release integrators.
- **GiniBankSDKExampleUITests**
  (`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/`) — new
  XCUITest class, new Page Object under `Screens/`, new
  `AccessibilityIdentifiers/PaymentHintScreenAccessibilityIdentifiers.swift`,
  extensions to `SettingScreen.swift` and
  `SettingScreenAccessibilityIdentifiers.swift`, new
  `Scripts/bs_run_payment_hint.sh`, small update to `bs_shared.sh`'s
  `BUILD_LABEL` case statement.

No other SDK modules change. The Gini backend contract, `/configurations`
schema, extraction pipeline, and coordinator control flow are unchanged
— PP-3261 and PP-3263 already shipped them onto
`release/GiniBankSDK-4.5`.

## Public API impact

- `GiniCaptureSDK` — **zero public API delta.** The `public protocol
  InfoBottomSheetViewModel` is untouched. The internal
  `InfoBottomSheetButtonsViewModel` init is untouched.
- `GiniCaptureSDK` — internal access-modifier widening on
  `InfoBottomSheetViewController`: two subview declarations change
  from `private let` to `let` (default access = `internal`):
  `headerLabel`, `descriptionLabel`. `buttonsViewContainer` was
  already internal (`lazy var`). No behavior change; only exposure
  within the module so subclasses can set `accessibilityIdentifier`
  on those subviews directly.
- `PaymentHintBottomSheetViewController` (already `public final class`)
  — no signature change. Adds an `override viewDidLoad()` that sets
  `accessibilityIdentifier` on the container view, the base class's
  `headerLabel` / `descriptionLabel`, and the two buttons. Gains a
  nested `internal enum AccessibilityIdentifiers` with the identifier
  string constants for both states.
- No new `public`/`open` declarations. No new protocol members. No
  breaking changes.
  (confidence: HIGH — verified against
  `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Custom views/InfoBottomSheet/InfoBottomSheetViewModel.swift`,
  `.../InfoBottomSheetButtonsViewModel.swift`,
  `.../InfoBottomSheetViewController.swift`, and
  `.../Screens/PaymentHint/PaymentHintBottomSheetViewController.swift`;
  `xcodebuild build -scheme GiniCaptureSDK` and `-scheme GiniBankSDK`
  both **BUILD SUCCEEDED** on 2026-08-25.)

## Technical conventions

1. **Language, access control, docs.**
   - New SDK code stays `internal` (Swift default). No new `public` /
     `open`. The a11y-identifier constants on
     `PaymentHintBottomSheetViewController` are declared
     `internal static let` so unit-test code inside GiniCaptureSDK can
     reuse them; the XCUITest target duplicates the string values in
     its own `PaymentHintScreenAccessibilityIdentifiers` enum (no
     `@testable import` from a UITest bundle).
   - Doc-comment style per `.claude/rules/mandatory-rules.md`:
     `/** ... */` for the new SDK properties and factory helpers,
     `///` inline where needed. Any new public-facing docs (none in
     this PR) would follow the same rule.
   - Copyright year on new files: **2026**.

2. **UI framework.** No new UI. The SDK sheet is UIKit and stays UIKit.
   The example app's Settings screen is UIKit and stays UIKit. Test
   code is XCUITest / XCTest — matches every neighboring UITest
   under `GiniBankSDKExampleUITests/`. No SwiftUI, no snapshot library.

3. **Architecture (MVVM + Coordinator).** No new coordinator or
   ViewModel. Identifier constants live on the sheet's controller
   (single owner). The example app's SettingsViewModel is unchanged
   — only the `accessibilityIdentifier` computed property in
   `SettingsViewController+SwitchOptionModel.swift` gains two `case`
   branches for `.paymentDueHintEnabled` and
   `.paymentScheduleHintEnabled`.

4. **Wiring / DI.** No DI change. The a11y IDs are set from the state
   at view-model construction time, following the same "view model
   carries the presentation data" pattern the two existing content
   structs (`DueDateContent`, `ScheduleContent`) already use for
   title, description, and colors.

5. **Localization.** No new string keys. Existing keys
   (`ginicapture.payment.hint.title`, `ginicapture.payment.hint.duedate.*`,
   `ginicapture.payment.hint.schedule.*` in
   `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/{en,de}.lproj/Localizable.strings`)
   already exist and are the copy the sheet renders. Test assertions
   go through `accessibilityIdentifier` (locale-independent) — no
   string key is asserted on directly.

6. **Quality gates.**
   - `make lint scheme=GiniCaptureSDK` clean (SDK a11y-ID change).
   - `make lint scheme=GiniBankSDK` clean (transitive).
   - The new XCUITests live in `GiniBankSDKExampleUITests`. Locally
     they can be run via the workspace's `GiniBankSDKExampleUITests`
     scheme; the intended and required run environment is BrowserStack
     via `bs_run_payment_hint.sh`. Multi-parameter formatting per
     `.claude/rules/mandatory-rules.md` (first parameter on the
     opening-paren line, subsequent vertically aligned).
   - No CI workflow changes: BrowserStack scripts are operator-run,
     not GitHub-Actions-triggered (see the survey — the current
     `.github/workflows/` runs unit tests only).

## Design

### SDK side — accessibility hooks on the sheet

The sheet is `PaymentHintBottomSheetViewController: InfoBottomSheetViewController`
at
`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/PaymentHint/PaymentHintBottomSheetViewController.swift`
with the state enum at
`.../PaymentHint/PaymentHintState.swift`. The base class
(`.../Custom views/InfoBottomSheet/InfoBottomSheetViewController.swift`)
owns `headerLabel`, `descriptionLabel`, and
`buttonsViewContainer.primaryButton` / `.secondaryButton`.

Change (minimum SDK footprint):

- In `InfoBottomSheetViewController`, change the access modifier on
  two subview declarations from `private let` to `let` (default
  = `internal`): `headerLabel`, `descriptionLabel`.
  `buttonsViewContainer` is already `internal` (`lazy var`); its
  `primaryButton` and `secondaryButton` are already accessible. No
  other change to the base class — `InfoBottomSheetViewModel`
  (public protocol) and `InfoBottomSheetButtonsViewModel` (internal
  class) stay untouched.
- In `PaymentHintBottomSheetViewController`:
  - Capture `state` as a stored property (was previously used only
    in `init`).
  - Add an `internal enum AccessibilityIdentifiers` with two nested
    enums, `DueDate` and `Schedule`, each holding 5 string constants
    (`container`, `title`, `description`, `proceedButton` /
    `scheduleButton`, `cancelButton` / `proceedButton`).
  - Override `viewDidLoad()` — after `super.viewDidLoad()` completes
    the layout, set `accessibilityIdentifier` on `view`,
    `headerLabel`, `descriptionLabel`,
    `buttonsViewContainer.primaryButton`, and
    `buttonsViewContainer.secondaryButton` from the state-scoped
    identifier constants.

The `configureAccessibility()` path in the base class (which sets
`accessibilityLabel` / `accessibilityTraits` in `viewDidAppear` and
`traitCollectionDidChange`) is orthogonal — `accessibilityIdentifier`
is a distinct property and is preserved across those calls. XCUITest
matches by identifier; VoiceOver uses the label.

**Identifier values (state-scoped, stable strings):**

| Element | Due Date state | Schedule state |
| --- | --- | --- |
| container view | `paymentHint.dueDate.container` | `paymentHint.schedule.container` |
| title label | `paymentHint.dueDate.title` | `paymentHint.schedule.title` |
| description label | `paymentHint.dueDate.description` | `paymentHint.schedule.description` |
| primary button | `paymentHint.dueDate.proceedButton` | `paymentHint.schedule.scheduleButton` |
| secondary button | `paymentHint.dueDate.cancelButton` | `paymentHint.schedule.proceedButton` |

The names mirror the closure labels in `PaymentHintState.swift` so a
reader jumping from spec → code → test does not have to translate.

### Example app — Settings a11y hooks

`BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewController+SwitchOptionModel.swift`
already contains `case .paymentDueHintEnabled` / `.paymentScheduleHintEnabled`
in the enum. Its `accessibilityIdentifier` computed property currently
returns `nil` for these two cases. Add:

- Two new cases to
  `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/AccessibilityIdentifiers/SettingScreenAccessibilityIdentifiers.swift`:
  `paymentDueHintSwitch = "paymentDueHintSwitchIdentifier"`,
  `paymentScheduleHintSwitch = "paymentScheduleHintSwitchIdentifier"`.
- Two new branches in `SwitchOptionModel.accessibilityIdentifier`
  returning those values.

### UITest — page object and identifiers

- New file
  `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/AccessibilityIdentifiers/PaymentHintScreenAccessibilityIdentifiers.swift`
  — mirrors the SDK's identifier strings (5 for Due Date, 5 for
  Schedule = 10 constants). Duplication is intentional: the UITest
  target cannot import `GiniCaptureSDK` (Xcode target boundary), and
  the current pattern in this codebase is a string-constant enum per
  screen under `AccessibilityIdentifiers/`.
- New file
  `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Screens/PaymentHintScreen.swift`
  — Page Object holding `dueDateContainer`, `dueDateTitle`,
  `dueDateDescription`, `dueDateProceedButton`,
  `dueDateCancelButton`, and the equivalent five for Schedule.
  Follows the constructor pattern of `SettingScreen.swift`
  (init(app:locale:), members typed `XCUIElement`).
- Extend `SettingScreen.swift` with `paymentDueHintSwitch:
  XCUIElement`, `paymentScheduleHintSwitch: XCUIElement`, and a
  helper `setPaymentHintFlags(dueDate: Bool, schedule: Bool)` that
  toggles each switch to the requested state using the existing
  `disableSwitchIfOn(_:)` pattern.

### UITest — the flow test class

New file
`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/PaymentHintFlowUITests.swift`.
Extends the same base class the existing BrowserStack test file uses
(`GiniBankSDKExampleUITests`), matching
`GiniCaptureFlowUITestsUsingBS.swift:11`. Adopts
`additionalLaunchArguments = ["-DisableReturnAssistant"]` (same reason
as the existing suite: keeps the flow predictable). Individual
test methods, one per requirement (see "Test plan" for the full
list).

The test's fixture path is the file-import flow already used by
`testCXCaptureFlowFileUpload` in `GiniCaptureFlowUITestsUsingBS.swift`
— `mainScreen.tapFileFromBestAvailableSource(fileName:
TestFixtures.Files.invoiceFutureDue)`.

**Fixtures reused from Android PP-3301** (single source of truth
across platforms; identical backend guarantees identical extraction):

- `invoice_future_due.pdf` (~186 KB) — anonymized synthetic invoice
  that extracts `paymentDueDate = 2028-09-01` and `paymentState =
  ToBePaid`. Validated against the real Gini API on 2026-08-17 with
  the `gini-mobile-test` client. Wrapped from the Android PP-3301
  JPEG source (`gini-mobile-android@release/bank-sdk-4.5:bank-sdk/
  example-app/src/androidTest/assets/invoice_future_due.jpeg`) into
  PDF so BrowserStack's `uploadMedia` surfaces it in Files.app
  Custom_Files; extraction is unchanged.
- `invoice_no_due_date.pdf` (~172 KB) — anonymized synthetic
  invoice that extracts **no** `paymentDueDate` (still `paymentState
  = ToBePaid`). Same PDF-wrap of the Android source
  `invoice_no_due_date.jpeg`.

Both fixtures are downloaded into
`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/TestSamples/TestSamplesForBS/`.
When the fixture needs to be regenerated (approaching mid-2028), pull the
current generator scripts from the Android repo at the path above and
re-validate the output against the Gini API before committing.

**Fixture-staleness strategy — threshold override, not fixture refresh.**
`FIXTURE_DUE_DATE = 2028-09-01` (Android-matched) is hard-coded as a
`Date` constant at the top of `PaymentHintFlowUITests.swift`.
Show/no-show cases are driven by overriding
`paymentDueHintThresholdDays` at runtime — the example app honors a
`-paymentDueHintThresholdDaysOverride <Int>` launch argument in
`#if DEBUG` builds. Each test computes
`remainingDays = daysBetween(today, FIXTURE_DUE_DATE)` at setup and
passes:

- `remainingDays - 1` (or default 5, whichever is smaller) → sheet
  shows (R1, R2, R7–R13)
- `remainingDays` exactly → boundary case, sheet still shows (R3, with
  midnight-skip guard)
- `remainingDays + 2` → sheet does not show (R4). `+ 1` still fires
  because `isDueSoon(within: N)` uses `daysUntilDue + 1 >= N`; the
  first strictly-non-firing threshold is `+ 2`.

The fixture stays valid until its encoded date actually becomes
today (approaching mid-2028). Regeneration deadline documented at
the top of the test file, matching Android's `DueDateFixtures.kt`
comment. Existing `sepa_due_date.pdf/.png` fixtures stay in the repo
untouched (they may be used by other suites).

### Threshold override wiring — example app

Extend the existing UITest-launch-argument hook in
`BankSDK/GiniBankSDKExample/GiniBankSDKExample/AppDelegate.swift` —
the function `applyUITestCleanStateLaunchArguments()` (lines 33–53)
already runs inside `#if DEBUG` early in
`didFinishLaunchingWithOptions` and already applies
`-DisableReturnAssistant` to `GiniBankConfiguration.shared`. Add a
value-carrying argument alongside it:

```swift
if let idx = CommandLine.arguments.firstIndex(
        of: "-paymentDueHintThresholdDaysOverride"),
   idx + 1 < CommandLine.arguments.count,
   let value = Int(CommandLine.arguments[idx + 1]) {
    GiniBankConfiguration.shared.paymentDueHintThresholdDays = value
}
```

Runs on the same line-of-code that today writes
`GiniBankConfiguration.shared.returnAssistantEnabled = false` — same
`#if DEBUG` gate (via the caller), same `CommandLine.arguments` idiom
— so this is a two-line extension of a proven hook, not a new
mechanism.

Verified in-session against `AppDelegate.swift:33-53`.

### BrowserStack script

New file
`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Scripts/bs_run_payment_hint.sh`
modeled 1:1 on `bs_run_smoke_tests.sh:1-77`. Differences:

- `ONLY_TESTING = '["GiniBankSDKExampleUITests/PaymentHintFlowUITests"]'`
- `buildName = "Payment Hints PP-3302"`
- `singleRunnerInvocation = "true"` — one `xcodebuild` invocation
  covers the whole class per device, avoiding per-test setup overhead.
- Uploads two PDF fixtures:
  `SAMPLES_DIR/invoice_no_due_date.pdf` and
  `SAMPLES_DIR/invoice_future_due.pdf`. PDFs are used (not JPEGs)
  because BrowserStack surfaces PDF `uploadMedia` files in Files.app
  "Custom_Files" — the tests select them by exact file name via
  `MainScreen.tapFileFromBestAvailableSource(fileName:)`. Each
  `upload_media` call passes the base name as `custom_id` so the
  display name in Custom_Files matches what the tests search for. No
  gallery-offset semantics.
- Runs across the latest iPhone on each currently-supported iOS
  major:
  `[\"iPhone 17-26\", \"iPhone 16-18\", \"iPhone 15-17\"]`. BS
  parallel cap is 2, so 2 devices run concurrently and the third
  queues.

Small update to `bs_shared.sh:33-41`: add
`bs_run_payment_hint) BUILD_LABEL="PaymentHint" ;;` to the case
statement so build artifacts get a meaningful label.

## Test plan

### Automated tests to add

- **`PaymentHintFlowUITests`** in
  `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/` — new file,
  XCTest / XCUITest (matches the neighboring
  `GiniCaptureFlowUITestsUsingBS.swift`; XCUITest is required — Swift
  Testing does not run under XCUITest bundles). Extends
  `GiniBankSDKExampleUITests` (the existing base class). Test count
  target: **11 methods** (1 helper is not a test):

  | Method | Covers |
  | --- | --- |
  | `testDueDateSheetAppearsWithDefaultThreshold` | R1 |
  | `testScheduleSheetAppearsWhenBothFlagsOn` | R2 (priority, due=ON) |
  | `testScheduleSheetAppearsWhenOnlyScheduleFlagOn` | R2 (due=OFF) |
  | `testSheetAppearsAtBoundaryThreshold` | R3 (with midnight-skip guard) |
  | `testSheetDoesNotAppearBelowThreshold` | R4 (with midnight-skip guard) |
  | `testFlagsOffProceedsDirectlyToExtraction` | R5 |
  | `testNoSheetWhenPaymentDueDateExtractionEmpty` | R6 (SHOULD — dropped if fixture can't be confirmed) |
  | `testDueDateProceedAnywayContinuesToExtraction` | R7 |
  | `testDueDateCancelTransferReturnsToMain` | R8 |
  | `testScheduleCTAFiresScheduleCallback` | R9 |
  | `testScheduleProceedAnywayContinuesToExtractionWithoutAlert` | R10 |
  | `testBackdropTapDoesNotDismissDueDate` | R11 (Due Date) |
  | `testBackdropTapDoesNotDismissSchedule` | R11 (Schedule) |
  | *(R12 automation deferred — see requirement note)* | R12 |
  | `testAXXXLDoesNotTruncateDueDateSheet` | R13 (Due Date) |
  | `testAXXXLDoesNotTruncateScheduleSheet` | R13 (Schedule) |

  Actual method count: **15** (R6 is conditional — 14 if the empty-
  due-date fixture cannot be confirmed). R12 is manual-only for now
  (see the requirement note in R12). Justification for count > 12:
  each requirement pins a distinct observable behavior on real
  hardware and cannot be collapsed — R7/R10 look similar but cover
  different sheet states and different negative assertions; the R11
  and R12 splits are per-state because each state exercises a
  different SDK code path (`.dueDate` vs `.schedulePayment` view-model
  factory). No test is a variation of another; they map 1:1 to the
  requirements above.

- **`PaymentHintScreen`** (Page Object, new file under
  `Screens/`) — no dedicated unit test, matching every other Page
  Object in the folder (`ReviewScreen.swift`, `SettingScreen.swift`,
  …). Its correctness is exercised transitively by
  `PaymentHintFlowUITests`.

- **`InfoBottomSheetViewController` + `PaymentHintBottomSheetViewController`
  a11y-identifier propagation** — extend the existing Swift Testing
  suite
  `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/PaymentHintBottomSheetViewControllerTests.swift`
  (Swift Testing framework, `@Suite`/`@Test` — matches the existing
  file). Add **4 new `@Test` methods** to the existing suite (extend
  rather than create — the file already covers this class):

  | Test | Covers |
  | --- | --- |
  | `dueDateStateAppliesAccessibilityIdentifiers` | R0 for `.dueDate` — view load then assert `headerLabel.accessibilityIdentifier == "paymentHint.dueDate.title"` etc. via key-path introspection or `view.subviews` walk (whichever the existing tests use — extend the same pattern) |
  | `scheduleStateAppliesAccessibilityIdentifiers` | R0 for `.schedulePayment` |
  | `viewCarriesContainerIdentifierForDueDate` | R0 container view |
  | `viewCarriesContainerIdentifierForSchedule` | R0 container view |

### BrowserStack runs

- **R14:** manual verification per this PR. Operator runs
  `Scripts/bs_run_payment_hint.sh` once with `BS_USER`/`BS_KEY` set
  from the shared credentials store. Success criteria: script exits
  0, build appears in the `GiniBankSDK-LiquidGlass-4.3.0` project on
  the BrowserStack dashboard with the expected 16–17 tests on both
  devices.
- **R15:** operator re-runs the same script four more times against
  the same commit (5 runs total) before merging. All tests must pass
  on every device in the matrix (`iPhone 17-26`, `iPhone 16-18`,
  `iPhone 15-17`) in every run (except R3/R4 tests that legitimately
  skipped near local midnight — those count as passes). Any method
  that flakes across the 5 runs is deleted from this PR before merge
  (or removed + refiled as follow-up — the ticket's AC forbids
  merging enabled flaky tests).

### Not tested

- **VoiceOver navigation order, contrast, external-keyboard
  operability, landscape orientation.** In manual QA scope per the
  a11y-coverage decision. The existing
  `InfoBottomSheetViewController.configureAccessibility()`
  (`CaptureSDK/.../InfoBottomSheet/InfoBottomSheetViewController.swift:337-368`)
  is already covered by unit-level assertions inside GiniCaptureSDK
  and does not regress under this PR.
- **Backend contract for `paymentScheduleHintEnabled` on
  `/configurations`.** Owned by PP-3260 (Done). Not re-verified here.
- **Copy correctness in EN/DE.** Covered by
  `PaymentHintBottomSheetViewControllerTests.swift` unit tests and
  by manual QA against Figma. Automated UI tests match on identifiers,
  not text — deliberate, so tests stay green across copy changes.
- **CaptureSuggestionsView localization key value.** R12 uses
  `contains` on the localized string; asserting a non-appearance is
  robust to copy changes at the level needed.
- **Paid-state suppression** (`paymentState = Paid` → sheet suppressed).
  Manual QA — no fixture in this repo is known to extract
  `paymentState = Paid` reliably; `sepa_already_paid.png` is candidate
  material but its extraction has not been verified for automation
  and it would exercise a code path outside PP-3302's scope.
- **Skonto and Return Assistant suppression.** Manual QA. These
  suppress the payment-hint sheet at the coordinator level per PP-3263
  precedence rules; existing unit tests
  (`NetworkingScreenApiCoordinatorTests+SchedulePaymentHint.swift`)
  cover the branch. Adding UI-level coverage would import the Return
  Assistant / Skonto flows into this test class, which are already
  sharded separately (`bs_run_ra.sh`, `bs_run_skonto.sh`).
- **Date-format variants** (dd/MM/yyyy, MM.dd.yyyy, etc.). Backend
  normalization concern; verifying requires distinct invoice
  documents per format. Manual QA.
- **Dark mode.** BrowserStack device configurations use the platform
  default (light). Dark-mode rendering of the sheet stays manual QA
  until the smoke matrix adds a dark-mode variant.
- **Tablet (iPad) rendering** and orientation matrix (landscape). The
  chosen device matrix is iPhone-only in portrait; the
  `shouldShowInFullScreenInLandscapeMode = true` code path
  (`InfoBottomSheetViewController.swift:99-101`) and the iPad-specific
  height override (`viewDidLayoutSubviews`) stay manual QA.
- **Input-channel variants** (camera capture, PDF upload, "Open with"
  from Files). The sheet's logic is channel-independent; one channel
  (file-import PDF/PNG) is exercised. Other channels are covered by
  neighboring BrowserStack suites (`bs_run_cx_normal.sh`,
  `bs_run_cx_multipage.sh`) — not re-run here.

## Out of scope

- **Fixture-refresh automation.** With the threshold-override
  strategy, `sepa_due_date` never needs periodic refresh — its date
  only matters as long as it stays in the future (many years for a
  mid-decade-target fixture). A one-time regeneration is in scope
  only if the current fixture encodes an inadequate date; recurring
  automated refresh is not.
- **Mocking `paymentDueDate` via a Charles-style proxy** or an
  extraction-injection seam. Rejected — the threshold override
  achieves the same test flexibility without adding an SDK test
  hook. If this ever proves insufficient (e.g. we need to test with
  a *past* due date), open a new ticket rather than smuggling an
  injection seam in here.
- **SwiftUI example variant** (`GiniBankSDKExampleSwiftUIUITests`).
  The UIKit example is authoritative for the Bank SDK integrator
  path; covering the SwiftUI variant is a separate ticket.
- **Adding BrowserStack triggering to GitHub Actions.** Kept
  operator-run to match every other `bs_run_*.sh` today.
- **Any change to the payment-hint SDK contract** —
  `paymentDueHintThresholdDays` default, schedule-callback
  signature, or the priority order (paid → schedule → due-date →
  proceed). Those are PP-3261 / PP-3263 territory and already
  shipped.

## Open questions

1. **~~Fixture validation~~ — RESOLVED.** Reused Android
   PP-3301's `invoice_future_due.pdf` fixture (already validated
   against the real Gini API on 2026-08-17 with the
   `gini-mobile-test` client). `FIXTURE_DUE_DATE = 2028-09-01`,
   `paymentState = ToBePaid`. Same backend guarantees identical
   extraction on iOS.

2. **~~Empty-`paymentDueDate` fixture~~ — RESOLVED.** Reused
   Android PP-3301's `invoice_no_due_date.pdf` fixture (validated
   as extracting *without* `paymentDueDate` on 2026-08-17). R6 is
   in scope with this fixture.

3. **PP-3260 server-flag sanity.** Proceeding under the
   assumption — matching Android's decision — that
   `/configurations` returns `paymentDueHintEnabled = true` and
   `paymentScheduleHintEnabled = true` for `gini-mobile-test` /
   `gini-mobile-ci`. Not re-verified before implementation. If the
   first BrowserStack run comes back uniformly red on
   sheet-shown tests, diagnose this before suspecting test code.
   (confidence: LOW — client-configuration state not visible from
   this repo)

## Implementation plan

- [x] 1. Download Android fixtures into iOS repo
      (`invoice_future_due.pdf`, `invoice_no_due_date.pdf` into
      `TestSamples/TestSamplesForBS/`).
      Blocks every test-writing step. (R1–R6)
- [x] 2. **SDK:** widen access on two subview declarations in
      `InfoBottomSheetViewController`
      (`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Custom views/InfoBottomSheet/InfoBottomSheetViewController.swift`)
      from `private let` to `let` — `headerLabel`, `descriptionLabel`.
      `buttonsViewContainer` (lazy var) already internal. No change
      to `InfoBottomSheetViewModel` protocol or
      `InfoBottomSheetButtonsViewModel` init. (R0)
- [x] 3. **SDK:** in `PaymentHintBottomSheetViewController`
      (`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/PaymentHint/PaymentHintBottomSheetViewController.swift`)
      add an `internal enum AccessibilityIdentifiers` with nested
      `DueDate` / `Schedule` enums (5 string constants each), store
      `state` as a property, and override `viewDidLoad()` to set the
      state-scoped identifiers on `view`, `headerLabel`,
      `descriptionLabel`, `buttonsViewContainer.primaryButton`, and
      `buttonsViewContainer.secondaryButton`. (R0)
- [x] 4. **SDK tests:** add 4 `@Test` methods to
      `PaymentHintBottomSheetViewControllerTests.swift`
      (`CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/`)
      verifying the identifiers propagate through the view hierarchy
      for both states. (R0 verification)
- [x] 5. **Example app:** extend
      `AppDelegate.applyUITestCleanStateLaunchArguments()`
      (`BankSDK/GiniBankSDKExample/GiniBankSDKExample/AppDelegate.swift`,
      lines 33–53) with a value-carrying
      `-paymentDueHintThresholdDaysOverride <Int>` read that sets
      `GiniBankConfiguration.shared.paymentDueHintThresholdDays`.
      (R3, R4)
- [x] 6. **Example app:** extend
      `SettingScreenAccessibilityIdentifiers`
      (`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/AccessibilityIdentifiers/SettingScreenAccessibilityIdentifiers.swift`)
      with `paymentDueHintSwitch = "paymentDueHintSwitchIdentifier"`
      and `paymentScheduleHintSwitch =
      "paymentScheduleHintSwitchIdentifier"`. Extend
      `SwitchOptionModel.accessibilityIdentifier`
      (`.../SettingsViewController+SwitchOptionModel.swift`) with
      matching cases. (R1, R2, R5)
- [x] 7. **UITests:** register `invoiceFutureDue = "invoice_future_due"`
      and `invoiceNoDueDate = "invoice_no_due_date"` in
      `TestFixtures.swift`. (R1–R6)
- [x] 8. **UITests:** create
      `AccessibilityIdentifiers/PaymentHintScreenAccessibilityIdentifiers.swift`
      mirroring the SDK's 10 identifier constants. (R0 wire-through)
- [x] 9. **UITests:** create `Screens/PaymentHintScreen.swift`
      Page Object (10 `XCUIElement` fields + helper waits, following
      `SettingScreen.swift` constructor pattern). (R1–R13)
- [x] 10. **UITests:** extend `Screens/SettingScreen.swift` with
       `paymentDueHintSwitch`, `paymentScheduleHintSwitch`, and a
       `setPaymentHintFlags(dueDate: Bool, schedule: Bool)` helper
       using the existing `disableSwitchIfOn(_:)` pattern. (R1, R2, R5)
- [x] 11. **UITests:** create
       `PaymentHintFlowUITests.swift`
       (`BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/`)
       extending `GiniBankSDKExampleUITests`. Includes
       `FIXTURE_DUE_DATE = 2028-09-01` constant, `remainingDays()`
       helper, midnight-skip guard, and the 17 test methods per
       the Test plan table. (R1–R13)
- [x] 12. **Scripts:** create
       `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Scripts/bs_run_payment_hint.sh`
       modeled on `bs_run_smoke_tests.sh`, restricted to the new
       test class, running on `$DEVICE_1` and `$DEVICE_2`. Extend
       `bs_shared.sh`'s `BUILD_LABEL` case statement with
       `bs_run_payment_hint) BUILD_LABEL="PaymentHint" ;;`. (R14)
- [x] 13. **Xcode project:** register the new files
       (PaymentHintScreenAccessibilityIdentifiers.swift,
       PaymentHintScreen.swift, PaymentHintFlowUITests.swift)
       plus the two new asset files with the
       `GiniBankSDKExampleUITests` target in
       `BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj/project.pbxproj`.
- [x] 14. **Verify:** SDK schemes compile clean —
       `xcodebuild build -scheme GiniCaptureSDK -destination
       'generic/platform=iOS'` and same for `GiniBankSDK` both report
       `** BUILD SUCCEEDED **` on 2026-08-25. Xcode-project
       (`plutil -lint`) OK. Example-app + UITest target compilation
       could not be verified on this dev machine due to a broken
       SwiftLint binary (SourceKitten crash — environment issue,
       unrelated to this PR); re-run in CI parity or on a machine
       with a healthy SwiftLint install. R14 (BrowserStack) and R15
       (5-run stability) are operator-run per the spec.

