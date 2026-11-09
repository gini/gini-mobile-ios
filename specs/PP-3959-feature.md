# PP-3959: [iOS] Read fraud signals from the extractions

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3959
Parent epic: PP-3518 — [Q4] Fraud prevention warnings – phase 1
Backend source of truth: PP-3952 — `[CVIE] Label mapping for fraudSignals compound extraction` (overrules Android on any conflict)
Android reference PR (parity only): https://github.com/gini/gini-mobile-android/pull/1028 (PP-3965)

## Problem

Backend ticket PP-3952 extends `/documents/{id}/extractions` with a new
compound extraction `fraudSignals` (same wire shape as `skontoDiscounts` and
`crossBorderPayment`). Each element carries `signalCode`, `severity`, `iban`,
and — for `IBAN_COUNTRY_MISMATCH` — `creditorCountry`. The iOS Bank SDK must
decode these signals so a follow-up ticket under PP-3518 can render a fraud
warning before payment. The signals must stay internal: they must not leak
onto the public `AnalysisResult` surface, and they must not be echoed back
to the backend as feedback.

Today `ExtractionsContainer` decodes three known compound keys (`lineItems`,
`skontoDiscounts`, `crossBorderPayment`) into the internal
`CompoundExtractions` struct, and `ExtractionResult` re-exposes those three
compound arrays as public properties. `AnalysisResult` (in CaptureSDK) is the
integrator-visible shape for banks. `GiniBankConfiguration` has six physical
`sendFeedback`/`sendSkontoFeedback` call sites (five logical sites — the two
branches of `cleanup(paymentRecipient:…)` form one site) that build
`updatedCompoundExtractions` payloads. None currently include fraud signals,
and the feedback-path hygiene rule must stay documented going forward.

## Requirements

Entry point: `fraudSignalsRaw` is observable on `ExtractionResult`
(SPI-gated). The typed model (`FraudSignal` / `FraudSignalCode`) is consumed
inside `GiniBankSDK` only — it is not an integrator-visible entry point.

- **R1 (MUST, happy path)** — Given a backend response whose
  `compoundExtractions.fraudSignals` holds one `QR_PRINTED_IBAN_MISMATCH`
  element with `signalCode`, `severity`, and `iban` members, when
  `ExtractionsContainer` decodes the payload, then
  `ExtractionsContainer.fraudSignalsRaw` is a single-element array of groups
  and the first group contains three `Extraction` instances whose `name`
  fields are `signalCode`, `severity`, and `iban`, with the `value` fields
  exactly matching the JSON values from the fixture.

- **R2 (MUST, happy path)** — Given a backend response whose
  `compoundExtractions.fraudSignals` holds one `IBAN_COUNTRY_MISMATCH`
  element with `signalCode`, `severity`, `iban`, and `creditorCountry`
  members, when `ExtractionsContainer` decodes the payload, then the first
  group contains four `Extraction` instances whose `name` fields are
  `signalCode`, `severity`, `iban`, and `creditorCountry`, with the `value`
  fields exactly matching the JSON values from the fixture.

- **R3 (MUST, happy path)** — Given a backend response whose
  `compoundExtractions.fraudSignals` holds two elements — one
  `QR_PRINTED_IBAN_MISMATCH` and one `IBAN_COUNTRY_MISMATCH` — when
  `ExtractionsContainer` decodes the payload, then `fraudSignalsRaw.count`
  is 2 and each group's `signalCode` extraction `value` matches its source
  JSON object.

- **R4 (MUST, happy path)** — Given any decoded `ExtractionsContainer`
  whose `fraudSignalsRaw` is non-nil, when an `ExtractionResult` is
  constructed from it via `init(extractionsContainer:)`, then
  `ExtractionResult.fraudSignalsRaw` returns the same array by value
  (same count, same element names and values).

- **R5 (MUST, error path — unknown signal)** — Given a backend response
  whose `compoundExtractions.fraudSignals` contains an element whose
  `signalCode.value` is neither `QR_PRINTED_IBAN_MISMATCH` nor
  `IBAN_COUNTRY_MISMATCH`, when `ExtractionsContainer` decodes the payload,
  then decoding does not throw and `fraudSignalsRaw` contains the raw
  element unchanged (the group's `signalCode` extraction still carries the
  unknown `value`). The `FraudSignalMapper` is responsible for filtering it
  out at the SDK layer (R10).

