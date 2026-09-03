# PP-3497: [iOS] `GiniCaptureResultsDelegate.giniCaptureDidRequestSchedulePayment` is a source-breaking new required method in 4.5.0

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3497
Fix versions: iOS Gini Bank SDK 4.5.1, iOS Gini Capture SDK 4.5.1

## Implementation note — spec deviation on `@objc` protocol

Build proved that R7's claim ("Swift permits `public extension` default
impls on `@objc` protocols and they satisfy the Swift protocol
requirement") is factually wrong: the Swift compiler rejects the
conformance with
`non-'@objc' method '…' does not satisfy requirement of '@objc' protocol`.
Verified with a minimal repro against Swift 6.x / Xcode 26.2.

To make the extension default impl actually satisfy the requirement, the
`@objc` attribute was dropped from the `GiniCaptureResultsDelegate`
protocol declaration. This is the minimal change that lets the extension
work; it strictly widens the tradeoff R7 already accepted (Objective-C
conformers cannot inherit the default) to the whole protocol losing
Objective-C-descriptor visibility. Verified in-repo that every conformer
is Swift (`grep` over `.h`/`.m` finds nothing) and every Swift conformer
either inherits from `NSObject` (still fine) or is a plain Swift class
(fine). No caller change needed.

## Problem

4.5.0 (PP-3263) added a fourth required method to
`GiniCaptureResultsDelegate`:

```swift
func giniCaptureDidRequestSchedulePayment(result: AnalysisResult)
```

The method has no default implementation, so every host-app type conforming
to the protocol (typically the integrator's `ScreenAPICoordinator` or
equivalent, whether they consume `GiniBankSDK` or `GiniCaptureSDK`
directly) fails to compile against 4.5.0 until it adds the method. This is
a source-breaking change that shipped in a minor version, discovered by
Valentina while upgrading the demo app and mitigated only in the 4.5.0
release notes' `Migration from 4.4` block and a draft Confluence page.

We need a same-day 4.5.1 patch that restores source compatibility so
integrators can bump 4.4.x → 4.5.1 without a code change, without
reshaping the API. Integrators who genuinely want to handle Schedule
Payment still can — they override the default. Discoverability moves from
"compiler error" to "release note + docs", which is the accepted trade-off
for a patch release.

Option B in the ticket (sibling `GiniCaptureScheduleDelegate` threaded
through the entry point) is a 4.6 conversation and is explicitly out of
scope here.

## Requirements

R1 (MUST, entry): Given an integrator whose 4.4.x code conforms to
`GiniCaptureResultsDelegate` and implements only the three original
methods (`giniCaptureAnalysisDidFinishWith(result:)`,
`giniCaptureDidCancelAnalysis()`, `giniCaptureDidEnterManually()`), when
they update their `Package.swift` / SPM pin from `GiniBankSDK` 4.4.x (or
`GiniCaptureSDK` 4.4.x) to 4.5.1 and rebuild, then the project compiles
without adding
`giniCaptureDidRequestSchedulePayment(result:)`.

R2 (MUST, happy path): Given the SDK invokes
`resultsDelegate?.giniCaptureDidRequestSchedulePayment(result: analysisResult)`
on a conformer that does NOT override the method, when the call site
fires (e.g. the Schedule Payment CTA in the payment-hint bottom sheet),
then the default extension implementation is invoked, it is a no-op, and
control returns to the SDK without crashing or throwing — verified in a
`GiniCaptureSDK` unit test that declares a Swift class conforming to
`GiniCaptureResultsDelegate` with only the three pre-4.5 methods
implemented and calls
`giniCaptureDidRequestSchedulePayment(result:)` directly on it.

R3 (MUST, happy path): Given an integrator that DOES implement
`giniCaptureDidRequestSchedulePayment(result:)` on their conformer
(matching the pattern already used by `MockCaptureResultsDelegate` and
the two example apps), when the SDK invokes the callback, then the
integrator's implementation is invoked (not the default) with the exact
`AnalysisResult` the SDK passed — verified by an existing
`NetworkingScreenApiCoordinatorTests+SchedulePaymentHint` test continuing
to pass.

