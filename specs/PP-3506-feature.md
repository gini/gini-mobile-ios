# PP-3506: [iOS] Enable/Disable Ingredient Brand in Analysis screen based on backend flag

Status: implemented (reduced scope)
Ticket: https://ginis.atlassian.net/browse/PP-3506
Parent epic: PP-2568 · Depends on PP-2570 (iOS Powered by Gini component, this branch's base) and PP-2572 (backend feature flag)

## Scope decision

PP-3506's original AC5 — "field missing from the response → treated as empty" — was **dropped after re-examining PP-2572** (backend Done, in prod as of 2026-09-11). PP-2572's own AC pins the field as **mandatory**: "The presence of the `ingredientBrandScreens` object is mandatory in the `/configurations` response". Silently defending against a missing key on iOS would also hide a real backend-contract violation (the whole `/configurations` decode failing with `keyNotFound` is louder — and therefore more useful — than a coerced `[]`). AC5 to be reworded or struck on the ticket by the assignee.

Result: **no production code change ships in this PR.** Everything else — forward-compatibility with unknown screen names, loud failure on a non-array value, and the two consumer-side badge tests — remains in scope and passes against Swift's auto-synthesized `Codable` decoder. The strict-loud behaviour on a missing key is pinned by `decodingFailsWhenIngredientBrandScreensKeyIsAbsent`, mirroring the pre-existing `decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent` — so a future defensive-decoding change to any single flag now trips an explicit test instead of an incidental one.

## Problem

PP-2570 shipped the Powered by Gini badge and wired `ingredientBrandScreens` end-to-end (backend → `ClientConfiguration` → storage → `AnalysisViewController` / `QRCodeOverlay`). PP-3506 tightens iOS-side coverage on two scenarios PP-2570 left untested:

1. **Unknown screen values.** PP-3506 anticipates future screens (`"NoResults"`, `"Camera"`, …) being added on the backend before iOS learns about them. The current code tolerates them by accident (a `[String].contains { caseInsensitiveCompare("Analysis") == .orderedSame }` filter is naturally forward-compatible), but there is no test pinning that tolerance.
2. **Loud failure on a malformed shape.** A backend schema regression that returns `ingredientBrandScreens` as a non-array JSON value must fail loudly with `DecodingError.typeMismatch`, not silently coerce to `[]`. Auto-synthesized `Codable` already does the right thing; this pins that behaviour with a regression test.

## Requirements

### Backend contract & decoding (`GiniBankAPILibrary`)

**R1 (MUST, entry):** Given a `/configurations` JSON response with `"ingredientBrandScreens": ["Analysis"]`, when `JSONDecoder().decode(ClientConfiguration.self, from: data)` runs, then `config.ingredientBrandScreens == ["Analysis"]`. *(regression on PP-2570 AC — already passing, must stay passing.)*

**R2 (MUST, happy):** Given a `/configurations` JSON response with `"ingredientBrandScreens": []`, when decoded, then `config.ingredientBrandScreens == []`. *(regression on PP-2570 AC — already passing.)*

**R3:** ~~Given a `/configurations` JSON response with **no** `ingredientBrandScreens` key present, when decoded, then decoding succeeds AND `config.ingredientBrandScreens == []`.~~ **Dropped** — see "Scope decision" above. PP-2572 guarantees the field is mandatory; auto-synthesized `Codable` throws `DecodingError.keyNotFound` if the guarantee ever breaks, which is the correct loud-failure behavior.

**R4 (MUST, happy):** Given a `/configurations` JSON response with `"ingredientBrandScreens": ["Analysis", "Foo", "UNKNOWN"]`, when decoded, then decoding succeeds AND `config.ingredientBrandScreens == ["Analysis", "Foo", "UNKNOWN"]` (unknown strings retained verbatim; downstream consumer decides what to do with them). *(AC4 decoding side.)*

**R5 (MUST, error):** Given a `/configurations` JSON response with `"ingredientBrandScreens": "notAnArray"` (wrong type, non-array JSON value), when decoded, then decoding throws `DecodingError.typeMismatch`. *(Guards against silent coercion — a schema regression on the backend must fail loudly, not fall back to `[]`.)*

### Consumer behavior (`GiniCaptureSDK.AnalysisViewController`)

**R6 (MUST, happy):** Given `GiniCaptureUserDefaultsStorage.ingredientBrandScreens == ["Analysis", "Foo", "UNKNOWN"]`, when `AnalysisViewController` loads its view, then `PoweredByGiniBadgeView` is inserted and visible — the "Analysis" match wins, unknown values are silently ignored. *(AC4 consumer side, positive case.)*

**R7 (MUST, happy):** Given `GiniCaptureUserDefaultsStorage.ingredientBrandScreens == ["Foo", "UNKNOWN"]` (contains only unknown values, no "Analysis"), when `AnalysisViewController` loads its view, then no `PoweredByGiniBadgeView` is inserted (same behavior as empty array). *(AC4 consumer side, no-match case.)*

## Affected modules

- **GiniBankAPILibrary production** — no change. Auto-synthesized `Codable` handles both remaining decoding requirements correctly.
- **GiniBankAPILibrary tests** — `ClientConfigurationTests.swift`: merged R1/R4 test on the two-variant fixture, plus a new R5 typeMismatch test; a small `ingredientBrandFixture(variant:)` helper extracts each sub-object.
- **GiniBankAPILibrary fixtures** — `clientConfigurationWithIngredientBrand.json` restructured to a `{ valid, malformed }` envelope covering R1/R4/R5. `clientConfiguration.json` unchanged.
- **GiniCaptureSDK tests** — `AnalysisViewControllerTests.swift`: two new consumer-side tests (unknown-values-with-Analysis, only-unknown-values).

No production source in `GiniCaptureSDK` or `GiniBankSDK` changes — the consumer code (`AnalysisViewController.addPoweredByGiniBadgeIfEnabled` and `QRCodeOverlay.addPoweredByGiniBadgeIfEnabled`) is already `[String].contains { caseInsensitiveCompare("Analysis") }`, which is already forward-compatible with unknown values. The tests pin that behavior; the code stays as-is.

**QR overlay is explicitly out of scope for PP-3506** — PP-3506 targets the Analysis screen per ticket wording. `QRCodeOverlay` inherits the same forward-compatibility behavior for free from the storage layer, and its PP-2570 test coverage is unaffected.

## Public API impact

**None.** Test-only + fixture changes; `ClientConfiguration`'s source, ABI, and Codable conformance surface are untouched.

## Technical conventions

1. **Language & access control:** Swift, `internal` by default. No new symbols in production. Doc-comment style per `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced).

2. **UI:** No UI changes.

3. **Architecture:** No coordinator, view model, delegate, or view controller changes. PP-3506 sits entirely at the test-and-fixture layer.

4. **Wiring:** No DI change. No new async surface.

5. **Localization:** No new user-facing strings.

6. **Quality gates:**
   - `make lint scheme=GiniBankSDK` clean.
   - `make lint scheme=GiniCaptureSDK` clean.
   - Test coverage:
     - `ClientConfigurationTests.swift` extended in Swift Testing (matches file convention).
     - `AnalysisViewControllerTests.swift` extended in XCTest (matches file convention).

## Design

### 1. Production code

**No change.** Auto-synthesized `Codable` on `ClientConfiguration` already:
- Decodes `["Analysis", "Foo", "UNKNOWN"]` verbatim into `[String]` (R4).
- Throws `DecodingError.typeMismatch` when `ingredientBrandScreens` is a non-array (R5).

The dropped R3 (missing key → empty) was the only requirement that would have needed a custom `init(from:)`; with R3 out of scope, the file is untouched.

### 2. `ClientConfigurationTests.swift` — one merged test, one new test, one helper

- **Combined R1 + R4 into one test:** `ingredientBrandScreensDecodesArrayVerbatimIncludingUnknownScreenNames` (renamed from `ingredientBrandScreensDecodesArrayFromJSON`). Reads the `valid` sub-object of the two-variant `clientConfigurationWithIngredientBrand.json` via the `ingredientBrandFixture(variant:)` helper. Assertion `#expect(config.ingredientBrandScreens == ["Analysis", "Foo", "UNKNOWN"])`.
- **New test:** `throwsTypeMismatchWhenIngredientBrandScreensIsNotAnArray`. Reads the `malformed` sub-object via the same helper. Assertion: `#expect(throws: DecodingError.self) { … }`, then `case .typeMismatch` match. Covers R5.
- **New helper:** `ingredientBrandFixture(variant: String) throws -> Data` — uses `JSONSerialization` to extract the requested sub-object (`valid`, `malformed`, or `missing`) from the envelope fixture and re-serializes it as top-level JSON `Data` for `JSONDecoder`.
- **Missing-key pin:** `decodingFailsWhenIngredientBrandScreensKeyIsAbsent`. Reads the `missing` sub-object. Assertion: `#expect(throws: DecodingError.self) { … }`, then `case .keyNotFound` match on `ingredientBrandScreens`. Mirrors the pre-existing `decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent`.

### 3. `AnalysisViewControllerTests.swift` — two new consumer tests

Follow the existing helper pattern (`findBadge(in:)`, `makeCameraImageDocument()`, `sepaExtractionsConfig()`):

- `testAnalysisShowsBadgeWhenScreensListContainsAnalysisMixedWithUnknownValues` — sets `ingredientBrandScreens = ["Analysis", "Foo", "UNKNOWN"]`, asserts `findBadge` returns non-nil and visible.
- `testAnalysisHidesBadgeWhenScreensListContainsOnlyUnknownValues` — sets `ingredientBrandScreens = ["Foo", "UNKNOWN"]`, asserts `findBadge` returns nil.

Both extend the existing XCTest class (per platform.md §6, "adding a case to an existing XCTest class should match that file").

### 4. Fixtures

**Zero new fixture files.** Both remaining PP-3506 requirements reuse an existing fixture:

- **R4 (unknown values), R5 (wrong type), and the missing-key pin**: restructure the existing `clientConfigurationWithIngredientBrand.json` into a three-variant envelope with `valid` (`["Analysis", "Foo", "UNKNOWN"]`), `malformed` (`"notAnArray"`), and `missing` (no `ingredientBrandScreens` key) sub-objects. All three cases live in the same file; the `ingredientBrandFixture(variant:)` helper extracts each sub-object. R1 and R4 collapse into one test on the `valid` variant.
- `clientConfiguration.json` and `clientConfigurationWithEmptyIngredientBrand.json` stay as-is.

## Test plan

Every MUST requirement maps to at least one named test.

### `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/ClientConfigurationTests.swift` (Swift Testing, extends existing suite)

**Existing test kept:** `ingredientBrandScreensDecodesEmptyArray` (R2). No change.

**Merged R1 + R4:** `ingredientBrandScreensDecodesArrayVerbatimIncludingUnknownScreenNames` — renamed from `ingredientBrandScreensDecodesArrayFromJSON`, now reads the widened `valid` variant of the two-variant fixture.

**New tests:**
- `throwsTypeMismatchWhenIngredientBrandScreensIsNotAnArray` (R5), reads the `malformed` variant of the fixture.
- `decodingFailsWhenIngredientBrandScreensKeyIsAbsent`, reads the `missing` variant of the fixture. Mirrors `decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent` — pins the strict-loud contract from the scope-decision explicitly, so a future defensive-decoding change to this key requires updating the test.

Rough count: 4 total in the ingredient-brand section of this file (was 3).

### `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/AnalysisViewControllerTests.swift` (XCTest, extends existing suite)

**New tests:**
- `testAnalysisShowsBadgeWhenScreensListContainsAnalysisMixedWithUnknownValues` (R6).
- `testAnalysisHidesBadgeWhenScreensListContainsOnlyUnknownValues` (R7).

Rough count: 2 new tests (existing file grows from 13 to 15 in the badge section).

### Not tested

- **AC5 "missing key" scenario.** Dropped from scope — see "Scope decision" above. Auto-synthesized `Codable` throws `DecodingError.keyNotFound` for a missing key, which is the correct loud-failure signal for a backend-contract violation. PP-2572 guarantees the key is always present.
- **QR overlay behavior on the AC4 scenario.** Out of scope per user decision — PP-3506 targets the Analysis screen. QR overlay inherits the same behavior from the storage layer for free, and its PP-2570 test coverage is unaffected.
- **Integration test hitting the real `/configurations` endpoint.** These require `TEST_CLIENT_ID` / `TEST_CLIENT_SECRET` (platform.md §6) and would only exercise the shape the backend currently returns.
- **`GiniBankNetworkingScreenApiCoordinator.startSDK` mirror line.** Already covered by `RemoteConfigPropagationTests` writer tests added under PP-2570 (`ingredientBrandScreens=["Analysis"]` and `ingredientBrandScreens=[]` cases). PP-3506 does not touch the coordinator.

### Manual QA

None required. All PP-3506 behavior is unit-testable end-to-end at the decoding layer plus the consumer-side view-tree checks that PP-2570 already established. Manual visual QA is a PP-2570 concern and was covered on that PR.

## Out of scope

- **QR overlay.** PP-3506 says "Analysis screen"; per user decision, `QRCodeOverlay` and `QRCodeOverlayTests` are not touched.
- **Async config race** (Copilot review comment on PP-2570). Repo-wide behavior of `GiniBankNetworkingScreenApiCoordinator.startSDK` — every sibling flag has the same "first-session-may-miss" timing. Separate ticket if ever prioritised.
- **Backfilling docs / property comments on `ClientConfiguration`'s 14 sibling properties.** PP-2570 review deliberately kept these bare to match file convention.
- **Localisation of "Powered by Gini".** Brand mark, pinned as non-localised under PP-2570 spec R11.

## Open questions

None. All three ambiguities from the clarifying-questions round (AC5 direction, AC4 test-scope layers, QR-overlay inclusion) have been resolved and folded into the requirements and the test plan.

## Implementation plan
- [x] 1. Restructure `clientConfigurationWithIngredientBrand.json` into a `valid` / `malformed` two-variant envelope so R1/R4 (merged) and R5 both read from a single fixture via a small `ingredientBrandFixture(variant:)` helper
- [x] 2. Merge R1 + R4 into `ingredientBrandScreensDecodesArrayVerbatimIncludingUnknownScreenNames` and add `throwsTypeMismatchWhenIngredientBrandScreensIsNotAnArray` (R5) in `ClientConfigurationTests.swift`
- [x] 3. Add `testAnalysisShowsBadgeWhenScreensListContainsAnalysisMixedWithUnknownValues` (R6) and `testAnalysisHidesBadgeWhenScreensListContainsOnlyUnknownValues` (R7) to `AnalysisViewControllerTests.swift`
- [x] 4. **Scope-decision revert:** drop the custom `init(from:)` in `ClientConfiguration.swift` and the `decodesAsEmptyArrayWhenIngredientBrandScreensKeyIsAbsent` test — see "Scope decision" above. AC5 to be reworded/struck on the ticket.