- **R6 (MUST, error path — field absent)** — Given a backend response with
  no `compoundExtractions.fraudSignals` key, when `ExtractionsContainer`
  decodes the payload, then `fraudSignalsRaw` is `nil` and no other
  decoded field (`extractions`, `compoundExtractions.lineItems`,
  `candidates`, etc.) is affected.

- **R7 (MUST, error path — empty array)** — Given a backend response
  whose `compoundExtractions.fraudSignals` is explicitly `[]`, when
  `ExtractionsContainer` decodes the payload, then `fraudSignalsRaw` is
  `[]` (an empty array, not `nil`). This mirrors how Android distinguishes
  "absent" from "explicitly empty" during tests even though PP-3952 says
  the backend will never emit an empty array in production.

- **R8 (MUST, entry)** — Given an `ExtractionResult` built from a
  container that holds fraud signals, when an integrator reads
  `ExtractionResult.fraudSignalsRaw` without importing the
  `GiniCaptureInternal` SPI, then the symbol is not visible (compile-time
  guarantee of SPI). When the same integrator imports
  `@_spi(GiniCaptureInternal) import GiniBankAPILibrary`, the property
  returns `[[Extraction]]?`.

- **R9 (MUST, happy path — typed model)** — Given an `ExtractionResult`
  whose `fraudSignalsRaw` holds the two known codes
  (`QR_PRINTED_IBAN_MISMATCH` and `IBAN_COUNTRY_MISMATCH`), when
  `FraudSignalMapper.map(extractionResult:)` runs inside GiniBankSDK,
  then it returns `[FraudSignal]` with two elements whose `code` is
  `.qrPrintedIbanMismatch` and `.ibanCountryMismatch` respectively, each
  carrying the `severity` string, `iban` string, and (for the country
  mismatch) the `creditorCountry` string sourced from the matching
  `Extraction.value`.

- **R10 (MUST, error path — typed model)** — Given an `ExtractionResult`
  whose `fraudSignalsRaw` holds one unknown `signalCode` (e.g.
  `"FOO_BAR"`), when `FraudSignalMapper.map(extractionResult:)` runs,
  then the resulting `[FraudSignal]` is empty and no error is thrown.
  (Combined with a known signal in the same group list, only the known
  signal is returned.)

- **R11 (MUST, error path — typed model)** — Given an `ExtractionResult`
  whose `fraudSignalsRaw` is `nil`, when
  `FraudSignalMapper.map(extractionResult:)` runs, then the result is
  `[]` and no error is thrown.

- **R12 (MUST, entry — AnalysisResult boundary)** — Given any
  `ExtractionResult` with non-nil `fraudSignalsRaw`, when
  `GiniBankNetworkingScreenApiCoordinator` constructs an `AnalysisResult`
  from it and hands it to `GiniCaptureResultsDelegate`, then the public
  `AnalysisResult` surface does not carry any fraud-signal data (there is
  no `fraudSignals` / `fraudSignalsRaw` property on `AnalysisResult`, no
  `extractions[key]` entry keyed `signalCode`/`severity`, and no
  `candidates` entry derived from the signals).

- **R13 (MUST, entry — feedback hygiene)** — Given fraud signals are
  present on the current `ExtractionResult`, when the integrator calls
  any feedback-emitting path on `GiniBankConfiguration`
  (`cleanup(paymentRecipient:…)`, `sendTransferSummary(paymentRecipient:…)`,
  `sendTransferSummary(extractions:)` SEPA or CX branch, or
  `sendTransferSummaryWithSkonto(…)` → `sendSkontoTransferSummary`),
  then the `updatedCompoundExtractions` dictionary passed to
  `documentService.sendFeedback` / `sendSkontoFeedback` does not contain
  a `fraudSignals` key. (Observable by asserting the dictionary keys
  returned to a stubbed `DocumentServiceProtocol`.) The parameterless
  `cleanup()` path (`resetToInitialState()` only, no `sendFeedback`) is
  not a feedback site and needs no annotation.

