# PP-2263: [iOS] Remove compound extractions for Credit Note feature

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-2263

## Problem

When the Gini Bank API marks an analyzed document as a credit note
(`businessDocType == "creditnote"`), the iOS SDK already suppresses the
Return Assistant and Skonto screens *when the credit-note warning sheet is
shown*, and removes `amountToPay` from the delivered extractions. However,
the compound extractions (`lineItems`, `skontoDiscounts`) and
`returnReasons` are still delivered to the host app via `AnalysisResult`,
still stored on `giniBankConfiguration.lineItems` / `.skontoDiscounts`, and
a Skonto transfer summary is still sent. (When the credit-note hint is
disabled — globally or by client configuration — the document flows through
the normal path; that path is deliberately out of scope here.)

Per the decision in PP-2257 (comment by Demis, 2026-01-09), compound
extractions must be removed for credit notes on iOS, matching the Android
implementation where removing the compound extractions is what prevents the
RA/Skonto screens from showing.

Decision from clarifying questions (this session, revised): stripping
applies only when the document is a credit note **and** the credit-note
hint is enabled (global `creditNoteHintEnabled` AND client configuration
`creditNoteHintEnabled` both true) — i.e. exactly when the credit-note
warning sheet is shown, matching the PP-2257 option "remove the compound
extractions if we show the credit note warning". With the hint disabled,
the flow is unchanged (compound extractions delivered, RA/Skonto screens
can show). `amountToPay` removal keeps its current trigger (only on
"Proceed" from the warning sheet) — that behavior is explicitly unchanged.

## Requirements

- R1 (MUST, entry): Given the SDK analyzes a document, the extraction
  result contains an extraction named `businessDocType` with value
  `creditnote` (case-insensitive), and the credit-note hint is enabled
  (global `creditNoteHintEnabled` AND client configuration
  `creditNoteHintEnabled` both true), when
  `GiniBankNetworkingScreenApiCoordinator.presentNextScreen(extractionResult:delegate:)`
  runs, then the credit-note warning sheet is shown and the extraction
  result used for subsequent delivery has `lineItems == nil`,
  `skontoDiscounts == nil`, and `returnReasons == nil`, while `extractions`
  and `candidates` are unchanged.
- R2 (MUST, happy): Given a credit-note extraction result (hint enabled)
  that also contains non-empty `lineItems` and `skontoDiscounts`, and
  `returnAssistantEnabled` and `skontoEnabled` are both true, when the user
  taps "Proceed" on the warning sheet, then neither the Return Assistant
  (digital invoice) screen nor the Skonto screen is presented, and the
  `AnalysisResult` passed to
  `GiniCaptureResultsDelegate.giniCaptureAnalysisDidFinishWith(result:)` has
  `lineItems == nil` and `skontoDiscounts == nil`.
- R3 (MUST, happy): Given a credit-note document with the credit-note hint
  enabled, when the user taps "Proceed" on the credit-note warning sheet,
  then the delivered extractions additionally exclude `amountToPay`
  (existing behavior, must not regress).
- R4 (MUST, error/negative): Given a credit-note document with the
  credit-note hint disabled (either flag false), when analysis completes,
  then no warning sheet is shown and the flow is byte-for-byte today's
  behavior: `amountToPay`, `lineItems`, `skontoDiscounts`, and
  `returnReasons` are all delivered unmodified, and the Return Assistant /
  Skonto screens can show per their own gates.
- R5 (MUST, happy): Given a credit-note extraction result (hint enabled)
  with `skontoDiscounts` present, when the result is delivered after
  "Proceed", then `giniBankConfiguration.skontoDiscounts` and
  `giniBankConfiguration.lineItems` are not populated with the stripped
  values and no Skonto transfer summary
  (`sendTransferSummaryWithSkonto`) is sent (follows from R1: the delivery
  code reads these fields off the already-stripped result).
- R6 (MUST, error/negative): Given an extraction result whose
  `businessDocType` is absent, empty, or any value other than `creditnote`
  (case-insensitive), when `presentNextScreen` runs, then `lineItems`,
  `skontoDiscounts`, and `returnReasons` pass through unmodified and the
  Return Assistant / Skonto flows behave exactly as today.
- R7 (SHOULD, happy): Given a cross-border payment flow
  (`productTag == .cxExtractions`), when the extraction result arrives, then
  the existing cross-border early-return in `presentNextScreen` keeps
  precedence over credit-note handling (order of checks unchanged).

## Affected modules

- **GiniBankSDK** (iOS 15+) — only module with code changes:
  `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift`
  and its test file.
