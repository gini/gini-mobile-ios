# PP-3261: Due Date Hint bottom sheet on the Analysis screen

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3261

## Problem

When an invoice is being paid but the due date is comfortably in the future
(more than the configured threshold of days), the current SDK inlines a
"payment due date hint" on the Analysis screen (a `PaymentDueHintView` + a
5-second-countdown `DismissMessageView`, both stacked inside
`AnalysisViewController.contentStack`). The inline layout collides with the capture-suggestions 
banner that appears after 4 seconds,
and auto-dismisses whether the user has read it or not.

PP-3261 replaces that inline hint with a **modal bottom sheet** presented on
top of the Analysis screen with a clear title, description, and two CTAs
("Cancel Transfer" and primary "Proceed Anyway"). The sheet is one component
with two states — Due Date Hint (this ticket) and Schedule Payment (separate
ticket) — chosen by different client feature flags. The user
explicitly closes the sheet via one of the CTAs; no
tap-outside-to-dismiss.

This spec covers only the **Due Date Hint state**. The Schedule Payment state
is an out-of-scope sibling that a later ticket will plug into the same
`InfoBottomSheetViewController` scaffold.

## Requirements

1. When extractions have been returned and:
   - `giniBankConfiguration.paymentDueHintEnabled == true`, **and**
   - `getDocumentPaymentDueDate(for:)` returns a non-nil `Date`, **and**
   - Return Assistant / Skonto are not shown in this flow, **and**
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
   strictly less than the threshold, no bottom sheet is shown and the flow continues as before.
3. The legacy inline hint is removed from the SDK's own flow: the
   `GiniBankNetworkingScreenApiCoordinator` no longer drives the
   `paymentDueDateHandler` (which itself has been deleted — see (4))
   inside `handleToBePaidCase`. Presentation now goes through a new
   `presentDueDateHintBottomSheet(dueDate:onProceed:)` helper.
4. `PaymentDueDateProtocol`, `GiniScreenAPICoordinator.paymentDueDateHandler`,
   the `AnalysisViewController` conformance
   (`handlePaymentDueDate(_:)` / `clearPaymentDueDate(after:)`), the
   supporting `PaymentDueHintView` and `DismissMessageView`, and the
   scrolling-stack infra that hosted them are **removed**. The legacy
   localization keys (`ginicapture.payment.due.hint.prefix`,
   `ginicapture.payment.due.hint.suggestion`,
   `ginicapture.dismiss.message.title`) are removed with them; new keys
   under `ginicapture.payment.duedate.hint.*` back the new sheet. This is
   a source-breaking API change for integrators who supplied their own
   `paymentDueDateHandler`; per the ticket decision it lands without a
   deprecation cycle, matching the parallel decision on Android PR #965
   (`PaymentDueHintDismissListener`/`PaymentDueHintContent`/`PaymentDueHintColors`
   removed outright). Release notes must call it out and the SDK version
   tag needs a major-version bump per SemVer.
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
10. While the sheet is being presented, any pending
    `CaptureSuggestionsView` banner on the Analysis screen must be cleared.
    This prevents VoiceOver from announcing suggestion hints on top of the
    modal. Implementation: the coordinator calls the pre-existing
    `AnalysisViewController.removeCaptureSuggestions()` (elevated to
    `public` in this ticket) before presenting the sheet — no new state
    flag, matching the Android approach in PR #965 (`stopAndHideHints()`).
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

- **GiniCaptureSDK** — new public `DueDateHintBottomSheetViewController`
  and its localization entries. Removes `PaymentDueDateProtocol`,
  `GiniScreenAPICoordinator.paymentDueDateHandler`, the
  `AnalysisViewController` conformance, `PaymentDueHintView.swift`,
  `DismissMessageView.swift`, and the supporting `scrollView` /
  `contentStack` / `setupScrollableStackView` /
  `updateContentStackConstraints` infrastructure. Elevates
  `AnalysisViewController.removeCaptureSuggestions()` from `private` to
  `public` so the coordinator can clear the pending
  `CaptureSuggestionsView` banner before presenting the sheet. Minimum
  deployment target: iOS 15+ (unchanged).
- **GiniBankSDK** — depends on `GiniCaptureSDK`. Rewrites
  `GiniBankNetworkingScreenApiCoordinator.handleToBePaidCase(_:_:)` to
  present the new sheet instead of driving the legacy handler. Adds an
  internal `presentDueDateHintBottomSheet(dueDate:onProceed:)` helper
  (mirrors `presentDocumentMarkedAsPaidBottomSheet(_:onProceedTapped:)`)
  and an internal `shouldPresentDueDateHint(for:)` predicate that
  consolidates the gate. Renaming of the sheet-container VC to a
  two-state class is out of scope — this spec introduces the
  Due-Date-only VC; the Schedule-Payment ticket will extend it. Minimum
  deployment target: iOS 15+ (unchanged).

No changes to `GiniBankAPILibrary`, `GiniHealthAPILibrary`, `GiniUtilites`,
`GiniInternalPaymentSDK`, `GiniHealthSDK`.

## Public API impact

