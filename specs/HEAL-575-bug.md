# HEAL-575: [iOS] Bank Selection sheet opens empty when `paymentProviders` fetch is still in-flight

Status: diagnosed (escalated to `/gini-plan` — see "Escalation" below)
Ticket: https://ginis.atlassian.net/browse/HEAL-575

## Symptom

If the user triggers `startPaymentFlow` before
`PaymentComponentsController.loadPaymentProviders()` resolves, the Bank
Selection bottom sheet (`BanksBottomView`) opens with its "Select your bank
to pay" header but zero provider cells. Waiting does not recover the sheet
— providers populate the controller's internal array seconds later, but
the sheet never reloads. Dismissing and re-opening the sheet is the only
workaround today.

Observed consistently under slow network on BrowserStack smoke tests on
`GiniHealthSDK;6.1.0` / `GiniInternalPaymentSDK` (current `main`). Also
reproducible on-device during a first-launch cold-start when the user taps
Transfer directly within the first ~2 s.

## Reproduction

**Preferred — unit test** (would live in
`GiniComponents/InternalPaymentSDK/Tests/GiniInternalPaymentSDKTests/BanksBottomViewTests.swift`,
new file — the module ships Swift Testing suites for every other VM/view
pair):

1. Stand up a `PaymentComponentsController` whose `giniSDK.fetchBankingApps`
   stub never resolves.
2. Immediately call `bankSelectionBottomSheet()` and read
   `BanksBottomViewModel.paymentProviders.count` — expect `0`.
3. Make the stub resolve with a non-empty `PaymentProviders` array.
4. Re-read `BanksBottomViewModel.paymentProviders.count` → bug: still `0`.
   `BanksBottomView.paymentProvidersTableView.numberOfRows(inSection: 0)`
   also stays at `0`.

**Manual on BrowserStack**: `GiniHealthSmokeScreensUITests.testBankSelectionSheetShowsProviders`
intermittently fails with "No bank cells found in the Bank Selection sheet
after 30 s" (test-side mitigation shipped in #1291 only tolerates the race;
it does not fix the already-presented empty sheet). Full logs on BS build 3
of the SmokeScreens suite under session `4534135430`.

**Manual on example app**: open `GiniHealthSDKExample`, throttle the Network
Link Conditioner to a slow 3G profile, launch the app, immediately tap
Invoices list → Transfer directly. Sheet appears empty, stays empty.

## Root cause

The Bank Selection sheet consumes a **frozen snapshot** of
`PaymentComponentsController.paymentProviders` at the moment of
construction. The controller later mutates its own array when
`fetchBankingApps` resolves, but no reactive link exists to the sheet that
was already presented.

Three files participate.

### 1. `HealthSDK/GiniHealthSDK/Sources/GiniHealthSDK/Core/PaymentComponentsController.swift`

```swift
public final class PaymentComponentsController: BottomSheetsProviderProtocol, GiniHealthTrackingDelegate {
    ...
    var paymentProviders: GiniHealthAPILibrary.PaymentProviders = []        // L90 — starts []
    ...
    public init(giniHealth: ...) {
        self.giniSDK = giniHealth
        ...
        loadPaymentProviders()                                               // L128 — async fetch kicked off
        fetchAndUpdateClientConfiguration()
    }
```

### 2. `HealthSDK/GiniHealthSDK/Sources/GiniHealthSDK/Core/PaymentComponentsController+Helpers.swift`

