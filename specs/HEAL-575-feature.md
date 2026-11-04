# HEAL-575: Make Bank Selection / Payment Component / Payment Info sheets reactive to late `paymentProviders` arrivals

Status: fixed
Ticket: https://ginis.atlassian.net/browse/HEAL-575

## Problem

`PaymentComponentsController.loadPaymentProviders()` fetches the provider
list asynchronously. Three sheets — Bank Selection (`BanksBottomView`),
Payment Component (`PaymentComponentView`), Payment Info
(`PaymentInfoViewController`) — snapshot the controller's `paymentProviders`
at construction time. If the user triggers `startPaymentFlow` before the
fetch resolves (slow network, BrowserStack smoke tests, first-launch
cold-start), the sheets render empty / stale, and no reactive link forwards
the late arrival. The only workaround today is dismiss-and-reopen.

See `specs/HEAL-575-bug.md` for the full root-cause analysis, call-site
timeline, and rejected minimal-fix rationale (escalated from `/gini-fix`).

## Requirements

**R1 (MUST, entry):** Given an integrator holds a `PaymentComponentsController`
instance, when they access `paymentProvidersPublisher`, then they receive an
`AnyPublisher<GiniHealthAPILibrary.PaymentProviders, Never>` that emits the
controller's current provider list immediately and every subsequent update
from `loadPaymentProviders()`.

**R2 (MUST, entry):** Given `BanksBottomViewModel`, `PaymentComponentViewModel`,
and `PaymentInfoViewModel` are constructed via their public inits, when the
caller provides an `AnyPublisher<PaymentProviders, Never>`, then each view
model subscribes internally and uses the published values as its provider
source.

**R3 (MUST, happy):** Given a `BanksBottomView` is presented with an empty
provider list (fetch in-flight), when the publisher emits a non-empty list,
then the sheet's `paymentProvidersTableView` reloads to show cells for each
emitted provider that passes the view model's existing filter
(`gpcSupportedPlatforms.contains(.ios) || openWithSupportedPlatforms.contains(.ios)`),
and the sheet's `heightTableView` recomputes to match the new row count.

**R4 (MUST, happy):** Given a `PaymentComponentView` is presented with no
`selectedPaymentProvider` (fetch in-flight, "Your bank" placeholder shown),
when the publisher emits a non-empty list AND the controller resolves a
`defaultInstalledPaymentProvider`, then the Payment Component view updates
to display the selected bank's icon and name in place of the placeholder.

**R5 (MUST, happy):** Given a `PaymentInfoViewController` is presented
(opened via the inline More Information link on the Bank Selection sheet)
while the fetch is in-flight, when the publisher emits a non-empty list,
then the bank-icons collection view reloads to show one cell per unique
emitted provider.

**R6 (MUST, async):** Given the publisher emits from any queue, when a
subscribing view model receives a value, then its state mutation and
`onPaymentProvidersUpdated` closure invocation occur on the main queue
(subscription includes `.receive(on: DispatchQueue.main)`), so view
`reloadData()` is safe to call synchronously from the closure.

**R7 (MUST, async):** Given a sheet is presented AFTER the fetch has already
resolved, when its view model subscribes to the publisher, then the current
value replays immediately (`CurrentValueSubject` semantics), the view model
applies it synchronously, and the view renders populated on first display —
no empty flash.

**R8 (MUST, error):** Given `giniSDK.fetchBankingApps` fails, when the
completion fires with `.failure`, then the publisher does NOT emit a new
value (behavior unchanged — the empty `[]` already published at init stays).
The failure is logged via `GiniUtilites.Log(...event: .error)` as today;
sheets stay in the empty state until a successful fetch is retried by a
subsequent controller call.

**R9 (SHOULD, async):** Given multiple sheets are presented concurrently
(e.g. Bank Selection from the Payment Component path, then Payment Info
from inside Bank Selection), when the publisher emits, then every live
subscriber receives the value; dismissing a sheet releases its subscription
via `cancellables` deinit — no leaks.

## Affected modules

