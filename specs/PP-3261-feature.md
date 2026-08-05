# PP-3261: Due Date Hint bottom sheet on the Analysis screen

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3261

## Problem

When an invoice is being paid but the due date is comfortably in the future
(more than the configured threshold of days), the current SDK inlines a
"payment due date hint" on the Analysis screen (a `PaymentDueHintView` + a
5-second-countdown `DismissMessageView`, both stacked inside
`AnalysisViewController.contentStack`). The inline layout collides with the
analysis progress indicator and with the capture-suggestions banner that
appears after 4 seconds, has poor VoiceOver semantics (announcements race,
focus doesn't move), and auto-dismisses whether the user has read it or not.

PP-3261 replaces that inline hint with a **modal bottom sheet** presented on
top of the Analysis screen with a clear title, description, and two CTAs
("Cancel Transfer" and primary "Proceed Anyway"). The sheet is one component
with two states — Due Date Hint (this ticket) and Schedule Payment (separate
ticket) — chosen by two backend/client-configuration flags. The user
explicitly closes the sheet via one of the CTAs; no auto-dismiss, no
tap-outside-to-dismiss, no progress bar.

This spec covers only the **Due Date Hint state**. The Schedule Payment state
is an out-of-scope sibling that a later ticket will plug into the same
`InfoBottomSheetViewController` scaffold.

## Requirements

1. When extractions have been returned and:
   - `giniBankConfiguration.paymentDueHintEnabled == true`, **and**
   - `getDocumentPaymentDueDate(for:)` returns a non-nil `Date`, **and**
   - `paymentDueDateHandler != nil` (legacy guard preserved), **and**
   - Return Assistant / Skonto are not taking priority, **and**
   - the pre-existing `Date.isDueSoon(within: paymentDueHintThresholdDays)`
     predicate returns `true` (unchanged from the legacy inline-hint
     flow — fires when `daysUntilDue + 1 ≥ threshold`),
   then the Due Date Hint bottom sheet is presented over the Analysis
   screen.
   The `paymentScheduleHintEnabled` priority gate is owned by the
   Schedule-Payment sibling ticket; when that ticket adds the flag to
   `ClientConfiguration`, it also inserts the `paymentScheduleHintEnabled
   == false` clause in front of the guards above. PP-3261 does not
   reference the flag because the field does not exist on
   `ClientConfiguration` today.
2. Given the due date is today, in the past, or the remaining-days count is
   ≤ threshold, no sheet is shown and the flow continues as before.
3. The legacy inline hint is removed from the SDK's own flow: the
   `GiniBankNetworkingScreenApiCoordinator` no longer drives the
   `paymentDueDateHandler` (i.e. no longer calls
   `handler.handlePaymentDueDate(_:)` / `handler.clearPaymentDueDate(after:)`)
   inside `handleToBePaidCase`. The public API surface that backed the
   legacy hint stays intact and functional — see (4).
4. `PaymentDueDateProtocol`, `GiniScreenAPICoordinator.paymentDueDateHandler`,
   and the `AnalysisViewController` conformance (including the internal
   `PaymentDueHintView` and `DismissMessageView` and the localization keys
   that back them) all remain **unchanged and un-deprecated**. Integrators
   that implement the protocol on a custom handler and drive it themselves
   keep the same behavior they have today. This ticket only stops the SDK
   from invoking that path automatically — the API stays fully alive.
5. The `paymentDueDate` extraction is the same generic-extractions field the
   code reads today via
   `GiniBankNetworkingScreenApiCoordinator.getDocumentPaymentDueDate(for:)`
   (raw `"yyyy-MM-dd"`, parsed by `Date.date(from:)`). Extraction reading
   and the threshold check are **unchanged** — the same
   `Date.isDueSoon(within:)` predicate that gated the legacy inline hint
   now gates the new bottom sheet. Only the presentation channel changed:
   what used to route through `paymentDueDateHandler` now presents
   `DueDateHintBottomSheetViewController` directly from the coordinator.
6. Sheet content (from Figma):
   - EN title: `Your invoice is due on dd.MM.yyyy.` (date formatted via
     the existing `Date.toDisplayString()` extension).
   - DE title: `Deine Rechnung ist am dd.MM.yyyy fällig.`
   - EN description: `You could set it up as a scheduled transfer.`
   - DE description: `Du könntest sie als Terminüberweisung anlegen.`
   - EN primary CTA: `Proceed Anyway`
   - DE primary CTA: `Trotzdem fortfahren`
   - EN secondary CTA: `Cancel Transfer`
   - DE secondary CTA: `Überweisung abbrechen`
7. Tapping **Proceed Anyway** dismisses the sheet and continues the
   transaction flow (the same continuation that `handleToBePaidCase` calls
   today after the legacy hint clears).
8. Tapping **Cancel Transfer** dismisses the sheet and cancels the
   transaction, invoking the same path
   `presentDocumentMarkedAsPaidBottomSheet` uses on cancel
   (`didCancelCapturing()` after `screenAPINavigationController.dismiss`).
9. The sheet is modal:
   - `isModalInPresentation = true` (blocks pull-to-dismiss).
   - `shouldShowDragIndicator == false` (inherited default from
     `InfoBottomSheetViewController`).
   - Tap-outside does not dismiss (already the `UISheetPresentationController`
     behavior when `isModalInPresentation == true`).
   - No auto-dismiss, no timer, no progress bar.
10. While the sheet is being presented, the 4-second-delayed
    `CaptureSuggestionsView` on the Analysis screen must not appear. This
    prevents VoiceOver from announcing suggestion hints on top of the modal.
    Implementation is a new `Bool` guard on the Analysis screen (see
    design) — no configuration change surfaces to integrators.
11. Accessibility (matches the `InfoBottomSheetViewController` +
    `GiniBottomSheetViewController` precedent, no new custom code):
    - `accessibilityViewIsModal = true` set after presentation.
    - `.screenChanged` accessibility notification posted so VoiceOver focus
      moves to the sheet.
    - Explicit `accessibilityElements` order: title → description →
      primary button → secondary button (icon added in front for portrait
      only — reuses `InfoBottomSheetViewController.configureAccessibility`).
    - Labels support Dynamic Type through
      `GiniConfiguration.shared.textStyleFonts[.title2] / .body`; buttons via
      `[.bodyBold]`. No truncation: `numberOfLines = 0` on labels;
      `configureBottomSheet(shouldIncludeLargeDetent:)` returns large detent
      when `GiniAccessibility.isFontSizeAtLeastAccessibilityMedium` is true.
    - Landscape: parent class handles constraint adjustment in
      `adjustPhoneLayoutForCurrentOrientation`; iPhone hides the icon
      container in landscape; iPad keeps `bottomSheetHeightIPad = 439`.
    - WCAG AA contrast is inherited from the existing `GiniCapture.dark1/6/7`
      / `light1/dark3` palette used by the sibling
      `DocumentMarkedAsPaidViewController`.
    - Fully operable with an external keyboard: primary/secondary buttons in
      `ButtonsView` are stock `UIButton`s, focusable via the standard iOS
      full-keyboard-access chain — no custom key handling required.

## Affected modules

- **GiniCaptureSDK** — new public bottom-sheet ViewController and its
  localization entries; new internal `CaptureSuggestionsView` suppression
  flag on `AnalysisViewController`. No deletions. `PaymentDueHintView`,
  `DismissMessageView`, `PaymentDueDateProtocol`,
  `paymentDueDateHandler`, and the `AnalysisViewController` conformance
  stay in place unchanged. Minimum deployment target: iOS 15+
  (unchanged).
- **GiniBankSDK** — depends on `GiniCaptureSDK`. Rewrites
  `GiniBankNetworkingScreenApiCoordinator.handleToBePaidCase(_:_:)` to
  present the new sheet instead of driving the legacy handler. Adds a
  `presentDueDateHintBottomSheet(...)` method that mirrors
  `presentDocumentMarkedAsPaidBottomSheet(_:onProceedTapped:)`. Renaming
  of the sheet-container VC to a two-state class is out of scope — this
  spec introduces the Due-Date-only VC; the Schedule-Payment ticket will
  extend it.

No changes to `GiniBankAPILibrary`, `GiniHealthAPILibrary`, `GiniUtilites`,
`GiniInternalPaymentSDK`, `GiniHealthSDK`.

## Public API impact

**Additive only.** No deprecations, no removals, no signature changes.
Every declaration on the current integrator-visible surface stays as-is.

**GiniCaptureSDK (public):**
- **New** `public final class DueDateHintBottomSheetViewController: InfoBottomSheetViewController`
  with a `public init(formattedDueDate: String, onCancel: @escaping () -> Void,
  onProceed: @escaping () -> Void)`. Mirrors
  `DocumentMarkedAsPaidViewController`. Located at
  `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/DueDateHint/DueDateHintBottomSheetViewController.swift`.
- **Unchanged.** `public protocol PaymentDueDateProtocol` and
  `public weak var paymentDueDateHandler: PaymentDueDateProtocol?` on
  `GiniScreenAPICoordinator` keep their current signatures, doc comments,
  and are not deprecated. Integrators that supply their own handler retain
  the same callable surface.
- **Unchanged.** `AnalysisViewController`'s conformance to
  `PaymentDueDateProtocol` — `handlePaymentDueDate(_:)` and
  `clearPaymentDueDate(after:)` — plus the internal `PaymentDueHintView`,
  `DismissMessageView`, and their localization keys
  (`ginicapture.payment.due.hint.prefix`,
  `ginicapture.payment.due.hint.suggestion`,
  `ginicapture.dismiss.message.title`) all stay. They become dead
  paths only from the SDK's own coordinator side; any external caller
  invoking `handlePaymentDueDate(_:)` on an `AnalysisViewController`
  instance directly (unusual, but possible) still gets the current
  behavior.
- **New public hooks on `AnalysisViewController`** (additive, needed
  for cross-module wiring from GiniBankSDK):
  - `public var shouldSuppressCaptureSuggestions: Bool = false`
  - `public func removeCaptureSuggestions()` (was `private`; body
    unchanged).

**GiniBankSDK (public):**
- None. All changes live inside
  `GiniBankNetworkingScreenApiCoordinator` (internal helper methods).
- `paymentDueHintEnabled` and `paymentDueHintThresholdDays` on
  `GiniBankConfiguration` are unchanged.
- `paymentScheduleHintEnabled` is not introduced by this spec.

Because the change is additive, no `Package-release.swift` bumps or
semver-major considerations are triggered.

## Technical conventions

Grounded in `platform.md` and the modules touched:

1. **Language & access control.** Swift. New types default to `internal`;
   `DueDateHintBottomSheetViewController` and its `public init` are the
   only `public` additions — justified above. Doc comments follow
   `AGENTS.md`: `/** ... */` for declarations, `///` reserved for
   in-body explanatory comments.
2. **UI framework.** UIKit. The Analysis screen (`AnalysisViewController`),
   the bottom-sheet container (`GiniBottomSheetViewController`), and the
   sibling `DocumentMarkedAsPaidViewController` are all UIKit. Per
   `platform.md` §UI-rules, extending an existing UIKit screen inside
   CaptureSDK stays UIKit — no SwiftUI mixing in this ticket.
3. **Colors.** Reuse the `GiniColor(light: .GiniCapture.*, dark: .GiniCapture.*)`
   palette that `InfoBottomSheetViewController` and
   `DocumentMarkedAsPaidViewController` already use — `light1/dark3` for
   sheet background, `dark1/light1` for title, `dark6/dark7` for
   description, `warning5` for icon container background. `GiniColorScheme`
   is not introduced here: the sibling stays on the legacy `GiniColor`
   wrapper for cross-CaptureSDK consistency (`platform.md` explicitly
   permits this inside CaptureSDK).
4. **Typography.** Dynamic Type via
   `GiniConfiguration.shared.textStyleFonts[.title2]` (title),
   `[.body]` (description), `[.bodyBold]` (buttons) — all inherited from
   `InfoBottomSheetViewController` / `ButtonsView`. `adjustsFontForContentSizeCategory = true` is set by the parent.
5. **Spacing.** No new spacing constants outside the parent's
   `InfoBottomSheetViewController.Constants`. If any local override is
   needed on the new subclass it goes into a local `private enum Constants`.
6. **Architecture.** UIKit MVVM. The new VC follows the existing pattern:
   two private content structs implementing `InfoBottomSheetViewModel` and
   `InfoBottomSheetButtonsViewModel` are constructed in the VC's `init`,
   as in `DocumentMarkedAsPaidViewController`. No new coordinator is
   introduced — presentation stays on the existing
   `GiniBankNetworkingScreenApiCoordinator`. Because the trigger is a
   coordinator method and the sheet has no interactive state beyond
   button taps, this ticket does not introduce a separate
   `DueDateHintViewModel` / `DueDateHintCoordinator` pair; the two closures
   supplied by the coordinator (`onCancel`, `onProceed`) are the entire
   ViewModel↔Coordinator surface, matching the sibling precedent
   (`DocumentMarkedAsPaidViewController`).
7. **Wiring.** Constructor injection: `dueDate`, `onCancel`, `onProceed`
   are all passed via `init`. No delegate back-references. Async style:
   the coordinator's `handleToBePaidCase(_:_:)` remains
   `@MainActor`-annotated; the inline `Task { … await handler.clearPaymentDueDate(after: 5) … }`
   auto-dismiss block is removed and replaced with a synchronous
   `presentDueDateHintBottomSheet(...)` call whose completions are the
   sheet's CTA closures.
8. **Localization.** New keys in
   `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/{en,de}.lproj/Localizable.strings`,
   accessed via `NSLocalizedStringPreferredFormat(key, comment:)` (matches
   the sibling `DocumentMarkedAsPaidViewController.Strings` pattern) —
   the codebase does not use a typed `LocalizableStringResource` enum for
   CaptureSDK strings today, so this spec matches neighboring code rather
   than importing a new pattern. New keys (following the
   `<sdk>.<feature>.<screen>.<element>` convention adapted to CaptureSDK's
   dotted style):
   - `ginicapture.payment.duedate.hint.title.format` — value with a
     single `%@` for the formatted date.
   - `ginicapture.payment.duedate.hint.description`
   - `ginicapture.payment.duedate.hint.proceedButtonTitle`
   - `ginicapture.payment.duedate.hint.cancelButtonTitle`

   The legacy keys `ginicapture.payment.due.hint.prefix`,
   `ginicapture.payment.due.hint.suggestion`, and
   `ginicapture.dismiss.message.title` are **kept** — they still back the
   preserved `PaymentDueHintView` / `DismissMessageView` API path.
9. **Quality gates.** `make lint scheme=GiniBankSDK` and `make lint
   scheme=GiniCaptureSDK` must be clean (local runs on
   `iPhone 15 Pro / iOS 17.2`; CI on `iPhone 17 / iOS 26.2` per
   `AGENTS.md` — re-run failing checks in CI parity before pushing).
   Multi-parameter formatting per `CLAUDE.md` §Code Style
   (first parameter on the opening-paren line; each subsequent parameter
   on a new line, vertically aligned).
10. **Test framework.** New CaptureSDK VC unit test uses **Swift Testing**
    (`@Suite`, `@Test`, `#expect`) to match the neighboring
    `AnalysisViewControllerPaymentDueHintTests` file that it replaces.
    New BankSDK coordinator test uses **XCTest** (matches
    `NetworkingScreenApiCoordinatorTests+CX.swift`).

## Design

### Class map (new)

```
GiniCaptureSDK
└── Core/Screens/DueDateHint/
    └── DueDateHintBottomSheetViewController.swift        (public, new)
                             ↑
                             │  extends
                             │
        InfoBottomSheetViewController  (existing, unchanged)
                             │
                             │  is-a
                             ↓
        GiniBottomSheetViewController  (existing, unchanged)
```

`DueDateHintBottomSheetViewController` composes:

- `private struct DueDateHintContentViewModel: InfoBottomSheetViewModel`
  with `image`, `imageTintColor`, `title` (formatted with the passed
  `Date`), `description`.
- `private struct DueDateHintStrings` — same shape as
  `DocumentMarkedAsPaidViewController.Strings`. Title uses
  `String(format: NSLocalizedStringPreferredFormat("ginicapture.payment.duedate.hint.title.format", comment: ...), formattedDate)`
  where `formattedDate = date.toDisplayString()` (existing
  `dd.MM.yyyy` formatter at
  `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Extensions/Foundation/Date+Formatting.swift`
  — accessible only inside GiniBankSDK; the CaptureSDK VC therefore
  takes a **preformatted string**, not a `Date` — see revised init below).

Revised init to keep the formatter in GiniBankSDK where it lives today:

```swift
public init(formattedDueDate: String,
            onCancel: @escaping () -> Void,
            onProceed: @escaping () -> Void)
```

`GiniBankNetworkingScreenApiCoordinator` supplies
`dueDate.toDisplayString()` at the call site — same string it passes to
the legacy `handler.handlePaymentDueDate` today (line 579).

### Coordinator flow (`GiniBankNetworkingScreenApiCoordinator.swift`)

Existing `handleToBePaidCase` (lines 564–586) is rewritten. The full
legacy guard chain is preserved verbatim inside an internal predicate
`shouldPresentDueDateHint(for:)` — same field reads, same
`Date.isDueSoon(within: threshold)` check:

```swift
func shouldPresentDueDateHint(for extractionResult: ExtractionResult) -> Bool {
    guard determineIfPaymentDueHintEnabled(for: extractionResult),
          let dueDate = getDocumentPaymentDueDate(for: extractionResult),
          paymentDueDateHandler != nil,
          !shouldShowReturnAssistant(for: extractionResult),
          !shouldShowSkonto(for: extractionResult) else {
        return false
    }
    return dueDate.isDueSoon(within: giniBankConfiguration.paymentDueHintThresholdDays)
}
```

`handleToBePaidCase` becomes a thin caller:

```swift
guard shouldPresentDueDateHint(for: extractionResult),
      let dueDate = getDocumentPaymentDueDate(for: extractionResult) else {
    continueWithFeatureFlow()
    return
}
presentDueDateHintBottomSheet(dueDate: dueDate,
                              onProceed: continueWithFeatureFlow)
```

New sibling to `presentDocumentMarkedAsPaidBottomSheet(_:onProceedTapped:)`:

```swift
private func presentDueDateHintBottomSheet(dueDate: Date,
                                           extractionResult: ExtractionResult,
                                           onProceed: @escaping () -> Void) {
    let vc = DueDateHintBottomSheetViewController(
        formattedDueDate: dueDate.toDisplayString(),
        onCancel: { [weak self] in
            self?.screenAPINavigationController.dismiss(animated: true) {
                self?.didCancelCapturing()
            }
        },
        onProceed: { [weak self] in
            self?.handleSavingPhotos(for: extractionResult)
            self?.screenAPINavigationController.dismiss(animated: true) {
                onProceed()
            }
        }
    )
    vc.isModalInPresentation = true
    vc.presentAsBottomSheet(from: screenAPINavigationController)
}
```

`handleSavingPhotos(for:)` on the proceed branch is copied from the
`presentDocumentMarkedAsPaidBottomSheet` precedent so the "save photo
locally" contract stays consistent when the user proceeds past a hint.

### Date helpers

`Date+Formatting.swift` is **unchanged**. `Date.isDueSoon(within:)`
remains the only threshold predicate — no new Date helpers are added.

### Analysis screen changes

`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Analysis/AnalysisViewController.swift`:

- **Keep** `hintView: PaymentDueHintView` (line 135), `dismissView`, and
  every helper under the `// MARK: - Handling UI - Payment DueHint`
  region. They preserve the public `PaymentDueDateProtocol` behavior
  for integrators that drive it themselves.
- **Keep** the `PaymentDueDateProtocol` conformance and both method
  bodies unchanged.
- **Keep** `PaymentDueHintView.swift` and `DismissMessageView.swift` in
  place, unchanged.
- The behavior change is confined to the coordinator — see
  §Coordinator flow. From the SDK's own flow, `handlePaymentDueDate` is
  simply never called anymore.

Suppression of the 4-second `CaptureSuggestionsView`:

- Add an internal `var shouldSuppressCaptureSuggestions: Bool = false` on
  `AnalysisViewController`.
- Guard the `showCaptureSuggestions()` call in `viewDidLoad()` (line 195)
  with `guard !shouldSuppressCaptureSuggestions else { return }`.
- In `GiniBankNetworkingScreenApiCoordinator.presentDueDateHintBottomSheet`,
  before calling `presentAsBottomSheet`, set
  `(screenAPINavigationController.children.last as? AnalysisViewController)?.shouldSuppressCaptureSuggestions = true`
  and, in both cancel/proceed dismissal closures, reset the flag to
  `false` and call `analysisVC.removeCaptureSuggestions()` (already an
  existing method).

This is deliberately internal state — no new public API — because the
suggestions banner is not something integrators toggle today.

### Sheet content plumbing

```swift
private struct DueDateHintContentViewModel: InfoBottomSheetViewModel {
    var image: UIImage? = UIImageNamedPreferred(named: "infoMessageIcon")
    var imageTintColor: UIColor? = GiniColor(light: .GiniCapture.warning2,
                                             dark: .GiniCapture.warning2).uiColor()
    var title: String
    var description: String = DueDateHintBottomSheetViewController.Strings.description
}

public final class DueDateHintBottomSheetViewController: InfoBottomSheetViewController {
    public init(formattedDueDate: String,
                onCancel: @escaping () -> Void,
                onProceed: @escaping () -> Void) {
        let title = String(format: Strings.titleFormat, formattedDueDate)
        let content = DueDateHintContentViewModel(title: title)

        // "Proceed Anyway" is primary; "Cancel Transfer" is secondary.
        let primary = InfoBottomSheetButtonsViewModel.Button(title: Strings.proceedButton,
                                                             action: onProceed)
        let secondary = InfoBottomSheetButtonsViewModel.Button(title: Strings.cancelButton,
                                                               action: onCancel)
        let buttons = InfoBottomSheetButtonsViewModel(primary, secondary)

        super.init(viewModel: content, buttonsViewModel: buttons)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
```

Note the button order reversal vs. `DocumentMarkedAsPaidViewController`
(which puts Cancel as primary): PP-3261 Figma + confirmed copy have
"Proceed Anyway" as the primary CTA for Due Date, but "Cancel Transfer"
remains primary for Marked-as-Paid. The Schedule-Payment sibling ticket
will use "Schedule Payment" as primary — three distinct CTA
configurations, all expressible with the same
`InfoBottomSheetButtonsViewModel` primary/secondary pairing.

### Diagram

```
Analysis screen           GiniBankNetworkingScreenApiCoordinator
      │                                    │
      │ extractions returned               │
      │ ─────────────────────────────────► │
      │                                    │
      │              handleToBePaidCase    │
      │                     │              │
      │                     │ paymentDueHintEnabled?
      │                     │ paymentDueDate valid?
      │                     │ paymentDueDateHandler != nil?
      │                     │ dueDate.isDueSoon(within: threshold)?
      │                     │
      │                     ├── no ─► continueWithFeatureFlow()
      │                     │
      │                     └── yes ─► shouldSuppressCaptureSuggestions = true
      │                                presentDueDateHintBottomSheet(...)
      │◄─────────────────────────── modal bottom sheet
      │
      │      Cancel Transfer  ─► dismiss + didCancelCapturing() → bank app
      │      Proceed Anyway   ─► dismiss + continueWithFeatureFlow()
```

## Test plan

Every new/changed class gets a unit test. Landscape rendering, VoiceOver
reading order, dynamic-font non-truncation, external-keyboard operability,
and WCAG AA contrast are covered by manual QA per the ticket AC.

### GiniCaptureSDK (Swift Testing — `@Suite`/`@Test`/`#expect`)

**Location:** `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/DueDateHintBottomSheetViewControllerTests.swift`
(new). The existing `AnalysisViewControllerPaymentDueHintTests.swift`
stays — it still validates the preserved
`handlePaymentDueDate(_:)` / `clearPaymentDueDate(after:)` behavior.

- `@Suite("DueDateHintBottomSheetViewController")` with tests for:
  - Title is formatted with the passed `formattedDueDate` (verify via
    `viewDidLoad` + reading the private header via test-only
    `accessibilityLabel` on the title label, matching the pattern the
    deleted `AnalysisViewControllerPaymentDueHintTests` used to peek
    into subviews).
  - Primary button tap invokes `onProceed`; secondary button tap invokes
    `onCancel` (use expectation closures passed at init).
  - `isModalInPresentation` is set by the caller — assert via a small
    presenting-VC harness that constructs the sheet + calls
    `presentAsBottomSheet` and inspects
    `presentedViewController?.isModalInPresentation`.
  - Localization: EN and DE bundle lookups resolve the four new keys
    (guard against typo drift). Test bundle already ships EN + DE.
  - Accessibility elements order equals
    `[title, description, primary, secondary]` (in portrait; landscape
    is a manual-QA target).

**Location:** `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/AnalysisViewControllerCaptureSuggestionsSuppressionTests.swift`
(new).

- `@Test` — when `shouldSuppressCaptureSuggestions == true` before
  `viewDidLoad`, the `CaptureSuggestionsView` is not added to the view
  hierarchy after the 4-second delay (advance a mocked scheduler / use
  `withCheckedContinuation` — reuse the timing helper from the
  preserved `AnalysisViewControllerPaymentDueHintTests` suite).
- `@Test` — flipping the flag back to `false` and calling
  `removeCaptureSuggestions()` does not crash and leaves the hierarchy
  clean.

### GiniBankSDK (XCTest)

**Location:** `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+DueDateHint.swift`
(new file, matches the pattern of `+CX.swift`).

- `func testDueDateHintSheetPresentedWhenAllGatesPass()` — configure
  `paymentDueHintEnabled = true`, feed a mock `ClientConfiguration` with
  `paymentScheduleHintEnabled = false`, extraction with `paymentDueDate`
  = today + 10 days, threshold 5. Expect
  `presentDueDateHintBottomSheet` invoked (verify via a subclass hook or
  a mock `screenAPINavigationController`).
- `func testDueDateHintNotPresentedWhenDueTodayOrPast()` — parameterize
  with dates: today, yesterday, 5 days ago. Expect no sheet.
- `func testDueDateHintNotPresentedWhenRemainingDaysAtOrBelowThreshold()`
  — threshold 5, dueDate = today + 5 (edge: 5 is NOT > 5). Expect no
  sheet. Then dueDate = today + 6 → expect sheet.
- `func testDueDateHintThresholdRespectsConfiguration()` — override
  `paymentDueHintThresholdDays = 3`, dueDate = today + 4 → expect sheet.
- `func testDueDateHintDoesNotSurfaceWhenReturnAssistantWins()` — same
  gate carried over from `handleToBePaidCase` today; assert precedence.
- `func testDueDateHintDoesNotSurfaceWhenSkontoWins()` — analogous.

### Manual QA (per the ticket AC)

- Dynamic Type at every accessibility size (up to `.accessibility5`) —
  no truncation, no overlap between title/description/buttons.
- VoiceOver: focus moves to the sheet on appear; order reads title →
  description → Proceed Anyway → Cancel Transfer.
- Landscape iPhone (with and without notch) and landscape iPad.
- Full-keyboard-access chain: Tab / Space / Enter through both buttons.
- WCAG AA contrast on both light and dark mode (Xcode Accessibility
  Inspector Audit).
- Confirmation that the 4-second capture-suggestions banner does NOT
  appear while the sheet is shown, and DOES appear on a subsequent
  Analysis run where no hint fires.
- Cancel Transfer returns to the bank app (SDK dismissal path).
- Proceed Anyway continues to the extraction result screen.

## Out of scope

- **Schedule Payment state** of the bottom sheet — separate ticket.
  This spec does not add `paymentScheduleHintEnabled` to
  `GiniBankConfiguration` / `ClientConfiguration`, does not add the
  "Schedule Payment" CTA copy or localization keys, and does not
  implement the callback that hands scheduling off to the bank app.
- **Liquid Glass** variant of the sheet (the second Figma link). Ships
  as a follow-up.
- **`paymentDueHintThresholdDays` minimum clamp** for schedule-payment
  banks (see Open questions). Out of scope until Schedule Payment lands.
- Renaming `DueDateHintBottomSheetViewController` to a two-state name
  (e.g. `PaymentHintBottomSheetViewController`). The Schedule-Payment
  ticket will decide whether to promote it or add a sibling.
- Any change to `GiniHealthSDK`, `GiniInternalPaymentSDK`,
  `GiniBankAPILibrary`, `GiniHealthAPILibrary`, `GiniUtilites`.
- `GiniBankSDKExample` settings changes — the `paymentDueHintEnabled`
  toggle at
  `BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewModel.swift:194`
  stays as-is. A `paymentScheduleHintEnabled` toggle will be added by
  its owning ticket.
- Analytics — no new tracking events are prescribed by the ticket. If
  a follow-up wants them, they're additive to the existing tracking
  delegates.
- Snapshot tests — no snapshot library exists in the repo (per
  `platform.md` §Test-stack).

## Open questions

1. **`paymentDueHintThresholdDays` minimum**: the Confluence source
   proposes a hard floor of 5 (avoids weekend/bank-holiday races) at
   least when Schedule Payment is enabled. Not adding it in PP-3261,
   but confirming: is the accepted design to leave overrides free until
   Schedule Payment lands, or clamp `< 5 → 5` proactively even for
   Due-Date-only banks now?