R4 (MUST, entry): Given both `GiniBankSDKVersion` and
`GiniCaptureSDKVersion` constants on `main` currently read `"4.4.0"` (the
4.5.0 release ships from tags but the constants were never bumped on main
in the release process — see
`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/GiniCaptureSDKVersion.swift`
and
`BankSDK/GiniBankSDK/Sources/GiniBankSDK/GiniBankSDKVersion.swift`), when
the 4.5.1 hotfix branch is prepared, then both constants are updated to
`"4.5.1"` and
`BankSDK/GiniBankSDK/Package-release.swift`'s pin on `GiniCaptureSDK` is
updated from `.exact("4.4.0")` to `.exact("4.5.1")`.

R5 (MUST, entry): Given the release plan excludes `GiniBankAPILibrary`
and `GiniUtilites`, when the hotfix branch is prepared, then neither
`GiniBankAPILibraryVersion` nor `GiniUtilitesVersion` is modified and no
`Package-release.swift` other than `GiniBankSDK`'s is modified.

R6 (SHOULD, happy path): Given the default implementation is a no-op,
when the extension is added, then it carries a `///` inline comment
explaining that (a) it exists to preserve source compatibility from 4.4.x
to 4.5.1 and (b) integrators SHOULD override it to route the user to
their scheduled-transfer flow. The comment is the only in-code
discoverability path for the callback.

R7 (SHOULD, error path): Given `GiniCaptureResultsDelegate` is declared
`@objc public protocol`, when a Swift-only default implementation is
added via `public extension GiniCaptureResultsDelegate`, then the spec
records the known trade-off — extension methods on `@objc` protocols are
NOT emitted into the Objective-C protocol descriptor, so an Objective-C
class conforming to the protocol still gets a "does not conform" runtime
error unless it implements the method itself. All in-repo conformers are
Swift; no known integrator uses the SDK from Objective-C for this
callback surface. This is accepted for 4.5.1 and called out in the
release note (see Design > Release note snippet).

## Affected modules

- `GiniCaptureSDK` — protocol declaration lives here; the default
  implementation is added here. Version constant bumped 4.4.0 → 4.5.1.
- `GiniBankSDK` — no source change; version constant bumped 4.4.0 →
  4.5.1 and `Package-release.swift`'s `GiniCaptureSDK` pin bumped 4.4.0
  → 4.5.1.
- `GiniBankAPILibrary`, `GiniUtilites`, `GiniHealthAPILibrary`,
  `GiniHealthSDK`, `GiniInternalPaymentSDK` — unaffected. No version
  bump, no `Package-release.swift` change.

Deployment target: iOS 15+ (both touched modules).

## Public API impact

`GiniCaptureSDK`:

- **Additive** — new default implementation of
  `giniCaptureDidRequestSchedulePayment(result:)` on
  `GiniCaptureResultsDelegate` via a `public extension`. The protocol
  requirement itself is unchanged; existing 4.5.0 conformers keep working
  and 4.4.x conformers now compile again. No new type, no new symbol
  visible to integrators beyond the extension method.

`GiniBankSDK`:

- **None**. `GiniBank.viewController(withClient:...:resultsDelegate:...)`
  and siblings are unchanged; the protocol continues to be re-used as-is.

## Technical conventions

Grounded in the modules actually touched (`GiniCaptureSDK` + version-bump
sites in `GiniBankSDK`):

1. **Language and access control** — Swift, `public extension` on
   `GiniCaptureResultsDelegate` in `GiniCaptureSDK`. The extension MUST
   be `public` (not `internal`) so it participates in the integrator's
   conformance resolution. Doc-comment style per
   `.claude/rules/mandatory-rules.md` — `/** */` on the protocol
   requirement is already present; the default impl body carries a `///`
   inline comment (R6).
2. **UI** — none. No screens, colors, fonts, spacing, or Liquid Glass
   surface changes.
3. **Architecture** — none. No new `Coordinator`/`ViewModel`/`ViewController`.
   No entry-point change. MVVM + Coordinator rules do not apply because
   nothing is being added to the view layer.
