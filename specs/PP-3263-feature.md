# PP-3263: Schedule Payment state of the payment-hint bottom sheet

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3263

## Problem

Some banks that integrate the Bank SDK (Sparkasse is the driving example)
have their own scheduled-transfer flow and want the SDK to hand the user
over to it instead of forcing the "cancel or proceed" choice from PP-3261.
Today the capture flow can only finish through the three terminal callbacks
on `GiniCaptureResultsDelegate` — `giniCaptureAnalysisDidFinishWith(result:)`,
`giniCaptureDidCancelAnalysis()`, `giniCaptureDidEnterManually()` — so there
is no way for the SDK to say "the user asked to schedule this instead of
paying now, here are the extractions".

PP-3263 adds a second state to the payment-hint bottom sheet PP-3261
introduced — **Schedule Payment** — driven by a new client-config flag
`paymentScheduleHintEnabled` and a new integrator flag on
`GiniBankConfiguration`. The primary CTA finishes the flow with a **new
terminal callback** carrying the extractions; the secondary "Proceed Anyway"
CTA falls back to the normal pay-now flow that PP-3261 already implements.

This is the iOS counterpart of Android PR
[gini-mobile-android#966](https://github.com/gini/gini-mobile-android/pull/966)
(PP-3264). iOS follows Android for user-visible copy (verbatim EN/DE from
Figma section `32630-16572`), the sheet's state model (single VC with a
state enum, not two sibling classes), the priority order paid → schedule
→ due-date → proceed, and the eligibility gate reuse. iOS diverges from
Android on the mechanism only where Android's shape doesn't map:
`GiniCaptureResultsDelegate` is `@objc protocol`, so the terminal result
is a **new required delegate method**, not a new subclass of a sealed
result type. The compile-error-on-integrator effect is the same as
Android's; the shape is Swift/`@objc`-idiomatic.

## Requirements

1. When extractions have been returned and:
   - `giniBankConfiguration.paymentScheduleHintEnabled == true`, **and**
   - `ClientConfiguration.paymentScheduleHintEnabled == true` (fetched from
     `/configurations`), **and**
   - `getDocumentPaymentDueDate(for:)` returns a non-nil `Date`, **and**
   - Return Assistant / Skonto are not shown in this flow, **and**
   - the flow is not a Cross-Border Payment flow, **and**
   - `Date.isDueSoon(within: paymentDueHintThresholdDays)` returns `true`
     (same threshold check PP-3261 uses),
   then the payment-hint bottom sheet is presented over the Analysis
   screen in the **Schedule Payment state**.
