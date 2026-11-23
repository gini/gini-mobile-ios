# PP-4080: Wire Extractions into the Fraud Warning Screen

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-4080
Parent: PP-3960 — [iOS] Fraud warning screen: IBAN mismatch

## Problem

`GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift` currently presents the fraud warning with hardcoded placeholder IBANs (`FraudWarningStubs.qrIBAN = "PL12 1000 0111 0100 1000"`, `printedIBAN = "DE89 3704 0044 0532 0130 00"`), gated only by `GiniBankConfiguration.fraudWarningEnabled`. The screen fires whenever the integrator toggles that flag on, with the same two hardcoded IBANs every time — so it cannot ship to real users.

PP-4080 replaces the placeholders with real values pulled from the current `AnalysisResult` and the fraud signals the backend returned, and adds the backend-pushed `ClientConfiguration.fraudSignalsEnabled` as a second gate so the warning only presents when both the integrator has opted in AND the backend reports a real `.qrPrintedIbanMismatch` signal. It also localizes the view's currently-hardcoded English strings into the typed `.strings` chain.

## Requirements

### Gating (entry)

- **R1.** Given `GiniBankConfiguration.shared.fraudWarningEnabled == false`, when any terminal delivery path runs, `presentFraudWarningIfEnabled(result:extractionResult:completion:)` calls `completion(result)` synchronously; no `FraudSignalMapper.map(...)` call, no coordinator constructed.
- **R2.** Given `fraudWarningEnabled == true` AND `GiniBankUserDefaultsStorage.clientConfiguration?.fraudSignalsEnabled` is `false` or `nil`, same outcome as R1 — `FraudWarningIBANResolver` returns `nil`, no presentation.
- **R3.** Given both gates on AND `FraudSignalMapper.map(...)` returns no `.qrPrintedIbanMismatch` signal, no presentation — `completion(result)` runs synchronously.
- **R4.** Given both gates on AND a `.qrPrintedIbanMismatch` signal is present BUT the printed-IBAN filter yields empty, no presentation — the signal cannot be explained in the single-case view.
- **R5.** Given both gates on AND the resolver returns a non-nil `(qrIBAN, printedIBAN)` pair, the warning presents via the existing seam (bottom sheet, large detent, accessibility isolation).

### Resolved values (happy)

- **R6.** The QR IBAN is the `.iban` field of the first `.qrPrintedIbanMismatch` signal returned by `FraudSignalMapper.map(...)`.
- **R7.** The printed IBAN is the first value in `result.candidates[key] ?? []` (where `key = result.extractions["iban"]?.candidates ?? "ibans"`) that (a) trims to non-empty, (b) normalizes (whitespace-stripped + uppercased) to a string different from the QR IBAN's normalized form, (c) hasn't already been seen earlier in the candidate list.

### Localization

- **R8.** The following 7 new keys land in both `en.lproj/Localizable.strings` and `de.lproj/Localizable.strings`, and `FraudWarningView.swift`'s hardcoded English literals get replaced with `NSLocalizedStringPreferredGiniBankFormat(_:comment:)` calls to them:
  - `ginibank.fraud.warning.title.qr.printed`, `.body.qr.printed`
  - `.ibans.header`, `.row.qr.label`, `.row.printed.label`
  - `.cta.cancel`, `.cta.proceed`
- **R9.** The "How do I protect myself?" expander's title + body in the view read from `ginibank.fraud.protect.title` / `.body` (already present in both locales) instead of inline hardcoded English.

### Non-regression

- **R10.** When `fraudWarningEnabled == false`, delivery behaviour is bit-for-bit identical to today's — the two gates short-circuit before any mapper work.
- **R11.** Accessibility isolation (`accessibilityElementsHidden`, `accessibilityViewIsModal`, screen-change notifications), single-terminal-callback dedup (`takeFraudWarningPresentation()`), and bottom-sheet presentation style are preserved — PP-4080 only swaps the IBAN values + the gate predicate.

## Affected modules