**Source-breaking.** The legacy inline-hint public surface is removed
outright (no deprecation cycle) per the ticket decision and in parity
with Android PR #965. This requires a major-version bump on GiniCaptureSDK.

**GiniCaptureSDK (public):**
- **New.** `public final class DueDateHintBottomSheetViewController:
  InfoBottomSheetViewController` with `public init(formattedDueDate:
  String, onCancel: @escaping () -> Void, onProceed: @escaping () -> Void)`.
  Mirrors `DocumentMarkedAsPaidViewController`. Located at
  `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/DueDateHint/DueDateHintBottomSheetViewController.swift`.
- **Removed.** `public protocol PaymentDueDateProtocol` and
  `public weak var paymentDueDateHandler: PaymentDueDateProtocol?` on
  `GiniScreenAPICoordinator`; the `AnalysisViewController` conformance
  and its `handlePaymentDueDate(_:)` / `clearPaymentDueDate(after:)`
  method bodies; the internal `PaymentDueHintView` and
  `DismissMessageView`; and the scrolling-stack infra
  (`scrollView`, `contentStack`, `setupScrollableStackView`,
  `updateContentStackConstraints`) that hosted them.
- **Removed localization keys.** `ginicapture.payment.due.hint.prefix`,
  `ginicapture.payment.due.hint.suggestion`,
  `ginicapture.dismiss.message.title` are deleted from both
  `en.lproj` and `de.lproj`. Integrator overrides for these keys become
  no-ops at runtime.
- **Visibility change.** `AnalysisViewController.removeCaptureSuggestions()`
  is elevated from `private` to `public` (body unchanged). The
  coordinator uses it to clear a pending capture-suggestions banner
  before presenting the sheet. No new `Bool` flag is added — the earlier
  draft's `shouldSuppressCaptureSuggestions` flag was discarded because
  the guard it inserted only ran during `viewDidLoad`, before the
  coordinator ever set it (Android reaches the same conclusion — its
  `stopAndHideHints()` is a synchronous stop + hide, no future-suppression
  flag).

**GiniBankSDK (public):**
- None. All changes live inside
  `GiniBankNetworkingScreenApiCoordinator` (internal helper methods:
  `shouldPresentDueDateHint(for:)` and `presentDueDateHintBottomSheet(dueDate:onProceed:)`).
- `paymentDueHintEnabled` and `paymentDueHintThresholdDays` on
  `GiniBankConfiguration` are unchanged.
- `paymentScheduleHintEnabled` is not introduced by this spec.

Requires `Package-release.swift` bump on `GiniCaptureSDK` and any
release-repo dependents, plus a major-version SemVer bump.

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
   `ginicapture.dismiss.message.title` are **removed** in both `en.lproj`
   and `de.lproj`, along with the deprecated header/footer banners.
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
          !shouldShowReturnAssistant(for: extractionResult),
          !shouldShowSkonto(for: extractionResult) else {
        return false
    }
    return dueDate.isDueSoon(within: giniBankConfiguration.paymentDueHintThresholdDays)
}
```

The legacy `paymentDueDateHandler != nil` clause is gone because the
handler property no longer exists (see §Public API impact).

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
@MainActor
func presentDueDateHintBottomSheet(dueDate: Date,
                                   onProceed: @escaping () -> Void) {
    /// Cancel the pending capture-suggestions banner so it doesn't collide
    /// with the sheet's VoiceOver focus while the sheet is up.
    let analysisVC = screenAPINavigationController.children.last as? AnalysisViewController
    analysisVC?.removeCaptureSuggestions()

    let sheet = DueDateHintBottomSheetViewController(
        formattedDueDate: dueDate.toDisplayString(),
        onCancel: { [weak self] in
            guard let self else { return }
            self.screenAPINavigationController.dismiss(animated: true) {
                /// Restore accessibility on the presenter — `presentAsBottomSheet`
                /// hides the presenter's view from VoiceOver on presentation and
                /// leaves it hidden when the sheet goes away.
                self.screenAPINavigationController.view.accessibilityElementsHidden = false
                self.didCancelCapturing()
            }
        },
        onProceed: { [weak self] in
            guard let self else { return }
            self.screenAPINavigationController.dismiss(animated: true) {
                self.screenAPINavigationController.view.accessibilityElementsHidden = false
                onProceed()
            }
        }
    )
    sheet.isModalInPresentation = true
    sheet.presentAsBottomSheet(from: screenAPINavigationController)
}
```

Notes:
- The helper is `internal` (not `private`) so the flow-level tests can
  drive it — same testability pattern used for
  `shouldPresentDueDateHint(for:)`.
- `handleSavingPhotos(for:)` is **not** called inside `onProceed`.
  Unlike the paid-warning path, the `.toBePaid` branch of the switch at
  `handleAnalysisResults` already calls `handleSavingPhotos` before
  `handleToBePaidCase`; re-calling it here would double-save.
- `accessibilityElementsHidden` is restored in both dismissal completions
  because `presentAsBottomSheet` unconditionally sets it to `true` on the
  presenter and never restores it. This fixes an inherited a11y bug in the
  shared `presentAsBottomSheet` extension for the due-date consumer; the
  sibling paid-warning path has the same latent issue and is left for a
  follow-up scoped ticket.