4. **Wiring** — DI unaffected. The default implementation is a synchronous
   no-op; no closure or `async`/`await` involvement. No builder change.
5. **Localization** — none. No user-facing string.
6. **Quality gates** — `make lint scheme=GiniBankSDK` and
   `make lint scheme=GiniCaptureSDK` must be clean per `AGENTS.md`. New
   `GiniCaptureSDK` test file follows the module's dominant framework
   (XCTest — see
   `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/GiniScreenAPICoordinatorTests.swift`
   and all sibling tests). Multi-parameter formatting rule does not
   apply — the default implementation has one parameter.
7. **`@objc` protocol trade-off (R7)** — the extension method MUST NOT
   be annotated `@objc`. Swift permits `public extension` default impls
   on `@objc` protocols and they satisfy the Swift protocol requirement;
   they do NOT participate in the Objective-C protocol descriptor. This
   is called out in the release note and accepted for the hotfix; a
   proper Objective-C-visible fix (making the requirement
   `@objc optional`, which is also a breaking change) belongs to Option
   B in 4.6.
8. **Version-bump convention** — bump both
   `GiniCaptureSDKVersion.swift` and `GiniBankSDKVersion.swift` string
   constants from `"4.4.0"` to `"4.5.1"` (they are currently stale on
   `main` — the 4.5.0 release shipped from tags without landing a
   version-constant bump on main). Bump the `GiniCaptureSDK` pin in
   `BankSDK/GiniBankSDK/Package-release.swift` from `.exact("4.4.0")` to
   `.exact("4.5.1")`. Do NOT touch
   `BankAPILibrary/.../GiniBankAPILibraryVersion.swift`,
   `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/GiniUtilitesVersion.swift`,
   `HealthAPILibrary/...`, `HealthSDK/...`, or
   `GiniComponents/GiniInternalPaymentSDK/...`.

## Design

### 1. The extension

Location: append to
`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Networking/GiniNetworkingScreenAPICoordinator.swift`
directly under the existing `GiniCaptureResultsDelegate` declaration
(currently ending at line 45). Keeping the extension in the same file as
the protocol matches the neighbor precedent at
`CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Networking/DocumentServiceProtocol.swift:44-51`,
which places a `public extension DocumentServiceProtocol` default impl
directly under the protocol.

Exact shape:

```swift
public extension GiniCaptureResultsDelegate {
    /// Default no-op — restores source compatibility for integrators
    /// upgrading from 4.4.x to 4.5.1 without adopting the Schedule
    /// Payment flow. Integrators SHOULD override this method to route
    /// the user to their own scheduled-transfer screen, carrying the
    /// extractions over from `result`. Not emitted into the
    /// Objective-C protocol descriptor — Objective-C conformers must
    /// still implement it themselves.
    func giniCaptureDidRequestSchedulePayment(result: AnalysisResult) {
        // No-op.
    }
}
```

### 2. Callers that remain unchanged

The single production call site is inside
`GiniBankNetworkingScreenApiCoordinator` (the
`GiniBankSDK`-side subclass that specialises the callback for the bank
flow). It calls `resultsDelegate?.giniCaptureDidRequestSchedulePayment(result:)`
on the optional weak reference — the default implementation transparently
handles the case where the integrator hasn't overridden it. No caller
change needed.

The two example apps and `MockCaptureResultsDelegate` all implement the
method explicitly (verified by grep in step 2) and continue to receive
the callback, unchanged.

### 3. Version bumps

Three files, one-line changes each:

- `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/GiniCaptureSDKVersion.swift`
  — change `"4.4.0"` → `"4.5.1"`.
- `BankSDK/GiniBankSDK/Sources/GiniBankSDK/GiniBankSDKVersion.swift`
  — change `"4.4.0"` → `"4.5.1"`.
- `BankSDK/GiniBankSDK/Package-release.swift` line 19 — change
  `.package(name: "GiniCaptureSDK", url: "https://github.com/gini/capture-sdk-ios.git", .exact("4.4.0"))`
  → `.exact("4.5.1")`.