- **GiniBankAPILibrary**, **GiniCaptureSDK** — read-only dependencies
  (`ExtractionResult`, `CreditNoteWarningViewController`); no changes.

## Public API impact

None. All touched declarations are `internal`/`private` members of
`GiniBankNetworkingScreenApiCoordinator`
(`presentNextScreen`, `shouldProceedWithCreditNote`, `excludingAmountToPay`,
new helper). No `public`/`open` declaration changes, no signature changes to
`ExtractionResult` or `AnalysisResult`. Behavior change only in what data
those existing types carry for credit-note documents (documented in the
changelog, not an API break).

## Technical conventions

1. **Language/access**: Swift; new helper is `internal` (placed in the
   existing `internal extension GiniBankNetworkingScreenApiCoordinator`
   alongside `excludingAmountToPay`, `GiniBankNetworkingScreenApiCoordinator.swift:715-826`,
   so tests can call it via `@testable import`). Doc comments `/** ... */`
   on the new helper declaration, `///` for inline notes, per AGENTS.md.
2. **UI**: none — no new views, no color/font/spacing/localization work.
   `CreditNoteWarningViewController` (CaptureSDK) is reused untouched.
3. **Architecture**: no new coordinator/view model — this is flow logic
   inside the existing `GiniBankNetworkingScreenApiCoordinator` (matches the
   precedent of `excludingAmountToPay` and the `shouldShow*` helpers living
   there). MVVM+Coordinator unaffected.
4. **Wiring**: no DI changes; no new async — the touched methods are the
   existing `@MainActor` `presentNextScreen` path and pure synchronous
   helpers, matching neighboring code.
5. **Localization**: no new strings.
6. **Quality gates**: `make lint scheme=GiniBankSDK` clean; multi-parameter
   calls/inits use one-parameter-per-line per CLAUDE.md. Tests follow the
   module's dominant framework — **XCTest** (the file being extended,
   `NetworkingScreenApiCoordinatorTests.swift`, is XCTest).

## Design

All changes in
`BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift`.

1. **New helper** in the `internal extension` (next to
   `excludingAmountToPay(from:)`, currently lines 800-807):

   ```swift
   /**
    Returns a copy of the extraction result with the compound extractions
    removed (`lineItems`, `skontoDiscounts`) together with `returnReasons`.
    Used for credit-note documents (PP-2263): without compound extractions
    the Return Assistant and Skonto flows are never triggered and the host
    app never receives them.
    */
   func excludingCompoundExtractions(from extractionResult: ExtractionResult) -> ExtractionResult {
       ExtractionResult(extractions: extractionResult.extractions,
                        lineItems: nil,
                        returnReasons: nil,
                        skontoDiscounts: nil,
                        candidates: extractionResult.candidates)
   }
   ```

   Mirrors the `excludingAmountToPay` precedent (pure function, new
   instance). Like that precedent, `crossBorderPayment` is not carried over;
   that is safe because the cross-border flow returns before this point
   (R7). `ExtractionResult` init is
   `BankAPILibrary/.../Documents/ExtractionResult.swift:44-58`.

2. **Strip inside the credit-note branch of `presentNextScreen`**
   (currently lines 547-556). The branch condition stays
   `shouldProceedWithCreditNote(extractionResult)` (credit note detected
   AND hint enabled, line 577-579) — the gate is unchanged. Only the
   "Proceed" completion changes: chain the new helper with the existing
   `amountToPay` filter before delivery:

   ```swift
   if shouldProceedWithCreditNote(extractionResult) {
       presentDocumentMarkedAsCreditNoteBottomSheet(extractionResult) { [weak self] in
           guard let self else { return }
           let strippedResult = self.excludingCompoundExtractions(from: extractionResult)
           let filteredResult = self.excludingAmountToPay(from: strippedResult)
           self.presentTransactionDocsAlert(extractionResult: filteredResult,
                                            delegate: delegate)
       }
       return
   }
   ```

   Warn-and-proceed delivers extractions minus `amountToPay` minus
   compounds (R2, R3). Every other path — hint disabled, non-credit-note —
   is untouched code (R4, R6). With compounds nil,
   `shouldShowReturnAssistant` (line 788) and `shouldShowSkonto` (line 794)
   stay false for the delivered result; the credit-note branch already
   bypasses those screens by going straight to
   `presentTransactionDocsAlert`.

4. **Delivery**: no changes needed. `deliverWithReturnAssistant`
   (lines 627-664) reads `result.lineItems`/`result.skontoDiscounts` —
   nil after stripping, so `AnalysisResult` carries nil,
   `giniBankConfiguration.lineItems/skontoDiscounts` get nil, and
   `sendSkontoTransferSummary` (guarded by `if let skontoDiscounts`) is not
   called (R5).