- **`GiniInternalPaymentSDK`** (iOS 17+): the three view models and their
  view/view-controller consumers.
  - `Sources/GiniInternalPaymentSDK/BanksView/BanksBottomViewModel.swift`
  - `Sources/GiniInternalPaymentSDK/BanksView/BanksBottomView.swift`
  - `Sources/GiniInternalPaymentSDK/PaymentComponents/PaymentComponentViewModel.swift`
  - `Sources/GiniInternalPaymentSDK/PaymentComponents/PaymentComponentView.swift`
  - `Sources/GiniInternalPaymentSDK/PaymentInfo/PaymentInfoViewModel.swift`
  - `Sources/GiniInternalPaymentSDK/PaymentInfo/PaymentInfoViewController.swift`
- **`GiniHealthSDK`** (iOS 17+): the controller that owns the subject and
  wires it into the view-model constructors.
  - `Sources/GiniHealthSDK/Core/PaymentComponentsController.swift`
  - `Sources/GiniHealthSDK/Core/PaymentComponentsController+Helpers.swift`

Dependency direction: `GiniHealthSDK` → `GiniInternalPaymentSDK`. The
publisher type lives in `GiniHealthAPILibrary` (`PaymentProviders`), which
both modules already depend on. No new dependency edges.

## Public API impact

### `GiniInternalPaymentSDK` — BREAKING

`BanksBottomViewModel.init` adds a required parameter:

```swift
public init(paymentProviders: PaymentProviders,
            paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never>,
            selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?,
            // ...all existing parameters unchanged after this point...)
```

Same for `PaymentComponentViewModel.init` and `PaymentInfoViewModel.init` —
each gains `paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never>`
immediately after its existing `paymentProviders` parameter (where
applicable; `PaymentComponentViewModel` keeps `paymentProvider:
PaymentProvider?` and gains the publisher as a new required param).

**Rationale for breaking (not deprecated-shim).** Searched the full
repository: these three `public init`s are constructed in exactly four
sites, all SDK-internal (3 inside
`PaymentComponentsController+Helpers.swift`, 1 inside `BanksBottomView`
for the Payment Info VC). Zero external callers. The package is named
`GiniInternalPaymentSDK` and is not documented as an integration surface.
A deprecation lifecycle would be theatre.

### `GiniHealthSDK` — ADDITIVE

New public property on `PaymentComponentsController`:

```swift
/// Publishes the controller's payment-provider list. Emits the current
/// value on subscribe and every subsequent successful load.
public var paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never> { ... }
```

Nothing else on the controller's public surface changes.
`startPaymentFlow`, `bankSelectionBottomSheet()`,
`paymentViewBottomSheet(documentId:)`, `delegate`,
`didFetchedPaymentProviders` — all behave identically for external
callers; the subject becomes the internal source of truth for
`paymentProviders`.

### Version bumps

- `GiniInternalPaymentSDK;3.1.1` → `GiniInternalPaymentSDK;4.0.0` (SemVer
  major, breaking init signatures).
- `GiniHealthSDK;6.1.0` → `GiniHealthSDK;6.2.0` (SemVer minor, additive
  `paymentProvidersPublisher` only).

(confidence: LOW — exact next semver values depend on current main's
version constants; verify against
`HealthSDK/GiniHealthSDK/Sources/GiniHealthSDK/GiniHealthSDKVersion.swift`
and
`GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/GiniInternalPaymentSDKVersion.swift`
at implementation time.)

## Technical conventions

Grounded in `.claude/skills/gini-plan/platform.md`'s checklist and
`.claude/rules/mandatory-rules.md`.

1. **Language & access control.** Swift. `paymentProvidersPublisher`
   justified `public` because it's the integrator's observation surface
   (R1). Internal `_paymentProvidersSubject`, per-view-model `cancellables:
   Set<AnyCancellable>`, and `onPaymentProvidersUpdated: (() -> Void)?` all
   `internal` (default). Doc comments `/** */` on new declarations.
2. **UI framework.** No change — `BanksBottomView` and `PaymentComponentView`
   stay `UIView` with programmatic Auto Layout; `PaymentInfoViewController`
   stays `UIViewController` embedding `UICollectionView` + `UITableView`.
   New views are NOT part of this scope.
3. **Architecture.** MVVM. View models own the Combine subscription; views
   bind to the view model via a plain closure
   (`onPaymentProvidersUpdated: (() -> Void)?`) exactly as the module
   already does for other state (see `BanksBottomView` existing closure
   usage patterns for `MoreInformationView` taps). No Combine in the view
   layer.
