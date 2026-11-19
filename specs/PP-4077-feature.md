# PP-4077: Scaffold fraud warning screen (routing only)

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-4077
Parent: PP-3960 — [iOS] Fraud warning screen: IBAN mismatch
References:
- gini/gini-mobile-ios PR #1308 (PP-3938 "Spike IBAN mismatch sheet-over-modal flow") — the end-to-end routing pattern this spec mirrored at write time.
- gini/gini-mobile-android PR #1030 (PP-3961 wire-fraud-signals) — reference for the final real-signal behaviour that this scaffold defers.

## Amendments after /gini-build + review (post-spec changes)

The spec body below is the **state at write time** and is partly superseded. These are the deltas you need to know before reading further:

- **IBAN selection sheet dropped from scope.** Mid-build decision: the picker (and its `IBANSelectionSheet`, `IBANSelectionSheetViewModel`, `IBANChoice` types) will be built separately. The shipped "Proceed anyway" path dismisses and resumes delivery directly — it does NOT show a sheet. This voids **R5, R7, R9, R10, R11, R12, R13** and the `choice` parameter in **R14**; the delegate methods carry no payload. Implementation-plan steps 2 and 3 were started then removed; those files are not in the diff.
- **Flag name + home changed.** `fraudWarningScaffoldEnabled` (as a static on the SDK coordinator and a mirror on `SettingsViewModel`) was renamed to **`debugFraudWarningOn`** and moved to `GiniBankConfiguration`'s `// MARK: - Development Debug` section next to `debugModeOn`. Tests mutate `configuration.debugFraudWarningOn`; `SettingsViewModel` reads/writes `giniConfiguration.debugFraudWarningOn`. **R1, R2, R17, R18, R19** describe the superseded shape.
- **R8 idempotency moved to the integration seam.** The ViewModel is intentionally dumb and will fire its delegate on every tap (the VM unit test `didTapCancelTwiceFiresTwice` documents this). The "single terminal callback to the integrator" guarantee is enforced in `GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift` via `takePendingDelivery()` — an atomic consume that nils the pending delivery synchronously, so any second entry (double-tap, Cancel-then-Proceed) bails before touching the results delegate. Three new integration tests cover this: `doubleCancelFiresTerminalOnce`, `cancelThenProceedFiresOnlyFirst`, `proceedThenCancelFiresOnlyFirst`.
- **Cancel path mirrors delivery's `resetToInitialState()`.** The original `deliver(result:)` always ran `documentService.resetToInitialState()` alongside `giniCaptureAnalysisDidFinishWith`. The cancel path on the fraud warning now mirrors this — without the reset, cached document state would leak into the next capture session. A code comment at the call site points at the delivery-path precedent.
- **Strings list in R20 is overspecified.** The sheet strings ("To continue, select one of the IBANs", "In the QR code", "Printed on the document", "Continue", footer) don't ship. Hardcoded strings in the actual diff: "Cancel transfer", "Proceed anyway" in `FraudWarningView.swift`, plus "Fraud warning scaffold" title + the row's description text in `SettingsViewController+SwitchOptionModel.swift`.
- **Test count** in Implementation plan step 12 reads "21 tests across 5 suites" — the shipped state is **15 tests across 5 suites** (picker suite removed; three double-fire regression tests added to the integration suite).
- **Swift-tools-version bumped too.** `.iOS(.v16)` is not expressible in the 5.5 syntax, so `swift-tools-version:5.5 → 5.7` shipped alongside the iOS 16 bump in both manifests. See the `## Release notes` section at the bottom.

**R3, R4, R6, R15, R16, R21** still describe the shipped code accurately.

## Problem

The parent ticket (PP-3960) ships the full fraud warning screen UI and the sibling PP-3938 ships the IBAN selection sheet UI; both are in flight. Before either lands, we need the plumbing that connects them: an analysis result interception point that routes the user into a fraud warning modal, a "Proceed anyway" path that layers the IBAN selection sheet on top, and a result-delivery resumption after the user either cancels or picks. Shipping that wiring now — against placeholder screens — lets product/design/QA exercise the full flow in the example app while the two screen implementations finalise in parallel, and avoids landing all three pieces in a single oversized PR.

## Requirements

Entry point: internal. No new public declaration. Presentation is driven from `GiniBankNetworkingScreenApiCoordinator.deliver(result:analysisDelegate:)` (`GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift:257`) as a pre-step before `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)`. The screen is skipped entirely when the GiniBankSDKExample debug toggle `SettingsViewModel.fraudWarningScaffoldEnabled` is `false` (the default) — production integrators see today's behaviour unchanged.

Content tags used below:
- **entry** — how the feature is reached from the enclosing flow
- **happy** — main path with expected outcome
- **error** — failure surface and exact state exposed

### Entry

- **R1 (MUST, entry — toggle on).** Given `SettingsViewModel.fraudWarningScaffoldEnabled == true`, when `GiniBankNetworkingScreenApiCoordinator.deliver(result:analysisDelegate:)` runs, then it constructs a `FraudWarningCoordinator`, calls `.start()`, and presents the returned `UIViewController` on top of the Analysis screen via `screenAPINavigationController.present(_, animated: true)` before invoking `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)`.
- **R2 (MUST, entry — toggle off).** Given `SettingsViewModel.fraudWarningScaffoldEnabled == false`, when `deliver(result:analysisDelegate:)` runs, then it behaves exactly as today — no `FraudWarningCoordinator` constructed, no modal presented, `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` fires with the original `AnalysisResult`.
- **R3 (MUST, entry — hosting).** When `FraudWarningCoordinator.start()` returns, the returned value is a `UIHostingController<FraudWarningContainer>` whose `modalPresentationStyle == .fullScreen` and `isModalInPresentation == true`.

### State / display