```swift
func loadPaymentProviders() {                                                // L29
    self.isLoading = true
    self.giniSDK.fetchBankingApps { [weak self] result in
        self?.isLoading = false
        switch result {
        case let .success(paymentProviders):
            self?.paymentProviders = paymentProviders.map{ $0.toHealthPaymentProvider() }
            self?.sortPaymentProviders()
            self?.selectedPaymentProvider = self?.defaultInstalledPaymentProvider()
            self?.delegate?.didFetchedPaymentProviders()                     // L38 — ONLY the delegate (host app) is told
        case let .failure(error):
            GiniUtilites.Log("Couldn't load payment providers: \(error.localizedDescription)", event: .error)
        }
    }
}
...
public func bankSelectionBottomSheet() -> UIViewController {                 // L168
    let paymentProvidersBottomViewModel = BanksBottomViewModel(
        paymentProviders: paymentProviders,                                  // snapshot — may be []
        selectedPaymentProvider: healthSelectedPaymentProvider,
        ...
    )
    paymentProvidersBottomViewModel.viewDelegate = self
    paymentProvidersBottomViewModel.documentId = documentId
    return BanksBottomView(viewModel: paymentProvidersBottomViewModel, ...)
}
```

- `paymentProviders` on the controller is a plain `var`, mutated inside
  the async completion.
- `bankSelectionBottomSheet()` dereferences that `var` at call time —
  caller receives a `BanksBottomView` built on the snapshot.
- The success branch of `loadPaymentProviders` notifies
  `self?.delegate?.didFetchedPaymentProviders()` — this is a
  `PaymentComponentsControllerProtocol` hook consumed by the HOST APP, not
  by the SDK's own sheet. In the example app, the hook only reloads the
  Invoices table (`InvoicesListViewModel.didFetchedPaymentProviders` →
  `invoicesListViewController?.reloadTableView()`).
- No one tells the already-presented sheet that providers finally arrived.

### 3. `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/BanksView/BanksBottomViewModel.swift`

```swift
public init(paymentProviders: PaymentProviders,                              // L55
            selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?,
            configuration: BankSelectionConfiguration,
            ...) {
    ...
    self.paymentInfoViewModel = PaymentInfoViewModel(
        paymentProviders: paymentProviders.uniqued(by: { $0.id }),           // L75 — snapshot propagated
        ...
    )
    ...
    self.paymentProviders = paymentProviders                                 // L85 — snapshot stored + filtered + sorted
        .map({ PaymentProviderAdditionalInfo(...) })
        .filter { ... }
        .uniqued(by: { $0.paymentProvider.id })
        .sorted { ... }
    self.calculateHeights()                                                  // L100 — height derived from snapshot count
}
```

- The init does substantial per-provider work (wrap in
  `PaymentProviderAdditionalInfo`, filter by GPC/Open-With platform support,
  dedupe, sort by install state and index). All of this derives from the
  frozen input and runs exactly once.
- `BanksBottomView.setupViewAttributes()` reads `viewModel.paymentProviders`
  and `viewModel.heightTableView` directly — no observer, no Combine
  subscription, no delegate hook back to the controller.
- The internal `BanksSelectionProtocol` is for user-triggered events
  (`didSelectPaymentProvider`, `didTapOnMoreInformation`, …) — not data
  arrival.

### Call-site timeline when it breaks

```
t=0.0s  PaymentComponentsController.init(giniHealth:) called
         └─ paymentProviders = []
         └─ loadPaymentProviders() → giniSDK.fetchBankingApps { ... } (async)
t=0.2s  User taps Transfer directly
t=0.3s  startPaymentFlow(..) eventually calls bankSelectionBottomSheet()
         └─ snapshot captured: BanksBottomViewModel(paymentProviders: [])
         └─ sheet presented: BanksBottomView with 0 rows
t=3.5s  fetchBankingApps completion fires
         └─ controller.paymentProviders = [...]   // internal only
         └─ delegate?.didFetchedPaymentProviders()  // host reloads invoices
         └─ nothing propagates to the already-presented sheet
         └─ sheet stays visibly empty until dismissed and re-opened
```

### Why this is primarily an SDK bug, not an example-app bug

- The SDK's documented contract for `PaymentComponentsController` is that
  `startPaymentFlow` is callable at any time after construction. Making
  the host app gate every Payment Flow entry on
  `didFetchedPaymentProviders` would push SDK-contract responsibility into
  every integrator.
- The sheet-building code and the view model both live inside the SDK —
  the SDK owns the lifecycle gap.