- **R14 (SHOULD, documentation)** — Each of the 5 feedback sites in
  `GiniBankConfiguration` carries one `///` line immediately above the
  `sendFeedback`/`sendSkontoFeedback` call (or the surrounding `if`/`else`
  pair, in the case of `cleanup(paymentRecipient:…)`) stating that fraud
  signals must never be included in the feedback payload. This is a
  documentation-only change — no runtime strip is introduced because R13
  is already guaranteed by the fact that `GiniBankConfiguration` builds
  its own `updatedCompoundExtractions` dictionary and never copies
  fraud-signal keys into it.

- **R15 (SHOULD, documentation)** — `CompoundExtractions` carries a
  `/** */` block explaining why `fraudSignals` is *not* a property on
  this struct (it is decoded at `ExtractionsContainer` level and exposed
  SPI-only on `ExtractionResult`), so a future maintainer who sees the
  `lineItems` / `skontoDiscounts` / `crossBorderPayment` pattern knows
  where to find the signal. The note is on `CompoundExtractions` —
  **not** on `AnalysisResult`, which has no `compoundExtractions`
  property.

## Affected modules

- **GiniBankAPILibrary** (SPM package, iOS 15+) — owns
  `ExtractionsContainer`, `CompoundExtractions`, `ExtractionResult`,
  `Extraction`. Decode and SPI exposure live here.
- **GiniBankSDK** (SPM package, iOS 15+; depends on
  `GiniBankAPILibrary` via `GiniCaptureSDK`) — owns `GiniBankConfiguration`,
  `GiniBankNetworkingScreenApiCoordinator`. New `FraudSignal` /
  `FraudSignalCode` / `FraudSignalMapper` live here.
- **GiniHealthAPILibrary**, **GiniHealthSDK**, **GiniCaptureSDK**,
  **GiniInternalPaymentSDK**, **GiniUtilites** — not touched. CaptureSDK
  is explicitly not touched (`AnalysisResult.swift` is unchanged; R12 is
  satisfied by the fact that the coordinator never maps `fraudSignalsRaw`
  into the `AnalysisResult` init call, not by a new property).

## Public API impact

Changes are **additive**. No breaking change.

- `GiniBankAPILibrary.ExtractionResult` gains a new property
  `@_spi(GiniCaptureInternal) public var fraudSignalsRaw: [[Extraction]]?`.
  Without the SPI import, the symbol is invisible to integrators, so the
  public surface is unchanged for integrators that do not opt in.
- `GiniBankAPILibrary.ExtractionsContainer` stays `internal` (no change
  to the package's public API; new `fraudSignalsRaw: [[Extraction]]?`
  internal property only).
