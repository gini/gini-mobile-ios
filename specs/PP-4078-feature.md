# PP-4078: Build fraud warning screen content + placeholder picker sheet

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-4078
Parent: PP-3960 — [iOS] Fraud warning screen: IBAN mismatch

Builds on:
- **PP-4077 / PR #1314 (open)** — fraud warning scaffold types (`FraudWarningCoordinator`, `FraudWarningViewModel`, `FraudWarningContainer`, `FraudWarningView`, delegates) + `GiniBankConfiguration.fraudWarningEnabled`. This branch (`feat/PP-4078_iban_mismatch`) is stacked on `feat/PP-4077_routing`.
- **PP-3995 / PR #1312 (open)** — `GiniUtilites.GiniExpandableInfoView` SwiftUI primitive. Consumed here as the "How do I protect myself?" expandable. Reaches us once PR #1312 merges into `release/fraud-prevention-phase`.
- **PP-3997 (merged, PR #1311)** — `GiniUtilites.GiniOptionRow`. Consumed here via the `.informational` variant for the two inline IBAN rows.

Hands off to:
- **PP-3962 (Qazi, In Progress)** — IBAN selection sheet. Qazi replaces the body of `IBANPickerPlaceholder.swift` that this ticket creates. Qazi also owns the chosen-IBAN propagation and the `bic` removal from `AnalysisResult.extractions`.

## Problem

PP-4077 shipped the fraud warning screen as a scaffold: a modal with just "Cancel transfer" and "Proceed anyway" buttons over an empty content area. The parent PP-3960's acceptance criteria require the warning to show the detected IBANs inline (QR IBAN + printed IBAN), a "How do I protect myself?" expandable info section with safety guidance, and a warning title/subtitle. Figma design is at `https://www.figma.com/design/5U3VTLmE2dcHdPkDG1GM3J/iOS-Gini-Bank-SDK-4.7-UI-Customisation?node-id=44909-11299`.

This subtask fills PP-4077's empty content area with the Figma layout, and wires "Proceed anyway" to present a placeholder bottom sheet at a medium detent. The placeholder is a trivial stub view named `IBANPickerPlaceholder` — PP-3962 (Qazi) replaces its body with the real IBAN selection sheet. By owning the `.sheet(isPresented:)` wiring side here and leaving only the sheet-body file for Qazi to swap, the two tickets converge with a minimal conflict surface.

What this ticket does **not** do: pick an IBAN, write a chosen IBAN into `AnalysisResult.extractions["iban"]`, drop `bic`, or trigger the fraud warning from a real analysis flow. The `fraudWarningEnabled` toggle on `GiniBankConfiguration` remains unconsumed by the SDK's delivery path — a separate ticket wires it in.

## Requirements

Entry point: internal. No new public declaration. The screen remains reachable only when `FraudWarningCoordinator.start()` is invoked explicitly by test code or a future integration seam.

Content tags: **entry** / **happy** / **error**.

### Content composition

- **R1 (MUST, happy — warning header).** `FraudWarningView` renders, from top to bottom: a warning icon (SF Symbol `exclamationmark.triangle.fill`, orange tint — scaffold placeholder for the Figma's custom red-exclamation glyph), the title `"Different IBANs in this document"` and the subtitle `"The IBAN in the QR code doesn't match the printed IBAN"`. Title + subtitle are centered, hardcoded English with `// TODO: localise and tokenize` markers (same deferral as PP-4077's buttons).
- **R2 (MUST, happy — protect-myself expandable).** Below the subtitle, `FraudWarningView` renders one `GiniExpandableInfoView` (from `GiniUtilites`, shipped by PP-3995 / PR #1312) with:
  - `title: "How do I protect myself?"` (hardcoded English, `// TODO:` marker)
  - `expandedBody: "Documents are sometimes changed to redirect payments. If you're unsure which IBAN is right, ask the sender using contact details you already know."` (hardcoded English, `// TODO:` marker)
  - `icon: UIImage(systemName: "shield.lefthalf.filled")!` with a blue tint (scaffold placeholder for Figma's `#006ECF` shield asset)
  - `giniColorScheme: UIColor.giniBankColorScheme()`
  - `isExpanded:` bound to `viewModel.isExpandedProtectMyself`
  - Collapsed by default (`viewModel.isExpandedProtectMyself == false` at init).
- **R3 (MUST, happy — IBAN rows).** Below the expandable, `FraudWarningView` renders a section header `"The following IBANs were detected"` (hardcoded English, `// TODO:` marker) followed by two `GiniOptionRow(variant: .informational, …)` rows stacked vertically:
  - Row 1: `title: "In the QR code"`, `content: viewModel.qrIBAN`, no footer, `giniColorScheme: UIColor.giniBankColorScheme()`, `onTap: nil`.
  - Row 2: `title: "Printed on the document"`, `content: viewModel.printedIBAN`, no footer, same scheme, `onTap: nil`.
  Both titles are hardcoded English with `// TODO:` markers. The two rows are purely informational (not selectable) — the user selects the IBAN on the picker sheet (PP-3962).
- **R4 (MUST, happy — buttons unchanged).** The Cancel and Proceed buttons at the bottom remain structurally as PP-4077 shipped them. Their visual styling follows the Figma: primary filled "Cancel transfer" on top (hardcoded English), secondary outlined "Proceed anyway" below (hardcoded English). No behaviour change on tap — the existing `onCancel` / `onProceed` closures from PP-4077 fire exactly as before. (Figma shows the buttons swapped — primary Cancel above secondary Proceed. PP-4078 adopts this order; PP-4077 had the opposite which was scaffold-only.)

### Data

- **R5 (MUST, entry — VM carries IBANs).** `FraudWarningViewModel` gains two stored properties: `let qrIBAN: String` and `let printedIBAN: String`. The init signature becomes `init(qrIBAN: String, printedIBAN: String, delegate: FraudWarningViewModelDelegate?)`; `FraudWarningCoordinator.init(qrIBAN:printedIBAN:delegate:)` forwards both. `FraudWarningView` reads the IBANs through `viewModel.qrIBAN` / `viewModel.printedIBAN` via `FraudWarningContainer`. For scaffold / preview use, call sites pass hardcoded `"PL12 1000 0111 0100 1000"` / `"DE89 3704 0044 0532 0130 00"` (same strings PP-4077's spec sketched).
- **R6 (MUST, entry — VM carries expand state).** `FraudWarningViewModel` gains `@Published var isExpandedProtectMyself: Bool = false`. `FraudWarningContainer` passes `$viewModel.isExpandedProtectMyself` to the `GiniExpandableInfoView.isExpanded:` binding. State ownership lives on the VM — the View stays stateless.

### Placeholder picker sheet

- **R7 (MUST, happy — sheet on Proceed).** `FraudWarningContainer` gains `@State private var isShowingPicker: Bool = false`. The container binds `.sheet(isPresented: $isShowingPicker) { IBANPickerPlaceholder().presentationDetents([.medium]).presentationDragIndicator(.visible) }` to its root. The existing PP-4077 `onProceed` closure is rewired to set `isShowingPicker = true` **instead of** calling `viewModel.didTapProceed()` — the proceed-to-terminal-delivery path is now owned by Qazi's picker on Confirm. Cancel's path (`viewModel.didTapCancel()` → `fraudWarningViewModelDidCancel`) is unchanged.
- **R8 (MUST, happy — placeholder body).** `IBANPickerPlaceholder: View` is a trivial stub whose body is:
  ```swift
  VStack {
      Text("IBAN picker — PP-3962 (Qazi)")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding()
      Spacer()
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  ```
  No delegate, no interaction, no init parameters. The file exists specifically so Qazi's PP-3962 PR can swap its body without touching `FraudWarningContainer`.
- **R9 (MUST, happy — swipe dismisses sheet only).** Dragging the sheet down or tapping its grabber calls SwiftUI's binding, setting `isShowingPicker = false`. The fraud warning behind it remains visible. No delegate fires. A subsequent tap on "Proceed anyway" re-presents the sheet with a fresh placeholder (SwiftUI constructs a new `IBANPickerPlaceholder` on each `.sheet` body call; trivial since the placeholder has no state).

### Delegate shape (unchanged from PP-4077)

- **R10 (MUST, entry — VM delegate unchanged).** `FraudWarningViewModelDelegate` keeps PP-4077's shape:
  ```swift
  protocol FraudWarningViewModelDelegate: AnyObject {
      func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel)
      func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel)
  }
  ```
  No `state:`, no `choice:` payload. The proceed delegate still fires in PP-4077 code paths (nothing in PP-4078 removes the method), but under the new `.sheet`-on-proceed wiring in R7, the Container short-circuits before reaching `viewModel.didTapProceed()`. Future wiring (PP-3962 or beyond) decides when `didTapProceed` fires terminally.
- **R11 (MUST, entry — Coordinator delegate unchanged).** `FraudWarningCoordinatorDelegate` keeps PP-4077's shape (`didCancel` / `didProceed`, both Void). No signature change.

### Presentation wire-up (scope expansion post-Step 7)

Added after the Content/Data/Placeholder slice shipped: the user needed the screen reachable from the running example app, not only from test code. This section wires the toggle into the three terminal delivery paths with **stub** IBANs — real extraction from `AnalysisResult.candidates` is explicitly deferred to a follow-up ticket per the user's direction. Without this, `fraudWarningEnabled = true` has no observable effect in the example app.

- **R13 (MUST, entry — toggle gates presentation across all three delivery paths).** Given `GiniBankConfiguration.fraudWarningEnabled == true`, when `GiniBankNetworkingScreenApiCoordinator`'s terminal delivery fires on any of the three real paths — `deliver(result:analysisDelegate:)` (plain), `deliverWithReturnAssistant(result:analysisDelegate:)` (invoices with line items), `deliverWithSkonto(result:analysisDelegate:)` (Skonto discounts) — plus the Wero fallback `deliverWeroResult(_:)`, then the fraud warning is presented BEFORE `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` is invoked. The terminal section of each path is wrapped in `self.presentFraudWarningIfEnabled(result:completion:)` where `completion` carries the original delegate call + any path-specific post-delivery side effects (line items assignment, Skonto summary, `documentService.resetToInitialState()`). When the toggle is off, the completion fires synchronously with the original result — zero behavioral change.
- **R14 (MUST, happy — stub IBANs).** `FraudWarningCoordinator` is constructed with the scaffold stubs `"PL12 1000 0111 0100 1000"` / `"DE89 3704 0044 0532 0130 00"`. No extraction parsing against `AnalysisResult.candidates["ibans"]`, no chosen-IBAN propagation — deferred.
- **R15 (MUST, happy — bottom-sheet presentation style).** The fraud warning is presented via `UISheetPresentationController` with the `.large()` detent, grabber visible (`shouldShowDragIndicator = true`), edge-attached in landscape disabled (`shouldShowInFullScreenInLandscapeMode = false`). Implementation uses a `FraudWarningBottomSheetController` subclass of `UIHostingController<FraudWarningContainer>` that conforms to `GiniBottomSheetPresentable` from `GiniUtilites`. The repo's `presentAsBottomSheet(from:)` hardcodes the medium detent, so the integration extension configures with `configureBottomSheet(shouldIncludeLargeDetent: true)` and runs `screenAPINavigationController.present(_:animated:)` manually while preserving the same accessibility setup (`presenting.view.accessibilityElementsHidden = true`, `hosting.view.accessibilityViewIsModal = true`, `UIAccessibility.post(.screenChanged, …)`).
- **R16 (MUST, happy — single-terminal-callback guarantee).** `GiniBankNetworkingScreenApiCoordinator` gains one stored property `fraudWarningPresentation: (coordinator: FraudWarningCoordinator, result: AnalysisResult, completion: (AnalysisResult) -> Void)?` that carries all state tied to the on-screen fraud warning. `takeFraudWarningPresentation()` is an atomic get-and-nil helper; both `fraudWarningCoordinatorDidCancel(_:)` and `fraudWarningCoordinatorDidProceed(_:)` guard on its result. Rapid double-tap (Cancel+Cancel, Cancel+Proceed, etc.) therefore resolves to exactly one terminal callback and exactly one `screenAPINavigationController.dismiss`. Swipe-to-dismiss is blocked by `hosting.isModalInPresentation = true` — otherwise a drag-down would leave the parked completion closure dangling with no terminal path.
- **R17 (MUST, happy — Confirm button on placeholder for Proceed terminality).** `IBANPickerPlaceholder` gains `var onConfirm: () -> Void = {}` and renders a "Confirm (placeholder — dev only)" primary-styled button beneath its stub text. `FraudWarningContainer` wires this closure to set `isShowingPicker = false` and call `viewModel.didTapProceed()`, which propagates through the ViewModel → Coordinator → integration-extension delegate chain to resolve the pending delivery. Without this button, the Proceed path on the warning opens an empty sheet with no terminal action and the parked delivery is stuck. When PP-3962 (Qazi) replaces the placeholder body, the real Confirm button takes over this responsibility; the default closure means existing tests that instantiate `IBANPickerPlaceholder()` still compile.
- **R18 (MUST, happy — Cancel path cancels analysis + resets).** `fraudWarningCoordinatorDidCancel(_:)` calls `resultsDelegate?.giniCaptureDidCancelAnalysis()` and `documentService.resetToInitialState()` after dismissing the sheet, matching the no-results-path behavior in the delivery methods. This ensures cached document state does not leak into the next capture session.
- **R19 (MUST, happy — Proceed delivers the ORIGINAL result).** `fraudWarningCoordinatorDidProceed(_:)` invokes the parked `completion` closure with the ORIGINAL `AnalysisResult` unchanged — no substitution, no `ChosenIBANExtractions` wrapping. The chosen IBAN remains scoped to the sheet layer; propagation into extractions is PP-3962 (Qazi) territory.

### Public API impact

- **R20.** None. Every new type (`IBANPickerPlaceholder`, `FraudWarningBottomSheetController`, the `GiniBankNetworkingScreenApiCoordinator+FraudWarning` extension) is `internal`. The `FraudWarningCoordinator.init` and `FraudWarningViewModel.init` signatures change to carry `qrIBAN:printedIBAN:` parameters — both internal, both affect no external consumer (PP-4077 shipped with no SDK or test-external caller of these inits). `FraudWarningCoordinator.start()`'s return type widens from `UIViewController` to `GiniBottomSheetViewController` (`UIViewController & GiniBottomSheetPresentable`) — covariant, internal, non-breaking. One new internal stored property on `GiniBankNetworkingScreenApiCoordinator` — `fraudWarningPresentation`. `GiniBankConfiguration.fraudWarningEnabled` unchanged. No new integrator-visible declaration.

## Affected modules

- **`GiniBankSDK`** (primary, iOS 16+ per PP-4077's manifest bump).
  - **Existing files (modifications to the PP-4077 scaffold):** `FraudWarningView.swift`, `FraudWarningContainer.swift`, `FraudWarningCoordinator.swift`, `FraudWarningViewModel.swift`. All at `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/FraudDetection/FraudMismatch/`.
  - **New file:** `IBANPickerPlaceholder.swift`, same folder. ≤30 lines of SwiftUI.
  - **Unchanged from PP-4077:** `FraudWarningViewModelDelegate.swift`, `FraudWarningCoordinatorDelegate.swift`.
- **`GiniUtilites`** — consumed only. `GiniExpandableInfoView` (from PR #1312, merge-pending) and `GiniOptionRow` (shipped in PP-3997). Unchanged.
- **`GiniCaptureSDK`** — no change.
- **`GiniBankSDKExample`** — no change. Settings toggle PP-4077 added is still unconsumed by the SDK's delivery path; the placeholder sheet remains reachable only via test code and SwiftUI previews until a later ticket wires the trigger.

## Public API impact

**None.** All new types / modified init signatures are `internal`. `GiniBankConfiguration.fraudWarningEnabled` (public) is unchanged.

## Technical conventions

Grounded in `.claude/rules/mandatory-rules.md`, `CLAUDE.md` § "MyApp Standards", `AGENTS.md`, and PP-4077's precedents:

1. **Language & access control.** Swift, `internal` by default. All new types `internal`. Doc comments on declarations use `/** ... */`; inline body comments use `///`.
2. **UI framework.** SwiftUI end-to-end. `FraudWarningView` body stays a composition of `VStack` + system styles + the two GiniUtilites primitives (`GiniExpandableInfoView`, `GiniOptionRow`). iOS 16 baseline — no `@available(iOS 16, *)` gates.
3. **Architecture.** MVVM. The fraud warning Coordinator (PP-4077) remains the sole coordinator for this screen; no new Coordinator introduced for the placeholder sheet (it's a sub-component of the fraud warning). The ViewModel holds state (`qrIBAN`, `printedIBAN`, `isExpandedProtectMyself`), the View is purely presentational, the Container owns sheet-presentation `@State`.
4. **Design system — scaffold trade-off.** `GiniOptionRow` is called with `giniColorScheme: UIColor.giniBankColorScheme()` so its colors already come from the design-system tokens (PP-3997 did that work). `GiniExpandableInfoView` is called with the same scheme. The remaining inline SwiftUI styling in `FraudWarningView` (warning title/subtitle font, button background) continues PP-4077's scaffold trade-off: plain SwiftUI defaults + system SF Symbols where Figma has custom assets, each marked `// TODO: apply design-system tokens` at the call site. This is a known deviation from mandatory-rules.md §Design system ("MUST prefer `GiniColorScheme`") — explicitly accepted for this scaffold pass because the final visual pass lands with PP-3960's production-design subtask. Magic numbers (padding, spacing, corner radius, button heights) live in a local `private enum Constants` inside `FraudWarningView.swift`.
5. **DI.** Constructor injection throughout. `FraudWarningCoordinator(qrIBAN:printedIBAN:delegate:)`, `FraudWarningViewModel(qrIBAN:printedIBAN:delegate:)`, `IBANPickerPlaceholder()`.
6. **Async.** No new async work. Expand/collapse of `GiniExpandableInfoView` is synchronous (its binding mutates state on the main actor).
7. **Strings.** Hardcoded English literals inline in the view bodies with `// TODO: localise and tokenize` markers. **No** typed `LocalizableStringResource` enum, **no** `Localizable.strings` entries. This is a known deviation from mandatory-rules.md §Localization ("MUST use typed enums") — explicitly accepted for this scaffold pass; localization lands with the final visual pass.
8. **Formatting.** Multi-parameter inits / methods use one-parameter-per-line with vertical alignment under the first parameter's external label.
9. **Quality gates.** `xcodebuild clean test -scheme GiniBankSDK -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2'` clean. Each new or modified ViewModel method ships with a unit test.

## Design

### Folder layout (additive + modifications to PP-4077)

```
BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/FraudDetection/FraudMismatch/
├── FraudWarningContainer.swift              (modified — adds @State + .sheet layer + binding passthrough)
├── FraudWarningCoordinator.swift            (modified — init takes qrIBAN + printedIBAN)
├── FraudWarningCoordinatorDelegate.swift    (unchanged)
├── FraudWarningView.swift                   (modified — renders the full Figma content)
├── FraudWarningViewModel.swift              (modified — holds IBAN strings + expand state)
├── FraudWarningViewModelDelegate.swift      (unchanged)
└── IBANPickerPlaceholder.swift              (NEW)
```

### Types (pseudocode — final formatting applied at implementation time)

```swift
// FraudWarningViewModel.swift (modified)
@MainActor
final class FraudWarningViewModel: ObservableObject {
    let qrIBAN: String
    let printedIBAN: String
    @Published var isExpandedProtectMyself: Bool = false
    weak var delegate: FraudWarningViewModelDelegate?

    init(qrIBAN: String,
         printedIBAN: String,
         delegate: FraudWarningViewModelDelegate?) {
        self.qrIBAN = qrIBAN
        self.printedIBAN = printedIBAN
        self.delegate = delegate
    }

    func didTapCancel()  { delegate?.fraudWarningViewModelDidCancel(self) }
    func didTapProceed() { delegate?.fraudWarningViewModelDidProceed(self) }
}

// FraudWarningCoordinator.swift (modified)
@MainActor
final class FraudWarningCoordinator: FraudWarningViewModelDelegate {
    weak var delegate: FraudWarningCoordinatorDelegate?
    let viewModel: FraudWarningViewModel

    init(qrIBAN: String,
         printedIBAN: String,
         delegate: FraudWarningCoordinatorDelegate?) {
        self.delegate = delegate
        self.viewModel = FraudWarningViewModel(qrIBAN: qrIBAN,
                                               printedIBAN: printedIBAN,
                                               delegate: nil)
        self.viewModel.delegate = self
    }
    // start(), delegate forwarding methods unchanged from PP-4077
}

// FraudWarningContainer.swift (modified)
struct FraudWarningContainer: View {
    @ObservedObject var viewModel: FraudWarningViewModel
    @State private var isShowingPicker = false

    var body: some View {
        FraudWarningView(viewModel: viewModel,
                         onCancel: viewModel.didTapCancel,
                         onProceed: { isShowingPicker = true })
            .sheet(isPresented: $isShowingPicker) {
                IBANPickerPlaceholder()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
    }
}

// FraudWarningView.swift (modified — much larger body now)
struct FraudWarningView: View {
    @ObservedObject var viewModel: FraudWarningViewModel
    var onCancel: () -> Void
    var onProceed: () -> Void

    var body: some View {
        VStack(spacing: Constants.sectionSpacing) {
            warningIcon
            titleAndSubtitle
            protectMyselfExpandable
            detectedIBANsSection
            Spacer(minLength: 0)
            buttonStack
        }
        .padding(Constants.outerPadding)
    }

    // warningIcon, titleAndSubtitle, protectMyselfExpandable, detectedIBANsSection,
    // buttonStack, Constants — see Implementation plan at /gini-build time.
}

// IBANPickerPlaceholder.swift (NEW)
/**
 Placeholder for the IBAN selection sheet shipped by PP-3962 (Qazi).

 Qazi's PR replaces this view's body with the real picker. The containing
 `FraudWarningContainer`'s `.sheet` wiring stays owned by this ticket — Qazi
 only touches the file below.
 */
struct IBANPickerPlaceholder: View {
    var body: some View {
        VStack {
            Text("IBAN picker — PP-3962 (Qazi)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

### Flow

1. `FraudWarningCoordinator(qrIBAN: …, printedIBAN: …, delegate: self)` is constructed somewhere (test, future integration). `start()` returns the hosting `UIHostingController<FraudWarningContainer>` (PP-4077's wiring unchanged).
2. User sees the full-screen modal with the Figma layout: warning icon, title, subtitle, collapsed expandable, "The following IBANs were detected" + two inline rows, Cancel + Proceed.
3. User taps the expandable → `viewModel.isExpandedProtectMyself.toggle()` → `GiniExpandableInfoView` animates open (or swaps the chevron glyph with Reduce Motion on).
4. User taps Cancel → `viewModel.didTapCancel()` → delegate chain → eventual integrator `giniCaptureDidCancelAnalysis()` once PP-4077's wiring is re-connected by a future ticket.
5. User taps Proceed → `FraudWarningContainer` sets `isShowingPicker = true` → `.sheet` presents `IBANPickerPlaceholder` at `.medium` detent. While PP-3962 is unmerged, the sheet shows the stub text. When PP-3962 lands, Qazi's picker replaces the placeholder body — Container-side wiring is unchanged.
6. User swipes the placeholder sheet down → SwiftUI sets `isShowingPicker = false` → fraud warning remains on screen. No delegate fires.

## Test plan

Test stack: **Swift Testing** (`@Suite`, `@Test`, `#expect`). Tests under `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/FraudMismatch/`.

| Test class | Covers | Rough count |
|---|---|---|
| `FraudWarningViewModelTests` *(extends PP-4077's suite)* | Existing: cancel / proceed / init-with-nil-delegate (unchanged from PP-4077). New: init stores `qrIBAN` and `printedIBAN`; `isExpandedProtectMyself` defaults to `false`; toggling it publishes an update. | +3 (existing 4 adapted for the new init) |
| `FraudWarningCoordinatorTests` *(extends PP-4077's suite)* | Existing: hosting-controller config / cancel forwarding / proceed forwarding (unchanged). New: init forwards `qrIBAN` and `printedIBAN` to the constructed VM. | +1 (existing 3 adapted) |
| `FraudWarningViewRenderingTests` *(extends PP-4077's suite)* | Existing: container renders without crash. New: container with non-empty IBAN strings renders without crash (smoke); container with `isShowingPicker = true` renders the placeholder body without crash (smoke); container with `isExpandedProtectMyself = true` renders the expanded expandable without crash (smoke). | +3 (existing 1 adapted) |
| `IBANPickerPlaceholderTests` *(new)* | Smoke: placeholder renders without crash inside a `UIHostingController` attached to a `UIWindow`; placeholder's body contains the stub text "IBAN picker — PP-3962 (Qazi)" (asserted by rendering the view into an `ImageRenderer` or by inspecting the `Text`'s accessibility label). | 2 |

Total new tests: ~9 on top of PP-4077's 8 (adapted for new init signatures) = ~17 FraudWarning tests on green.

Every ViewModel method with observable behaviour has a test (`didTapCancel`, `didTapProceed`, `isExpandedProtectMyself` publishing). The placeholder gets a smoke suite so a regression that turns its body empty surfaces as a failing assertion before Qazi ships.

### Not tested

- **Visual fidelity to Figma** — pixel-level matching is manual-QA. The Figma's custom warning glyph and `#006ECF` shield icon are swapped for SF Symbols; Qazi's final-visual ticket (or PP-3960's design subtask) replaces them. The spec explicitly accepts this in §Technical conventions §4.
- **`GiniOptionRow` and `GiniExpandableInfoView` internals** — owned by `GiniUtilitesTests` (PP-3997 and PP-3995 respectively). This ticket relies on their shipped contracts.
- **`UIColor.giniBankColorScheme()` resolution** — owned by `GiniUtilites`.
- **`.sheet(isPresented:) + .presentationDetents([.medium]) + .presentationDragIndicator(.visible)` behaviour** — OS-native.
- **Swipe-to-dismiss** — OS-native; the behaviour that the fraud warning survives dismissal is implicit in SwiftUI's view-identity rules and not asserted.
- ~~**Full integration from `GiniBankNetworkingScreenApiCoordinator.deliver(result:)`**~~ — **MOVED INTO SCOPE post-Step 7** (R13–R19). Presentation is wired across all four delivery paths with stub IBANs. Real extraction from `AnalysisResult.candidates` is still deferred (follow-up ticket).
- **Chosen-IBAN propagation + `bic` removal** — owned by PP-3962 (Qazi).
- **Localization** — nothing localised; hardcoded English with TODOs.

## Out of scope

- **IBAN selection sheet content / picker UI** — ships with PP-3962 (Qazi). Qazi replaces `IBANPickerPlaceholder.swift`'s body; the `.sheet` wiring in `FraudWarningContainer` stays owned here. The dev-only Confirm button on the placeholder (R17) exists only to give the Proceed path a terminal action while Qazi's picker is unbuilt — his real Confirm takes over that responsibility.
- **Chosen-IBAN propagation past the delegate boundary** → PP-3962.
- **`AnalysisResult.extractions["iban"]` rewrite + `bic` removal** when the user picks a non-QR IBAN → PP-3962's AC.
- **Real fraud-signal detection via `FraudSignalMapper.map(…)`** → separate ticket (equivalent to Android PR #1030's mapper wiring).
- **Country-mismatch state + routing** → separate ticket. The `.ibanCountryMismatch` case the previous spec draft introduced is deferred; this ticket ships only the QR-vs-printed layout.
- **Final visual pass** — the production-design icons, color tokens, typography — → the parent PP-3960 or a design-focused subtask.
- **Liquid Glass on iOS 26+** → final visual pass.
- **iPad / landscape adaptivity** → final visual pass.
- **Accessibility audit (VoiceOver, 200% Dynamic Type, external keyboards)** → final visual pass.
- **Localization** → final visual pass.

## Open questions

None open at spec-write time. Implementation notes:

- **R7 rewires the proceed path from "fire delegate" to "show sheet".** PP-4077's `viewModel.didTapProceed()` still exists and still fires the delegate when called, but under the new Container wiring it is **not called** on the user tap — the Container intercepts first. PP-3962 will decide whether its Confirm button calls `viewModel.didTapProceed()` to resume the pre-PP-4078 delegate path or introduces its own callback. Either choice works and is PP-3962's call, not this ticket's.
- **Visual deviations from Figma** — warning icon, shield icon, exact title/subtitle typography — are explicitly accepted for scaffold. The final visual pass ticket owns matching the design pixel-wise.

## Resolutions at /gini-build time (2026-11-18)

1. **GiniExpandableInfoView (PR #1312) not yet in the worktree.** PR #1312 (PP-3995, Qazi) is still open and the API may still shift ("update a bit" per the author). Rather than rebasing onto an unstable base, this ticket ships `ExpandableInfoPlaceholder.swift` in `FraudMismatch/` as a local stub that mirrors the expected API (`title: String`, `body: String`, `icon: Image`, `@Binding var isExpanded: Bool`) using SwiftUI's built-in `DisclosureGroup`. When PR #1312 merges and this branch rebases, the stub is deleted and the call site in `FraudWarningView` swaps `ExpandableInfoPlaceholder(…)` for `GiniExpandableInfoView(…)` — one-line delta. R2 is satisfied against the stub during this build; the real-component swap is a follow-up single-file change.

## Implementation plan

Build-order rationale: VM first (data shape change forces the test update, which forces the code update — test-first by construction). Coordinator next since its init forwards to the VM. Placeholders next (standalone, no dependencies). View last since it composes everything. Container after View so the sheet wiring lands once the View signature is stable. Final verify runs the full FraudWarning suite + the GiniBankConfiguration property-count regression.

- [x] 1. Modify `FraudWarningViewModel.swift` — add `let qrIBAN: String`, `let printedIBAN: String`, `@Published var isExpandedProtectMyself: Bool = false`; change init to `init(qrIBAN:printedIBAN:delegate:)`. Update `FraudWarningViewModelTests.swift` to pass the new init params; add 3 tests (stores qrIBAN, stores printedIBAN, isExpandedProtectMyself defaults to false and publishes on toggle). (R5, R6, R10)
- [x] 2. Modify `FraudWarningCoordinator.swift` — change init to `init(qrIBAN:printedIBAN:delegate:)`, forward both to the VM. Update `FraudWarningCoordinatorTests.swift` to pass the new init params; add 1 test (init forwards qrIBAN + printedIBAN to the constructed VM). (R5, R11)
- [x] 3. Create `ExpandableInfoPlaceholder.swift` — SwiftUI stub mirroring GiniExpandableInfoView's shape (title / body / icon / $isExpanded) using `DisclosureGroup`. ~30 lines, no tests (trivially verified by rendering tests in step 5). (R2 + Resolution §1)
- [x] 4. Create `IBANPickerPlaceholder.swift` — SwiftUI stub showing `"IBAN picker — PP-3962 (Qazi)"`. Create `IBANPickerPlaceholderTests.swift` with 2 smoke tests (renders in UIWindow; body contains the expected text). (R8)
- [x] 5. Modify `FraudWarningView.swift` — rewrite body to render the Figma composition: warning icon (SF Symbol), title + subtitle, `ExpandableInfoPlaceholder`, "The following IBANs were detected" header, two `GiniOptionRow(.informational)` rows for QR + printed IBANs, swapped button order (Cancel on top, Proceed below). Local `enum Constants` for spacing / corner radius. (R1, R3, R4)
- [x] 6. Modify `FraudWarningContainer.swift` — add `@State private var isShowingPicker = false`; pass `viewModel` into `FraudWarningView` so the View can read `qrIBAN` / `printedIBAN` / bind `$viewModel.isExpandedProtectMyself`; rewire `onProceed` to set `isShowingPicker = true` (instead of calling `viewModel.didTapProceed()`); attach `.sheet(isPresented: $isShowingPicker) { IBANPickerPlaceholder().presentationDetents([.medium]).presentationDragIndicator(.visible) }`. Update `FraudWarningViewRenderingTests.swift` — adapt the existing smoke test for the new VM init signature; add 3 smoke tests (non-empty IBANs render; `isShowingPicker = true` renders the placeholder; `isExpandedProtectMyself = true` renders the expanded expandable). (R7, R9)
- [x] 7. Run `xcodebuild clean test -scheme GiniBankSDK -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2'` with `-only-testing` on the FraudWarning suites + `GiniBankConfigurationTests` to confirm no regression. Report test counts and any pre-existing failures explicitly.
- [x] 8. **Scope expansion.** Add `fraudWarningPresentation` stored property on `GiniBankNetworkingScreenApiCoordinator` and route the terminal section of `deliver(result:)`, `deliverWithReturnAssistant(result:)`, `deliverWithSkonto(result:)`, and `deliverWeroResult(_:)` through a new `presentFraudWarningIfEnabled(result:completion:)` call. Preserve each path's post-delivery side effects (line items assignment, Skonto summary, documentService reset). (R13, R14)
- [x] 9. Create `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/FraudDetection/FraudMismatch/GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift`. The extension conforms to `FraudWarningCoordinatorDelegate`, implements `presentFraudWarningIfEnabled`, `fraudWarningCoordinatorDidCancel`, `fraudWarningCoordinatorDidProceed`, and the private `takeFraudWarningPresentation()` atomic consumer. Uses stub IBANs; imports `GiniUtilites` for `configureBottomSheet(shouldIncludeLargeDetent:)`. (R16, R18, R19)
- [x] 10. **Bottom-sheet presentation.** Add `FraudWarningBottomSheetController` (nested in `FraudWarningCoordinator.swift`) — `UIHostingController<FraudWarningContainer> & GiniBottomSheetPresentable`, `shouldShowDragIndicator = true`, `shouldShowInFullScreenInLandscapeMode = false`. Change `FraudWarningCoordinator.start()` return type from `UIViewController` to `GiniBottomSheetViewController` and construct the new subclass with `isModalInPresentation = true`. The extension calls `configureBottomSheet(shouldIncludeLargeDetent: true)` then `screenAPINavigationController.present(_:animated:)` with the same accessibility setup `presentAsBottomSheet` applies. (R15)
- [x] 11. **Confirm button on placeholder.** `IBANPickerPlaceholder` adds `var onConfirm: () -> Void = {}` and renders a primary-styled "Confirm (placeholder — dev only)" button. `FraudWarningContainer` wires the closure to dismiss the sheet and fire `viewModel.didTapProceed()`. (R17)
- [x] 12. Update `FraudWarningCoordinatorTests.startReturnsConfiguredHostingController` for the new type + bottom-sheet presentation (expect `FraudWarningBottomSheetController`, `shouldShowDragIndicator == true`, `isModalInPresentation == true`; drop the `.fullScreen` assertion).
- [x] 13. **SonarCloud + orchestrator-review follow-ups.** (a) `IBANPickerPlaceholder` magic numbers (50 / 14 / 20) moved into a local `enum Constants` (mandatory-rules spacing rule). (b) Doc header on `GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift` updated from the single-path "Testability wire-up" wording to the four-path description. (c) New Swift Testing suite `GiniBankNetworkingScreenApiCoordinatorFraudWarningTests` locks R13's toggle-off semantic-equivalence promise (completion fires synchronously with the input result; no presentation state parked). (d) PP-4077 Sonar fixes landed as a separate commit on `feat/PP-4077_routing` (PR #1314). **Verified 2026-11-18**: 17 FraudWarning tests across 5 suites + 98 shared-state tests across 10 suites (incl. `GiniBankConfigurationFeatureFlagsTests`) — all pass. Zero failures.
