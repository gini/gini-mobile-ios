# PP-2298: [iOS] Cleanup code related to return reasons after dropping the support for it

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-2298

## Problem

The "Return Reasons" feature — a picker asking why a user deselected a
line item in the Digital Invoice / Return Assistant — was announced as
"no longer supported" in a previous release. The runtime path is already
dead: `GiniBankConfiguration.enableReturnReasons` is
`internal let ... = false` and the UI branch that would present the
picker (`DigitalInvoiceViewController.swift:409`) is gated on that flag,
so it never runs.

What remains is *code*: the still-`public` `ReturnReason` class on
`GiniBankAPILibrary`, the `public var returnReasons` on `ExtractionResult`,
JSON decoding of the field, internal `GiniBankSDK` scaffolding
(`DeselectLineItemActionSheet`, the `.deselected(reason:)` associated value,
`DigitalInvoice.returnReasons`), localization strings, tests, an
example-app Settings toggle, and every call site that passes
`returnReasons: nil` / `[]` through the constructor. This cleanup removes
all of it in one PR — the deprecation window ran its course in earlier
releases; there is nothing left to warn.

## Requirements

R1 (MUST, entry): Given an integrator building against the new
`GiniBankAPILibrary`, when they compile code that references
`ReturnReason` or `ExtractionResult.returnReasons`, then compilation
fails with `Cannot find type 'ReturnReason' in scope` / `Value of type
'ExtractionResult' has no member 'returnReasons'`. Source-breaking is the
intended contract of this release.

R2 (MUST, entry): Given an integrator calling
`ExtractionResult(extractions:lineItems:returnReasons:skontoDiscounts:crossBorderPayment:candidates:)`,
when they omit the `returnReasons:` argument entirely, then compilation
succeeds. When they still pass `returnReasons:`, then compilation fails.
The parameter is removed from the initializer, not defaulted-away.