### 4. Release note snippet (for the release-notes step, not this PR)

The 4.5.1 note (to be drafted separately via `/gini-release-notes`) must
record:

- What it fixes: source compatibility for integrators upgrading 4.4.x →
  4.5.x. `GiniCaptureResultsDelegate.giniCaptureDidRequestSchedulePayment(result:)`
  now has a default no-op implementation.
- Behavioural nuance: integrators who want to handle Schedule Payment
  MUST still implement the method — the default silently does nothing.
- Objective-C nuance: the default impl is Swift-only; Objective-C
  conformers still get a "does not conform" error unless they implement
  the method themselves.
- Confluence migration page needs a follow-up note that jumping
  4.4.x → 4.5.1 no longer requires a code change.

### 5. Confidence

All claims above are HIGH confidence — read against
`GiniNetworkingScreenAPICoordinator.swift`, `DocumentServiceProtocol.swift`,
`GiniCaptureSDKVersion.swift`, `GiniBankSDKVersion.swift`,
`Package-release.swift`, `MockCaptureResultsDelegate.swift`, and the
`grep` sweep across `GiniCaptureResultsDelegate` conformers in this
session.

## Test plan

One new focused XCTest class in `GiniCaptureSDK`, one existing suite
kept green.

### New: `GiniCaptureResultsDelegateDefaultImplTests`

- Location:
  `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/GiniCaptureResultsDelegateDefaultImplTests.swift`
- Framework: **XCTest** — matches the module's dominant framework and
  every neighboring test file in
  `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/` (see
  `GiniScreenAPICoordinatorTests.swift`, `CameraViewControllerTests.swift`,
  etc.). Do NOT introduce Swift Testing here — the module hasn't adopted
  it yet.
- Rough size: 2 tests (this is a focused compatibility bolt, not a
  multi-path component).

Tests (each mapped to a MUST requirement):