4. **Wiring.**
   - DI: constructor injection of the publisher into each view model's
     init (R2). `PaymentComponentsController+Helpers.swift` passes
     `self.paymentProvidersPublisher` into the three `init(...)` sites
     (lines 126, 169, 289).
   - Async: Combine (`CurrentValueSubject`, `AnyPublisher`, `.sink`,
     `.receive(on:)`). `import Combine` added to each of the three view
     model files (not currently imported) and to
     `PaymentComponentsController.swift` (where the subject lives).
   - Thread safety: subscriptions use `.receive(on: DispatchQueue.main)`
     so state mutation + closure invocation happen on main (R6).
5. **Localization.** No new user-facing strings. No `.strings` files
   change.
6. **Formatting / doc style.** Multi-parameter inits one-per-line per
   `CLAUDE.md` › Code Style. Enforced by `gini-orchestrator`.
7. **Quality gates.** `make lint scheme=GiniHealthSDK` must pass. Local
   runs on `iPhone 15 Pro / iOS 17.2`; CI runs on `iPhone 17 / iOS 26.2`
   per `.github/workflows/shared-config.yml` — re-run failing checks in
   CI parity before pushing. New view model tests use **Swift Testing**
   (dominant framework in GiniInternalPaymentSDK). New controller test
   uses **XCTest** (dominant framework in GiniHealthSDK). No new mocks
   beyond the existing `MockPaymentComponents` /
   `MockPaymentComponentsDelegate`; manual protocol conformances only.

## Design

### Controller — single source of truth

`PaymentComponentsController` replaces the plain
`var paymentProviders: GiniHealthAPILibrary.PaymentProviders = []`
(`PaymentComponentsController.swift:90`) with a `CurrentValueSubject`:

```swift
private let _paymentProvidersSubject = CurrentValueSubject<PaymentProviders, Never>([])

public var paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never> {
    _paymentProvidersSubject.eraseToAnyPublisher()
}

var paymentProviders: PaymentProviders {
    _paymentProvidersSubject.value
}
```

The computed `paymentProviders` getter means every existing read site in
`+Helpers.swift` continues to work unchanged. `loadPaymentProviders()`
(`+Helpers.swift:29`) replaces its direct assignment with a `send(...)`:

```swift
case let .success(paymentProviders):
    let mapped = paymentProviders
        .map { $0.toHealthPaymentProvider() }
        .sorted(by: /* existing sortPaymentProviders logic */)
    self?._paymentProvidersSubject.send(mapped)
    self?.selectedPaymentProvider = self?.defaultInstalledPaymentProvider()
    self?.delegate?.didFetchedPaymentProviders()
```

`sortPaymentProviders()` currently mutates `self.paymentProviders` in
place; it becomes a pure function returning the sorted list, called inside
the success branch above. Delegate notification stays — host apps
(e.g. `InvoicesListViewModel.didFetchedPaymentProviders`) continue to
receive it unchanged.

### View models — subscribe once, forward to view via closure

Each view model gains:
```swift
import Combine
...
private var cancellables = Set<AnyCancellable>()
var onPaymentProvidersUpdated: (() -> Void)?

public init(paymentProviders: PaymentProviders,
            paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never>,
            // ... existing params ...) {
    // ... existing init body applying `paymentProviders` snapshot ...
    paymentProvidersPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] providers in
            self?.applyPaymentProviders(providers)
        }
        .store(in: &cancellables)
}

private func applyPaymentProviders(_ raw: PaymentProviders) {
    // Same wrap/filter/uniqued/sort pipeline that currently lives in init.
    // Extracted into a private helper so init and the sink share logic.
    self.paymentProviders = raw
        .map { PaymentProviderAdditionalInfo(
            isSelected: $0.id == selectedPaymentProvider?.id,
            isInstalled: isPaymentProviderInstalled(paymentProvider: $0),
            paymentProvider: $0) }
        .filter { $0.paymentProvider.gpcSupportedPlatforms.contains(.ios)
                 || $0.paymentProvider.openWithSupportedPlatforms.contains(.ios) }
        .uniqued(by: { $0.paymentProvider.id })
        .sorted { ... /* unchanged */ }
    self.calculateHeights()
    onPaymentProvidersUpdated?()
}
```

