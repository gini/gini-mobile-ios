# PP-3962: [iOS] IBAN selection sheet — UI phase

Status: draft (UI phase only — integration deferred to phase 2)
Ticket: https://ginis.atlassian.net/browse/PP-3962
Parent epic: [PP-3518 — Fraud prevention warnings – phase 1](https://ginis.atlassian.net/browse/PP-3518)
Branch: `PP-3962` off `release/fraud-prevention-phase` (GiniOptionRow PR #1311 already merged in)
Depends on: PP-3997 `GiniOptionRow` (merged, `release/fraud-prevention-phase`) — `GiniOptionRow.radio(…)` renders each option row.
Will integrate with (separate ticket, not required for merge): PP-3960 warning screen — Nadya will host this sheet via the new `.bottomSheet(…)` modifier shipped here.
Android counterpart (behavior reference for phase 2): PP-3966, [gini-mobile-android PR #1030](https://github.com/gini/gini-mobile-android/pull/1030).
Figma: iOS section `38468-42450`; sheet frames `38512:27755` (normal), `38457:29452` (error state), `38466:32857` (combined-warning host); pure-sheet component `38762:210919`.

## Scope split — phase 1 (this ticket) vs phase 2

**Phase 1 (THIS ticket) — UI only.** Ship a self-contained SwiftUI sheet and a reusable
`.bottomSheet(isPresented:) { … }` SwiftUI modifier in `GiniUtilites`. The sheet's inputs are
two plain strings (`qrIBAN`, `printedIBANs: [String]`) and a `Binding<IBANChoice?>`; outputs are
two callbacks (`onContinue(IBANChoice)`, `onDismiss()`). It knows nothing about `AnalysisResult`,
`FraudSignal`, `Extraction`, coordinators, or BIC-removal. Verified in isolation via previews and
unit tests.

**Phase 2 (follow-up ticket, not this one).** Nadya's PP-3960 warning screen presents the sheet
via the new `.bottomSheet` modifier; a new `IBANSelectionCoordinator` turns `IBANChoice` into the
final `AnalysisResult` using a `ChosenIBANExtractions.apply(to:chosenIBAN:)` helper (replaces
`extractions["iban"]`, strips `extractions["bic"]`) and forwards to
`GiniBankNetworkingScreenApiCoordinator.deliverAnalysisResult(_:)`. Mirrors Android PR #1030's
`ChosenIbanExtractions`. See "Phase 2 — deferred work" section at the bottom.

This split is deliberate: PP-3960 isn't on `origin` yet, so phase 1 can land independently and
unblock Nadya when she needs the sheet to drop into her container.

## Problem (UI phase)

After "Proceed anyway" on the warning screen (PP-3960), the user must choose which IBAN the
bank will receive. Today nothing lets them. The design (Figma `38512:27755`) specifies a native
iOS bottom sheet at `.medium` detent with:

- Grabber (system-provided)
- Title "To continue, select one of the IBANs"
- Two radio rows — "In the QR code" + each "Printed on the document" — with a divider between
- Footer hint "You can still check the IBAN on the next screen."
- Primary "Continue" button, full-width, filled blue

The sheet is validation-driven, not selection-gated: Continue is **always tappable**. Tapping it
with no selection switches both radios to error-tint and shows the red validation line
"Select an IBAN to continue" above the footer hint (Figma `38457:29452`). Tapping any row clears
the error state back to the normal unselected/selected visuals.

Phase 1 ships this sheet as a stand-alone SwiftUI composition that any SwiftUI parent — Nadya's
`MismatchContainer` next week, previews now, example-app harness today — can embed via a shared
`.bottomSheet(isPresented:) { IBANSelectionSheet(…) }` modifier that goes into `GiniUtilites`.

## Requirements (UI phase)

Common setup: The sheet is instantiated with
`IBANSelectionSheet(viewModel: IBANSelectionSheetViewModel, selection: $selection, onContinue:,
onDismiss:)` where `viewModel.qrIBAN: String`, `viewModel.printedIBANs: [String]` (non-empty,
caller-deduped — see R8), and `selection: Binding<IBANChoice?>` is owned by the parent. All
strings on the sheet come from `viewModel`, already localized by the caller.

- **R1 (MUST, entry):** Given the parent view embeds the sheet as
  `.bottomSheet(isPresented: $show) { IBANSelectionSheet(viewModel: vm, selection: $sel,
  onContinue: { … }, onDismiss: { … }) }`, when the sheet appears, then it renders, in order:
  (a) the title (`vm.title`);
  (b) one `GiniOptionRow.radio(…)` row for the QR IBAN using `vm.qrRowTitle` + `vm.qrIBAN`;
  (c) a `Divider` between rows;
  (d) one `GiniOptionRow.radio(…)` row per entry in `vm.printedIBANs`, all using the same
     `vm.printedRowTitle` label;
  (e) the footer hint (`vm.footerHint`);
  (f) the "Continue" primary button (`vm.continueCTA`), always enabled (not conditional on
     selection).
  Each radio row's variant is `.unselected` when `selection` does not match that row, `.selected`
  when it does, and `.error` when the error flag is set (see R3). The sheet is
  `@available(iOS 16.0, *)` to inherit `GiniOptionRow`'s availability.

- **R2 (MUST, happy path — selection):** Given the sheet is visible and `selection == nil`,
  when the user taps a row whose choice is `<C>`, then `selection.wrappedValue == .some(<C>)`,
  that row's `GiniOptionRow` variant switches to `.radio(.selected)`, every other row stays
  `.radio(.unselected)`, and any prior error state (R3) is cleared.

- **R3 (MUST, error path — validation):** Given the sheet is visible and `selection == nil`,
  when the user taps "Continue", then (a) `onContinue` is **not** invoked, (b) all rows switch
  to `.radio(.error)` (Figma: both radios tinted error-red), (c) the red validation line
  `vm.validationErrorMessage` ("Select an IBAN to continue") renders between the last row and
  the footer hint, (d) `vm.footerHint` stays visible below the validation line, (e) the
  "Continue" button stays enabled. When the user then taps any row, every radio returns to its
  pre-error variant, the validation line disappears, and R2 applies.

- **R4 (MUST, happy path — confirm):** Given the sheet is visible and
  `selection == .some(<C>)`, when the user taps "Continue", then `onContinue(<C>)` is invoked
  exactly once. The sheet does not dismiss itself — the parent owns the `isPresented` binding
  and clears it in the `onContinue` callback (see R6 for the recommended cascade).

- **R5 (MUST, error path — dismiss):** Given the sheet is visible, when the user drags it down
  or iOS reports an interactive dismissal, then `onDismiss()` is invoked exactly once,
  `onContinue(_:)` is **not** invoked, and the `isPresented` binding flips to `false` via the
  modifier's standard SwiftUI-to-Binding bridge. The `.bottomSheet` modifier wires this through
  `UIAdaptivePresentationControllerDelegate` on iOS 15 and through SwiftUI's native
  `.sheet(isPresented:)` on iOS 16+ — the sheet view itself never calls `dismiss()` directly.

- **R6 (SHOULD, async — recommended confirm cascade):** When the parent's `onContinue` closure
  fires, the recommended pattern (mirrors PP-3938 spike's
  `MismatchContainer.forwardAndDismiss`) is to flip `isPresented = false` in the same run loop
  and `DispatchQueue.main.async` any further handoff. This keeps the sheet dismissal animation
  interrupting-free and lets phase 2's coordinator run the apply-choice step without racing a
  two-dismiss-in-one-frame SwiftUI quirk. Documented in the sheet's doc comment, not enforced
  by the sheet.

- **R7 (MUST, happy path — single printed IBAN):** Given `vm.printedIBANs == ["<P>"]`, when
  the sheet appears, then exactly two radio rows render (one QR row + one printed row) and
  behavior R1–R6 holds unchanged.

- **R8 (MUST, happy path — multiple printed IBANs):** Given
  `vm.printedIBANs == ["<P1>", "<P2>", "<P3>"]`, when the sheet appears, then exactly four
  radio rows render (one QR row + three printed rows), each printed row uses the same label
  (`vm.printedRowTitle`, "Printed on the document"), and `IBANChoice.printed(iban:)` carries
  the exact string value selected. Dedupe and QR-exclusion happen upstream of the viewmodel
  (phase 2's integration layer); the sheet renders what it is given. Preserves the ticket's
  "Multiple printed IBANs: TBD" note by making the UI N-ready without committing to an
  integration policy here.

- **R9 (MUST, entry — bottomSheet modifier):** `GiniUtilites` ships
  `extension View { func giniBottomSheet<Content: View>(isPresented: Binding<Bool>,
  @ViewBuilder content: @escaping () -> Content) -> some View }`. When applied to a parent
  view, it presents `content()` as a medium-detent bottom sheet with a visible drag indicator.
  On iOS 16+ it uses SwiftUI's native `.sheet(isPresented:) { content.presentationDetents([.medium])
  .presentationDragIndicator(.visible) }`. On iOS 15 (if needed; currently out via R10 of the
  sheet gate) it bridges to `UISheetPresentationController.detents = [.medium()]` via
  `UIViewControllerRepresentable` as prototyped in the PP-3938 spike. The modifier respects
  `accessibilityReduceMotion` (hides the drag indicator) and never calls `dismiss()` itself —
  dismissal flips `isPresented` back to `false`.

- **R10 (MUST, entry — iOS availability):** Both `IBANSelectionSheet` and `giniBottomSheet(...)`
  are `@available(iOS 16.0, *)`. Phase 1 does not ship an iOS 15 code path. (Decision from
  2026-11-17 clarifying question: `GiniOptionRow`'s iOS 16 gate stays; the sheet inherits it;
  phase 2's coordinator will skip the fraud flow on iOS 15 so no user-visible behavior changes
  for iOS 15 users.)

- **R11 (MUST, entry — a11y label composition):** Given VoiceOver is active, when the user
  focuses a row, then VoiceOver reads the label built by
  `GiniOptionRowAccessibility.makeLabel(title: vm.qrRowTitle, content: vm.qrIBAN, footer: nil)`
  (and the equivalent for printed rows). The focused row is announced as a `Button`; its value
  is "selected" when selection matches and absent otherwise; the "Continue" button and the
  validation line (when present per R3) are reachable through the rotor.

- **R12 (MUST, happy path — Dynamic Type & long IBANs):** Given the user has Dynamic Type at
  AX1 (200%) or higher, when the sheet renders, then IBAN values wrap cleanly across lines
  without truncation, the "Continue" button stays tappable with its full label, and the sheet
  grows to its content height (via `giniBottomSheet`'s detent). No fixed heights, no
  `lineLimit(1)` on IBAN rows.

- **R13 (MUST, entry — Reduce Motion):** Given the user has Reduce Motion on, when the sheet
  appears, then (a) the drag indicator is hidden (sheet is still interactively dismissible via
  system gesture; just no visible grabber motion-cue), (b) the error-state radio color change
  (R3) uses no `withAnimation { … }` wrapper — the transition happens instantly. Matches
  `GiniExpandableInfoView`'s Reduce Motion pattern (PP-3995).

- **R14 (MUST, entry — design-system tokens):** Colors resolved through the host SDK's
  `GiniColorScheme` passed as `GiniOptionRow.giniColorScheme:` parameter (rows) and via
  `GiniColor(uiColor: UIColor.GiniBank.accent1)` for the primary button background (matches
  neighbouring `GiniBankSDK` button styling). Fonts via `textStyleFonts[.title3]` /
  `[.caption1]` / `[.body1]` / `[.footnote]` (viewmodel declares which `UIFont` to use for
  which text line; the sheet bridges with `Font(giniFont:)`). Spacing in a local
  `enum Constants` inside the sheet file (no magic numbers).

- **R15 (MUST, entry — localization):** All on-screen strings come from the viewmodel as
  already-localized `String` values. The sheet carries no `NSLocalizedString` calls. The
  viewmodel's documentation shows a reference call site using
  `NSLocalizedStringPreferredGiniBankFormat` with keys in the
  `ginibank.fraud.ibanSelection.<element>` namespace, matching the existing
  `ginibank.fraud.protect.*` neighbours in
  `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Resources/*.lproj/Localizable.strings` (added by
  commit `3b7931278`). The sheet does not add new `.strings` entries in phase 1 because
  `GiniUtilites` does not ship a resource bundle; the integrator-side strings land with PP-3960
  or phase 2, co-located with the warning-screen strings.

## Affected modules

- **GiniUtilites** (SPM package, iOS 15+; sheet consumers gated at iOS 16+ via R10) — hosts
  `giniBottomSheet(isPresented:content:)` under
  `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Views/` (flat with
  `GiniOptionRow/` and `GiniExpandableInfoView.swift`; the `SwiftUI/` subdirectory was removed
  in PR #1311 — commit `bd61d9b95` moved `GiniHeightPreferenceKey.swift` out of `SwiftUI/`
  into `Views/`). First reusable sheet modifier in the package. **Does not touch** the
  existing `GiniInternalPaymentSDK.GiniBottomSheetModifier` — that modifier is bound to
  PaymentReview's content-height binding and `giniLayout.isLandscape` detent logic; ours is
  simpler and reusable. A future refactor can consolidate them (out of scope). Rationale for
  landing the modifier here rather than in GiniBankSDK: other SDKs (HealthSDK,
  InternalPaymentSDK) will present SwiftUI sheets with the same medium-detent + grabber
  pattern — the modifier is a true primitive with no banking knowledge.
- **GiniBankSDK** (SPM package, iOS 15+; sheet gated at iOS 16+ via R10) — owns
  `IBANSelectionSheet` and `IBANSelectionSheetViewModel` under
  `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/FraudMismatch/` (folder expected to be created
  by PP-3960 — if PP-3960 doesn't land first, phase 1 creates it). Rationale for landing the
  sheet content here rather than GiniUtilites: it carries bank-fraud-specific concepts
  (`IBANChoice.qr(iban:)` / `.printed(iban:)`, "In the QR code" / "Printed on the document"
  labels), and the layering direction forbids leaking banking domain concepts into a utility
  package that every SDK depends on. This matches the repo-wide precedent for feature-specific
  SwiftUI screens: `GiniCaptureSDK` holds `CreditNoteWarningViewController.swift` and
  `DocumentMarkedAsPaidViewController.swift`; `GiniInternalPaymentSDK` holds
  `PaymentReviewContentView.swift`; each SDK owns the SwiftUI screens unique to its flow.
- **GiniBankAPILibrary, GiniCaptureSDK, GiniInternalPaymentSDK, GiniHealthSDK,
  GiniHealthAPILibrary** — **not touched** in phase 1.

## Public API impact

Phase 1 adds **one new public declaration** total:

- `GiniUtilites`:
  ```swift
  @available(iOS 16.0, *)
  extension View {
      public func giniBottomSheet<Content: View>(
          isPresented: Binding<Bool>,
          @ViewBuilder content: @escaping () -> Content
      ) -> some View
  }
  ```
  Additive. No breaking change.

Everything else in phase 1 is `internal` to `GiniBankSDK`:
`IBANSelectionSheet`, `IBANSelectionSheetViewModel`, `IBANChoice`.

## Technical conventions

1. **Language and access control.** Swift. One new `public` declaration (the modifier
   extension); everything else `internal` (default). `@available(iOS 16.0, *)` on
   `IBANSelectionSheet`, `IBANSelectionSheetViewModel`, `IBANChoice` and the modifier.
   Doc-comment style per `.claude/rules/mandatory-rules.md` — `/** */` on every new declaration
   (the modifier, the sheet, the viewmodel, `IBANChoice`); `///` for inline body notes.
2. **UI.** **SwiftUI**, iOS 16+. New view follows the SwiftUI view init pattern — single
   `viewModel: IBANSelectionSheetViewModel` config-struct param + external
   `@Binding var selection: IBANChoice?`, mirroring `GiniCarouselView` and PP-3995's
   `GiniExpandableInfoView` (memory note on SwiftUI view init pattern, 2026-11-14). Colors via
   `GiniColorScheme` (rows) and `UIColor.GiniBank.*` (button); fonts via
   `giniBankConfiguration.textStyleFonts[...]`; spacing in local `enum Constants`. No raw
   `UIColor(red:…)`, no `Font.system(size:)`, no numeric literals for spacing outside
   `Constants`. The sheet does **not** self-present — it is content for the modifier.
3. **Architecture.** View-only. No coordinator in phase 1 (that is phase 2). ViewModel is a
   plain `struct`, immutable, no UIKit import inside the viewmodel itself (the `FontConfig`
   bridging struct declares `UIFont?` the same way `GiniOptionRow.FontConfiguration` does —
   intentional precedent, not a rule break). No `@Observable`, no `ObservableObject`. No
   delegate, no weak references in phase 1 — all callbacks are plain closures passed by the
   parent.
4. **Wiring / DI.** Constructor injection. `IBANSelectionSheetViewModel.init` takes every
   display string + the color scheme + fonts — no singleton lookups inside. Swift concurrency
   not involved.
5. **Localization.** No new `.strings` entries in phase 1 (viewmodel receives pre-localized
   strings). Phase 2 adds `ginibank.fraud.ibanSelection.<element>` keys to
   `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Resources/de.lproj/Localizable.strings` and
   `en.lproj/Localizable.strings` under the existing `// MARK: - Fraud prevention —` block.
6. **Quality gates.** `make lint scheme=GiniBankSDK` and `make lint scheme=GiniUtilites` clean.
   Test framework: **Swift Testing** (`@Suite`, `@Test`, `#expect`) — matches
   `GiniOptionRowTests`, `GiniExpandableInfoViewModelTests`, and all post-2026-11 fraud code.
   Multi-parameter formatting per `.claude/rules/mandatory-rules.md` — one param per line,
   first on the opening-paren line, subsequent vertically aligned (every init with >1 param:
   `IBANSelectionSheetViewModel`, `FontConfig`). CI runs `iPhone 17 / iOS 26.2`; local
   `make lint` on `iPhone 15 Pro / iOS 17.2` — re-run in CI parity before pushing. Copyright
   year on new files: 2026.

## Design

### File layout

New files (phase 1):

```
GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Views/
  View+GiniBottomSheet.swift                    (new — modifier; phase 1 is iOS 16+ only)
```

The `SwiftUI/` subdirectory in `GiniUtilites` was removed as part of PR #1311 (see commit
`bd61d9b95` moving `GiniHeightPreferenceKey.swift` from `SwiftUI/` → `Views/`). All new
SwiftUI files in `GiniUtilites` go under `Views/` directly, matching the `GiniOptionRow` /
`GiniExpandableInfoView` layout.

```
BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/FraudMismatch/
  IBANSelectionSheet.swift                      (new — SwiftUI View + #Preview catalogue)
  IBANSelectionSheetViewModel.swift             (new — plain struct, FontConfig nested type)
  IBANChoice.swift                              (new — enum, Hashable)
```

The `Core/FraudMismatch/` folder will be created by PP-3960 if that ticket lands first; if
PP-3962 ships first, phase 1 creates it. Folder name matches Nadya's spike working copy
(`origin/PP-3938-fraud`) — treated as a label choice, not as architectural precedent (the
spike itself will not merge).

Tests:

```
GiniComponents/Utilities/GiniUtilites/Tests/GiniUtilitesTests/Views/
  ViewGiniBottomSheetTests.swift                (new — modifier builder-API surface; not runtime sheet behavior)

BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/
  IBANSelectionSheetViewModelTests.swift        (new — Swift Testing)
```

### Public modifier contract

```swift
import SwiftUI

public extension View {

    /**
     Presents `content` as a medium-detent bottom sheet with a visible drag indicator.

     On iOS 16+ this is SwiftUI's native `.sheet` with `.presentationDetents([.medium])` and
     `.presentationDragIndicator(.visible)`. Dismissal (drag-down, tap-outside where the detent
     allows it, or `isPresented = false`) flips `isPresented` back through the normal
     SwiftUI binding bridge — this modifier never calls `dismiss()` itself.

     - Parameters:
       - isPresented: Two-way binding owned by the caller. The caller is responsible for
         flipping it to `false` from inside the sheet's own callbacks (e.g. on "Continue");
         user-initiated drag-dismiss flips it automatically.
       - content: The sheet body. Usually a SwiftUI View that takes its own viewmodel and
         exposes callbacks the caller wires to `isPresented.wrappedValue = false` + any
         further handoff.
     */
    @available(iOS 16.0, *)
    func giniBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
```

The iOS-15 `UIViewControllerRepresentable` + `UISheetPresentationController` fallback from
the PP-3938 spike is **not** shipped in phase 1 (R10). If product decides to re-add iOS 15
support later, the branch sits here behind an `else` of an `#available` check without
touching any call site.

### Sheet contract

```swift
import SwiftUI
import UIKit

internal enum IBANChoice: Hashable {
    case qr(iban: String)
    case printed(iban: String)

    var iban: String {
        switch self {
        case .qr(let iban), .printed(let iban): return iban
        }
    }
}

@available(iOS 16.0, *)
internal struct IBANSelectionSheetViewModel {

    /**
     Font bundle for the sheet's five text lines. `nil` falls back to a SwiftUI system font
     that respects Dynamic Type. Non-nil values bridge to SwiftUI via `Font(giniFont:)`.
     Resolve from `GiniBankConfiguration.textStyleFonts[...]` at the call site, the same way
     `GiniOptionRow.FontConfiguration` does.
     */
    struct FontConfig {
        let title: UIFont?         // vm.title
        let rowTitle: UIFont?      // row small label ("In the QR code" / "Printed on the document")
        let rowContent: UIFont?    // the IBAN value
        let validationError: UIFont?
        let footerHint: UIFont?
        let continueCTA: UIFont?
    }

    let title: String                     // "To continue, select one of the IBANs"
    let qrRowTitle: String                // "In the QR code"
    let printedRowTitle: String           // "Printed on the document"
    let footerHint: String                // "You can still check the IBAN on the next screen."
    let continueCTA: String               // "Continue"
    let validationErrorMessage: String    // "Select an IBAN to continue"

    let qrIBAN: String
    let printedIBANs: [String]            // non-empty, caller-deduped

    let giniColorScheme: GiniColorScheme
    let rowFonts: GiniOptionRow.FontConfiguration
    let sheetFonts: FontConfig

    init(…one-param-per-line per repo convention…) { … }
}

@available(iOS 16.0, *)
internal struct IBANSelectionSheet: View {
    let viewModel: IBANSelectionSheetViewModel
    @Binding var selection: IBANChoice?
    var onContinue: (IBANChoice) -> Void = { _ in }
    var onDismiss: () -> Void = {}

    @State private var showValidationError: Bool = false

    var body: some View { … }
}
```

### Error-state wiring (R3)

`showValidationError` is a private `@State` on the sheet. Flow:

1. User taps "Continue" with `selection == nil` → `showValidationError = true`.
2. Every row's `GiniOptionRow` variant is computed as:
   ```swift
   if showValidationError { .radio(.error) }
   else if selection == rowChoice { .radio(.selected) }
   else { .radio(.unselected) }
   ```
3. Validation line renders conditionally: `if showValidationError { Text(vm.validationErrorMessage) … }`.
4. Any row tap sets `selection = .some(rowChoice)` **and** `showValidationError = false` in the
   same `onTap` closure.

This lives inside the sheet — not the viewmodel — because it's pure UI state driven by a
transient "did the user try and fail to confirm" fact. The viewmodel stays a plain, equatable,
testable struct.

### Example parent call site (what PP-3960 will do)

```swift
@available(iOS 16.0, *)
struct MismatchContainer: View {               // owned by PP-3960
    let mismatchArgs: MismatchArgs             // owned by PP-3960
    @State private var showIBANPicker = false
    @State private var selection: IBANChoice? = nil

    var body: some View {
        MismatchView(args: mismatchArgs,
                     onProceedAnyway: { showIBANPicker = true })
            .giniBottomSheet(isPresented: $showIBANPicker) {
                IBANSelectionSheet(
                    viewModel: makeSheetViewModel(from: mismatchArgs),
                    selection: $selection,
                    onContinue: { choice in
                        showIBANPicker = false
                        DispatchQueue.main.async {
                            iBANSelectionCoordinator.userConfirmed(choice)  // phase 2
                        }
                    },
                    onDismiss: { selection = nil }
                )
            }
    }
}
```

Phase 1 ships a `#if DEBUG` preview catalogue that renders this host exactly, with hand-built
`MismatchArgs`-equivalent dummy data so previews work without PP-3960.

## Test plan

Framework: **Swift Testing** (`@Suite`, `@Test`, `#expect`) — matches `GiniOptionRowTests`,
`GiniExpandableInfoViewModelTests`, `FraudSignalMapperTests`, and the Nov-2026 convention for
all new fraud-prevention tests.

### 1. `IBANSelectionSheetViewModelTests.swift` — new

Pure viewmodel round-trip tests. ~4 tests:

- `initStoresAllDisplayStrings()` — pass every string into `init`, assert every `let` holds the
  same value by `#expect`. Covers R1 (strings on screen) and R15 (no NSLocalizedString inside).
- `initPreservesPrintedIBANsOrder()` — pass `["P1", "P2", "P3"]`, assert
  `vm.printedIBANs == ["P1", "P2", "P3"]` (identity order). Covers R8.
- `initAcceptsSinglePrintedIBAN()` — pass `["P1"]`, assert viewmodel holds it. Covers R7.
- `initPassesThroughColorSchemeAndFonts()` — build a sentinel `GiniColorScheme` + sentinel
  `UIFont` values; assert pass-through by identity. Covers R14.

Fixtures: hand-built `GiniColorScheme` with sentinel colors (same pattern
`GiniExpandableInfoViewModelTests` uses — PR #1312).

### 2. `ViewGiniBottomSheetTests.swift` — new (GiniUtilites)

Modifier is a thin wrapper around SwiftUI's own `.sheet`; runtime behavior is Apple's
responsibility. Test only the public API shape. 1 test:

- `modifierCompilesAsAnAvailableExtensionOnView()` — call `EmptyView().giniBottomSheet(isPresented: .constant(false)) { Text("x") }` inside an `@available(iOS 16, *)` function, assert it type-checks (test lives in a target that compiles). Covers R9 at the smoke-test level.

Runtime sheet presentation (the actual `.medium` detent + `.visible` drag indicator) is
visible-only in the sheet's own preview catalogue and a UI test if we add one later. No
snapshot library is in the repo (per `platform.md`) — runtime appearance is verified via
previews + manual QA on the finished `IBANSelectionSheet`.

### 3. `IBANSelectionSheet.swift` — `#Preview` catalogue

Ships three `#Preview` blocks inside the sheet's file (`@available(iOS 17.0, *)` for the
`#Preview` macro; the sheet is iOS 16+):

- **Default** — selection `.constant(nil)`, no error. Matches Figma `38762:210919`.
- **Selected printed** — selection `.constant(.printed(iban: "DE89…"))`, no error.
- **Validation error** — selection `.constant(nil)`, `showValidationError = true` (via a
  `PreviewHelper` that overrides the private `@State` through a wrapper view). Matches Figma
  `38457:29452`.

Also a dark-mode variant of "Default" and a Dynamic Type AX3 variant, mirroring
`GiniOptionRowPreviewCatalog`'s pattern.

### Not tested (phase 1)

- Runtime sheet dismissal (drag-down, tap-outside) — Apple's SwiftUI `.sheet` is trusted.
  Phase 2's integration test will exercise this on device via the example app.
- The sheet's visual appearance at every color scheme / Dynamic Type size — manual QA against
  Figma.
- VoiceOver rotor navigation of the sheet end-to-end — manual check with
  `mobile-a11y-specialist` on the finished build.
- `IBANChoice` equality / hashing — synthesised, no custom implementation worth testing.
- `ChosenIBANExtractions`, `IBANSelectionCoordinator`, BIC removal, `AnalysisResult` wiring —
  phase 2, separate test suites.

## Out of scope (phase 1)

- Mismatch warning screen (`MismatchView`, `MismatchContainer`, `MismatchHostingController`) —
  PP-3960.
- Coordinator (`IBANSelectionCoordinator`) and apply-choice helper
  (`ChosenIBANExtractions.apply(to:chosenIBAN:)`) — phase 2.
- `extractions["bic"]` removal, `extractions["iban"]` replacement, `AnalysisResult`
  reconstruction, `GiniBankNetworkingScreenApiCoordinator.deliverAnalysisResult(_:)` wiring —
  phase 2.
- Reading `candidates["ibans"]` / dedupe / case-insensitive normalisation — phase 2.
- Country-mismatch handling (sheet never opens for country-only) — phase 2 / PP-3960.
- Localized `.strings` entries for `ginibank.fraud.ibanSelection.*` — phase 2 (co-located with
  the warning-screen strings).
- iOS 15 fallback — R10 locks phase 1 at iOS 16+.
- Public integrator docs — separate ticket (mirrors Android PP-3968).
- Analytics / telemetry for sheet events.
- Liquid Glass adoption beyond what the system `.sheet` gives for free on iOS 26+.
- Consolidation with `GiniInternalPaymentSDK.GiniBottomSheetModifier` — the modifier shipped
  here is intentionally a simpler primitive; a future refactor can promote the Internal
  Payment version into `GiniUtilites` and unify.

## Open questions

- **O1 — Does PP-3960 want the modifier on the parent or on the host?** Our example site
  applies `.giniBottomSheet` to the `MismatchView`-containing parent. If PP-3960 prefers to
  attach it inside `MismatchView` itself (e.g. so a `UIHostingController` can toggle the
  binding), nothing about this spec changes — the modifier is a pure `View` extension and both
  attachment points work. Confirm with Nadya when PP-3960 branch lands.
- **O2 — Design review of validation line placement.** The Figma (`38457:29452`) places the
  validation line between the rows and the footer hint. Confirm with design before build that
  it stays above the footer hint (not below it, not replacing it) — this spec assumes "above,
  footer stays visible."

## Phase 2 — deferred work (follow-up ticket, NOT this PR)

Opens after PP-3960 lands. Scope mirrors Android PR #1030's `ChosenIbanExtractions` +
`AnalysisScreenPresenterExtension` wiring:

- `IBANSelectionCoordinator` (internal `final class`) with weak
  `IBANSelectionCoordinatorDelegate`; constructed by PP-3960's `MismatchContainer` when the
  sheet opens.
- `ChosenIBANExtractions.apply(to:chosenIBAN:) -> AnalysisResult` (internal enum, pure
  transform): replace `extractions["iban"]` with a new `Extraction(box: nil, candidates:
  oldIBAN.candidates, entity: "iban", value: chosen, name: "iban")` and remove
  `extractions["bic"]` when `chosen` normalises to a value different from the current QR IBAN
  (whitespace-insensitive, case-insensitive). No-op when `chosen == nil` / empty / equals QR.
- `IBANNormalization.normalize(_:)` (internal) — trim + uppercase; shared with PP-3960's
  mapper.
- `GiniBankNetworkingScreenApiCoordinator` wiring: the deliver path (currently
  `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` at
  `GiniBankNetworkingScreenApiCoordinator.swift:277`) is replaced by PP-3960's
  `deliverAnalysisResult(_:)` extension which routes through `IBANSelectionCoordinator` when a
  fraud signal is present. On "Continue": coordinator runs `ChosenIBANExtractions.apply` and
  forwards the new `AnalysisResult` to the results delegate. On "Dismiss": coordinator returns
  control to the warning screen (does not deliver).
- Localized strings: add `ginibank.fraud.ibanSelection.title`, `.row.qr.label`,
  `.row.printed.label`, `.footer.hint`, `.cta.continue`, `.validation.selectIBAN`,
  `.a11y.hint.*` to `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Resources/*.lproj/Localizable.strings`.
- Reading `candidates["ibans"]` + dedupe (case-insensitive + whitespace-insensitive against
  QR), as Android `IBANMismatchArgsMapper` does.
- Tests: `ChosenIBANExtractionsTests` (6 cases mirroring Android `ChosenIbanExtractionsTest`),
  `IBANSelectionCoordinatorTests` (3 cases), `NetworkingScreenApiCoordinatorTests+ChosenIBAN`
  extension (2 cases).

Backend-confirmed invariants carried over from Android (PR #1030, backend team 2026-11-10):
QR IBAN is `extractions["iban"]`; printed IBANs are candidates under
`extractions["iban"].candidates ?? "ibans"`; backend never pairs `bic` with a printed IBAN, so
switching off QR means removing `bic` entirely — banks derive BIC from IBAN, no BIC is safer
than a wrong one.

## Concreteness gate

- [x] Every requirement testable as written (R1–R15 are Given/When/Then with concrete
      observable results; the viewmodel round-trip tests directly realise R1/R7/R8/R14/R15).
- [x] Entry, happy path, error path, async all covered (R1/R9/R10 entry; R2/R4/R7/R8 happy;
      R3/R5 error; R6 async).
- [x] No vague words ("properly", "appropriate", "correctly", "etc." — none present).
- [x] Affected modules named by SPM product name (GiniUtilites, GiniBankSDK; the "not touched"
      list is explicit).
- [x] Integrator-visible entry point named exactly: the new `public` extension method
      `View.giniBottomSheet(isPresented:content:)` in `GiniUtilites`. Internal entry for the
      sheet: `IBANSelectionSheet(viewModel:selection:onContinue:onDismiss:)` in `GiniBankSDK`.
- [x] Public API impact: one additive public declaration named exactly.
- [x] Test plan names concrete test file names and framework (Swift Testing).
- [x] Design references real existing code by path (`GiniOptionRow.swift`,
      `GiniExpandableInfoView` / `GiniExpandableInfoViewModelTests`, `GiniBankConfiguration.swift`,
      `GiniBankNetworkingScreenApiCoordinator.swift:277`, Figma nodes). All read in this session
      or prior sessions.
- [x] No `(confidence: LOW …)` markers left — every low-confidence item from the previous spec
      revision was either resolved by the 2026-11-17 clarifying questions and the Figma pull
      (R10, modifier location, viewmodel shape, error-state pattern) or moved into phase 2.