2. The Schedule Payment state has:
   - Title = same title as PP-3261's Due Date Hint state (invoice-is-due copy
     with the formatted due date). Reuses PP-3261's title key so a single
     backend copy change updates both states.
   - Description = schedule-specific copy from Figma section `32630-16572`.
   - Primary CTA "Schedule Payment" / "Terminüberweisung" — invokes the new
     terminal callback `giniCaptureDidRequestSchedulePayment(result:)` on
     `GiniCaptureResultsDelegate` with the full `AnalysisResult` (extractions,
     lineItems, images, document, candidates — same construction as the
     success path in `deliver(result:analysisDelegate:)`).
   - Secondary CTA "Proceed Anyway" / "Trotzdem fortfahren" — dismisses the
     sheet and continues into the pay-now flow (identical continuation to
     PP-3261's Proceed Anyway).
   - No "Cancel Transfer" button in this state (the schedule state has
     only Schedule Payment and Proceed Anyway).
3. **Priority order** (mirrors Android): paid → schedule payment → due
   date hint → proceed with feature flow. The Schedule Payment state is
   checked *before* PP-3261's Due Date Hint state; the Due Date Hint
   branch is only reached when `paymentScheduleHintEnabled == false` (either
   flag) or when the Schedule Payment eligibility fails.
4. The Schedule Payment state shows **regardless of
   `paymentDueHintEnabled`** — turning off the due-date hint does not turn
   off scheduling. Turning off `paymentScheduleHintEnabled` reverts to
   PP-3261's Due Date Hint state under PP-3261's original gates.
5. When the sheet is presented in either state, any pending
   `CaptureSuggestionsView` banner on the Analysis screen is cleared
   (reuses PP-3261's `AnalysisViewController.removeCaptureSuggestions()`
   call in the coordinator's presentation helper).
6. Tapping **Schedule Payment**:
   - Dismisses the sheet.
   - Restores `accessibilityElementsHidden = false` on the presenter (same
     a11y fix PP-3261 applies in its dismissal completions).
   - Sends the SDK-close analytics event.
   - Constructs an `AnalysisResult` from the current `extractionResult` + `pages`
     + `documentService.document`, exactly as `deliver(result:analysisDelegate:)`
     does.
   - Invokes `resultsDelegate?.giniCaptureDidRequestSchedulePayment(result:)`.
   - Resets `documentService` to initial state.
   - Does **not** invoke `continueWithFeatureFlow` — the flow terminates
     here.
7. Tapping **Proceed Anyway** on the Schedule Payment state: exact same
   behavior as PP-3261's Proceed Anyway (dismiss + restore a11y + invoke
   the `onProceed` continuation, which runs Return Assistant / Skonto /
   Transaction Docs).
8. The sheet in the Schedule Payment state is modal (`isModalInPresentation
   = true`), no pull-to-dismiss, no tap-outside-to-dismiss, no drag
   indicator — identical presentation modality to PP-3261's Due Date Hint
   state.
9. Accessibility for the Schedule Payment state follows the same rules
   PP-3261 established: `accessibilityViewIsModal = true`, `.screenChanged`
   VoiceOver notification on appear, explicit `accessibilityElements` order
   (title → description → primary → secondary), Dynamic Type via
   `textStyleFonts[.title2]`/`[.body]`/`[.bodyBold]`, landscape hides the
   icon container on iPhone.

## Affected modules

- **GiniBankAPILibrary** — adds `paymentScheduleHintEnabled` to
  `ClientConfiguration`. Minimum deployment target: iOS 15+ (unchanged).
- **GiniCaptureSDK** — the following changes:
  - **Rename** the PP-3261 VC `DueDateHintBottomSheetViewController` to
    `PaymentHintBottomSheetViewController`; introduce a public
    `PaymentHintState` enum with two cases (`dueDate`, `schedulePayment`)
    that carry their per-state CTAs as associated values.
  - Move localization keys under `ginicapture.payment.hint.duedate.*` and
    add sibling keys under `ginicapture.payment.hint.schedule.*`. The title
    format is shared and lives under `ginicapture.payment.hint.title`
    (deduplicated across both states — see §Localization).
  - Add a new required method
    `giniCaptureDidRequestSchedulePayment(result:)` to
    `GiniCaptureResultsDelegate`.
  - Minimum deployment target: iOS 15+ (unchanged).
- **GiniBankSDK** — adds `paymentScheduleHintEnabled: Bool = true` to
  `GiniBankConfiguration`; adds
  `determineIfPaymentScheduleHintEnabled(for:)` and
  `shouldPresentSchedulePaymentHint(for:)` to
  `GiniBankNetworkingScreenApiCoordinator`; **replaces** the PP-3261
  `presentDueDateHintBottomSheet(dueDate:onProceed:)` helper with a peer
  `presentPaymentHintBottomSheet(state:...)` that dispatches on
  `PaymentHintState`; inserts the `paymentScheduleHintEnabled == false`
  clause on the due-date gate as PP-3261's spec reserved. Minimum
  deployment target: iOS 15+ (unchanged).
- **GiniBankSDKExample** (UIKit example) — adds a settings toggle for the
  new flag and implements `giniCaptureDidRequestSchedulePayment(result:)`
  on the example's `GiniCaptureResultsDelegate` conformance.
- **GiniBankSDKExampleSwiftUI** — implements
  `giniCaptureDidRequestSchedulePayment(result:)` on `GiniBankSDKModel`.

No changes to `GiniHealthSDK`, `GiniHealthAPILibrary`,
`GiniInternalPaymentSDK`, `GiniUtilites`.

## Public API impact

**Source-breaking on both integrator surfaces** — same design choice as
PP-3261 and matching Android's PR#966 explicit rationale ("integrators
with an exhaustive `when` over `CaptureResult` get a compile error until
they add a branch. That is the intended, visible-by-design consequence").
Ships with a **major-version bump** on both `GiniBankAPILibrary` and
`GiniCaptureSDK` (and consequently `GiniBankSDK`).

### GiniBankAPILibrary (public)

- **`ClientConfiguration`** — one new stored property
  `public let paymentScheduleHintEnabled: Bool` and one new required
  parameter on `public init(...)`. Matches the existing convention (all
  11 fields are required, no defaults). Source-breaking for anyone
  constructing a `ClientConfiguration` by hand — internally that is only
  the `Testing/GiniBankSDKTests` convenience init at
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests.swift:353`,
  which the spec updates.
- Backend rollout is coordinated (Android and iOS ship together), so the
  `Codable` decoder does not need a `decodeIfPresent` fallback — the
  `/configurations` endpoint will return the new field.

### GiniCaptureSDK (public)

- **`PaymentHintBottomSheetViewController`** (new name; replaces the
  PP-3261 `DueDateHintBottomSheetViewController` that has not been
  released yet — PP-3261 is on the same 4.5 release branch and rename
  cost is zero for integrators). `public final class` extending
  `InfoBottomSheetViewController`. Located at
  `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/PaymentHint/PaymentHintBottomSheetViewController.swift`.
- **`PaymentHintState`** (new). `public enum` with per-state associated
  values:
  ```swift
  public enum PaymentHintState {
      case dueDate(formattedDueDate: String,
                   onProceed: () -> Void,
                   onCancel: () -> Void)
      case schedulePayment(formattedDueDate: String,
                           onSchedule: () -> Void,
                           onProceed: () -> Void)
  }
  ```
  Distinct CTAs per state are expressed via associated values instead of a
  common tuple with optional closures — the compiler enforces that only
  the CTAs the state actually needs are supplied.
- **`PaymentHintBottomSheetViewController.init(state:)`** — the single
  init. All content and CTAs come from `state`.
- **Renamed / removed.** The PP-3261 API surface `public init(formattedDueDate:
  onCancel:onProceed:)` on `DueDateHintBottomSheetViewController` is
  removed. Anyone integrating against the freshly-released 4.5 must
  switch to `PaymentHintBottomSheetViewController(state: .dueDate(...))`.
- **`GiniCaptureResultsDelegate`** — adds one **required** method:
  ```swift
  func giniCaptureDidRequestSchedulePayment(result: AnalysisResult)
  ```
  The protocol is `@objc`. Adding a required (non-optional) method is
  source-breaking for all conformers (compile error), which is the
  intended, visible-by-design behavior — Android's stated rationale
  applies verbatim ("integrators with an exhaustive branch get a compile
  error until they add a branch"). Every host app must add an
  implementation, even one that just calls
  `giniCaptureAnalysisDidFinishWith(result:)` to fall back to the
  pay-now path.
- **Renamed localization keys — legacy keys retained as deprecated.** The
  active keys move under `ginicapture.payment.hint.*` (see §Localization).
  The pre-PP-3261 shipping keys — `ginicapture.payment.due.hint.prefix`,
  `ginicapture.payment.due.hint.suggestion`, and
  `ginicapture.dismiss.message.title` — are retained inside a
  `// DEPRECATED … // END DEPRECATED` banner in `Localizable.strings`
  with their pre-PR values, so any integrator override pinned against
  those keys still resolves. Not source-breaking; slated for removal
  in a future major.

### GiniBankSDK (public)

- **`GiniBankConfiguration.paymentScheduleHintEnabled`** — new `public var
  = true`. Additive (defaulted `Bool` on an existing public class), so
  integrators do nothing unless they want to opt out per instance.
- **Coordinator additions** (`internal`, testable seam) —
  `determineIfPaymentScheduleHintEnabled(for:)`,
  `shouldPresentSchedulePaymentHint(for:)`, and the
  `presentPaymentHintBottomSheet(state:)` helper are all `internal`; no
  new public API on `GiniBankSDK`.

## Technical conventions

Grounded in `platform.md` and the modules touched:

1. **Language & access control.** Swift. New declarations default to
   `internal`; `PaymentHintBottomSheetViewController` + `PaymentHintState`
   + the delegate method are the `public` additions, each justified above.
   Doc comments per `AGENTS.md`: `/** ... */` for declarations, `///` for
   in-body explanatory comments.
2. **UI framework.** UIKit. The sheet extends the existing UIKit
   `InfoBottomSheetViewController`. Per `platform.md` §UI-rules, extending
   an existing UIKit component inside CaptureSDK stays UIKit — no SwiftUI
   mixing.
3. **Colors.** Reuse the `GiniColor(light: .GiniCapture.*, dark:
   .GiniCapture.*)` palette PP-3261 uses, unchanged. CaptureSDK stays on
   the legacy `UIColor.GiniCapture.*` namespace per `platform.md`.
4. **Typography.** Dynamic Type via
   `GiniConfiguration.shared.textStyleFonts[.title2]` (title), `[.body]`
   (description), `[.bodyBold]` (buttons) — all inherited from
   `InfoBottomSheetViewController` / `ButtonsView`.
5. **Spacing.** No new spacing constants; parent's
   `InfoBottomSheetViewController.Constants` covers everything.
6. **Architecture.** UIKit MVVM. The new VC follows PP-3261's pattern:
   private content structs implementing `InfoBottomSheetViewModel` and
   `InfoBottomSheetButtonsViewModel` are constructed inside `init(state:)`
   from the `state` associated values. No new coordinator / view-model
   is introduced — the two closures per state form the entire
   ViewController↔Coordinator surface (same as PP-3261).
7. **Wiring.** Constructor injection: `state: PaymentHintState` carries
   all inputs. No delegate back-references. Coordinator methods stay
   `@MainActor`-annotated as in PP-3261. Terminal callback into
   `resultsDelegate` uses the existing synchronous @objc protocol call
   (no Swift concurrency at this seam).
8. **Localization.** Renamed and extended keys in
   `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/{en,de}.lproj/Localizable.strings`.
   Accessed via `NSLocalizedStringPreferredFormat(key, comment:)` (matches
   PP-3261). Key layout (`<sdk>.<feature>.<screen>.<element>`):
   - `ginicapture.payment.hint.title` — value with a single `%@`
     placeholder for the formatted date. **Shared across both states** —
     the Figma copy is identical (`"Your invoice is due on %@."` /
     `"Deine Rechnung ist am %@ fällig."`). The trailing scope follows the
     project convention (see `ginicapture.saveinvoice.local.title`); the
     `%@` placeholder is documented in the accompanying `titleFormatKey`
     constant on `PaymentHintBottomSheetViewController.Strings` rather than
     encoded in the key.
   - `ginicapture.payment.hint.duedate.description`
   - `ginicapture.payment.hint.duedate.proceedButtonTitle`
   - `ginicapture.payment.hint.duedate.cancelButtonTitle`
   - `ginicapture.payment.hint.schedule.description`
   - `ginicapture.payment.hint.schedule.scheduleButtonTitle` — primary
     CTA for the schedule state.
   - `ginicapture.payment.hint.schedule.proceedButtonTitle` — secondary
     CTA. Copy is identical to
     `ginicapture.payment.hint.duedate.proceedButtonTitle` but a separate
     key is kept so per-state copy tweaks stay independent (mirrors
     Android's per-state string entries).
   The pre-PP-3261 shipping keys (`ginicapture.payment.due.hint.prefix`,
   `ginicapture.payment.due.hint.suggestion`,
   `ginicapture.dismiss.message.title`) are retained behind a
   `// DEPRECATED … // END DEPRECATED` banner (see §Public API impact).
9. **Quality gates.** `make lint scheme=GiniBankSDK`, `make lint
   scheme=GiniCaptureSDK`, and `make lint scheme=GiniBankAPILibrary` must
   be clean. Multi-parameter formatting per `CLAUDE.md` §Code Style.
10. **Test framework.**
    - GiniBankAPILibrary: Swift Testing (`ClientConfigurationTests` already
      uses `@Suite`/`@Test`/`#expect`).
    - GiniCaptureSDK: Swift Testing (PP-3261's
      `DueDateHintBottomSheetViewControllerTests` is Swift Testing).
    - GiniBankSDK: XCTest (`NetworkingScreenApiCoordinatorTests+*` is
      XCTest; extending an existing suite here).

## Design

### Class map

```
GiniCaptureSDK
├── Core/Screens/PaymentHint/                     (renamed from DueDateHint/)
│   ├── PaymentHintState.swift                    (public, new — top-level enum)
│   └── PaymentHintBottomSheetViewController.swift (public, replaces PP-3261 file)
└── Networking/GiniNetworkingScreenAPICoordinator.swift
    └── GiniCaptureResultsDelegate                (public, +1 required method)
```

`PaymentHintBottomSheetViewController` composes:

- Two private content structs conforming to `InfoBottomSheetViewModel` and
  `InfoBottomSheetButtonsViewModel`, chosen inside `init(state:)`:
  ```swift
  private struct DueDateContent: InfoBottomSheetViewModel { … }
  private struct ScheduleContent: InfoBottomSheetViewModel { … }
  ```
  Each carries the shared title format applied to the state's
  `formattedDueDate`, plus the state-specific description/icon-tint.
- `InfoBottomSheetButtonsViewModel` is built per case:
  - `.dueDate(_, onProceed, onCancel)` — primary = proceed, secondary = cancel.
  - `.schedulePayment(_, onSchedule, onProceed)` — primary = schedule,
    secondary = proceed.
- Both cases use the same `image` (`infoMessageIcon`) and the same
  warning tint (`GiniColor(light: .GiniCapture.warning2, dark:
  .GiniCapture.warning2)`).

### State enum shape

```swift
public enum PaymentHintState {
    /**
     Due Date Hint state — the invoice is due comfortably in the future.
     The user chooses between continuing (primary) and cancelling the
     transfer (secondary). PP-3261 semantics unchanged.
     */
    case dueDate(formattedDueDate: String,
                 onProceed: () -> Void,
                 onCancel: () -> Void)

    /**
     Schedule Payment state — the client has opted into
     `paymentScheduleHintEnabled`. The user chooses between handing off
     to the bank's own scheduled-transfer flow (primary) and continuing
     with the pay-now flow (secondary).
     */
    case schedulePayment(formattedDueDate: String,
                         onSchedule: () -> Void,
                         onProceed: () -> Void)
}
```

### GiniCaptureResultsDelegate change

```swift
@objc public protocol GiniCaptureResultsDelegate: AnyObject {
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult)
    func giniCaptureDidCancelAnalysis()
    func giniCaptureDidEnterManually()

    /**
     Called when the user chose to schedule the payment instead of paying
     now. The host app should present its own scheduled-transfer screen
     and carry over the extractions from `result`.

     - Parameter result: The analysis result — same shape and construction
       as the one delivered to `giniCaptureAnalysisDidFinishWith(result:)`.
     */
    func giniCaptureDidRequestSchedulePayment(result: AnalysisResult)
}
```

Required (non-optional). All conformers get a compile error until they
add an implementation — same intended behavior as Android's sealed-class
addition.

### Coordinator flow (`GiniBankNetworkingScreenApiCoordinator.swift`)

New peer to `determineIfPaymentDueHintEnabled`, in the internal extension
around line 674:

```swift
func determineIfPaymentScheduleHintEnabled(for extractionResult: ExtractionResult) -> Bool {
    guard !isCrossBorderPayment() else { return false }
    let global = giniBankConfiguration.paymentScheduleHintEnabled
    let client = GiniBankUserDefaultsStorage.clientConfiguration?
        .paymentScheduleHintEnabled ?? false
    return global && client
}

/**
 Predicate — is the Schedule Payment bottom sheet warranted for this
 extraction result? Reuses the same eligibility (parseable due date,
 no Return Assistant / Skonto, `Date.isDueSoon(within: threshold)`) as
 `shouldPresentDueDateHint`.
 */
func shouldPresentSchedulePaymentHint(for extractionResult: ExtractionResult) -> Bool {
    guard determineIfPaymentScheduleHintEnabled(for: extractionResult),
          let dueDate = getDocumentPaymentDueDate(for: extractionResult),
          !shouldShowReturnAssistant(for: extractionResult),
          !shouldShowSkonto(for: extractionResult) else {
        return false
    }
    return dueDate.isDueSoon(within: giniBankConfiguration.paymentDueHintThresholdDays)
}
```

**Update to `shouldPresentDueDateHint(for:)`** — insert the schedule-off
clause reserved by PP-3261:

```swift
func shouldPresentDueDateHint(for extractionResult: ExtractionResult) -> Bool {
    guard !determineIfPaymentScheduleHintEnabled(for: extractionResult),
          determineIfPaymentDueHintEnabled(for: extractionResult),
          let dueDate = getDocumentPaymentDueDate(for: extractionResult),
          !shouldShowReturnAssistant(for: extractionResult),
          !shouldShowSkonto(for: extractionResult) else {
        return false
    }
    return dueDate.isDueSoon(within: giniBankConfiguration.paymentDueHintThresholdDays)
}
```

**Rewrite `handleToBePaidCase(_:_:)`** — priority: schedule → due date →
proceed:

```swift
@MainActor
func handleToBePaidCase(_ extractionResult: ExtractionResult,
                        _ continueWithFeatureFlow: @escaping () -> Void) {
    if shouldPresentSchedulePaymentHint(for: extractionResult),
       let dueDate = getDocumentPaymentDueDate(for: extractionResult) {
        presentPaymentHintBottomSheet(
            state: .schedulePayment(
                formattedDueDate: dueDate.toDisplayString(),
                onSchedule: { [weak self] in
                    self?.finishWithSchedulePayment(extractionResult: extractionResult)
                },
                onProceed: continueWithFeatureFlow
            )
        )
        return
    }

    if shouldPresentDueDateHint(for: extractionResult),
       let dueDate = getDocumentPaymentDueDate(for: extractionResult) {
        presentPaymentHintBottomSheet(
            state: .dueDate(
                formattedDueDate: dueDate.toDisplayString(),
                onProceed: continueWithFeatureFlow,
                onCancel: { [weak self] in self?.didCancelCapturing() }
            )
        )
        return
    }

    continueWithFeatureFlow()
}
```

**`presentPaymentHintBottomSheet(state:)`** replaces PP-3261's
`presentDueDateHintBottomSheet(dueDate:onProceed:)`. Same removeCaptureSuggestions
call, same a11y restore in the dismissal path, same `isModalInPresentation
= true`. The two-CTA vs three-CTA branching happens inside
`PaymentHintBottomSheetViewController`, not the coordinator:

```swift
@MainActor
func presentPaymentHintBottomSheet(state: PaymentHintState) {
    let analysisVC = screenAPINavigationController.children.last as? AnalysisViewController
    analysisVC?.removeCaptureSuggestions()

    let sheet = PaymentHintBottomSheetViewController(state: wrapStateForDismissal(state))
    sheet.isModalInPresentation = true
    sheet.presentAsBottomSheet(from: screenAPINavigationController)
}

/**
 Wraps the caller's closures with the dismiss + a11y-restore steps so
 the view controller doesn't have to know about presentation lifecycle.
 Mirrors PP-3261's synchronous callback-first order: fire the closure,
 then dismiss.
 */
private func wrapStateForDismissal(_ state: PaymentHintState) -> PaymentHintState {
    switch state {
    case let .dueDate(formattedDueDate, onProceed, onCancel):
        return .dueDate(
            formattedDueDate: formattedDueDate,
            onProceed: { [weak self] in
                self?.screenAPINavigationController.view.accessibilityElementsHidden = false
                self?.screenAPINavigationController.dismiss(animated: true)
                onProceed()
            },
            onCancel: { [weak self] in
                self?.screenAPINavigationController.view.accessibilityElementsHidden = false
                self?.screenAPINavigationController.dismiss(animated: true)
                onCancel()
            }
        )
    case let .schedulePayment(formattedDueDate, onSchedule, onProceed):
        return .schedulePayment(
            formattedDueDate: formattedDueDate,
            onSchedule: { [weak self] in
                self?.screenAPINavigationController.view.accessibilityElementsHidden = false
                self?.screenAPINavigationController.dismiss(animated: true)
                onSchedule()
            },
            onProceed: { [weak self] in
                self?.screenAPINavigationController.view.accessibilityElementsHidden = false
                self?.screenAPINavigationController.dismiss(animated: true)
                onProceed()
            }
        )
    }
}
```

**`finishWithSchedulePayment(extractionResult:)`** — builds the same
`AnalysisResult` as the success path (see `deliver(result:analysisDelegate:)`
at `GiniBankNetworkingScreenApiCoordinator.swift:256`), sends the SDK-close
analytics event, hands over via the new delegate method, and resets the
document service:

```swift
@MainActor
private func finishWithSchedulePayment(extractionResult: ExtractionResult) {
    let extractions: [String: Extraction] = Dictionary(
        uniqueKeysWithValues: extractionResult.extractions.compactMap {
            guard let name = $0.name else { return nil }
            return (name, $0)
        }
    )
    let images = pages.compactMap { $0.document.previewImage }
    let analysisResult = AnalysisResult(
        extractions: isCrossBorderPayment() ? [:] : extractions,
        lineItems: isCrossBorderPayment() ? nil : extractionResult.lineItems,
        skontoDiscounts: isCrossBorderPayment() ? nil : extractionResult.skontoDiscounts,
        crossBorderPayment: extractionResult.crossBorderPayment,
        images: images,
        document: documentService.document,
        candidates: extractionResult.candidates
    )
    sendAnalyticsEventSDKClose()
    resultsDelegate?.giniCaptureDidRequestSchedulePayment(result: analysisResult)
    documentService.resetToInitialState()
}
```

The `isCrossBorderPayment()` guard cannot fire here in practice (the
schedule gate excludes CX), but the construction is copied verbatim from
`deliver` to keep the two hand-off paths identical and defensive against
future changes.

### Diagram

```
Analysis screen           GiniBankNetworkingScreenApiCoordinator
      │                                    │
      │ extractions returned               │
      │ ─────────────────────────────────► │
      │                                    │
      │              handleToBePaidCase    │
      │                     │              │
      │                     │ shouldPresentSchedulePaymentHint?
      │                     │
      │                     ├── yes ─► removeCaptureSuggestions
      │                     │          presentPaymentHintBottomSheet(.schedulePayment)
      │◄────────────────────────────── modal bottom sheet — Schedule state
      │                     │
      │                     │              onSchedule ─► finishWithSchedulePayment ─►
      │                     │                            resultsDelegate.giniCaptureDidRequestSchedulePayment
      │                     │              onProceed  ─► continueWithFeatureFlow
      │                     │
      │                     └── no ─► shouldPresentDueDateHint?
      │                                (extra guard: paymentScheduleHintEnabled == false)
      │                                     │
      │                                     ├── yes ─► removeCaptureSuggestions
      │                                     │          presentPaymentHintBottomSheet(.dueDate)
      │                                     │
      │                                     │          onProceed ─► continueWithFeatureFlow
      │                                     │          onCancel  ─► didCancelCapturing()
      │                                     │
      │                                     └── no ─► continueWithFeatureFlow()
```

### Example apps

- **`GiniBankSDKExample`**
  ([SettingsViewController+SwitchOptionModel.swift](../BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewController+SwitchOptionModel.swift):49)
  gains a new case `.paymentScheduleHintEnabled` with title `"Payment
  schedule hint feature"`; the switch model gains the same case.
  `SettingsViewModel.swift:194` gains a matching feature-toggle row that
  reads/writes `giniConfiguration.paymentScheduleHintEnabled`.
- **`ScreenAPICoordinator.swift`** (`BankSDK/GiniBankSDKExample/GiniBankSDKExample/Screen API/`)
  gets a new
  `giniCaptureDidRequestSchedulePayment(result:)` implementation that
  shows an alert like `"Schedule payment requested with N extractions"`
  and simulates the host-app hand-off (matches Android's example-app
  behaviour — visible toast + logged extraction count).
- **`GiniBankSDKModel.swift`** (`GiniBankSDKExampleSwiftUI`) gains the
  same delegate method; the SwiftUI model publishes a schedule-request
  state so the example UI can present its own screen.

## Test plan

Every new class / delegate method / gate gets a test.

### GiniBankAPILibrary (Swift Testing — extend the existing `@Suite`)

**Location:** `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/ClientConfigurationTests.swift`.

- Extend the existing `@Test("Initialization sets all properties correctly")`
  to include the new field.
- Add `@Test("paymentScheduleHintEnabled defaults from JSON")` — decodes
  a JSON payload that includes `"paymentScheduleHintEnabled": true` and
  asserts the value round-trips.
- Update the "disabled flags" test to include the new flag.
- Update the JSON fixture at
  `Tests/GiniBankAPILibraryTests/Resources/clientConfiguration.json` to
  include the new field.

### GiniCaptureSDK (Swift Testing)

**Location:** `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/PaymentHintBottomSheetViewControllerTests.swift`
(renamed from `DueDateHintBottomSheetViewControllerTests.swift`).

- `@Suite("PaymentHintBottomSheetViewController — .dueDate state")`
  covers the PP-3261 cases against the new API surface: title-format
  substitution, primary CTA invokes `onProceed`, secondary CTA invokes
  `onCancel`, no drag indicator.
- `@Suite("PaymentHintBottomSheetViewController — .schedulePayment state")`
  covers:
  - Title reuses the same format as the due-date state.
  - Description text equals the schedule-specific localized string.
  - Primary button label is the localized "Schedule Payment" title.
  - Secondary button label is the localized "Proceed Anyway" title.
  - Tapping the primary button invokes `onSchedule` (and not
    `onProceed`).
  - Tapping the secondary button invokes `onProceed` (and not
    `onSchedule`).
  - `shouldShowDragIndicator == false`.

CTA taps are exercised via `didPressPrimary()` / `didPressSecondary()`
directly on the VC (bypassing `sendActions()`), matching PP-3261's test
pattern.

### GiniBankSDK (XCTest — extend the existing suite)

**Location:** `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+SchedulePaymentHint.swift`
(new file; mirrors `+DueDateHint.swift` in shape).

Gate-predicate tests — `shouldPresentSchedulePaymentHint(for:)`:

- Fires when both flags on + eligible due date + no CX / RA / Skonto.
- Does not fire when `giniBankConfiguration.paymentScheduleHintEnabled ==
  false`.
- Does not fire when `ClientConfiguration.paymentScheduleHintEnabled ==
  false`.
- Does not fire when the payment due date is today, past, or under the
  threshold.
- Does not fire when `isCrossBorderPayment()` is true.
- Does not fire when Return Assistant / Skonto win.

Priority tests — `handleToBePaidCase`:

- With both flags on and eligible date, the presented sheet is
  `PaymentHintBottomSheetViewController` in `.schedulePayment` state.
- With `paymentScheduleHintEnabled` off and eligible date, the presented
  sheet is `.dueDate` state (PP-3261 behaviour preserved).
- With both flags off, `continueWithFeatureFlow` fires synchronously and
  no sheet is presented.

Flow-level presentation tests — `presentPaymentHintBottomSheet(.schedulePayment)`:

- The presented sheet has `isModalInPresentation == true` and
  `shouldShowDragIndicator == false`.
- Tapping the schedule CTA invokes
  `MockCaptureResultsDelegate.giniCaptureDidRequestSchedulePayment(result:)`
  with an `AnalysisResult` whose `extractions` dictionary is populated
  from the extractionResult (add a new capture on
  `MockCaptureResultsDelegate` at
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/Helpers/MockCaptureResultsDelegate.swift`).
- Tapping the Proceed CTA invokes the caller's `onProceed` continuation
  (verified via a spy closure) and does **not** invoke the schedule
  delegate.

**Existing due-date test file** `NetworkingScreenApiCoordinatorTests+DueDateHint.swift`
is updated to:

- Set `paymentScheduleHintEnabled = false` in `configureForDueDateHint`
  (so the schedule branch does not take precedence in the tests that
  exercise the due-date branch).
- Replace `DueDateHintBottomSheetViewController` references with
  `PaymentHintBottomSheetViewController` and switch on the state where
  needed.

### Manual QA

- Dynamic Type at every accessibility size — no truncation on either
  state.
- VoiceOver: order reads title → description → primary CTA → secondary
  CTA on both states; focus moves to the sheet on appear.
- Landscape iPhone (with and without notch) and landscape iPad on both
  states.
- Full-keyboard-access chain: Tab / Space / Enter through both buttons on
  both states.
- WCAG AA contrast on light + dark mode (Xcode Accessibility Inspector
  Audit).
- End-to-end using the fixture PDF equivalent of Android's
  `Testrechnung-due-date-future.pdf` (a future-dated invoice). With the
  client flag on and `giniBankConfiguration.paymentScheduleHintEnabled ==
  true`, the schedule sheet appears; primary CTA fires
  `giniCaptureDidRequestSchedulePayment(result:)` in the example app.
- Toggle `paymentScheduleHintEnabled` off in the example settings —
  behaviour reverts to PP-3261's Due Date Hint state.

## Out of scope

- **Liquid Glass variant** of the sheet — planned per SDK, out of scope
  here.
- **Analytics events** specific to the schedule state — no new events
  prescribed by the ticket; the existing `sendAnalyticsEventSDKClose()`
  fires on hand-off, which is the analogous event to the success path.
- **`paymentDueHintThresholdDays` minimum clamp** for schedule-payment
  banks — deferred; the threshold is reused unchanged with no clamping,
  matching Android.
- **Weekend / bank-holiday handling** on the threshold — matches Android
  ("no weekend/bank-holiday handling").
- **`GiniHealthSDK` / `GiniHealthAPILibrary` / `GiniInternalPaymentSDK`**
  — no changes; scheduling is a Bank-SDK feature.
- **Renaming `DueDateHintBottomSheetViewControllerTests`** as a
  standalone task — the rename happens inside this ticket alongside the
  VC rename.
- **Migration guide beyond release notes** — the release notes for the
  major-version bump call out the two source-breaking changes
  (`ClientConfiguration.init` + `GiniCaptureResultsDelegate` new method +
  the sheet VC rename); no separate migration doc.

## Open questions

None. All decisions confirmed in review before writing this spec:

- **Terminal-result shape:** required delegate method on
  `GiniCaptureResultsDelegate` (matches Android's compile-error intent).
- **Sheet architecture:** single VC with a state enum
  (`PaymentHintBottomSheetViewController` + `PaymentHintState`), renaming
  the PP-3261 VC. Matches Android's `WarningType` shape.
- **`ClientConfiguration.paymentScheduleHintEnabled`:** required
  parameter on the initializer, matches every other field on iOS
  `ClientConfiguration`.