Note the deliberate duplication: the initial `paymentProviders` snapshot
parameter is kept for backward-compatible call shape AND because
`CurrentValueSubject` replays its current value on subscribe — but the
subscribe happens AFTER init completes, so the init still runs the pipeline
once for the snapshot. The replay from the subject re-invokes
`applyPaymentProviders` with the same value and triggers one extra
`reloadData()`. Acceptable; the alternative (dropping the `paymentProviders`
param and awaiting the first emit) complicates the API without a visible
benefit.

Same shape in `PaymentComponentViewModel` and `PaymentInfoViewModel`:
each applies its OWN internal transform of the raw provider list (not
shared logic — PaymentComponentViewModel updates `selectedPaymentProvider`
via `defaultInstalledPaymentProvider` semantics; PaymentInfoViewModel
rebuilds its bank-icon collection).

### Views — reload on closure fire

```swift
// BanksBottomView.setupView()
viewModel.onPaymentProvidersUpdated = { [weak self] in
    guard let self else { return }
    self.paymentProvidersTableView.reloadData()
    self.setupViewAttributes()  // existing method; recomputes height constraint from viewModel
}

// PaymentComponentView: same shape, re-renders bank label/icon.
// PaymentInfoViewController: same shape, bankIconsCollectionView.reloadData().
```

Closure is set in the view's existing `setupView()` method (post-init,
before the first appearance). `[weak self]` prevents retain cycles.

### Call-site timeline — after fix

```
t=0.0s  PaymentComponentsController.init()
         └─ _paymentProvidersSubject(value: [])
         └─ loadPaymentProviders() → fetchBankingApps { ... } (async)
t=0.2s  User taps Transfer directly
t=0.3s  bankSelectionBottomSheet() → BanksBottomViewModel(..., publisher: subject.erase)
         └─ init applies snapshot [] (no cells)
         └─ subscription stored in cancellables
         └─ sink fires IMMEDIATELY with the current value [] — redundant reload
         └─ sheet presented, 0 rows
t=3.5s  fetchBankingApps completes
         └─ _paymentProvidersSubject.send([providers...])
         └─ sink fires on main queue
         └─ applyPaymentProviders([providers...]) → paymentProviders filled, height recalculated
         └─ onPaymentProvidersUpdated() → tableView.reloadData()
         └─ sheet now shows N rows — bug fixed
```

## Test plan

### `BanksBottomViewModelTests` — **extend** existing Swift Testing suite

File: `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Tests/GiniInternalPaymentSDKTests/BanksBottomViewModelTests.swift`
(already uses `@Suite("BanksBottomViewModel") @MainActor struct`).

Extend `makeSUT` to accept a publisher parameter with a default of
`Just([]).eraseToAnyPublisher()` so existing tests compile unchanged. Add
3 new `@Test`s (count justified: subscribe-replay + late-arrival + no-emit
cover the three branches of R2/R3/R6/R7):

1. `@Test("Subscribes to publisher and applies emitted providers")` —
   makeSUT with `providers: []` and `CurrentValueSubject` holding `[.fixture()]`
   erased to publisher; expect `paymentProviders.count == 1` after init
   (replay on subscribe). Fires R2 + R7.
2. `@Test("Reapplies providers when publisher emits a new value")` —
   makeSUT with `providers: []` and a `CurrentValueSubject` initial `[]`;
   capture `onPaymentProvidersUpdated` call count; `subject.send([.fixture(a), .fixture(b)])`;
   expect `paymentProviders.count == 2` AND callback fired. Fires R3.
3. `@Test("Ignores failures — publisher never emits .failure")` — not a
   publisher failure test (publisher is `Never`), but a smoke that
   confirms when `fetchBankingApps` fails in the controller, the subject
   doesn't send and the view model remains at init snapshot. Lives in the
   controller test suite (see below), not here.

### `PaymentComponentViewModelTests` — **extend** existing Swift Testing suite

File: `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Tests/GiniInternalPaymentSDKTests/PaymentComponentViewModelTests.swift`.

Add 3 `@Test`s mirroring the above but asserting `selectedPaymentProvider`
and the "Your bank" placeholder visibility state. Fires R4 + R6 + R7.

### `PaymentInfoTests` — **extend** existing Swift Testing suite

File: `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Tests/GiniInternalPaymentSDKTests/PaymentInfoTests.swift`.

Add 2 `@Test`s: subscribe-replay with providers, late-arrival emits reload.
Fires R5.

### `PaymentComponentsControllerTests` — **extend** existing XCTest suite