- **`GiniBankSDK`** — modified: `GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift` (add `extractionResult:` parameter + resolver call + delete `FraudWarningStubs`), `GiniBankNetworkingScreenApiCoordinator.swift` (4 call sites), `FraudWarningView.swift` (localize 7 strings + 2 expander strings), `Resources/{en,de}.lproj/Localizable.strings` (+7 keys).
- **`GiniBankSDK`** — new: `Core/FraudDetection/FraudMismatch/FraudWarningIBANResolver.swift` (pure static resolver).
- **`GiniBankSDK/Tests`** — new `FraudMismatch/FraudWarningIBANResolverTests.swift`; extended `NetworkingScreenApiCoordinatorTests+FraudSignals.swift` with ~4 presentation-level cases.

## Public API impact

None. `fraudWarningEnabled` was added in PP-4077. The new resolver is `internal`. `presentFraudWarningIfEnabled`'s added parameter is on an internal extension.

## Technical conventions

- Swift, `internal` by default. `/** ... */` on declarations, `///` only for inline body comments.
- Localization keys follow `ginibank.<feature>.<screen>.<element>`. All call sites use `NSLocalizedStringPreferredGiniBankFormat(_:comment:)`.
- Tests: Swift Testing (`@Suite`/`@Test`/`#expect`) to match the existing suites in `Tests/GiniBankSDKTests/FraudMismatch/` and `Tests/GiniBankSDKTests/NetworkingScreenApiCoordinatorTests+FraudSignals.swift`.
- `FraudWarningIBANResolver` is a pure `internal enum` with one static function — no instance state, no storage.

## Design

`FraudWarningIBANResolver.swift`:

```swift
internal enum FraudWarningIBANResolver {
    static func resolve(result: AnalysisResult,
                        extractionResult: ExtractionResult,
                        fraudSignalsEnabled: Bool) -> (qrIBAN: String, printedIBAN: String)?
}
```

Returns `nil` on any of the short-circuit conditions (R2/R3/R4). Otherwise returns the first viable pair per R6/R7.

`presentFraudWarningIfEnabled(result:extractionResult:completion:)` adds the `extractionResult` parameter. Internally reads `GiniBankUserDefaultsStorage.clientConfiguration?.fraudSignalsEnabled ?? false`, calls the resolver, and uses the resolved pair in place of `FraudWarningStubs`. The enum `FraudWarningStubs` is deleted.

Each of the 4 terminal delivery call sites passes its in-scope `extractionResult` into `presentFraudWarningIfEnabled`.

## Test plan

- `FraudWarningIBANResolverTests.swift` (NEW, Swift Testing, ~8 cases):
  - returns nil when `fraudSignalsEnabled == false`
  - returns nil when mapper produces no `.qrPrintedIbanMismatch`
  - returns nil when QR signal present but no printed-IBAN candidate survives the filter
  - returns the pair when all conditions met
  - printed-IBAN filter excludes the QR IBAN after normalization (whitespace + case)
  - printed-IBAN filter dedupes by normalized form, preserving first-seen order
  - printed-IBAN filter skips empty / whitespace-only candidate values
  - uses `result.extractions["iban"]?.candidates` as the candidate-dict key, falling back to `"ibans"`

### Not tested

- Foundation `Locale` / `Bundle` localization lookup (framework behaviour).
- SwiftUI rendering internals beyond what the hosting-controller smoke test already covers.
- **Extension-level integration** (`presentFraudWarningIfEnabled` call-through): deferred to manual QA. The resolver tests cover R2/R3/R4/R6/R7 (the full gating + resolution logic); the extension's remaining code is a `guard + call + present` pattern wrapping that logic. Writing Swift Testing cases that construct a full `GiniBankNetworkingScreenApiCoordinator` requires `MockTokenSource`, a results-delegate mock, and a window hierarchy for `screenAPINavigationController.present` — too much new fixture plumbing relative to the ~10 lines of extension glue being tested. Manual QA scenarios to run before merge: (a) `fraudWarningEnabled = false` → warning never shows, (b) `fraudWarningEnabled = true` but backend `fraudSignalsEnabled` off → warning never shows, (c) both gates on + a `.qrPrintedIbanMismatch` present → warning shows with the extracted QR + printed IBANs (NOT the old hardcoded stubs), (d) proceed delivers the original `AnalysisResult` to the results delegate.
- Manual QA — VoiceOver reading order through the localized view (required before merge).