- **R4 (MUST, happy — scaffold layout).** When `FraudWarningView` renders, the body is exactly two SwiftUI `Button`s stacked vertically — a secondary "Cancel transfer" above a primary "Proceed anyway" — with every other area (icon, title, body, protect-chip, IBAN rows) deliberately empty. The content area reserves vertical space (the `Spacer()` above the buttons) so the buttons sit at the bottom of the screen; the empty area is where PP-3960 will slot the real content.
- **R5 (MUST, happy — no sheet initially).** When `FraudWarningContainer` first renders, `viewModel.isShowingPicker == false` and no SwiftUI `.sheet` is presented over `FraudWarningView`.

### Interaction

- **R6 (MUST, happy — cancel).** Given `FraudWarningView` is on screen, when the user taps "Cancel transfer", then `viewModel.didTapCancel()` runs which calls `viewModel.delegate?.fraudWarningViewModelDidCancel(viewModel)` exactly once; `viewModel.isShowingPicker` stays `false`; no other delegate method on `FraudWarningViewModelDelegate` fires.
- **R7 (MUST, happy — proceed toggles sheet).** Given `FraudWarningView` is on screen, when the user taps "Proceed anyway", then `viewModel.didTapProceed()` runs which sets `viewModel.isShowingPicker = true`; no delegate method fires at this point (the delegate only fires after the user resolves the picker — R10 / R11).
- **R8 (MUST, error — idempotent taps).** When the user taps "Cancel transfer" twice in rapid succession, `fraudWarningViewModelDidCancel(_:)` fires exactly once; subsequent taps are ignored while the delegate callback is in flight. Same rule for "Proceed anyway" — the sheet is presented exactly once per press cycle (the `isShowingPicker` binding naturally debounces re-presentation while the sheet is already up).

### Sheet layering (IBAN selection)

- **R9 (MUST, happy — sheet appears).** Given `viewModel.isShowingPicker == true`, when SwiftUI renders `FraudWarningContainer`, then an `IBANSelectionSheet` is presented via `.sheet(isPresented: $viewModel.isShowingPicker) { IBANSelectionSheet(...) }.presentationDetents([.medium]).presentationDragIndicator(.visible)`. No `if #available(iOS 16.0, *)` branch — the deployment target is iOS 16+ after R16.
- **R10 (MUST, happy — swipe/drag dismiss).** When the user swipes the sheet down or taps outside its content region, SwiftUI drives `viewModel.isShowingPicker = false`; `FraudWarningView` remains on screen; no delegate callback fires; a subsequent tap on "Proceed anyway" re-presents the sheet with a fresh (empty) selection.
- **R11 (MUST, happy — picker rows).** `IBANSelectionSheet` renders exactly two `GiniOptionRow` instances (iOS 16+ type from GiniUtilites) — one labeled "In the QR code" with a hardcoded QR IBAN (`"PL12 1000 0111 0100 1000"`), one labeled "Printed on the document" with a hardcoded printed IBAN (`"DE89 3704 0044 0532 0130 00"`). Each row uses `GiniOptionRow.Variant.radio(.unselected)` initially, flipping to `.radio(.selected)` when it is the current selection.
- **R12 (MUST, happy — selection drives Continue).** The sheet's "Continue" button is `disabled` while `pickerViewModel.selection == nil`. Tapping a row sets `pickerViewModel.selection` to `.qr` or `.printed` respectively; "Continue" enables; tapping it calls `pickerViewModel.didTapContinue()`, which in turn invokes the sheet's `onContinue: (IBANChoice) -> Void` closure exactly once with the current selection.
- **R13 (MUST, error — no selection).** Given `pickerViewModel.selection == nil`, when the user taps the disabled "Continue" button, then nothing happens — the closure does not fire, no state changes.

### Routing back to delivery

- **R14 (MUST, happy — proceed with pick).** When `IBANSelectionSheet.onContinue(choice)` fires, `FraudWarningViewModel` calls its `delegate?.fraudWarningViewModelDidProceed(viewModel, choice: choice)` exactly once; `FraudWarningCoordinator`'s impl forwards via `coordinatorDelegate?.fraudWarningCoordinatorDidProceed(coordinator, choice: choice)`; `GiniBankNetworkingScreenApiCoordinator` dismisses the hosting controller (`screenAPINavigationController.dismiss(animated: true)`) and, in the dismissal completion, calls `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` with the **original** `AnalysisResult` — no `ChosenIBANExtractions`-style substitution (that is a follow-up ticket). The `choice` value is stored on the extension for later inspection but has no observable effect on the result.
- **R15 (MUST, happy — cancel terminates).** When `FraudWarningViewModelDelegate.fraudWarningViewModelDidCancel(_:)` fires, `FraudWarningCoordinator` forwards via `coordinatorDelegate?.fraudWarningCoordinatorDidCancel(coordinator)`; `GiniBankNetworkingScreenApiCoordinator` dismisses the hosting controller and, in the dismissal completion, calls `resultsDelegate?.giniCaptureDidCancelAnalysis()` (the existing cancel path at `GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift:427` / `:1064`).

### Platform

- **R16 (MUST, entry — iOS 16 bump).** `BankSDK/GiniBankSDK/Package.swift:10` and `BankSDK/GiniBankSDK/Package-release.swift:9` platforms arrays contain `.iOS(.v16)`, not `.v15`. Verified by (a) `swift package describe --type json | jq .platforms` on both manifests showing `v16`, and (b) `xcodebuild clean build` succeeding for scheme `GiniBankSDK` and target `GiniBankSDKExample` on `iPhone 17 / iOS 26.2` destination. `@available(iOS 16, *)` gates inside `BankSDK/GiniBankSDK/Sources/` that are now unconditional are removed in the same PR (expected scope: `grep -rn '@available(iOS 16' BankSDK/GiniBankSDK/Sources/` returns nothing after the change, barring the PP-3997 `GiniOptionRow` import from GiniUtilites where the gate remains because GiniUtilites stays at iOS 15+).

### Example app toggle