R3 (MUST, happy): Given a document returning JSON with a top-level
`returnReasons` array, when `GiniBankAPILibrary`'s
`ExtractionsContainer.init(from:)` decodes the payload, then decoding
succeeds and the `returnReasons` field is not exposed to callers because
the internal property is removed. The `returnReasons` JSON key is silently
ignored (Swift's `Decodable` does not error on unknown keys by default).

R4 (MUST, happy): Given the Return Assistant / Digital Invoice flow is
enabled by an integrator, when the user deselects a line item, then the
line item's `selectedState` becomes `.deselected` (no associated value)
and no action sheet is presented. `DigitalInvoiceViewController.swift`
takes the else-branch at line 409 as the only path.

R5 (MUST, happy): Given a credit-note document flowing through
`GiniBankNetworkingScreenApiCoordinator.excludingCompoundExtractions(from:)`,
when it strips compound extractions, then the returned `ExtractionResult`
carries `lineItems == nil` and `skontoDiscounts == nil` and no
`returnReasons` field exists. The delivered result still has `amountToPay`
removed as before.

R6 (MUST, happy): Given `GiniBankSDK` initializes analytics with
`initializeAnalytics(with:)`, when it sets user properties, then the
`.returnReasonsEnabled` key is not sent. The other user properties
(`.returnAssistantEnabled`, `.bankSDKVersion`, `.instantPaymentEnabled`)
remain unchanged.

R7 (MUST, entry): Given a QA operator on `GiniBankSDKExample`, when they
open the Settings screen, then no "Enable Return Reasons" row is
visible. The row, its `SettingsOption.enableReturnReasons` case, and the
associated `SettingsViewModelTests` assertions no longer exist.

R8 (MUST, error): Given a build of `GiniBankSDK` / `GiniBankAPILibrary`
after the change, when `make lint scheme=GiniBankSDK` and
`make lint scheme=GiniBankAPILibrary` run, then both complete without
errors and without new warnings originating from unused-code left behind
by the removal (dead `ReturnReason` symbols, orphaned localization keys,
etc.).

R9 (SHOULD, entry): Given a translator maintaining
`Sources/GiniBankSDK/Resources/{de,en}.lproj/Localizable.strings`, when
they inspect the file after this PR, then the keys
`ginibank.digitalinvoice.deselectreasonactionsheet.message` and
`ginibank.digitalinvoice.deselectreasonactionsheet.action.cancel` are
absent. Both locales are updated in lock-step.

## Affected modules

- **`GiniBankAPILibrary`** — customer-facing API library, iOS 15+
  minimum. Removes the public `ReturnReason` class and the
  `returnReasons` field / initializer parameter on `ExtractionResult`,
  plus the wire decoding in `ExtractionsContainer`. Source-breaking.
- **`GiniBankSDK`** — customer-facing SDK, iOS 15+ minimum. Removes
  `GiniBankConfiguration.enableReturnReasons` stub, `DigitalInvoice.returnReasons`,
  `DigitalInvoice.SelectedState.deselected(reason:)` associated value,
  `DeselectLineItemActionSheet`, the return-reasons branch in
  `DigitalInvoiceViewController`, and the analytics user property in
  `GiniBankNetworkingScreenApiCoordinator`.
- **`GiniCaptureSDK`** — customer-facing SDK, iOS 15+ minimum. Removes the
  `.returnReasonsEnabled` case from `GiniAnalyticsUserProperty` and the
  `returnReasons: []` argument in
  `GiniNetworkingScreenAPICoordinator.swift:206`.
- **`GiniBankSDKExample`** — example app (not shipped). Removes the
  Settings toggle, its case, its tests, and the
  `returnReasons: []`/`nil` arguments in `ScreenAPICoordinator.swift`
  and `UITestMockBackend.swift`.
- **`GiniHealthSDKExample`** — example app (not shipped). Removes the
  `returnReasons: nil` argument in `HealthNetworkingService.swift:98`
  because `ExtractionResult`'s initializer no longer accepts it.

Downstream ripple: because `GiniBankAPILibrary` is a source-breaking
change and every SDK that transitively uses `ExtractionResult` must
recompile, all customer-facing SDKs downstream (`GiniCaptureSDK`,
`GiniBankSDK`) get a version bump too. See "Public API impact" and
"Open questions" for the version alignment call.

## Public API impact

Breaking. Three declarations disappear from customer-facing surface:

1. `BankAPILibrary/…/ReturnReason.swift` — entire file deleted.
   Removes `public class ReturnReason: NSObject`, `public init(id:localizedLabels:)`,
   `public let id: String`, `public let localizedLabels: [String: String]`,
   `public override func isEqual(_:)`, `public override var debugDescription: String`,
   `public convenience init(from decoder:) throws`. `@objcMembers`
   attribute goes with them.
2. `BankAPILibrary/…/ExtractionResult.swift`:
   - `public var returnReasons: [ReturnReason]?` — property removed.
   - `public init(extractions:lineItems:returnReasons:skontoDiscounts:crossBorderPayment:candidates:)`
     — the `returnReasons:` parameter is removed. Signature becomes
     `public init(extractions:lineItems:skontoDiscounts:crossBorderPayment:candidates:)`.
   - `convenience init(extractionsContainer:)` — internal, adjusted to
     match. Not part of the customer surface but noted for completeness.
3. `GiniAnalyticsUserProperty.swift` — the `returnReasonsEnabled` enum
   case is `internal`; removing it is not customer-facing.

No new public declaration. No `@available(*, deprecated, …)` layer
because the deprecation communication ran in the previous release and
the `enableReturnReasons` handle was already reduced to an
`internal let` stub.

**No CI check covers this API surface** — per
`.claude/skills/gini-review/platform.md` §9, iOS has no `.api` snapshot
or `swift-api-digester` gate. The reviewer verifies by running:

```bash
BASE=$(git merge-base HEAD origin/main)
git diff "$BASE"...HEAD -- '*/Sources/*.swift' | grep -nE '^-\s*(public|open)\s'
```

Every hit in that output is intentional in this PR.

## Technical conventions

Grounded in the modules actually touched — every rule below is enforced
by **gini-orchestrator** per `.claude/rules/mandatory-rules.md` unless
otherwise noted; do not restate the rule text.

1. **Language and access control** — Swift, `internal` by default. Every
   symbol added is `internal`; the only surface change is *deletion* of
   existing `public` symbols. No `@available(*, deprecated, …)`
   attribute added (the deprecation window already ran). Doc-comment
   style unchanged; no new declarations require a `/** */` block.
2. **UI** — none. This PR deletes UI (`DeselectLineItemActionSheet`); it
   creates no new views. No SwiftUI vs UIKit call.
3. **Architecture** — none. No new coordinator, view model, or delegate.
   The touched controller `DigitalInvoiceViewController` stays as-is
   apart from the branch pruning at line 409.
4. **Wiring** — none. No new DI. No new builder. No new async work.
5. **Localization** — remove keys from
   `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Resources/de.lproj/Localizable.strings`
   and `.../en.lproj/Localizable.strings`. Also update the commented-out
   entries in `BankSDK/GiniBankSDKExample/GiniBankSDKExample/{de,en}.lproj/LocalizableCustomName.strings`
   (they're commented out already, but keep the file tidy).
6. **Quality gates** — `make lint scheme=GiniBankAPILibrary`,
   `make lint scheme=GiniCaptureSDK`, `make lint scheme=GiniBankSDK`
   clean; run `bundle exec fastlane run_unit_tests` per
   `AGENTS.md`. Note the local-vs-CI simulator drift called out in
   `platform.md`. Multi-parameter formatting rule per
   `.claude/rules/mandatory-rules.md` — most touched initializers are
   already one-parameter-per-line; keep them that way after removing
   `returnReasons:`.

## Design

The change is a **pure deletion pass** — no new file, no new type. The
only novel behavior is that `SelectedState` collapses from an enum with
an associated value to one without. Ordered by module, from bottom to
top of the SDK dependency chain (`CLAUDE.md` §"SDK Dependency Graph"):

**1. `GiniBankAPILibrary` (the leaf; break here first, propagate up)**
   - Delete
     `BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/Documents/ReturnReason.swift`
     entirely.
   - `BankAPILibrary/…/ExtractionResult.swift`: remove the property (line 27),
     the `returnReasons:` parameter and its assignment (lines 46, 52),
     and the same argument in `convenience init(extractionsContainer:)`
     (line 64).
   - `BankAPILibrary/…/ExtractionsContainer.swift`: remove `let returnReasons`
     (line 13), the `.returnReasons` coding key (line 19), and the
     `decodeIfPresent` line (line 45).

**2. `GiniCaptureSDK`**
   - `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Tracking/GiniAnalyticsUserProperty.swift`:
     remove `case returnReasonsEnabled = "return_reasons_enabled"` at
     line 17.
   - `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Networking/GiniNetworkingScreenAPICoordinator.swift:206`:
     drop the `returnReasons: []` argument in the `ExtractionResult(...)`
     call. Signature match.

**3. `GiniBankSDK`**
   - `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankConfiguration.swift:346`:
     delete the `internal let enableReturnReasons: Bool = false` stub
     and its doc comment.
   - `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift`:
     drop `returnReasons: []` at line 348, remove
     `.returnReasonsEnabled: giniBankConfiguration.enableReturnReasons,`
     from the analytics dictionary at line 461, remove
     `returnReasons: extractionResult.returnReasons,` at line 923, remove
     `returnReasons: nil,` at line 935, and update the doc comment at
     line 930 / 942 to drop the "and `returnReasons`" clause.
   - `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/ReturnAssistant/DigitalInvoice/DigitalInvoiceViewController.swift`:
     at lines 409-417 keep only the else-branch (unconditional
     `.deselected` and `isLineItemSelected = false`); delete the
     `presentReturnReasonActionSheet(for:source:with:isLineItemSelected:)`
     method at lines 437-459 entirely.
   - `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/ReturnAssistant/DigitalInvoice/Models/LineItem.swift`:
     change `.deselected(reason: ReturnReason?)` to `case deselected` at
     line 14. Remove the `switch` arm at lines 107-115 that appended a
     `returnReason` extraction. Remove the whole `extension ReturnReason
     { … }` at lines 132-137 (the `labelInLocalLanguageOrGerman` helper
     has no remaining caller).
   - `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/ReturnAssistant/DigitalInvoice/Models/DigitalInvoice.swift`:
     remove the `returnReasons` property at line 20; remove the
     assignment at line 159; drop the `returnReasons:` argument from
     both `ExtractionResult(...)` returns at lines 171 and 187.
   - Delete
     `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/ReturnAssistant/DigitalInvoice/Components/DeselectLineItemActionSheet.swift`
     entirely.
   - Remove the two localization keys in
     `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Resources/de.lproj/Localizable.strings`
     (lines 36-37) and
     `.../en.lproj/Localizable.strings` (lines 41-42).

**4. Example apps (not shipped)**
   - `BankSDK/GiniBankSDKExample/GiniBankSDKExample/Screen API/ScreenAPICoordinator.swift:366`:
     drop `returnReasons: []`.
   - `BankSDK/GiniBankSDKExample/GiniBankSDKExample/UITestSupport/UITestMockBackend.swift:232`:
     drop `returnReasons: []`.
   - `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/HealthNetworkingService.swift:98`:
     drop `returnReasons: nil`.
   - Settings screen: locate `SettingsOption.enableReturnReasons` in the
     example's Settings enum (referenced by `SettingsViewModelTests.swift`
     lines 1810, 1816, 1829, 1835). Remove the case, its row/section
     wiring, and any localization it uses (confidence: LOW — file path
     for the `SettingsOption` enum not verified this session; see Open
     questions).
   - Delete the assignment `configuration.enableReturnReasons = true` at
     `SettingsViewModelTests.swift:48` (currently uncompilable against
     the source-level `internal let`, which suggests this test file is
     either excluded from the build or the assignment is dead code — the
     removal makes the file compilable regardless).
   - `BankSDK/GiniBankSDKExample/GiniBankSDKExample/{de,en}.lproj/LocalizableCustomName.strings`:
     remove the commented-out `deselectreasonactionsheet` lines
     (lines 126-127 / 130-131). Housekeeping only.

## Test plan

All existing tests are being **modified or deleted** — no new
functionality means no new test. Every MUST requirement maps to an
existing test that either updates or disappears.

| Requirement | Test class · framework | Change |
|---|---|---|
| R1, R2 (public API contract) | *(no test — verified by compile of the module and its consumers)* | The `make lint scheme=…` and `xcodebuild ... test` runs are the compile-time proof. There is no source-of-truth API snapshot to update. |
| R3 (wire decoding tolerates the key) | `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/ExtractionsContainerTest.swift` · **XCTest** (extends `final class ExtractionsContainerTest: XCTestCase`) | Delete the `XCTAssertNil(container.returnReasons)` assertion at line 66. Delete the whole test that constructs a `ReturnReason` and asserts equality (lines 114-117). Roughly 2 lines and 4 lines removed. |
| R4 (UI branch collapses) | *(no test — `DigitalInvoiceViewController` is a UIKit VC and ViewControllers are the weakest coverage area per `platform.md` §6; adding one for a deletion is not in scope)* | Manual QA on the Return Assistant flow (see "Not tested"). |
| R5 (credit-note filter unchanged apart from `returnReasons`) | `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests.swift` · **XCTest** (`final class NetworkingScreenApiCoordinatorTests: XCTestCase`) | Delete `testExcludingCompoundExtractionsRemovesLineItemsSkontoDiscountsAndReturnReasons` at line 441 (it asserts the removed field is nil). Update the two other tests at lines 523 and 566 to drop `createMockReturnReasons()` arguments and the `XCTAssertNil(...returnReasons...)` assertions. Delete `createMockReturnReasons()` in `+Helpers.swift` (line 131). Total change: 1 test deleted, 2 updated, 1 helper deleted. Test count in the class stays roughly equal minus one. |
| R6 (analytics property gone) | *(no test — analytics user-property setup is a value-in / value-out call with no assertion suite today)* | Covered by the compile of `GiniBankSDK` once the enum case is removed. |
| R7 (Settings toggle gone) | `BankSDK/GiniBankSDKExample/Tests/SettingsViewModelTests.swift` · **XCTest** | Delete `testReturnReasonsDigitalInvoiceDialogSwitchOn` (line 1809-1826) and `testReturnReasonsDigitalInvoiceDialogSwitchOff` (line 1828-1845). Delete the setUp assignment at line 48. Delete any `SettingsOption.enableReturnReasons` case references in the tests (lines 1810, 1816, 1829, 1835). |
| R8 (lint clean) | *(build gate, not a test — `make lint scheme=<Scheme>` per `AGENTS.md`)* | |
| R9 (localization keys removed) | *(no automated test; grep verifies)* | Manual verification: `grep -rn "deselectreasonactionsheet" BankSDK/GiniBankSDK/Sources` returns no matches after the PR. |

`GiniBankConfigurationTests.swift:54` (**Swift Testing**, `@Suite` for
`GiniBankConfiguration Feature Flags`) — delete the one `#expect` that
asserts `enableReturnReasons` default `false`. No new tests here — the
property is gone.

**Test framework choice** per `platform.md` §6: match neighboring files.
`ExtractionsContainerTest.swift`, `NetworkingScreenApiCoordinatorTests.swift`,
and `SettingsViewModelTests.swift` are XCTest — keep them XCTest.
`GiniBankConfigurationTests.swift` is Swift Testing — keep it Swift
Testing. No file's framework flips.

### Not tested

- **Manual QA of the Return Assistant flow.** With
  `returnAssistantEnabled: true`, capturing an invoice with multiple
  line items, deselecting one, and confirming: the action sheet no
  longer appears; the item is deselected immediately; the resulting
  `ExtractionResult` on the delegate callback still contains
  everything the host app expects (line items, skonto, amounts).
  Test on `iPhone 17 / iOS 26.2` (CI parity per `platform.md` §6) and
  on `iPhone 15 Pro / iOS 17.2` (`make lint` parity).
- **Wire-level: server payload with `returnReasons` present.** The
  cleanup relies on Swift `Decodable`'s tolerant behavior for unknown
  keys. Confirmed against `ExtractionsContainer.init(from:)` code —
  the decoder uses a `CodingKeys` enum and any key not in it is
  silently dropped. No unit test change captures this; integration
  test against the real API (needs `TEST_CLIENT_ID` /
  `TEST_CLIENT_SECRET`) implicitly covers it.
- **Downstream ripple compile.** `bundle exec fastlane
  run_unit_tests` covers every module's test target; a green run is
  the proof that no example app or downstream consumer left a stray
  reference.

## Out of scope

- **Deprecation for one release then removal.** The user answered
  "Full internal removal now" — this ticket is the removal PR, not a
  two-step deprecate-then-delete.
- **`@objc` compatibility layer.** The old `ReturnReason` was
  `@objcMembers` for Objective-C interop with integrators. Removing it
  is a break for any Obj-C integrator; that is accepted by the same
  answer.
- **Android mirror (PP-3230).** Separate ticket, separate repo. This
  spec does not coordinate the two releases beyond noting the mirror
  exists.
- **Migration guide entry.** User answered "changelog / release notes
  only". No new sections added to
  `BankAPILibrary/GiniBankAPILibrary/Documentation/source/Migration guide.md`
  or any other doc file.
- **Return Assistant / Digital Invoice feature itself.** Only the
  reasons-picker sub-feature is removed. The rest of the flow —
  selecting/deselecting line items, skonto, addons — stays intact.
- **Splitting into per-module PRs.** One PR spans `GiniBankAPILibrary`,
  `GiniCaptureSDK`, `GiniBankSDK`, plus both example apps, because a
  source-breaking change to `GiniBankAPILibrary` cannot compile
  downstream until every consumer is fixed in the same commit.

## Open questions

None — target release version deferred to a separate release ticket per
user answer at `/gini-build` (`GiniBank*Version.swift` and every
`Package-release.swift` `.exact()` pin left untouched);
`SettingsOption.enableReturnReasons` confirmed absent from
`SettingsViewController+SwitchOptionModel.swift` (the Settings row had
already been removed in an earlier PR); `SettingsViewModelTests.swift`
confirmed as an orphan not referenced by
`BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj/project.pbxproj`,
so the stale `configuration.enableReturnReasons = true` line at :48 and
the two `testReturnReasonsDigitalInvoiceDialogSwitch{On,Off}` blocks
were stripped for future compilability of the orphan file.

## Implementation plan

Ordered so the compile stays green step-by-step: modify tests alongside sources within each module before moving to the next dependent module. Version bump is explicitly **out of scope** per user decision — a separate release ticket owns `GiniBank*Version.swift` and `Package-release.swift` updates.

- [x] 1. **GiniBankAPILibrary — remove `ReturnReason` type and `ExtractionResult.returnReasons`.** Delete `BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/Documents/ReturnReason.swift` entirely. In `ExtractionResult.swift` remove the `returnReasons` property, initializer parameter, assignment, and the argument in `convenience init(extractionsContainer:)`. In `ExtractionsContainer.swift` remove the `returnReasons` stored property, the `.returnReasons` `CodingKeys` case, and the `decodeIfPresent` line. Update `ExtractionsContainerTest.swift`: delete the `XCTAssertNil(container.returnReasons)` line and the `ReturnReason` block at lines 114-117. (R1, R2, R3)
- [x] 2. **GiniCaptureSDK — remove analytics case and internal caller.** In `GiniAnalyticsUserProperty.swift` remove `case returnReasonsEnabled = "return_reasons_enabled"`. In `Networking/GiniNetworkingScreenAPICoordinator.swift` drop the `returnReasons: []` argument in the `ExtractionResult(...)` call around line 206. (R6 partial for Capture-side wiring)
- [x] 3. **GiniBankSDK sources — remove all return-reasons wiring.** In `GiniBankConfiguration.swift` delete the `internal let enableReturnReasons: Bool = false` stub and its doc comment. In `GiniBankNetworkingScreenApiCoordinator.swift` drop the `returnReasons: []` argument at ~line 348, remove `.returnReasonsEnabled: giniBankConfiguration.enableReturnReasons,` from the analytics dictionary at ~line 461, drop `returnReasons: extractionResult.returnReasons,` at ~line 923, drop `returnReasons: nil,` at ~line 935, and prune the "and `returnReasons`" wording in the doc comments at ~lines 930 and 942. (R5 partial, R6)
- [x] 4. **GiniBankSDK Digital Invoice — collapse `SelectedState` and prune UI branch.** In `LineItem.swift` change `case deselected(reason: ReturnReason?)` to `case deselected`, remove the associated-value `switch` arm that appended the `"returnReason"` extraction (lines 106-116), and delete the `extension ReturnReason { … }` at the end of the file. In `DigitalInvoice.swift` remove the `returnReasons` stored property, the `returnReasons = extractionResult.returnReasons` assignment, and the `returnReasons:` argument in both `ExtractionResult(...)` return sites. In `DigitalInvoiceViewController.swift` collapse the guard at line 409 to always take the else-branch (unconditional `.deselected` + `isLineItemSelected = false`) and delete the `presentReturnReasonActionSheet(for:source:with:isLineItemSelected:)` method. Delete `DeselectLineItemActionSheet.swift`. (R4)
- [x] 5. **GiniBankSDK localization — drop the two orphan keys in both locales.** Remove `ginibank.digitalinvoice.deselectreasonactionsheet.message` and `ginibank.digitalinvoice.deselectreasonactionsheet.action.cancel` from `Sources/GiniBankSDK/Resources/{de,en}.lproj/Localizable.strings`. Remove the four commented-out `deselectreasonactionsheet` lines in `BankSDK/GiniBankSDKExample/GiniBankSDKExample/{de,en}.lproj/LocalizableCustomName.strings`. (R9)
- [x] 6. **GiniBankSDK tests — update assertions and helpers.** In `NetworkingScreenApiCoordinatorTests+Helpers.swift`: drop the `returnReasons: [ReturnReason] = []` parameter from `createExtractionResult` and its use in the `ExtractionResult(...)` call, and delete `createMockReturnReasons()`. In `NetworkingScreenApiCoordinatorTests.swift`: rename `testExcludingCompoundExtractionsRemovesLineItemsSkontoDiscountsAndReturnReasons` to `testExcludingCompoundExtractionsRemovesLineItemsAndSkontoDiscounts`, drop the `returnReasons: createMockReturnReasons()` argument and the `XCTAssertNil(result.returnReasons, ...)` assertion — keep the `lineItems == nil` / `skontoDiscounts == nil` assertions (refinement of the spec: those assertions have no other coverage). In the two tests at lines 523 and 566 drop the `returnReasons: createMockReturnReasons()` arguments and the `XCTAssertNil(...returnReasons...)` assertions. In `GiniBankConfigurationTests.swift`: delete the `#expect(!configuration.enableReturnReasons, …)` line. (Tests for R3, R5, R6)
- [x] 7. **GiniBankSDKExample — drop `returnReasons` arguments and clean stale test file.** Drop `returnReasons: []` from `Screen API/ScreenAPICoordinator.swift` and `UITestSupport/UITestMockBackend.swift`. In `Tests/SettingsViewModelTests.swift` (confirmed orphan — not referenced by any target in `GiniBankSDKExample.xcodeproj/project.pbxproj`; that's why the impossible `configuration.enableReturnReasons = true` assignment doesn't fail CI): delete the setUp assignment at line 48 and both `testReturnReasonsDigitalInvoiceDialogSwitch{On,Off}` tests + their `// MARK: - ReturnReasonsDigitalInvoiceDialog` header. `SettingsOption` / `OptionType.enableReturnReasons` does **not** exist in `SettingsViewController+SwitchOptionModel.swift` — the Settings row was already removed. (R7)
- [x] 8. **GiniHealthSDKExample — drop `returnReasons: nil` argument.** In `HealthNetworkingService.swift` drop the `returnReasons: nil` from the `GiniBankAPILibrary.ExtractionResult(...)` call at line 98.
- [x] 9. **Verify.** Run `make lint scheme=GiniBankAPILibrary`, `make lint scheme=GiniCaptureSDK`, `make lint scheme=GiniBankSDK`, then the three `xcodebuild ... test` commands (BankAPILibrary, CaptureSDK, BankSDK). Grep the repo for `returnReasons`, `ReturnReason`, `enableReturnReasons`, `deselectreasonactionsheet`, `returnReasonsEnabled` — every remaining match should be intentional (e.g. release notes, changelog). (R8, R9)