- `test_defaultImplementation_compilesOnConformer_withOnlyPre45Methods`
  → R1: declares a private test class inside the test file that
  conforms to `GiniCaptureResultsDelegate` and implements ONLY
  `giniCaptureAnalysisDidFinishWith(result:)`,
  `giniCaptureDidCancelAnalysis()`, and `giniCaptureDidEnterManually()`.
  The test asserts the class instantiates and can be typed as
  `GiniCaptureResultsDelegate`. The compile itself IS the assertion for
  R1 (if the default impl regresses, this file won't build). Include an
  explicit `XCTAssertTrue(true)` with a comment saying so.
- `test_defaultImplementation_isNoOp_whenNotOverridden` → R2: on the
  same private class from the first test, calls
  `sut.giniCaptureDidRequestSchedulePayment(result: <fixture>)`
  directly and asserts that no observable side effect occurred (no
  crash, no state change on an added `private(set) var
  didReceiveSchedule: Bool` — which stays `false`). Uses a synthetic
  `AnalysisResult` — reuse the fixture-construction pattern already used
  in `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/` sibling
  files; if none exists trivially, build a minimal `AnalysisResult` with
  `extractions: [:], lineItems: nil, images: [], document: nil, candidates: [:]`.

Fixture reuse: no JSON fixture needed — the `AnalysisResult` is
constructed inline; the requirement is about method dispatch, not
extraction content. No new file under `Tests/GiniCaptureSDKTests/Resources/`.

### Existing (kept green): `NetworkingScreenApiCoordinatorTests+SchedulePaymentHint`

- Location:
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+SchedulePaymentHint.swift`
- Framework: **XCTest** (matches surrounding `GiniBankSDKTests`).
- Requirement mapping: R3 — the existing suite already exercises the
  flow where `MockCaptureResultsDelegate` (which DOES implement the
  method) receives the callback. It must continue to pass unchanged
  after the extension is added. No new tests needed here — the
  regression is caught by simply re-running the suite.

### Requirement coverage matrix

- R1 → `test_defaultImplementation_compilesOnConformer_withOnlyPre45Methods`
- R2 → `test_defaultImplementation_isNoOp_whenNotOverridden`
- R3 → existing `NetworkingScreenApiCoordinatorTests+SchedulePaymentHint`
  suite (unchanged)
- R4, R5 → verified via `git diff` review + CI (no test needed —
  version-constant changes are single-line invariants with no runtime
  branch)
- R6 → code review (comment presence)
- R7 → spec + release note; no automated test (Objective-C conformance
  is an out-of-scope surface for the hotfix)

### Not tested

- The 4.4.x → 4.5.1 SPM bump path for external integrators is not
  simulated in this repo — R1's compile-time evidence inside
  `GiniCaptureSDK`'s test target is the closest faithful proxy, and the
  release note carries the human-visible confirmation.
- Objective-C conformance is deliberately not tested (see R7).
- The Schedule Payment UI flow itself (payment-hint bottom sheet CTA →
  delegate call) is already covered by `PP-3263`'s existing tests and
  is not re-tested here.
- Manual QA: install `4.5.1` in a demo integrator project that only
  implements the pre-4.5 delegate methods and confirm the build
  succeeds.

## Out of scope

- Option B from the ticket — sibling `GiniCaptureScheduleDelegate`
  protocol threaded through `GiniBank.viewController(withClient:...)`.
  This is a 4.6 conversation.
- Any version bump for `GiniBankAPILibrary`, `GiniUtilites`,
  `GiniHealthAPILibrary`, `GiniHealthSDK`, or `GiniInternalPaymentSDK`.
- Any change to the payment-hint bottom sheet, its Schedule Payment
  state, or the extraction shape carried by `AnalysisResult`.
- Making `giniCaptureDidRequestSchedulePayment(result:)` `@objc optional`
  — that is a source-breaking reshape (it changes the requirement's
  ABI-visible optionality flag and forces every conformer to guard with
  `responds(to:)` checks). Not appropriate for a patch.
- Updating the Confluence migration page — handled outside this PR by
  the release-notes step, blocked separately on the Atlassian connector
  re-consent for Confluence write.
- The release-notes drafting itself — handled by
  `/gini-release-notes` after this spec ships.

## Open questions

None. The ticket answers everything the spec needs and no LOW-confidence
markers remain.

## Implementation plan

- [x] 1. Add `GiniCaptureResultsDelegateDefaultImplTests.swift` under
      `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/` — declares a
      private class conforming to `GiniCaptureResultsDelegate` with only
      the three pre-4.5 methods, exercises the default no-op
      implementation. Written first; fails to compile until step 2 lands.
      (requirements R1, R2)
- [x] 2. Append `public extension GiniCaptureResultsDelegate` with a
      default no-op `giniCaptureDidRequestSchedulePayment(result:)` in
      `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Networking/GiniNetworkingScreenAPICoordinator.swift`
      under the protocol declaration (currently ends line 45), carrying
      the `///` comment required by R6. Also drop `@objc` from the
      protocol declaration itself — see "Implementation note" above.
      (requirements R1, R2, R6, R7)
- [x] 3. Bump `GiniCaptureSDKVersion` string from `"4.5.0"` to `"4.5.1"`
      in
      `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/GiniCaptureSDKVersion.swift`.
      Spec drift note: it currently reads `"4.5.0"`, not `"4.4.0"` — the
      target `"4.5.1"` is unchanged. (requirement R4)
- [x] 4. Bump `GiniBankSDKVersion` string from `"4.5.0"` to `"4.5.1"` in
      `BankSDK/GiniBankSDK/Sources/GiniBankSDK/GiniBankSDKVersion.swift`,
      and bump the `GiniCaptureSDK` pin in
      `BankSDK/GiniBankSDK/Package-release.swift` from `.exact("4.5.0")`
      to `.exact("4.5.1")`. Spec drift note: both currently read
      `"4.5.0"`, not `"4.4.0"`. (requirements R4, R5)
- [x] 5. Re-run the existing
      `NetworkingScreenApiCoordinatorTests+SchedulePaymentHint` suite
      unchanged — it verifies the overriding path continues to fire.
      (requirement R3)