### Date helpers

`Date+Formatting.swift` is **unchanged**. `Date.isDueSoon(within:)`
remains the only threshold predicate — no new Date helpers are added.

### Analysis screen changes

`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Analysis/AnalysisViewController.swift`:

- **Remove** `hintView: PaymentDueHintView`, `dismissHintView`, and every
  helper under the `// MARK: - Handling UI - Payment DueHint` region.
- **Remove** the `PaymentDueDateProtocol` conformance and both method
  bodies. The protocol itself is deleted from
  `GiniScreenAPICoordinator.swift` (see §Public API impact).
- **Remove** `PaymentDueHintView.swift` and `DismissMessageView.swift`.
- **Remove** the scroll/stack infrastructure that hosted the legacy hint:
  `scrollView`, `contentStack`, `setupScrollableStackView()`,
  `updateContentStackConstraints()`. The remaining screen goes back to
  laying out `imageView` and `overlayView` directly.

Suppression of the 4-second `CaptureSuggestionsView`:

- The Analysis screen exposes `removeCaptureSuggestions()` (visibility
  elevated from `private` to `public`).
- The coordinator's `presentDueDateHintBottomSheet(dueDate:onProceed:)`
  calls `removeCaptureSuggestions()` on the top-of-stack
  `AnalysisViewController` synchronously before presenting the sheet.
- No `Bool` flag is added — a "suppress future banners" flag would only
  matter if the coordinator could run before `viewDidLoad`, which it
  can't. Android reaches the same conclusion (its `stopAndHideHints()`
  is a synchronous stop + hide, no future-suppression flag).

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
      │                     │ Return Assistant / Skonto not shown?
      │                     │ dueDate.isDueSoon(within: threshold)?
      │                     │
      │                     ├── no ─► continueWithFeatureFlow()
      │                     │
      │                     └── yes ─► analysisVC.removeCaptureSuggestions()
      │                                presentDueDateHintBottomSheet(...)
      │◄─────────────────────────── modal bottom sheet
      │
      │      Cancel Transfer  ─► dismiss + restore a11y + didCancelCapturing() → bank app
      │      Proceed Anyway   ─► dismiss + restore a11y + continueWithFeatureFlow()
```

## Test plan

Every new/changed class gets a unit test. Landscape rendering, VoiceOver
reading order, dynamic-font non-truncation, external-keyboard operability,
and WCAG AA contrast are covered by manual QA per the ticket AC.

### GiniCaptureSDK (Swift Testing — `@Suite`/`@Test`/`#expect`)

**Location:** `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/DueDateHintBottomSheetViewControllerTests.swift`
(new). The legacy `AnalysisViewControllerPaymentDueHintTests.swift`
suite is **removed** — the code paths it exercised
(`handlePaymentDueDate(_:)` / `clearPaymentDueDate(after:)`) no longer
exist.

- `@Suite("DueDateHintBottomSheetViewController")` covers:
  - Title is formatted with the passed `formattedDueDate` — assert the
    header label text equals `String(format: Strings.titleFormat,
    formattedDate)`.
  - Primary button tap invokes `onProceed`; secondary button tap invokes
    `onCancel`. Bypasses `sendActions()` — the UIApplication chain
    isn't running in the test host — and calls the `@objc` `didPressPrimary`
    / `didPressSecondary` handlers that back the button targets directly.
  - `shouldShowDragIndicator == false` — dismissal is CTA-driven only.

### GiniBankSDK (XCTest — extends the existing suite)

**Location:** `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+DueDateHint.swift`
(new file, matches the pattern of `+CX.swift` / `+Helpers.swift`; extends
the existing `NetworkingScreenApiCoordinatorTests: XCTestCase` via a
Swift `extension` to reuse the fixture setup + helpers).

Gate-predicate tests — `shouldPresentDueDateHint(for:)`:

- Fires when the due date is comfortably beyond the threshold.
- Does not fire when the due date is today, in the past, at the legacy
  boundary (daysUntilDue = 3 with threshold 5), or below it.
- Fires at the legacy boundary (daysUntilDue = 4 with threshold 5) and
  under a custom threshold (daysUntilDue = 2 with threshold 3).
- Does not fire when `paymentDueHintEnabled` is off, when Return Assistant
  wins, when Skonto wins, or when `paymentDueDate` is missing.

Flow-level presentation tests — `presentDueDateHintBottomSheet(...)`:

- Sheet is presented as a `DueDateHintBottomSheetViewController` with
  `isModalInPresentation == true` and `shouldShowDragIndicator == false`.
- Primary CTA (`didPressPrimary`) dismisses the sheet, restores
  `accessibilityElementsHidden` on the presenter, and invokes the
  continuation.
- Secondary CTA (`didPressSecondary`) dismisses the sheet, restores
  `accessibilityElementsHidden`, and calls
  `giniCaptureDidCancelAnalysis()` on the results delegate.
- Presentation and dismissal are driven with the navigation controller
  mounted in a `UIWindow`; async completion is awaited via
  `XCTNSPredicateExpectation`.

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