- An example-app workaround (guard `startPaymentFlow` on
  `paymentProviders.isEmpty == false`) is possible but should not be
  needed, and does not fix the on-device cold-start race for real
  integrators.

## Impact

- iOS UI smoke tests on BrowserStack flake on `testBankSelectionSheetShowsProviders`
  / `testBankSelectionSheetSelectionUpdatesPaymentComponent` /
  `testPaymentReviewBankPickerOpensBankSelection` / the Payment Info opener
  under `openPaymentInfoFromBankSelection`. Mitigated test-side in PR #1291
  with a 30 s `waitForProviders` wait — mitigation only works because the
  fetch sometimes resolves before the sheet is opened; it does not help an
  already-empty presented sheet.
- End users on first-launch cold-start may see the same empty sheet in
  production under slow network. Dismiss-and-reopen is the only workaround
  on-device.

## Fix sketch (NOT yet implemented — see "Escalation")

Keep the frozen-array constructor for backward compatibility, add an
imperative update entry point on the view model, and have the controller
forward late arrivals via a weak reference captured at sheet construction:

- `BanksBottomViewModel` gains `func replacePaymentProviders(_ providers: PaymentProviders)`
  that redoes the init's wrap/filter/sort pipeline and emits an
  `onPaymentProvidersUpdated: (() -> Void)?` closure.
- `BanksBottomView.setupView()` subscribes to that closure to
  `reloadData()` + recompute height.
- `PaymentComponentsController` gains a `weak var activeBanksViewModel`,
  assigns it inside `bankSelectionBottomSheet()`, and forwards the latest
  providers to it from the `loadPaymentProviders` success branch (next to
  the existing `delegate?.didFetchedPaymentProviders()` call).

Alternative — reactive source: replace the frozen `PaymentProviders` input
on `BanksBottomViewModel.init` with an `AnyPublisher<PaymentProviders, Never>`
and have the view model subscribe internally. Idiomatic Combine, but
public-init-signature changing.

Alternative — gate presentation: short-circuit `bankSelectionBottomSheet()`
when `paymentProviders.isEmpty && isLoading`, returning a lightweight
loading `UIViewController` and resolving on the fetch completion. Changes
sheet lifecycle semantics; most invasive.

## Escalation

Per `.claude/skills/gini-fix/SKILL.md`'s escalation rule:

> "The moment the work stops being a minimal fix — the change needs design
> decisions, alters public API, or spreads beyond the module(s) implicated
> by the root cause — stop and say so. Finish writing the diagnosis (it
> stays valuable), then route the ticket to `/gini-plan`."

All three criteria apply to HEAL-575:

- **Design decision.** Three competing patterns (closure observer with
  weak-ref forward / Combine `AnyPublisher` injection / defer-present-sheet
  with loading state). Each has non-trivial API, testability, and backward-
  compatibility implications; the choice should be reviewed, not improvised
  inside a fix PR.
- **Alters public API.** `BanksBottomViewModel.init` is `public`. Any of
  the three options either adds a new public method / closure property to
  it, or changes an init parameter type.
- **Spreads beyond one module.** Fix touches both
  `GiniInternalPaymentSDK` (`BanksBottomViewModel` + `BanksBottomView`) and
  `GiniHealthSDK` (`PaymentComponentsController` +
  `PaymentComponentsController+Helpers`). Two SDK modules in the dependency
  graph change signatures together.

Routing to `/gini-plan HEAL-575` with this diagnosis as input. No code
change lands under `/gini-fix`.

## Related

- UI-test mitigation already shipped: PR #1291, commit `6c5e53cbc` —
  `BankSelectionBottomSheet.waitForProviders(timeout: 30, settle: 1.0)`.
  Tolerates the race only when the fetch beats the sheet open; does not
  resolve this bug.
- `delegate?.didFetchedPaymentProviders()` consumers today are host-app
  only — see `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/InvoicesList/InvoicesListViewModel.swift:270`.