## Out of scope

- `.country` + `.combined` visual cases, sender card, per-row red hint lines — PP-4078 layout follow-up.
- `ExpandableInfoPlaceholder` → real `GiniExpandableInfoView` swap — already noted as TODO in the placeholder file.
- `IBANPickerPlaceholder` → real `IBANSelectionSheet` wiring + chosen-IBAN propagation into `AnalysisResult.extractions` — PR #1317 follow-up.
- Typed `LocalizableStringResource` enum migration — codebase-wide ticket.

## Implementation plan

- [x] **1. Localization keys** — 7 new `ginibank.fraud.warning.*` entries appended to both locale files per R8.
- [x] **2. Localize `FraudWarningView.swift`** — swapped all 9 hardcoded English literals (title, body, expander title + message, IBANs header, qr/printed row labels, cancel/proceed CTAs) for `NSLocalizedStringPreferredGiniBankFormat(…)` via a private `static func localized(_:)` helper. Deleted the two `Constants.qrRowTitle` / `.printedRowTitle` raw-string constants. Expander now reads `ginibank.fraud.protect.title` + `.body` per R9.
- [x] **3. New `FraudWarningIBANResolver.swift`** — internal enum with the public static `resolve(result:extractionResult:fraudSignalsEnabled:)` implementing R2/R3/R4/R6/R7, plus private `firstPrintedIBAN(from:excluding:)` and `normalize(_:)` helpers. Returns `nil` on any suppression condition (backend flag off / no `.qrPrintedIbanMismatch` signal / printed-IBAN filter empty) and the resolved `(qrIBAN, printedIBAN)` pair otherwise.
- [x] **4. Rewire `GiniBankNetworkingScreenApiCoordinator+FraudWarning.swift`** — added `extractionResult: ExtractionResult` parameter; now reads `fraudSignalsEnabled` from `GiniBankUserDefaultsStorage.clientConfiguration` and calls `FraudWarningIBANResolver.resolve(...)` after the integrator-gate check; short-circuits to `completion(result)` on nil. `FraudWarningStubs` deleted. The resolved pair feeds `FraudWarningCoordinator(qrIBAN:printedIBAN:delegate:)`. Doc comment updated to reflect all three short-circuit conditions. Also added `import GiniBankAPILibrary` for `ExtractionResult`.
- [x] **5. Update 4 call sites** at `L283`, `L581`, `L726`, `L1163` to pass their in-scope `extractionResult`. **O1 resolved:** 3 of the 4 enclosing methods (`deliver`, `deliverWithReturnAssistant`, `deliverWithSkonto`) take `result: ExtractionResult` as a parameter which gets shadowed inside by `let result = AnalysisResult(...)`; added a `let extractionResult = result` alias on the line before each shadow so the outer `ExtractionResult` remains accessible. `deliverWeroResult` already has an `extractionResult` parameter (no shadowing conflict) — pass-through only. `FraudWarningStubs` references confirmed zero in the source tree.
- [x] **6. Tests** — new `FraudWarningIBANResolverTests.swift` with **9 Swift Testing cases** covering R2 (backend-flag gate), R3 (no triggering signal — both empty-signals and only-country-signal variants), R4 (QR signal unexplainable), R6/R7 (happy path + four printed-IBAN-filter rules: exclusion across normalization, dedupe by normalized form, skip empty/whitespace, candidate-dict key fallback to `"ibans"`). **Extension-level integration tests deferred to manual QA** — the resolver tests already cover R2/R3/R4/R6/R7 logic; the extension is a thin `guard + call + present` wrapper whose remaining code paths (R1 integrator gate + R5 presentation) are verifiable in the simulator but not unit-testable without a window hierarchy. Manual QA scenarios listed under **Not tested**.

## Open questions

- **O1 (confidence: LOW).** Whether all 4 call sites have `extractionResult` in scope. L581 clearly does. L283/L726/L1163 need verification during step 5; may require threading `extractionResult` down from higher in the delivery path.