## Test plan

Extend the existing
`BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests.swift`
(XCTest — matches the file's framework; it already has
`makeCoordinatorAndService()`, `createExtractionResult(...)`,
`createMockLineItems()`, `createMockSkontoDiscounts()` helpers to reuse).
No new test class. ~6 new tests:

| Test | Proves |
|---|---|
| `testExcludingCompoundExtractionsRemovesLineItemsSkontoDiscountsAndReturnReasons` | R1 — all three fields nil after helper |
| `testExcludingCompoundExtractionsKeepsExtractionsAndCandidates` | R1 — flat extractions (incl. `amountToPay`) and candidates untouched |
| `testShouldShowReturnAssistantFalseAfterExcludingCompoundExtractions` | R2 — RA gate false on stripped result even with `returnAssistantEnabled = true` and lineItems originally present |
| `testShouldShowSkontoFalseAfterExcludingCompoundExtractions` | R2 — Skonto gate false on stripped result even with `skontoEnabled = true` |
| `testExcludingAmountToPayOnStrippedResultRemovesAmountToPay` | R3 — chaining both helpers removes `amountToPay` AND compounds (extends existing `testExcludingAmountToPayExtractionResultCreditNote`) |
| `testNonCreditNoteResultKeepsCompoundExtractions` | R6 — a result with `businessDocType == "invoice"` is not stripped by the flow decision (`isDocumentMarkedAsCreditNote` false ⇒ no strip) |

Where the outcome is data, assertions compare against the specific fixture
values fed in via `createExtractionResult` (e.g. the mock line items /
skonto discounts built by the existing helpers), not just nil/non-nil where
a hardcoded return could pass.

### Not tested

- `presentNextScreen` end-to-end (sheet presentation, delegate delivery):
  requires a live navigation stack + capture UI; the class's existing tests
  also stop at helper level. The branching itself is a one-line ternary
  exercised indirectly by the helper tests. Left to manual QA: scan a
  credit-note document with hint enabled/disabled and verify no RA/Skonto
  screen and no compound extractions in the example app's result screen.
- `CreditNoteWarningViewController` (unchanged CaptureSDK code).
- R5 (no transfer summary): follows structurally from nil
  `skontoDiscounts` (guard in `deliverWithSkonto`/`deliverWithReturnAssistant`);
  asserting it would need a full delivery harness that doesn't exist today.
- R7: order of checks is unchanged code, covered by review.

## Out of scope

- Android — already implemented there; this ticket only aligns iOS.
- Changing WHEN the credit-note warning sheet shows (hint flags logic
  `determineIfCreditNoteHintEnabled` stays as is).
- Hint-disabled credit-note documents: they keep today's normal flow,
  including compound extraction delivery and RA/Skonto screens (decision
  revised in this session with the assignee).
- Changing `amountToPay` removal semantics (stays tied to
  warning-sheet "Proceed").
- `crossBorderPayment` compound extractions and the cross-border flow.
- Any `ExtractionResult` / `AnalysisResult` API changes.
- UI tests / Page Objects.
- HealthSDK — credit-note handling exists only in GiniBankSDK.

## Open questions

None — strip scope (lineItems + skontoDiscounts + returnReasons), trigger
(only when the credit-note warning is shown, i.e. `businessDocType ==
creditnote` AND both hint flags enabled), and test scope (unit only) were
settled with the assignee in this session.

## Implementation plan
- [x] 1. Add the 6 tests from the test plan to
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests.swift`
  (XCTest, reuse existing helpers) (requirements R1, R2, R3, R6)
- [x] 2. Add `excludingCompoundExtractions(from:)` helper to the internal
  extension in `GiniBankNetworkingScreenApiCoordinator.swift` (requirement R1)
- [x] 3. Chain the helper into the credit-note "Proceed" completion in
  `presentNextScreen` (requirements R1, R2, R3, R5; R4/R6/R7 by leaving
  other paths untouched)

Note (verification): fixed two pre-existing test-target failures unrelated
to this feature, both blocking the `GiniBankSDKTests` run on this branch:
1. `RemoteConfigPropagationTests.swift` was missing the
   `creditNoteHintEnabled` argument of the `ClientConfiguration`
   initializer (compile error).
2. `GiniBankConfigurationTests.swift` property-count guard was stale
   (expected 65, actual 67); `creditNoteHintEnabled` — the only stored
   property added since the guard was written — already has default-value
   and toggle tests in that suite, so only the count was updated.