- `GiniBankAPILibrary.CompoundExtractions` stays `internal` (no change
  to the package's public API; only a new `/** */` doc block).
- `GiniBankSDK.FraudSignal`, `GiniBankSDK.FraudSignalCode`,
  `GiniBankSDK.FraudSignalMapper` are all `internal` (no public API
  impact).
- `GiniBankSDK.GiniBankConfiguration` — unchanged public signature. The
  5 feedback sites get documentation-only `///` lines. No new public
  method, no renamed parameter.
- `AnalysisResult` (in `GiniCaptureSDK`) — unchanged.

## Technical conventions

1. **Language and access control.** Swift. New types in `GiniBankSDK`
   (`FraudSignal`, `FraudSignalCode`, `FraudSignalMapper`) are `internal`
   (default). The one new public symbol is
   `ExtractionResult.fraudSignalsRaw`, gated under
   `@_spi(GiniCaptureInternal)`. No other declaration changes visibility.
   Doc-comment style per `.claude/rules/mandatory-rules.md` — `/** */` on
   the new declarations (SPI property, typed model types, mapper entry
   point); `///` for the feedback-site single-line notes and the
   `CompoundExtractions` intent note's rationale lines.
   *(confidence: LOW — no pre-existing `@_spi` usage in the repo was
   found by grep. If the team prefers `internal` + `@testable import`
   over an SPI contract, resolve under Open questions before build.)*
2. **UI.** Not applicable — this ticket is data-layer only. No SwiftUI,
   no UIKit changes, no Liquid Glass impact.
3. **Architecture.** Not applicable — no new coordinator / view model /
   view controller. The typed-model mapping (`FraudSignalMapper`) is a
   pure function; it is a plain internal type, not a service with a
   delegate. Future warning-UI ticket under PP-3518 will add
   `<Feature>Coordinator` / `<Feature>ViewModel` / `<Feature>ViewController`
   around it.
4. **Wiring.** No DI changes. Mapper is a static function
   (`FraudSignalMapper.map(extractionResult:) -> [FraudSignal]`) — no
   builder, no stored state. Async not involved (pure value transform).
5. **Localization.** No localizable strings added in this ticket. The
   warning text lives in the follow-up UI ticket. No
   `Sources/<SDK>/Resources/*.strings` changes.
6. **Quality gates.** Multi-parameter formatting per
   `.claude/rules/mandatory-rules.md` — the new `FraudSignal` init and
   the extended `ExtractionResult` init (which gains the
   `fraudSignalsRaw:` parameter) must use one-parameter-per-line with
   subsequent parameters vertically aligned. Test framework per the
   module's dominant stack: `GiniBankAPILibrary` tests stay **XCTest**
   (match neighboring `ExtractionsContainerTest.swift`);
   `GiniBankSDK` tests stay **XCTest** (match neighboring
   `CXTransferSummaryTests.swift` and `NetworkingScreenApiCoordinatorTests+*`).
   `make lint scheme=GiniBankSDK` and `make lint scheme=GiniBankAPILibrary`
   must stay clean. CI runs on `iPhone 17 / iOS 26.2`; local
   `make lint` on `iPhone 15 Pro / iOS 17.2` — re-run in CI parity before
   pushing. Copyright year on new files: 2026.

## Design

### Decode path — `GiniBankAPILibrary`

**`ExtractionsContainer.swift`** gains a new stored property
`fraudSignalsRaw: [[Extraction]]?` and a new `CodingKey` is added for the
existing `compoundExtractions` key (already present) so decoding can
extract `fraudSignals` from its nested object. The pattern:

```swift
struct ExtractionsContainer {
    let extractions: [Extraction]
    let compoundExtractions: CompoundExtractions?
    let fraudSignalsRaw: [[Extraction]]?          // new
    let candidates: [String: [Extraction.Candidate]]
}
```

In `init(from decoder:)` the `compoundExtractions` nested object is
consulted twice — once as `CompoundExtractions` (unchanged existing
decode), and once as a keyed container to pluck `fraudSignals`:

```swift
if let compoundContainer = try? container.nestedContainer(
    keyedBy: FraudSignalsKey.self,
    forKey: .compoundExtractions
),
   let raw = try compoundContainer.decodeIfPresent(
       [[String: Extraction]].self,
       forKey: .fraudSignals
   ) {
    fraudSignalsRaw = Self.mapExtractions(input: raw)
} else {
    fraudSignalsRaw = nil
}
```

`FraudSignalsKey` is a `private enum: String, CodingKey { case
fraudSignals }` local to `ExtractionsContainer`. `mapExtractions` reuses
the same name-assigning transform `CompoundExtractions` already uses —
extract it to a fileprivate helper or duplicate the three-line map to
keep `CompoundExtractions` untouched structurally. **Duplicate** (see R15:
`CompoundExtractions` gains only a `/** */` intent note, not a new
member).

An explicit `[]` JSON array must decode to `fraudSignalsRaw = []` to
satisfy R7. `decodeIfPresent` returns the empty array for an explicit
`[]`, so the mapping transform preserves emptiness naturally.

**`CompoundExtractions.swift`** gains a `/** */` block above the struct
declaration explaining that `fraudSignals` is a sibling key under the
`compoundExtractions` JSON object but is **not** modeled here — it is
decoded at `ExtractionsContainer` level and exposed SPI-only on
`ExtractionResult` so it never participates in feedback payloads or
public SDK surfaces. No code changes.

**`ExtractionResult.swift`** gains:

```swift
@_spi(GiniCaptureInternal)
public var fraudSignalsRaw: [[Extraction]]?
```

The public `init(extractions:lineItems:skontoDiscounts:crossBorderPayment:candidates:)`
stays unchanged (additive, no breaking change). A new SPI-gated init that
accepts `fraudSignalsRaw` is **not** needed because the only internal
construction path goes through
`convenience init(extractionsContainer:)`, which is updated to copy
`extractionsContainer.fraudSignalsRaw` onto the new property. The public
init defaults `fraudSignalsRaw` to `nil` by not setting it (the stored
property's declaration provides `var … = nil`).

Downstream `ExtractionResult(extractions:...)` call sites in the repo
(found in `GiniNetworkingScreenAPICoordinator.swift`, test suites, and
`HealthNetworkingService.swift`) do not need to change — they pass `nil`
implicitly via the default.

### Typed model — `GiniBankSDK`

Three new files under `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/`:

- **`FraudSignalCode.swift`** — `enum FraudSignalCode: String { case
  qrPrintedIbanMismatch = "QR_PRINTED_IBAN_MISMATCH"; case
  ibanCountryMismatch = "IBAN_COUNTRY_MISMATCH" }`. Internal. Unknown
  backend codes are dropped silently (R10) by letting
  `FraudSignalCode(rawValue:)` return `nil` in the mapper.
- **`FraudSignal.swift`** — `struct FraudSignal { let code:
  FraudSignalCode; let severity: String; let iban: String; let
  creditorCountry: String? }`. Severity stays `String` for this ticket
  (backend PP-3952 still "To Do"; severity vocabulary not yet locked).
  Internal.
- **`FraudSignalMapper.swift`** — `enum FraudSignalMapper { static func
  map(extractionResult: ExtractionResult) -> [FraudSignal] }`. Reads
  `extractionResult.fraudSignalsRaw` via the SPI import
  (`@_spi(GiniCaptureInternal) import GiniBankAPILibrary` at the top of
  the mapper file). For each group, builds a `[String: Extraction]`
  dictionary keyed by `name`, then constructs a `FraudSignal` only when
  all of (a) `signalCode.value` maps to a known `FraudSignalCode`,
  (b) `severity.value` is present, and (c) `iban.value` is present.
  `creditorCountry` is optional. `fraudSignalsRaw == nil` returns `[]`.

### Feedback hygiene — `GiniBankSDK`

`GiniBankConfiguration.swift` gets `///` lines at 5 call sites. Exact
locations in the current file (L597…L800 of `GiniBankConfiguration.swift`):

| Site | Line (current) | Where to place the `///` line |
|------|----------------|-------------------------------|
| 1 | `cleanup(paymentRecipient:…)` if/else, L596–L602 | one `///` line above the `if let lineItems = lineItems {` on L596, covering both branches |
| 2 | private `sendTransferSummary(updatedExtractions:)` L656–L660 | above the `documentService?.sendFeedback` call on L658 |
| 3 | `sendTransferSummary(extractions:)` CX branch L710–L712 | above the `documentService?.sendFeedback` call on L711 |
| 4 | `sendTransferSummary(extractions:)` SEPA branch L713–L716 | above the `documentService?.sendFeedback` call on L714 |
| 5 | `sendSkontoTransferSummary(…)` L796–L798 | above the `documentService?.sendSkontoFeedback` call on L796 |

The parameterless `cleanup()` method at L823 (no `sendFeedback` call)
gets **no** annotation per the locked decision.

The `///` line is a single sentence stating that `fraudSignals` must
never be included in the `updatedCompoundExtractions` payload. No runtime
code is added — the invariant is already preserved because each site
builds its own `[String: [[Extraction]]]` dictionary from scratch and
never reads `fraudSignalsRaw`.

### Boundary — `GiniBankNetworkingScreenApiCoordinator`

No code change needed. The coordinator already builds `AnalysisResult`
by naming each compound array explicitly (`lineItems`, `skontoDiscounts`,
`crossBorderPayment`) and does **not** pass `fraudSignalsRaw`. A test
locks the invariant (R12).

## Test plan

### GiniBankAPILibrary

**`BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/ExtractionsContainerTest.swift`**
— extend the existing XCTest class. ~12 new `func test…` methods, grouped
as 6 scenarios × 2 assertion sets (container-level + ExtractionResult
pass-through). Each scenario loads a new JSON fixture from
`Tests/GiniBankAPILibraryTests/Resources/`.

| # | Scenario → fixture | Container test | ExtractionResult test |
|---|-----|-----|-----|
| 1 | QR_PRINTED_IBAN_MISMATCH only → `extractionsContainerWithFraudSignalsQRPrintedIBANMismatch.json` | `testFraudSignalsQRPrintedIBANMismatchDecoding()` covers R1 | `testExtractionResultFraudSignalsQRPrintedIBANMismatchPassthrough()` covers R4 |
| 2 | IBAN_COUNTRY_MISMATCH only → `extractionsContainerWithFraudSignalsIBANCountryMismatch.json` | `testFraudSignalsIBANCountryMismatchDecoding()` covers R2 | `testExtractionResultFraudSignalsIBANCountryMismatchPassthrough()` covers R4 |
| 3 | Both signals → `extractionsContainerWithFraudSignalsBoth.json` | `testFraudSignalsBothDecoding()` covers R3 | `testExtractionResultFraudSignalsBothPassthrough()` covers R4 |
| 4 | Unknown signalCode → `extractionsContainerWithFraudSignalsUnknown.json` | `testFraudSignalsUnknownSignalDecoding()` covers R5 | `testExtractionResultFraudSignalsUnknownPassthrough()` covers R4 |
| 5 | fraudSignals absent → reuse existing `extractionsContainer.json` (asserts `fraudSignalsRaw == nil`) | `testFraudSignalsAbsentDecoding()` covers R6 | `testExtractionResultFraudSignalsAbsentIsNil()` covers R6+R4 |
| 6 | fraudSignals explicitly `[]` → `extractionsContainerWithFraudSignalsEmpty.json` | `testFraudSignalsEmptyArrayDecoding()` covers R7 | `testExtractionResultFraudSignalsEmptyPassthrough()` covers R4 |

Fixtures mirror Android: IBANs `DE89370400440532013000` (German, for
QR_PRINTED_IBAN_MISMATCH's bogus-printed value), `GB29NWBK60161331926819`
(British, for IBAN_COUNTRY_MISMATCH), and `creditorCountry = "DE"` — exact
values to be cross-checked against Android PR #1028's test JSON before
writing. *(confidence: LOW — Android IBANs/country codes not read in this
session. If they differ, update fixtures to match before implementation.)*

### GiniBankSDK

**`BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/FraudSignalMapperTests.swift`**
— **new** XCTest file (match neighboring XCTest suites like
`CXTransferSummaryTests.swift`). Imports with
`@_spi(GiniCaptureInternal) import GiniBankAPILibrary` to build
fixtures. ~4 tests:

- `testMapsBothKnownSignals()` — covers R9. Build an `ExtractionResult`
  with `fraudSignalsRaw` holding both codes; assert the returned
  `[FraudSignal]` contains two elements with the expected `code`,
  `severity`, `iban`, `creditorCountry`.
- `testDropsUnknownSignalCode()` — covers R10. Mixed known + unknown in
  the raw; assert only the known element survives.
- `testEmptyWhenRawIsNil()` — covers R11.
- `testEmptyWhenAllSignalsUnknown()` — covers R10 edge case.

**`BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+FraudSignals.swift`**
— **new** XCTest extension on the existing
`NetworkingScreenApiCoordinatorTests` class (match the `+CX`, `+Helpers`,
`+SchedulePaymentHint` extension pattern). 2 tests:

- `testAnalysisResultHasNoFraudSignalKeys()` — covers R12. Feed a
  stubbed `ExtractionResult` with `fraudSignalsRaw` populated; assert
  the resulting `AnalysisResult.extractions` dictionary has no
  `signalCode`/`severity`/`creditorCountry` keys and no new public
  property exists on `AnalysisResult`.
- `testFeedbackPayloadOmitsFraudSignals()` — covers R13. Capture the
  `updatedCompoundExtractions` dictionary that the
  `GiniBankConfiguration.cleanup(paymentRecipient:…)` path forwards to a
  stub `DocumentServiceProtocol`; assert the dictionary has no
  `fraudSignals` key under any of the five documented sites.

### Not tested

- `FraudSignal` as a `Codable` round-trip — it is a plain internal value
  type with no serialization responsibility.
- The `///` and `/** */` comment text itself — SwiftLint/style rules are
  enforced by `make lint`; asserting on comments is brittle.
- The follow-up warning UI (routing, VM, strings) — out of scope,
  separate ticket under PP-3518.
- Manual QA: once the backend (PP-3952) is in staging, hit `/documents`
  with a fixture that triggers both signals and verify
  `ExtractionResult.fraudSignalsRaw` populates end-to-end via the
  example app's debug hooks. This is QA's responsibility, not an
  automated integration test, because PP-3952 is still "To Do" and the
  real endpoint won't return the field during this ticket's development.

## Out of scope

- Warning UI, strings, Figma, accessibility for the fraud-warning
  screen. Belongs to a later ticket under PP-3518.
- Adding `fraudSignalsEnabled` to `ClientConfiguration` (PP-3951 — the
  client feature flag). Server already filters via `feature-fraud-signals`
  per PP-3952, so no client-side gating is needed here.
- `GiniHealthAPILibrary` / `GiniHealthSDK` parity. Not requested by the
  ticket.
- `CaptureSDK.AnalysisResult` — no new property. R12 is asserted as an
  invariant, not a new field.
- Any runtime feedback-payload strip (defensive `filter` on
  `updatedCompoundExtractions`). The 5 `///` lines are documentation; the
  invariant is already preserved by construction.
- Analytics / telemetry for unknown signalCode frequencies.
- Changing the existing `CompoundExtractions` decoder to also surface
  `fraudSignals` — the locked decision is to decode on
  `ExtractionsContainer`.

## Open questions

- **O1 (resolves confidence marker on §Technical conventions #1).** The
  repo has no prior `@_spi` usage. Confirm the team is happy to
  introduce `@_spi(GiniCaptureInternal)` as the exposure contract on
  `ExtractionResult.fraudSignalsRaw`, vs. keeping the property `internal`
  and reaching it from `GiniBankSDK` via `@testable import` (only works
  for tests) or via a sibling helper type in `GiniBankAPILibrary`. If
  this is wrong, the mapper's import line and R8 change; R9–R11 do not.
- **O2 (resolves confidence marker on §Test plan fixtures).** Confirm
  that the IBANs / `creditorCountry` chosen for the 6 fixtures match
  Android PR #1028's JSON so cross-review across repos reads the same
  values. If Android picks different IBANs or country codes, mirror
  Android — PP-3952 does not pin example values.

## Build-time decisions (deltas from the drafted spec)

Decided before implementation, in session:

- **O1** — keep the `@_spi(GiniCaptureInternal)` design as drafted. It
  is the closest SPM equivalent to Kotlin `internal` and aligns with
  Android PR #1028, which keeps the whole fraud-signal surface strictly
  internal.
- **O2** — use the spec's IBAN values (`DE89370400440532013000`,
  `GB29NWBK60161331926819`) and `creditorCountry = "DE"`. Decoder
  correctness is independent of IBAN content; QA/Android can reconcile
  later if needed.
- **Android parity on the typed model (updates R9, R10, R11, fixtures)**
  — mirror PR #1028:
  - `FraudSignalSeverity` is an `enum` (`stop`, `check`, `escalator`,
    `silent`), not a `String`. `FraudSignal.severity: FraudSignalSeverity`.
  - `FraudSignalMapper` drops an element when any of `signalCode`,
    `severity`, or `iban` is missing or unknown. For
    `IBAN_COUNTRY_MISMATCH` the mapper additionally requires
    `creditorCountry`; a `QR_PRINTED_IBAN_MISMATCH` without
    `creditorCountry` is still accepted (optional).
  - Results are **deduped by `code`** — if two elements map to the same
    `FraudSignalCode`, the first wins (Android: `.distinctBy { it.code }`).
  - Values are trimmed and empty strings are treated as missing.
- **Runtime feedback strip (upgrades R13)** — in addition to the
  documentation lines (R14), introduce a defensive strip of the
  `fraudSignals` key from `updatedCompoundExtractions` at every feedback
  site. Belt-and-braces alignment with Android's
  `FraudSignalsExtractions.withoutFraudSignals(…)`. The strip lives as
  a private helper in `GiniBankConfiguration` (not a new public API);
  the key constant is `"fraudSignals"`.
- **PP-3951 (feature flag) stays out of scope** per the spec. The
  mapper is unconditionally called — gating moves in with the
  follow-up ticket, matching the way Android's
  `GetFraudSignalsEnabledUseCase` is layered on top of the parser.

## Implementation plan

- [x] 1. `ExtractionsContainer.swift` — add stored `fraudSignalsRaw:
  [[Extraction]]?` and a nested-container decoder for the `fraudSignals`
  key under `compoundExtractions`. Explicit `[]` decodes to `[]`; absent
  key decodes to `nil`. (R1, R2, R3, R5, R6, R7)
- [x] 2. `CompoundExtractions.swift` — add the `/** */` intent note
  explaining why `fraudSignals` is not a property here. (R15)
- [x] 3. `ExtractionResult.swift` — add
  `@_spi(GiniCaptureInternal) public var fraudSignalsRaw: [[Extraction]]?`
  and wire the convenience init to copy from the container. (R4, R8)
- [x] 4. Typed model — `FraudSignalCode.swift`, `FraudSignalSeverity.swift`,
  `FraudSignal.swift` under `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/`.
  Internal. Enums use `fromApiValue(_:)` for unknown-tolerant parsing.
- [x] 5. `FraudSignalMapper.swift` — internal `enum FraudSignalMapper`
  with `static func map(extractionResult: ExtractionResult) -> [FraudSignal]`.
  Imports GiniBankAPILibrary via `@_spi(GiniCaptureInternal)`. Skips
  elements with unknown code or missing/empty `severity`/`iban`;
  requires `creditorCountry` for `IBAN_COUNTRY_MISMATCH`; dedupes by
  code; returns `[]` when `fraudSignalsRaw` is `nil`. (R9, R10, R11)
- [x] 6. `GiniBankConfiguration.swift` — add a private
  `stripFraudSignals(_:)` helper + `fraudSignalsFeedbackKey = "fraudSignals"`
  constant. Apply it to `updatedCompoundExtractions` immediately before
  each `documentService.sendFeedback` / `sendSkontoFeedback` call (5
  sites). Add the `///` lines above the 5 sites. (R13, R14)
- [x] 7. Fixtures — one new JSON file at
  `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/Resources/extractionsContainerWithFraudSignals.json`
  holding both known signals (`QR_PRINTED_IBAN_MISMATCH` and
  `IBAN_COUNTRY_MISMATCH`). The remaining scenarios (QR-only, country-only,
  unknown code, explicit empty) are derived in-test by decoding the file as
  `[String: Any]` and mutating the `compoundExtractions.fraudSignals`
  array before re-serializing. The absent-key case reuses the existing
  `extractionsContainer.json`.
- [x] 8. `ExtractionsContainerTest.swift` — extend with 12 methods
  (6 scenarios × container-level + `ExtractionResult` passthrough). (R1–R7)
- [x] 9. `FraudSignalMapperTests.swift` — new XCTest file in
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/`, imports
  `@_spi(GiniCaptureInternal) @testable import GiniBankAPILibrary` +
  `@testable import GiniBankSDK`. Tests both known signals, drop on
  unknown code, drop on missing severity / iban / required
  `creditorCountry`, dedupe by code, nil raw → `[]`. (R9, R10, R11, dedupe)
- [x] 10. `NetworkingScreenApiCoordinatorTests+FraudSignals.swift` —
  new XCTest extension; asserts `AnalysisResult` constructed by the
  coordinator carries no fraud-signal data and that the feedback
  payload through `GiniBankConfiguration.cleanup(paymentRecipient:…)`
  (with and without a pre-seeded `fraudSignals` key) omits
  `fraudSignals`. (R12, R13)
- [x] 11. `make lint` was unavailable locally (bundler/Ruby mismatch),
  so verification used `xcodebuild build`/`test` directly against the
  workspace with `platform=iOS Simulator,name=iPhone 17,OS=26.2`:
  - `GiniBankAPILibrary` build: **BUILD SUCCEEDED**, no warnings.
  - `GiniBankSDK` build: **BUILD SUCCEEDED**, no warnings.
  - `GiniBankAPILibraryTests` → `ExtractionsContainerTest`: **17/17 passed**
    (all 12 new fraud-signal cases included).
  - `GiniBankSDKTests` → `FraudSignalMapperTests`: **11/11 passed**.
  - `GiniBankSDKTests` → the 4 new coordinator extension cases
    (`testAnalysisResultHasNoFraudSignalKeysWhenFraudSignalsPresent`,
    `testCleanupWithPaymentRecipientFeedbackPayloadHasNoFraudSignals`,
    `testCXTransferSummaryFeedbackPayloadHasNoFraudSignals`,
    `testSEPATransferSummaryFeedbackPayloadHasNoFraudSignals`) and the 3
    `testStripFraudSignals*` cases: **7/7 passed** (seen inside the full
    `NetworkingScreenApiCoordinatorTests` run reporting 115 total passed).
- [x] 12. All 12 steps complete.