- **R17 (MUST, entry — SettingsViewModel flag).** `BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewModel.swift` gains a `static private(set) var fraudWarningScaffoldEnabled: Bool = false` next to the existing `shouldCloseSDKAfterTenSeconds` (at `SettingsViewModel.swift:20`).
- **R18 (MUST, entry — Debug section row).** The existing `debugSection` (built in `SettingsViewModel.generateDebugSection()` / equivalent — same site as the `shouldCloseSDKAfterTenSeconds` switch) gains a new `.switchOption(data: .init(type: .fraudWarningScaffoldEnabled, isSwitchOn: Self.fraudWarningScaffoldEnabled))` row; `SettingsOptionType` gains a `.fraudWarningScaffoldEnabled` case; `SettingsViewController` renders the new row through its existing switch-cell path (zero changes required there).
- **R19 (MUST, happy — toggle flips).** `SettingsViewModel.handleOnToggle(at:isSwitchOn:)` matches the new `SettingsOptionType.fraudWarningScaffoldEnabled` case and writes through to `Self.fraudWarningScaffoldEnabled = isSwitchOn`.

### Strings (deliberately deferred)

- **R20 (SHOULD, scaffold — hardcoded English).** Every user-facing string in this ticket is a hardcoded English literal inline in the SwiftUI view bodies — the two button labels ("Cancel transfer", "Proceed anyway"), the sheet title ("To continue, select one of the IBANs"), the two row labels ("In the QR code", "Printed on the document"), the sheet footer ("You can still check the IBAN on the next screen."), and the sheet CTA ("Continue"). Each literal is followed by a `// TODO PP-3960: localise` comment. No `Localizable.strings` entries added, no typed `LocalizableStringResource` enum — those ship with the final layout in PP-3960.

### Public API impact

- **R21.** No new `public`/`open` declarations. All new types `internal`. The `BankSDK/GiniBankSDK/Package.swift` iOS 15 → iOS 16 bump is a breaking SemVer change for integrators still shipping on iOS 15; call it out in the release notes of the first GiniBankSDK release containing this PR. The release carrying it is expected to be a major version bump (`GiniBankSDK 4.x → 5.0.0`), scheduled as a release-process step, not part of this PR.

## Affected modules

- **`GiniBankSDK`** (primary, **iOS 15 → iOS 16+**). Two sets of changes in one PR:
  - **Manifest bump.** `BankSDK/GiniBankSDK/Package.swift:10` and `BankSDK/GiniBankSDK/Package-release.swift:9` — `.v15` → `.v16`. `GiniUtilites` and `GiniCaptureSDK` stay at `.v15` (SPM binary-compatibility: a package whose `platforms:` is lower than its consumer's `platforms:` is fine; only GiniBankSDK's OWN target requires bumping).
  - **New `Core/FraudMismatch/` folder.** Eight new Swift files (listed in Design). Integration into `GiniBankNetworkingScreenApiCoordinator` goes through a new extension file `Core/FraudMismatch/GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift` that adds exactly one call site into `deliver(result:analysisDelegate:)` (line `:257` today) — matching the pattern PR #1308 established with its `+FraudMismatch.swift` extension.
- **`GiniBankSDKExample`.** Debug-only. `SettingsViewController/SettingsViewModel.swift` gains a static flag + a new debug row; `SettingsOptionType` gains one case. No changes to `SettingsViewController` itself — the existing switch-cell handler picks up the new case for free.
- **`GiniUtilites`** — **no source change.** Consumed only (`GiniOptionRow`). Already present on this branch via PP-3997. Deployment target stays iOS 15+; `GiniOptionRow` is already `@available(iOS 16.0, *)` so it works either way, and our consumer is iOS 16+ so no new gates needed at the call site.
- **`GiniCaptureSDK`** — no change. The Analysis screen remains UIKit and is not touched; the fraud warning presents on top of it via standard `UIViewController.present(_, animated: true)`.

## Public API impact

**None.** All new types in `Core/FraudMismatch/` are `internal`. `GiniBankNetworkingScreenApiCoordinator.deliver(result:analysisDelegate:)` gains one internal call site into the new extension file; its public surface is unchanged. Banks continue to receive the exact same `AnalysisResult` on `giniCaptureAnalysisDidFinishWith(result:)` — the `IBANChoice` the user picks is **not** written into the result for this scaffold (that substitution is a follow-up ticket).

**Breaking SemVer.** Raising the minimum deployment target from iOS 15 to iOS 16 is a breaking change for integrators still shipping on iOS 15. The release containing this PR is a major version bump (e.g. `GiniBankSDK 4.x → 5.0.0`); the release notes MUST call out the iOS 16 minimum. Bumping `GiniBankSDKVersion.swift` is a release-process step, not part of this PR.

## Technical conventions

Grounded in `.claude/rules/mandatory-rules.md` + `platform.md`:

1. **Language & access control.** Swift. All new types `internal` — no `public`/`open`. Declarations use `/** */`; body comments use `///`. Multi-parameter signatures use one-parameter-per-line formatting with vertical alignment under the first parameter's external label (precedent: `DocumentPagesProvider.getDocumentPage(for:size:completion:)`).
2. **UI framework.** SwiftUI end-to-end. `FraudWarningView: View` is the screen body; `FraudWarningContainer: View` is the composition root owning sheet presentation; `IBANSelectionSheet: View` is the picker. The Coordinator wraps the Container in `UIHostingController<FraudWarningContainer>` purely to return a `UIViewController` to the enclosing UIKit flow (per `.claude/rules/mandatory-rules.md` — SDK entry point is a `UIViewController`). With the iOS 16 baseline, no `@available(iOS 16.0, *)` gates are needed on any symbol in this feature.
3. **Architecture.** MVVM + Coordinator. `FraudWarningCoordinator` owns the `FraudWarningViewModel` and the hosting controller; `FraudWarningViewModel` is `@MainActor` and conforms to `ObservableObject`; `FraudWarningView` reads it as `@ObservedObject` indirectly — through `FraudWarningContainer` which holds the `@StateObject`. The ViewModel never imports UIKit — it exposes a weak `delegate: FraudWarningViewModelDelegate?` (protocol in a separate file). Coordinator-to-parent events go through `delegate: FraudWarningCoordinatorDelegate?`. Separately, `IBANSelectionSheet` has its own `@MainActor IBANSelectionSheetViewModel` (also `ObservableObject`) owning selection state; its outcome is reported via a closure `onContinue: (IBANChoice) -> Void` passed from `FraudWarningContainer` (which bridges it into the parent `FraudWarningViewModel`'s delegate call).
   **Delegate-impl rule (Sonar `swift:S1172`).** When implementing either delegate, the sender parameter (`_ viewModel: FraudWarningViewModel` / `_ coordinator: FraudWarningCoordinator`) must either be referenced in the body or renamed to an ignored internal name (`_ viewModel _: FraudWarningViewModel`). Leaving an unused but named parameter is what tripped the same rule on `giniColorScheme` in PP-3997.
4. **Colors / fonts / spacing.** For the scaffold, inline SwiftUI defaults (`Color.accentColor`, `Font.body`, `.body.weight(.semibold)`, numeric constants in local `enum Constants` inside each view — padding, corner radius, button height, button spacing). Design-system tokens (`UIColor.giniBankColorScheme()`, `GiniBankConfiguration.textStyleFonts[textStyle]`) are introduced in PP-3960 along with the final layout. Numeric values still live in a local `enum Constants` per mandatory-rules — no magic numbers. (`confidence: LOW — needs confirmation that inline Color/Font defaults are acceptable for a scaffold that explicitly defers styling to PP-3960; see Open questions`)
5. **DI.** Constructor injection throughout: `FraudWarningCoordinator(delegate:)`, `FraudWarningViewModel(delegate:)`, `IBANSelectionSheetViewModel(onContinue:)`. No singletons introduced; `SettingsViewModel.fraudWarningScaffoldEnabled` is a static read (debug-flag convention matching `SettingsViewModel.shouldCloseSDKAfterTenSeconds` already at `SettingsViewModel.swift:20`), read from inside `GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift`.
6. **Async.** No new async work on this screen. Button taps are synchronous; the sheet appears/dismisses via SwiftUI's own state-driven animation; the hosting controller dismisses synchronously after the delegate routes.
7. **Strings.** Hardcoded English string literals inline in the SwiftUI view bodies, each followed by a `// TODO PP-3960: localise` comment. **No** typed `LocalizableStringResource` enum, **no** `Localizable.strings` entries. Explicitly deferred to PP-3960 (where the final content + layout + strings land together).
8. **Quality gates.** `make lint scheme=GiniBankSDK` clean. Each new ViewModel ships its unit test (see Test plan). SwiftUI view files are covered by the `*View.swift` / `*ViewController.swift` exclusion already in `BankSDK/sonar-project.properties` (verified in the paused PP-3960 /gini-build session: the exclusion is in place at `sonar.coverage.exclusions`).

## Design

New folder `/BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/FraudMismatch/` (freshly created — the PR #1308 spike's files are NOT present on this branch; the folder is created with the PP-4077 files only):

```
FraudMismatch/
├── FraudWarningCoordinator.swift                       (new)
├── FraudWarningCoordinatorDelegate.swift               (new)
├── FraudWarningViewModel.swift                         (new)
├── FraudWarningViewModelDelegate.swift                 (new)
├── FraudWarningContainer.swift                         (new)
├── FraudWarningView.swift                              (new)
├── IBANSelectionSheet.swift                            (new)
├── IBANSelectionSheetViewModel.swift                   (new)
└── GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift  (new)
```

Existing code the integration refers to (no changes beyond the new call site):
- `GiniBankNetworkingScreenApiCoordinator.deliver(result:analysisDelegate:)` — `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift:257`. Gains one call into the new extension file.
- `GiniBankNetworkingScreenApiCoordinator`'s `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` call (`:277`) and `resultsDelegate?.giniCaptureDidCancelAnalysis()` calls (`:427`, `:1064`) — reused as the resumption points.
- `GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewModel.swift:20` — the static debug flag pattern. The `handleOnToggle(at:isSwitchOn:)` switch gains one new case for `.fraudWarningScaffoldEnabled`.
- `GiniUtilites.GiniOptionRow` (`/GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Views/GiniOptionRow/GiniOptionRow.swift:29`) — `@available(iOS 16.0, *) public struct`, used for both picker rows.

### Types

```swift
// FraudWarningViewModelDelegate.swift
protocol FraudWarningViewModelDelegate: AnyObject {
    func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel)
    func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel,
                                         choice: IBANSelectionSheet.IBANChoice)
}

// FraudWarningViewModel.swift
@MainActor
final class FraudWarningViewModel: ObservableObject {
    @Published var isShowingPicker: Bool = false
    weak var delegate: FraudWarningViewModelDelegate?

    init(delegate: FraudWarningViewModelDelegate?) {
        self.delegate = delegate
    }

    func didTapCancel() { delegate?.fraudWarningViewModelDidCancel(self) }
    func didTapProceed() { isShowingPicker = true }
    func pickerDidPick(_ choice: IBANSelectionSheet.IBANChoice) {
        isShowingPicker = false
        delegate?.fraudWarningViewModelDidProceed(self, choice: choice)
    }
}

// FraudWarningCoordinatorDelegate.swift
protocol FraudWarningCoordinatorDelegate: AnyObject {
    func fraudWarningCoordinatorDidCancel(_ coordinator: FraudWarningCoordinator)
    func fraudWarningCoordinatorDidProceed(_ coordinator: FraudWarningCoordinator,
                                           choice: IBANSelectionSheet.IBANChoice)
}

// FraudWarningCoordinator.swift
@MainActor
final class FraudWarningCoordinator: FraudWarningViewModelDelegate {
    private let viewModel: FraudWarningViewModel
    weak var delegate: FraudWarningCoordinatorDelegate?

    init(delegate: FraudWarningCoordinatorDelegate?) {
        self.delegate = delegate
        self.viewModel = FraudWarningViewModel(delegate: nil)
        self.viewModel.delegate = self
    }

    func start() -> UIViewController {
        let container = FraudWarningContainer(viewModel: viewModel)
        let hosting = UIHostingController(rootView: container)
        hosting.modalPresentationStyle = .fullScreen
        hosting.isModalInPresentation = true
        return hosting
    }

    // MARK: - FraudWarningViewModelDelegate
    func fraudWarningViewModelDidCancel(_ viewModel: FraudWarningViewModel) {
        delegate?.fraudWarningCoordinatorDidCancel(self)
    }
    func fraudWarningViewModelDidProceed(_ viewModel: FraudWarningViewModel,
                                         choice: IBANSelectionSheet.IBANChoice) {
        delegate?.fraudWarningCoordinatorDidProceed(self, choice: choice)
    }
}

// FraudWarningContainer.swift
struct FraudWarningContainer: View {
    @ObservedObject var viewModel: FraudWarningViewModel

    var body: some View {
        FraudWarningView(
            onCancel: viewModel.didTapCancel,
            onProceed: viewModel.didTapProceed
        )
        .sheet(isPresented: $viewModel.isShowingPicker) {
            IBANSelectionSheet(
                qrIBAN: Constants.stubQrIBAN,
                printedIBAN: Constants.stubPrintedIBAN,
                onContinue: viewModel.pickerDidPick
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private enum Constants {
        static let stubQrIBAN = "PL12 1000 0111 0100 1000"
        static let stubPrintedIBAN = "DE89 3704 0044 0532 0130 00"
    }
}

// FraudWarningView.swift
struct FraudWarningView: View {
    var onCancel: () -> Void
    var onProceed: () -> Void

    var body: some View {
        VStack(spacing: Constants.buttonSpacing) {
            Spacer()                       // the empty content area — PP-3960 fills it
            Button("Cancel transfer",      action: onCancel)   // TODO PP-3960: localise
                .buttonStyle(ScaffoldSecondaryButton())
            Button("Proceed anyway",       action: onProceed)  // TODO PP-3960: localise
                .buttonStyle(ScaffoldPrimaryButton())
        }
        .padding(Constants.outerPadding)
    }

    private enum Constants {
        static let buttonSpacing: CGFloat = 12
        static let outerPadding: CGFloat = 20
    }
}

// IBANSelectionSheet.swift
struct IBANSelectionSheet: View {
    enum IBANChoice: Hashable { case qr, printed }

    let qrIBAN: String
    let printedIBAN: String
    var onContinue: (IBANChoice) -> Void

    @StateObject private var viewModel: IBANSelectionSheetViewModel

    init(qrIBAN: String,
         printedIBAN: String,
         onContinue: @escaping (IBANChoice) -> Void) {
        self.qrIBAN = qrIBAN
        self.printedIBAN = printedIBAN
        self.onContinue = onContinue
        _viewModel = StateObject(wrappedValue: IBANSelectionSheetViewModel(onContinue: onContinue))
    }

    var body: some View {
        // Two GiniOptionRow(.radio(…)) rows + Continue button.
        // See Flow §3 below for exact row wiring.
    }
}

// IBANSelectionSheetViewModel.swift
@MainActor
final class IBANSelectionSheetViewModel: ObservableObject {
    @Published var selection: IBANSelectionSheet.IBANChoice?
    private let onContinue: (IBANSelectionSheet.IBANChoice) -> Void

    init(onContinue: @escaping (IBANSelectionSheet.IBANChoice) -> Void) {
        self.onContinue = onContinue
    }

    func didTapRow(_ choice: IBANSelectionSheet.IBANChoice) { selection = choice }
    func didTapContinue() {
        guard let selection else { return }
        onContinue(selection)
    }
}
```

### Flow

1. Analysis completes → `GiniBankNetworkingScreenApiCoordinator.deliver(result:analysisDelegate:)` runs.
2. Extension reads `SettingsViewModel.fraudWarningScaffoldEnabled`:
   - `false` → existing behaviour (calls `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` directly).
   - `true` → constructs `FraudWarningCoordinator(delegate: self)` (self is the `GiniBankNetworkingScreenApiCoordinator`, which conforms to `FraudWarningCoordinatorDelegate` via the new extension), calls `coordinator.start()`, and `present(_, animated: true)` on `screenAPINavigationController`. The original `AnalysisResult` is captured by the delegate callbacks' closure so it's available on resumption.
3. User sees `FraudWarningView` — two buttons over an empty area.
4. User taps:
   - **Cancel** → `FraudWarningViewModel.didTapCancel()` → `viewModel.delegate?.fraudWarningViewModelDidCancel(viewModel)` → `FraudWarningCoordinator.fraudWarningViewModelDidCancel(_)` → `coordinator.delegate?.fraudWarningCoordinatorDidCancel(coordinator)` → `GiniBankNetworkingScreenApiCoordinator`'s extension dismisses the hosting controller and calls `resultsDelegate?.giniCaptureDidCancelAnalysis()`.
   - **Proceed** → `FraudWarningViewModel.didTapProceed()` → sets `isShowingPicker = true` → SwiftUI presents `IBANSelectionSheet` with `.presentationDetents([.medium])` + `.presentationDragIndicator(.visible)`.
5. In the sheet:
   - User taps a row → `IBANSelectionSheetViewModel.didTapRow(.qr | .printed)` → `selection` updates; the two `GiniOptionRow`s re-render with the chosen one in `.radio(.selected)`.
   - User taps "Continue" (enabled only when `selection != nil`) → `IBANSelectionSheetViewModel.didTapContinue()` → `onContinue(selection)` → `FraudWarningViewModel.pickerDidPick(choice)` → `isShowingPicker = false` (dismisses the sheet) → `viewModel.delegate?.fraudWarningViewModelDidProceed(viewModel, choice:)` → `FraudWarningCoordinator` forwards → `GiniBankNetworkingScreenApiCoordinator`'s extension dismisses the hosting controller and calls `resultsDelegate?.giniCaptureAnalysisDidFinishWith(result:)` with the ORIGINAL `AnalysisResult` (no substitution — R14).
   - User swipes the sheet down → SwiftUI sets `isShowingPicker = false` → `FraudWarningView` remains visible; nothing else fires.

### Example-app toggle wiring

`BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewModel.swift` — three pinpoint changes:

1. Add alongside line 20: `static private(set) var fraudWarningScaffoldEnabled: Bool = false`.
2. In the debug-section builder (matching `.closeSDK` row construction — see the surrounding `.append(.switchOption(data: .init(type: .closeSDK, …)))` call in `generateDebugSection()` or equivalent), add a new row:
   ```swift
   debugSection.items.append(.switchOption(data: .init(type: .fraudWarningScaffoldEnabled,
                                                       isSwitchOn: Self.fraudWarningScaffoldEnabled)))
   ```
3. Add a new `SettingsOptionType.fraudWarningScaffoldEnabled` case + its display title (follow the convention of the neighbouring cases — `.closeSDK` uses `"Close SDK after 10s"` or equivalent; here: `"Fraud warning scaffold"`); extend the `handleOnToggle(at:isSwitchOn:)` switch to write through `Self.fraudWarningScaffoldEnabled = isSwitchOn`.

### `confidence: LOW` markers

- The scaffold's inline SwiftUI styling (`Color.accentColor`, system fonts) is defensible for a throwaway visual but may fail code review that expects `UIColor.giniBankColorScheme()` + `textStyleFonts[textStyle]` from day one. — `(confidence: LOW — needs confirmation that bypassing design tokens for a deliberately ugly scaffold is acceptable; alternative is to apply the tokens now and rely on PP-3960 to re-skin)`
- `SettingsOptionType` is assumed to be the enum type keying the existing `switchOption(data:)` rows. Need to verify the enum exists under that exact name — adjacent cases (`.closeSDK`, `.openWith`, `.returnAssistantEnabled`, etc.) strongly imply it does, but I haven't opened the file in this session. — `(confidence: LOW — needs a read of SettingsViewModel's SettingsOptionType enum during /gini-build; if the name differs, use whatever the existing cases conform to)`

Both LOW markers appear in "Open questions" below.

## Test plan

Test stack: **Swift Testing** (`@Suite`, `@Test`, `#expect`) for all new suites, per `.claude/rules/mandatory-rules.md`. New test files under `/BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/FraudMismatch/`.

| Test class (new file) | Covers | Rough count |
|---|---|---|
| `FraudWarningViewModelTests` | Init with nil delegate → no crash; `didTapCancel()` → `fraudWarningViewModelDidCancel(_)` fires exactly once; `didTapProceed()` → `isShowingPicker` flips to `true`; `pickerDidPick(.qr)` → `isShowingPicker` flips back to `false` AND `fraudWarningViewModelDidProceed(_, choice: .qr)` fires exactly once; same for `.printed`; two rapid `didTapCancel()` in a row still fire the delegate only once (R8). Uses a manual `FraudWarningViewModelDelegate` mock conformance in-file. `@MainActor`. | 6 |
| `FraudWarningCoordinatorTests` | `start()` returns a `UIHostingController` whose `modalPresentationStyle == .fullScreen` and `isModalInPresentation == true`; coordinator's `fraudWarningViewModelDidCancel(_)` forwards to `coordinatorDelegate?.fraudWarningCoordinatorDidCancel(_)`; coordinator's `fraudWarningViewModelDidProceed(_, choice:)` forwards with the right `choice`; nil coordinator-delegate → no crash. Manual `FraudWarningCoordinatorDelegate` mock. `@MainActor`. | 4 |
| `IBANSelectionSheetViewModelTests` | Init `selection == nil`; `didTapRow(.qr)` → `selection == .qr`; `didTapRow(.printed)` → `selection == .printed`; `didTapContinue()` with `selection == nil` → `onContinue` never fires (R13); `didTapContinue()` with `selection == .qr` → `onContinue(.qr)` fires exactly once. `@MainActor`. | 5 |
| `GiniBankNetworkingScreenApiCoordinator+FraudWarningTests` | Toggle `false` → `deliver(result:)` path does NOT present a `FraudWarningCoordinator` and calls `giniCaptureAnalysisDidFinishWith(result:)` unchanged (R2); toggle `true` → presents the coordinator and does NOT call `giniCaptureAnalysisDidFinishWith` until the delegate resolves (R1); `fraudWarningCoordinatorDidCancel(_)` → `giniCaptureDidCancelAnalysis()` is called on the results delegate (R15); `fraudWarningCoordinatorDidProceed(_, choice: .qr)` → `giniCaptureAnalysisDidFinishWith(result:)` is called with the ORIGINAL `AnalysisResult` instance (R14). Mocks for both `GiniCaptureResultsDelegate` and `UINavigationController.present/dismiss` via a minimal stub (reuse neighbouring `GiniBankNetworkingScreenApiCoordinatorTests` scaffolding if present). `@MainActor`. | 4 |
| `FraudWarningViewRenderingTests` | Host-controller rendering (attached to a `UIWindow`, mirroring the `GiniOptionRowRenderingTests` pattern from PP-3997) — `FraudWarningContainer` with a fresh VM renders without crashing; container with `isShowingPicker = true` renders the sheet content path without crashing. 2 tests. `@MainActor`. | 2 |

Every new ViewModel has a unit test. Coordinator and integration-extension tests cover the hot-path flows (R1, R2, R14, R15). View rendering tests give a smoke signal that the SwiftUI body actually compiles and runs.

### Not tested

- Pixel-level visual fidelity (irrelevant for a scaffold — final layout is PP-3960 scope; manual QA after PP-3960 lands).
- `GiniOptionRow` itself (owned by `GiniUtilitesTests`, PP-3997).
- SwiftUI's own `.sheet(isPresented:)` / `.presentationDetents([.medium])` / `.presentationDragIndicator(.visible)` behaviour (OS-native, no custom logic).
- Swipe-to-dismiss on the sheet (OS-native; the VM resets `selection` on re-presentation which is covered implicitly by `IBANSelectionSheetViewModelTests`).
- `SettingsViewController`'s rendering of the new switch row (trivial UITableView delegation; existing switch rows cover the code path).
- Package.swift iOS 16 bump → exercised by `make lint scheme=GiniBankSDK` + `xcodebuild build` in verification, no unit test.
- Localisation (nothing localised — strings are hardcoded English with `// TODO PP-3960` markers).

## Out of scope

- Fraud warning content — icon, title, body paragraph, "How do I protect myself?" expandable, IBAN rows: **PP-3960**.
- IBAN selection sheet's final layout — Android-parity visual, country hints, selection error state, multi-printed-IBAN support: the follow-up that supersedes PR #1308's spike (nominally **PP-3938 productionisation**).
- Real fraud-signal detection — gating on `FraudSignalMapper.map(…)` non-empty, pulling IBANs from `extractions["iban"]` / the `FraudSignal` values instead of the scaffold constants: separate ticket (equivalent to Android PP-3961/PR #1030 wiring).
- `ChosenIBANExtractions.apply(…)` — writing the user's picker choice back into `AnalysisResult.extractions["iban"]` and dropping `bic`: separate ticket (equivalent to Android PP-3966).
- Localization — `.strings` entries, typed `FraudWarningStrings: LocalizableStringResource` enum: **PP-3960**.
- Accessibility — VoiceOver labels, Dynamic Type verification, external keyboard support: **PP-3960** (the scaffold's two buttons inherit system a11y defaults, which is adequate for a throwaway visual).
- Liquid Glass on iOS 26+: **PP-3960**.
- iPad / landscape adaptive layout: **PP-3960**.
- Android parity PR: Android has its own ticket under PP-3518.

## Open questions

1. **Scaffold styling bypass.** Is it acceptable to ship the scaffold with inline SwiftUI defaults (`Color.accentColor`, system `.body.weight(.semibold)` fonts) instead of applying `UIColor.giniBankColorScheme()` + `GiniBankConfiguration.textStyleFonts[textStyle]` from day one? The TODO comment is honest, but the code path demonstrated won't be reused — PP-3960 re-skins the view. `(confidence: LOW)`
2. **`SettingsOptionType` enum name.** The debug-toggle row needs a new enum case; the existing switch rows (`.closeSDK`, `.openWith`, `.returnAssistantEnabled`, etc.) imply an enum under that name, but I haven't opened the file in this session. If the actual enum name differs (e.g. `SettingsOption.Kind`), use whatever the existing cases conform to and keep the `.fraudWarningScaffoldEnabled` case name. `(confidence: LOW — resolved by a one-line grep during /gini-build)`

### Resolutions at /gini-build time (2026-11-17)

1. **Open question §1 (scaffold styling bypass).** Resolved: plain SwiftUI defaults. `Color.accentColor` + system `.body.weight(.semibold)` fonts + inline `enum Constants` for spacing. Each literal carries a `// TODO PP-3960: localise and tokenize` marker. Design-system tokens arrive with PP-3960 when it re-skins the view.
2. **Open question §2 (`SettingsOptionType` enum).** Resolved: the enum is `SwitchOptionModel.OptionType` (nested in `BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewController+SwitchOptionModel.swift`). Add the new case there, plus a `title` branch (string `"Fraud warning scaffold"`). Call-site pattern matches `.closeSDK`.
3. **Interception approach for `deliver(result:)`.** Verified on disk: the existing method dispatches the delivery block to `DispatchQueue.main.async { ... self.resultsDelegate?.giniCaptureAnalysisDidFinishWith(result: result) ... }` inside a `hasExtractions` branch (lines 257–283). The interception goes INSIDE this main-queue block, BEFORE the `giniCaptureAnalysisDidFinishWith` call, only on the `hasExtractions == true` path. The `!hasExtractions` branch (`tryDisplayNoResultsScreen`) is untouched.
4. **Coordinator retention.** `FraudWarningCoordinator` needs a strong reference during presentation (otherwise it dies after `start()` returns, breaking the delegate chain). Add one private stored property to `GiniBankNetworkingScreenApiCoordinator`: `private var fraudWarningCoordinator: FraudWarningCoordinator?`. Nil-out in both dismissal completions (cancel + proceed).

## Implementation plan

Build-order rationale: platform bump first so SwiftUI code carries no `@available(iOS 16.0, *)` noise; pure-Swift ViewModels before any UI (fast tests); view-then-container-then-coordinator; the integration extension (which touches an existing file) lands last so the build stays green at every step.

- [x] 1. Bump `BankSDK/GiniBankSDK/Package.swift` + `Package-release.swift` from `.iOS(.v15)` to `.iOS(.v16)`; verify `make lint scheme=GiniBankSDK` is green. (R16)
- [~] 2. ~~Add `IBANSelectionSheetViewModel.swift`~~ — initially built, then removed mid-scope as part of the picker drop (see Amendments at the top). File is not in the shipped diff. (pure Swift, `@MainActor`, selection state + continue action) and `IBANSelectionSheetViewModelTests.swift` (5 Swift Testing cases: init-nil, didTapRow QR, didTapRow printed, didTapContinue no-selection = no-fire, didTapContinue with selection = fires-once). (R12, R13)
- [~] 3. ~~Add `IBANSelectionSheet.swift`~~ — initially built, then removed mid-scope as part of the picker drop. File is not in the shipped diff. — SwiftUI view, two `GiniOptionRow(.radio(…))` rows + Continue button, uses `@StateObject` for its VM. (R11, R12)
- [x] 4. Add `FraudWarningViewModelDelegate.swift` and `FraudWarningViewModel.swift` (`@MainActor`, `@Published isShowingPicker`, `didTapCancel` / `didTapProceed` / `pickerDidPick`) plus `FraudWarningViewModelTests.swift` (6 Swift Testing cases: init-nil-delegate, didTapCancel fires once, didTapProceed flips `isShowingPicker`, pickerDidPick QR fires delegate + flips back, pickerDidPick printed fires delegate + flips back, rapid double-tap cancel fires once). Uses manual delegate mock. (R6, R7, R8, R14)
- [x] 5. Add `FraudWarningView.swift` — SwiftUI view with `Spacer()` + two buttons + local `enum Constants` + TODO localise comments. (R4)
- [x] 6. Add `FraudWarningContainer.swift` — composition root with `@StateObject` on a provided VM, applies `.sheet(isPresented: $viewModel.isShowingPicker)` + `.presentationDetents([.medium])` + `.presentationDragIndicator(.visible)`, hands `viewModel.pickerDidPick` to the sheet's `onContinue`. (R5, R9, R10)
- [x] 7. Add `FraudWarningCoordinatorDelegate.swift` and `FraudWarningCoordinator.swift` (owns VM, `start()` returns `UIHostingController<FraudWarningContainer>` with `.fullScreen` + `isModalInPresentation = true`, conforms to `FraudWarningViewModelDelegate` and forwards to its own delegate) plus `FraudWarningCoordinatorTests.swift` (4 Swift Testing cases: start returns correct hosting controller, cancel forwards, proceed QR forwards with choice, proceed printed forwards with choice). (R3, R15)
- [x] 8. Modify `BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewController+SwitchOptionModel.swift` — add `.fraudWarningScaffoldEnabled` case + its `title` branch ("Fraud warning scaffold"). Then modify `BankSDK/GiniBankSDKExample/GiniBankSDKExample/SettingsViewController/SettingsViewModel.swift` — add `static private(set) var fraudWarningScaffoldEnabled: Bool = false` next to `shouldCloseSDKAfterTenSeconds` (line 20); append a new `.switchOption(data: .init(type: .fraudWarningScaffoldEnabled, isSwitchOn: Self.fraudWarningScaffoldEnabled))` row in the debug-section builder (next to the `.closeSDK` row at line 303); extend `handleOnToggle(at:isSwitchOn:)` switch with a new `.fraudWarningScaffoldEnabled` case that writes through to `Self.fraudWarningScaffoldEnabled = data.isSwitchOn` (next to the `.closeSDK` case at line 414). (R17, R18, R19)
- [x] 9. Add `GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift` extension — makes the coordinator conform to `FraudWarningCoordinatorDelegate`, exposes `internal func presentFraudWarningIfScaffoldEnabled(result:completion:)`, routes delegate callbacks back into the extracted result-or-cancel paths. Modify `GiniBankNetworkingScreenApiCoordinator.swift:277` (the existing `giniCaptureAnalysisDidFinishWith` call inside `deliver(result:)`) to route through the new interception; add the private `fraudWarningCoordinator: FraudWarningCoordinator?` stored property to the main class. The `!hasExtractions` branch is untouched. (R1, R2, R14, R15)
- [x] 10. Add `GiniBankNetworkingScreenApiCoordinator+FraudWarningTests.swift` — 4 Swift Testing cases: toggle off bypasses coordinator; toggle on presents + defers delivery; cancel path → `giniCaptureDidCancelAnalysis`; proceed path → original `giniCaptureAnalysisDidFinishWith(result:)`. Uses minimal mock `GiniCaptureResultsDelegate` conformance. `@MainActor`. (R1, R2, R14, R15)
- [x] 11. Add `FraudWarningViewRenderingTests.swift` — 2 Swift Testing host-controller tests attached to a `UIWindow` (pattern from `GiniOptionRowRenderingTests` in PP-3997): container renders without crash; container with `isShowingPicker = true` renders sheet body without crash. `@MainActor`. (smoke)
- [x] 12. Verification completed via direct `xcodebuild`. Scheme `GiniBankSDK` builds clean on iPhone 17 / iOS 26.2 (EXIT=0). Shipped state: **15 tests across 5 suites** pass — `FraudWarningViewModelTests` (4), `FraudWarningCoordinatorTests` (3), `FraudWarningViewRenderingTests` (1), `FraudWarningScaffoldRoutingTests` (7, nested under `GiniConfigurationSharedStateSuite` — includes the three double-fire regression tests `doubleCancelFiresTerminalOnce`, `cancelThenProceedFiresOnlyFirst`, `proceedThenCancelFiresOnlyFirst` added during review). The picker suite (`IBANSelectionSheetViewModelTests`) was removed with the picker. **Note on `make lint`**: this machine's `make lint` target points at `iPhone 15 Pro / iOS 17.2` which is unavailable locally — `xcodebuild -showBuildSettings` times out. The repo's Makefile destination is a known local-vs-CI drift (platform.md §Verification) and does not block verification against the CI parity destination (`iPhone 17 / iOS 26.2`).

## Release notes (for the PR body and the GiniBankSDK major bump)

Two breaking changes ship together; both must be called out explicitly so integrators update their build pin deliberately:

> **Breaking changes in this release:**
> - **Minimum iOS deployment target raised from iOS 15 to iOS 16.** Integrators still shipping on iOS 15 cannot update to this version.
> - **Minimum Xcode version raised from Xcode 13 to Xcode 14** (`swift-tools-version` bumped to 5.7 — required to declare `.iOS(.v16)` in the SPM manifest). Integrators building against the SPM distribution need Xcode 14 or newer; older Xcodes will fail to resolve the package.
>
> Both changes ship together because they are structurally coupled (the iOS 16 minimum requires the newer swift-tools syntax). The release warrants a GiniBankSDK major version bump.

The second line is easy to forget — the PR title will read as "iOS 16 bump" and the swift-tools change is on line 1 of two manifests, not in the obvious source diff.