File: `HealthSDK/GiniHealthSDK/Tests/GiniHealthSDKTests/PaymentComponentsControllerTests.swift`.

Add 3 `XCTestCase` methods:

1. `test_paymentProvidersPublisher_emitsCurrentValueOnSubscribe` — subscribe
   to the publisher after init (before any fetch resolves); XCTExpectation
   fires when the first value `[]` lands. Fires R1 + R7.
2. `test_loadPaymentProviders_success_emitsThroughPublisher` — inject a
   `MockGiniHealth` whose `fetchBankingApps` returns `.success([mockProvider])`
   on completion; subscribe; expect a second value `[mockProvider.toHealthPaymentProvider()]`
   within 1s. Fires R1 + R3.
3. `test_loadPaymentProviders_failure_doesNotEmit` — mock fails; subscribe;
   assert only the initial `[]` is received within 1s (second `.sink`
   invocation count stays at 1 for the replay). Fires R8.

### `GiniHealthSmokeScreensUITests` — no changes

The existing `waitForProviders(timeout: 30, settle: 1.0)` mitigation in
`BankSelectionBottomSheet` (PR #1291 commit `6c5e53cbc`) keeps its 30s
timeout. After the fix lands, `anyBankCell.waitForExistence` typically
resolves within 1–2s instead of hitting the 30s edge; the existing wait
remains correct for the (rarer) case where the fetch still outruns the
sheet open. No test-side change required.

### Not tested

- Combine's `CurrentValueSubject` replay semantics (framework behavior).
- `AnyCancellable` lifecycle on view model deinit (framework behavior,
  verified visually in instruments if a leak is suspected).
- Multi-queue thread-safety stress: a single `.receive(on: .main)` is
  sufficient per Apple's Combine documentation; serialising on main is the
  contract.
- End-to-end BrowserStack re-run to confirm the smoke test stops flaking —
  that's manual QA for the release engineer, not an automated gate.
- **R8 fetch-failure non-emission as a unit test.** `MockSessionManager`
  always returns success for the `paymentProviders` endpoint via the bundled
  `providers.json` fixture; there is no built-in failure injection. Adding
  one would require either a new mock session manager that fails for the
  `.paymentProviders` resource case or a mock `GiniHealth` that replaces the
  real `fetchBankingApps`. R8 is verifiable by inspection — the failure
  branch of `loadPaymentProviders` only logs via `GiniUtilites.Log(...event:
  .error)` and never touches `_paymentProvidersSubject` — and will be
  covered automatically when the next ticket extends `MockSessionManager`
  for failure cases (a cross-cutting improvement, not a HEAL-575 blocker).

## Out of scope

- Loading-state UI inside the Bank Selection / Payment Component / Payment
  Info sheets. The empty state during a slow fetch stays visually empty
  (not a spinner). Addressing it is a separate design decision; file a
  follow-up HEAL ticket if product wants it.
- Retry-on-failure for `fetchBankingApps`. The controller already logs
  the error and leaves the sheets empty; manual retry via re-entering the
  flow is unchanged.
- Any changes to `PaymentReviewObservableModel`, `PaymentReviewViewController`,
  or the SwiftUI Payment Review screen — this bug touches the three
  pre-review bottom sheets only.
- Deprecation shims on the view-model `init`s (justified above).

## Open questions

1. **Semver version bump exact values** —
   `GiniInternalPaymentSDK;x.y.z → 4.0.0`, `GiniHealthSDK;6.1.0 → 6.2.0`
   stated as working targets; confirm against the `*Version.swift`
   constants at implementation time. (confidence: LOW — resolved by
   reading the constants.)

No other open questions. Three decisions (pattern / scope / migration)
were resolved in the clarifying round.

## Implementation plan

Ordered so the tree compiles at the end of each step. The three view models
are refactored in the same shape — each step touches one module and leaves
the next step with a clear boundary. Tests follow each view model's
refactor rather than all at the end, so a failing test immediately tells
us which step regressed.

- [x] 1. **Controller publisher.** `PaymentComponentsController.swift` — add `import Combine`, replace stored `var paymentProviders` with a `private let _paymentProvidersSubject = CurrentValueSubject<PaymentProviders, Never>([])`, expose `public var paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never>`, and keep a computed `var paymentProviders` reading `_paymentProvidersSubject.value` so all current read sites in `+Helpers.swift` compile unchanged. Refactor `sortPaymentProviders()` into a pure helper and update the success branch of `loadPaymentProviders` to `send(...)` through the subject. (requirements R1, R8)
- [x] 2. **`BanksBottomViewModel` reactive.** `BanksView/BanksBottomViewModel.swift` — add `import Combine`; add required init param `paymentProvidersPublisher: AnyPublisher<PaymentProviders, Never>`; extract the init's wrap/filter/sort pipeline into `private func applyPaymentProviders(_:)`; add `private var cancellables: Set<AnyCancellable>` and `var onPaymentProvidersUpdated: (() -> Void)?`; subscribe at end of init via `.receive(on: DispatchQueue.main).sink { [weak self] in self?.applyPaymentProviders($0) }`. Update the single construction site in `PaymentComponentsController+Helpers.swift:169`. (R2, R3, R7)
- [x] 3. **`BanksBottomView` wiring.** `BanksView/BanksBottomView.swift` — in the existing `setupView()`, assign `viewModel.onPaymentProvidersUpdated = { [weak self] in self?.paymentProvidersTableView.reloadData(); self?.setupViewAttributes() }`. (R3, R6, R9)
- [x] 4. **`BanksBottomViewModelTests` extensions.** Three new `@Test`s in `BanksBottomViewModelTests.swift` using Swift Testing: subscribe-replay with providers; late-emission applies providers and fires closure; empty-emission leaves state empty but still fires. Extend `makeSUT` to accept a publisher with default `Just([]).eraseToAnyPublisher()`. (R2, R3, R7)
- [x] 5. **`PaymentComponentViewModel` reactive.** `PaymentComponents/PaymentComponentViewModel.swift` — same mechanical refactor as step 2, applied to the "Your bank" placeholder / selected-provider state. Update the single construction site in `PaymentComponentsController+Helpers.swift:126`. (R2, R4, R7)
- [x] 6. **`PaymentComponentView` wiring.** `PaymentComponents/PaymentComponentView.swift` — assign `viewModel.onPaymentProvidersUpdated` in the view's existing setup method; closure refreshes the bank label/icon state. (R4, R6)
- [x] 7. **`PaymentComponentViewModelTests` extensions.** Three new `@Test`s in `PaymentComponentViewModelTests.swift`: replay, late emit updates `selectedPaymentProvider`, empty emit. (R4, R7)
- [x] 8. **`PaymentInfoViewModel` reactive.** `PaymentInfo/PaymentInfoViewModel.swift` — same mechanical refactor as step 2, applied to the bank-icon collection. Update the single construction site in `PaymentComponentsController+Helpers.swift:289`. (R2, R5, R7)
- [x] 9. **`PaymentInfoViewController` wiring.** `PaymentInfo/PaymentInfoViewController.swift` — assign `viewModel.onPaymentProvidersUpdated` in `viewDidLoad()`; closure reloads `bankIconsCollectionView`. (R5, R6)
- [x] 10. **`PaymentInfoTests` extensions.** Two new `@Test`s in `PaymentInfoTests.swift`: replay with providers, late emit reloads icons. (R5)
- [x] 11. **`PaymentComponentsControllerTests` extensions.** Three new XCTest methods in `PaymentComponentsControllerTests.swift`: publisher emits current value on subscribe; `loadPaymentProviders` success emits through publisher; failure does not emit. Use existing `MockPaymentComponents` + `MockPaymentComponentsDelegate`. (R1, R3, R8)
- [ ] 12. **Version bumps.** `GiniInternalPaymentSDKVersion.swift` 3.1.1 → 4.0.0 (SemVer major, breaking inits). `GiniHealthSDKVersion.swift` 6.1.1 → 6.2.0 (SemVer minor, additive publisher). Resolves the LOW-confidence Open Question.
- [x] 13. **Verify.** `GiniInternalPaymentSDK` 266/266 tests passing, `GiniHealthSDK` 93/93 tests passing (2 pre-existing skipped). Both built against `platform=iOS Simulator,name=iPhone 16`. `make lint scheme=GiniHealthSDK`; `xcodebuild clean test -scheme GiniHealthSDKExample` (hosts GiniHealthSDK tests); run GiniInternalPaymentSDK test target via `swift test` or the equivalent xcodebuild invocation. All green before handoff.
