# PP-3857: [iOS] Return Wero URL for unrecognised QR codes

Status: implemented, tests green (CVIE classification pending — see Rollout)
Ticket: https://ginis.atlassian.net/browse/PP-3857
Parent epic: PP-2666 "[Q4] Wero QR code support"
Backend companions:
- PP-3856 "[BAC] Wero client feature flag — per client" — **DEPLOYED** (`/configurations` carries `weroQRCodeScanningEnabled`).
- PP-3860 "[CVIE] Label mapping for paymentQRCodeType in general extractions, including Wero" — **PENDING**. Until CVIE ships, the backend returns no `paymentQRCodeType` label, so every unknown URL falls through to the AC6 fallback (camera + "unsupported QR" alert) by design.
Branch: `feat/PP-3857-wero-qr-support`

## Source documents (read in full before implementation)

- **Concept** — https://ginis.atlassian.net/wiki/spaces/bank/pages/1878327497 — the user-visible
  flow and the "EPS vs. Wero" result-object table are the normative references for R1, R8 and
  the user-flow table below.
- **Wero QR code discovery** — https://ginis.atlassian.net/wiki/spaces/bank/pages/1420787713 —
  Wero QRs follow EPC024-22 MSCT (URL-based). Scheme-specific details are not public.
  **Consequence:** the SDK does not parse the MSCT URL structure; it forwards the raw scanned
  payload and relies on backend classification via `paymentQRCodeType`. See D6.
- **Sparkasse URLs for Wero** — https://ginis.atlassian.net/wiki/spaces/bank/pages/1826717698 —
  the four production domains Sparkasse ships with. Used as test fixtures.
- **Sparkasse proposal (rejected decision-callback)** —
  https://ginis.atlassian.net/wiki/spaces/bank/pages/1952612354 — background on why the SDK
  stays on the extraction-key path (R7) instead of exposing a new delegate.

## User-visible flow (mirrors Concept §3, verbatim)

| # | Situation | What happens |
| --- | --- | --- |
| 1 | User scans a QR code in the camera screen | — |
| 2 | It's a payment QR we already support | Nothing changes |
| 3 | It's unknown and the customer has Wero enabled | Short processing indicator (~1–2 s) while the SDK checks with the backend — the existing QR `/document` upload indicator, which follows the ingredient-brand rule (D7 / R10) |
| 4 | Wero confirmed by backend | App receives `weroPaymentQRCodeUrl` through the existing extraction callback |
| 5 | Not Wero, or unknown QR code | Camera's "unsupported QR code" feedback — nav stack pops back to the camera and `handleInvalidQRCode()` fires. See D8 for the fallback mechanics; the user-visible wording / alert style is unchanged. |
| 6 | Backend check fails (error or timeout) | Reuse the existing `/document` partial-upload error flow — no Wero-specific branch |

## Problem

Sparkasse wants its app to recognise Wero QR codes. When the user scans one, the Gini Bank SDK
should hand the Wero URL back to the host app through the existing EPS-style callback
(`weroPaymentQRCodeUrl` key in `AnalysisResult.extractions`) instead of the current
"unsupported QR code" fallback.

Wero is not a single QR format — NL legacy iDEAL URLs, BE/LU legacy Payconiq URLs, and DE/FR
native Wero URLs all count. The device cannot tell them apart from any other unknown URL by
content, so the decision has to live in the backend. The SDK's job is:

1. gate behind the per-client flag `ClientConfiguration.weroQRCodeScanningEnabled` so Wero
   stays off for every non-Sparkasse customer,
2. upload unknown QR payloads through the existing `/document` path for the backend to
   classify,
3. surface the result as a single extraction via the existing EPS-style callback.

No public API change beyond one new extraction key. This mirrors the EPS pattern exactly — same
`AnalysisResult`, same `giniCaptureAnalysisDidFinishWith(result:)` callback, same `Extraction`
shape (`box: nil`, `candidates: nil`), only the key name and value change.

## Approach

Mirror the EPS pattern end-to-end:

- **Recognition stays on-device, unchanged.** `GiniQRCodeDocument.qrCodeFormat`
  (`CaptureSDK/.../Core/Models/GiniQRCodeDocument.swift:52`) continues to return a known
  `QRCodesFormat` for GiroCode / EPC / BezahlCode / EPS / Swiss QR-bill / etc. Zero code
  change on recognised codes.
- **The Wero flag gates `GiniCaptureDocumentValidator.validate(qrCode:)` at its `.none`
  branch.** Today an unknown QR (`qrCodeFormat == nil`) throws `qrCodeFormatNotValid`, which
  routes the camera scan to `didDetectInvalidQR` → `CameraViewController.handleInvalidQRCode()`
  → the "unsupported QR code" alert, with **no upload**. The Wero change widens that single
  branch: when the flag is ON the validator **lets the unknown QR through** instead of
  throwing — the camera's existing valid-QR path then routes it to `didCaptureAndValidate(_:)`
  → `GiniNetworkingScreenAPICoordinator.didCapture(document:networkDelegate:)` → the standard
  upload pipeline. When the flag is OFF, nothing changes.
- **The classification lives in `/analysis` extractions.** When upload+analysis completes, the
  extractions response carries a new `paymentQRCodeType` label (`epc`, `wero`, `other`, …).
  The mapper reads this label and, if `wero`, builds a single `Extraction` with
  name/entity `weroPaymentQRCodeUrl` and value = the original scanned payload, then delivers
  via the existing `deliver(result:to:)` path. If missing or not `wero`, the existing
  no-results flow fires.

## Flag source — the ClientConfiguration path (supersedes the dev-time seam)

The original draft of this spec defined a hardcoded `WeroFeatureFlag.isEnabled = true`
seam, with a note to swap once PP-3856 shipped. **PP-3856 is now deployed**, so the hardcoded
seam never ships: we wire straight into `ClientConfiguration`.

Flow (identical pattern to `qrCodeEducationEnabled` / `eInvoiceEnabled` /
`ingredientBrandScreens`):

1. Backend `/configurations` response includes `"weroQRCodeScanningEnabled": true|false`.
2. `GiniBankAPILibrary.ClientConfiguration` decodes the field into
   `public let weroQRCodeScanningEnabled: Bool`.
3. `GiniBankNetworkingScreenApiCoordinator.startSDK` persists the value into
   `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled` after the configuration fetch
   succeeds.
4. Both call sites in CaptureSDK read
   `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false` at decision time.
5. UI tests inject the flag via `UITestMockBackend.clientConfigurationOverrides` (new key
   added to the override list and the flag factory).

There is **no `WeroFeatureFlag.swift` file, no new import of `GiniBankAPILibrary` from
CaptureSDK, and no new DI parameter.** The config-fetch-async race the ingredient-brand
code hit (Q10 in PP-3511) does not apply here: the flag is read inside
`validate(qrCode:)` only after the user physically scans a QR — several seconds after
`startSDK` returns, by which time the config fetch has landed.

## Decisions

- **D1 — Flag source: `ClientConfiguration.weroQRCodeScanningEnabled`.** Supersedes the
  original hardcoded seam. PP-3856 is deployed; the backend already returns the field.
- **D2 — No short-circuit for Wero in `didCapture(document:networkDelegate:)`.** Unlike EPS
  (which resolves on-device), Wero requires the full `/document` upload path. The gate for
  Wero sits at validation — Wero is "unknown payload, let backend decide". The networking
  coordinator is untouched on `didCapture`; it only grows a mapper on the response side.
- **D3 — The scanned payload is preserved client-side as the `weroPaymentQRCodeUrl` value.**
  The SDK already has it (it was the thing scanned); backend only returns
  `paymentQRCodeType = wero` as the signal.
- **D4 — Backend errors go through the existing QR `/document` error flow.** No bespoke Wero
  error handling.
- **D5 — Picture / PDF open-with paths keep today's no-results screen.** For picture / PDF
  uploads of a Wero QR there is no on-device `GiniQRCodeDocument` to pull the raw payload
  from — the mapper returns the extraction result unchanged and the AC6 fallback (D8) does
  not fire (`shouldRouteBackToCameraForWeroFallback` requires a camera-scanned
  `GiniQRCodeDocument` in `pages`), so the pre-existing no-results screen remains the
  terminal state for this source.
- **D6 — The SDK does not parse the Wero URL structure.** Backend owns classification. No
  client-side URL parser, no domain allow-list, no MSCT structural check. Keeps R9
  (keyword independence) honest.
- **D7 — Processing indicator follows the existing ingredient-brand rule, not a Wero-specific
  override.** The ~1–2 s overlay shown during the Wero `/document` upload is the existing QR
  overlay. Its indicator selection already honours `ingredientBrandScreens` via PP-3511's
  `IngredientBrandScreen.isEnabled` — nothing new needed. See R10.
- **D8 — Non-Wero / no-classification response routes back to the camera, not the no-results
  screen.** The `/analysis` no-results screen is a nav push with "Retake images" / "Enter
  manually" buttons — meaningless for a user who scanned exactly one QR. The AC6 fallback
  pops the nav stack back to the `CameraViewController` and triggers `handleInvalidQRCode()`,
  so the user ends up in the same visual state as if the camera itself had rejected the
  payload client-side (modal alert when `unsupportedQRCodeWarningEnabled` is true, yellow
  overlay otherwise). Gate narrowed to `qrCodeFormat == nil` so recognised formats
  (BezahlCode, EPC, Stuzza, Swiss QR-bill, …) that happen to upload via `/document` for
  extraction keep their payment-extraction result delivery untouched.

## Requirements

Numbered so unit tests and PR review can tag back.

- **R1 (MUST, happy path, Wero).** Given the Wero flag is ON and the user scans a QR the
  device does not recognise (`qrCodeFormat == nil`) that the backend classifies as
  `paymentQRCodeType = wero`, when `didCapture(document:networkDelegate:)` runs: exactly one
  `/document` upload fires with the raw scanned content in the `qrcode` JSON field; the
  extraction result delivered via `giniCaptureAnalysisDidFinishWith(result:)` contains
  exactly one entry at key `weroPaymentQRCodeUrl` whose value is the original scanned
  payload; no other extraction keys are present.
- **R2 (MUST, happy path, flag off).** Given the Wero flag is OFF and the user scans or
  opens-with an unknown QR, no `/document` upload fires and the existing "unsupported QR
  code" UX (camera path) or no-results screen (open-with picture / PDF) is shown, matching
  today's behaviour for every unknown QR code.
- **R3 (MUST, unhappy path, not Wero).** Given the Wero flag is ON and the backend returns
  `paymentQRCodeType` either missing or not equal to `wero`, no `weroPaymentQRCodeUrl`
  extraction is produced and the camera-side "unsupported QR code" feedback fires via the
  AC6 fallback (nav pops back to camera, `handleInvalidQRCode()` runs). See D8.
- **R4 (MUST, configuration seam).** The Wero flag is read via
  `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled` (seeded from
  `ClientConfiguration.weroQRCodeScanningEnabled`). The default when the backend omits the
  field is **false** (fail-closed). No `WeroFeatureFlag` constant ships.
- **R5 (MUST, recognised codes untouched).** Scanning any `QRCodesFormat` the SDK already
  recognises (`.epc06912`, `.bezahlCode`, `.eps4mobile`, `.giniQRCode`, Swiss QR-bill, …)
  fires no new network call and takes the exact code path it takes today. EPS specifically
  keeps its on-device short-circuit — Wero does not share that short-circuit.
- **R6 (MUST, backend error).** When `/document` upload or `/analysis` fails (HTTP 5xx or
  network failure) while the Wero flag is ON, the SDK surfaces the same error UX a
  GiroCode upload failure takes today. No Wero-specific error branch.
- **R7 (MUST, additive public API only).** Additions:
  (a) `"weroPaymentQRCodeUrl"` extraction key — consumed via `AnalysisResult.extractions`.
  (b) `ClientConfiguration.weroQRCodeScanningEnabled: Bool` field with `= false` default —
      integrators do not construct this manually.
  (c) `AnalysisDelegate.tryDisplayInvalidQRMessage()` — `@objc optional`, so existing
      conformers (including Objective-C integrators) keep compiling without changes.
  (d) `CameraViewController.showUnsupportedQRCodeFeedback()` — public forwarder to the
      pre-existing `handleInvalidQRCode()`, used by the AC6 fallback plumbing.
  (e) `GiniQRCodeDocument.scannedPayload: String` — public accessor exposing the raw
      scanned string so the networking coordinators can forward it verbatim.
  (f) `GiniNetworkingScreenAPICoordinator.mapWeroExtractions(_:scannedPayload:)` /
      `.mapWeroExtractionsIfApplicable(_:)` — public so BankSDK can reuse the same mapper
      from its own `startAnalysisWithReturnAssistant` call-site.
  No breaking changes. No new init parameter on the SDK entry point. No new builder step.
- **R8 (SHOULD, parity with EPS).** The `Extraction` built for Wero has `box: nil`,
  `candidates: nil`, `name == entity == "weroPaymentQRCodeUrl"`, and
  `AnalysisResult.document == nil`, `images == []`, `lineItems == []`, `candidates == [:]`.
- **R9 (MUST, keyword independence).** The gate must not assume the string "wero" (or any
  substring) appears in the QR payload. Legacy iDEAL (NL) and Payconiq (BE/LU) URLs are valid
  Wero codes but contain neither. The decision is backend-only via `paymentQRCodeType`.
- **R10 (MUST, ingredient-brand parity on the Wero processing overlay).** The processing
  overlay shown during the Wero `/document` upload (camera path and open-with picture/PDF
  both) selects its loading indicator via the same ingredient-brand gate already shipped by
  PP-3511, with **no new override**. (a) `ingredientBrandScreens` contains `"Analysis"` →
  Gini custom loader + "Powered by gini" is rendered; the integrator's custom loading
  indicator is **not** shown on this overlay. (b) `ingredientBrandScreens` empty or
  missing `"Analysis"` → default loading indicator; "Powered by gini" is not rendered.

## Affected modules

| Area | File | Why |
| --- | --- | --- |
| Config model | `BankAPILibrary/.../Documents/Configuration/ClientConfiguration.swift` | Add `public let weroQRCodeScanningEnabled: Bool` + init parameter (default `false`). |
| Config storage | `CaptureSDK/.../Core/Storage/GiniCaptureUserDefaultsStorage.swift` | Add `@GiniUserDefault("ginicapture.defaults.clientConfigurations.weroQRCodeScanningEnabled", defaultValue: nil) public static var weroQRCodeScanningEnabled: Bool?`. |
| Config bridge | `BankSDK/.../Core/GiniBankNetworkingScreenApiCoordinator.swift` (around line 312) | One line: `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = configuration.weroQRCodeScanningEnabled`. |
| Flag gate for unknown QR | `CaptureSDK/.../Core/Helpers/GiniCaptureDocumentValidator.swift` | `.none` branch of `validate(qrCode:)` — if `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled == true` let the unknown QR pass validation; otherwise keep today's throw. No new import. |
| Extraction result mapping | `CaptureSDK/.../Networking/GiniNetworkingScreenAPICoordinator.swift` | Public static `mapWeroExtractions(_:scannedPayload:)` + instance `mapWeroExtractionsIfApplicable(_:)`. If flag ON + extractions contain `paymentQRCodeType = wero` + scanned payload available → return single-extraction result with `weroPaymentQRCodeUrl`; otherwise pass-through. Also `shouldRouteBackToCameraForWeroFallback` + the `deliver(…)` fallback branch calling `tryDisplayInvalidQRMessage?()`. Gate narrowed to `qrCodeFormat == nil`. |
| Mapper call-site (BankSDK) | `BankSDK/GiniBankSDK/.../Core/GiniBankNetworkingScreenApiCoordinator.swift` | BankSDK has its own `startAnalysisWithReturnAssistant` + `deliver` (siblings of CaptureSDK's, not inherited). Call `GiniNetworkingScreenAPICoordinator.mapWeroExtractions` on `.success` before `handleSuccessfulAnalysis`; `presentNextScreen` intercepts the Wero fallback via its own `shouldRouteBackToCameraForWeroFallback`. |
| Extraction key constants | `CaptureSDK/.../Core/Helpers/QRCodesExtractor.swift` | `public static let weroPaymentQRCodeUrlKey = "weroPaymentQRCodeUrl"` + `paymentQRCodeTypeKey` + `weroPaymentQRCodeTypeValue`. |
| QR document payload | `CaptureSDK/.../Core/Models/GiniQRCodeDocument.swift` | Promote `scannedPayload` to `public` so the mapper (now in both coordinators) can read the raw scanned payload. Public contract otherwise unchanged. |
| AC6 fallback protocol | `CaptureSDK/.../Core/Screens/Analysis/AnalysisViewController.swift` | Add `@objc optional func tryDisplayInvalidQRMessage()` to `AnalysisDelegate`. |
| AC6 fallback impl | `CaptureSDK/.../Core/Screens/Screen API Coordinator/GiniScreenAPICoordinator+Analysis.swift` | Implement `tryDisplayInvalidQRMessage` — `clearDocuments()`, pop nav stack to `CameraViewController`, after 0.4 s call `cameraVC.showUnsupportedQRCodeFeedback()`. Falls back to `tryDisplayNoResultsScreen` if the camera is not in the stack. |
| Camera public forwarder | `CaptureSDK/.../Core/Screens/Camera/Camera/CameraViewController.swift` | Expose `public func showUnsupportedQRCodeFeedback()` — resets overlay visuals (`qrCodeOverLay.hideAnimation()`, hide, re-enable interaction, reset `validQRCodeProcessing`), then runs `handleInvalidQRCode()`. Also hides `qrCodeFrameView` from `showValidQRCodeFeedback` to prevent the small QR-only brackets drawing inside the big processing overlay on rescans. |
| UI test harness | `BankSDK/GiniBankSDKExample/.../UITestSupport/UITestMockBackend.swift` | Add `weroQRCodeScanningEnabled` to the override list and the flag factory. |
| Test fixtures | `BankAPILibrary/.../Tests/.../Resources/clientConfiguration*.json` | Add `weroQRCodeScanningEnabled` key to all fixtures (except the ones that intentionally omit a required field earlier in decode order). |
| Test fixtures | `CaptureSDK/.../Tests/.../Resources/wero_extraction_fixtures.json` (new) | Single flat file keyed by variant (`wero_type_only`, `wero_with_payment_extractions`, `wero_mixed_case`, `non_wero_classification`, `missing_payment_qr_code_type`) — mapper tests ask for a variant by name. |
| Unit tests | Folded into existing SUT-named files per repo pattern — no new `Wero*Tests.swift` files. See Testing section. |

Not touched by this PR:
- `GiniQRCodeDocument.paymentInformation` serialisation — unchanged. Unknown payloads today
  already serialise as `{"qrcode": "<raw>"}` with no `paymentdata`, which is exactly what the
  Wero path needs.
- `GiniScreenAPICoordinator+Camera.swift` — the convergence point `didCaptureAndValidate(_:)`
  is already upstream of the gate; no change needed.
- `QRCodeOverlay` / `AnalysisViewController` ingredient-brand paths — PP-3511's selection
  logic already fires on the Wero code path with no change (R10 verified by test, not by
  rewiring).
- `GiniBankSDKExample` app — the example-app Wero handoff (opening the URL / routing to a
  Wero flow) is a separate task per scope decision.

## Public API impact

- **Additive:** one new extraction key, delivered through the existing callback.

  ```swift
  func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
      if let weroUrl = result.extractions["weroPaymentQRCodeUrl"]?.value {
          // open Wero flow with URL
      } else {
          // existing extraction handling (iban, amountToPay, …)
      }
  }
  ```

- **Additive:** one new `ClientConfiguration` field. Default on the public init is `false`,
  so existing integrator code that constructs `ClientConfiguration(...)` manually keeps
  compiling. SDK consumption is read-only (via the backend fetch) in production.
- **Additive protocol method:** `AnalysisDelegate.tryDisplayInvalidQRMessage()` as `@objc optional` — existing conformers (including Objective-C integrators) keep compiling without changes.
- No new init parameter on the SDK entry point, no breaking change.

## Testing plan

Swift Testing (`@Suite`, `@Test`, `#expect`) per `.claude/rules/mandatory-rules.md`. Mocks
are manual protocol conformances; fixtures live under `Tests/Resources/` as JSON.

Updated / extended suites — all new coverage lives alongside the SUT it tests, matching
the pattern established by `ingredientBrandScreens` / `unsupportedQRCodeWarningEnabled`:

- **`GiniCaptureDocumentValidatorTests.GiniCaptureDocumentValidatorWeroGateTests`** (new
  Swift Testing suite appended to the existing file) — exercises R2, R5.
  - Flag OFF + unknown payload → validator throws `qrCodeFormatNotValid` (today's
    behaviour).
  - Flag ON + unknown payload → validator does **not** throw (upload proceeds).
  - Flag ON / OFF + recognised EPC payload → format-specific path, Wero gate not reached.

- **`GiniScreenAPICoordinatorTests.GiniNetworkingScreenAPICoordinatorWeroMapperTests`**
  (new Swift Testing suite appended to the existing coordinator-tests file) — exercises
  R1, R3, R6, R8, R9. Calls the pure static mapper
  `GiniNetworkingScreenAPICoordinator.mapWeroExtractions` with `ExtractionResult`s
  decoded from a single consolidated fixture.
  - `paymentQRCodeType = wero` + scanned payload → single-extraction result with
    `weroPaymentQRCodeUrl` = original scanned payload, nil compounds, empty candidates.
  - `paymentQRCodeType` missing / non-`wero` → pass-through unchanged.
  - Backend returns Wero label + other extractions (IBAN, amount) → only
    `weroPaymentQRCodeUrl` survives.
  - Flag OFF → pass-through unchanged even if backend returned Wero label.
  - Scanned payload nil (picture/PDF path) → pass-through unchanged (D5).
  - **R9 round-trip** — parameterised test over six URLs: the four Sparkasse production
    domains (`pay.weropay.eu`, `pay.wero-wallet.eu`, `qr.weropay.eu`, `share.weropay.eu`),
    plus one synthetic NL legacy iDEAL and one BE/LU legacy Payconiq URL.
  - Case-insensitive matching on both the key (`paymentQRCodeType`) and value (`wero`).

- **R10 overlay parity — no new file.** The QR overlay indicator-selection matrix is already
  pinned by `QRCodeOverlayTests` (14+ existing `@Test` cases on
  `GiniCaptureUserDefaultsStorage.ingredientBrandScreens` behaviour). The Wero flow runs the
  overlay through the same selection path with no override, so R10 inherits that coverage
  — no additional test file is added.

- **`GiniQRCodeDocumentTests`** (updated) — three cases that today assert "unknown payload →
  throws" seed the Wero flag via `UserDefaultsFlagLock.acquire()` in `setUp` and assert
  `XCTAssertNoThrow` under flag ON.

- **`RemoteConfigPropagationTests`** (updated — same file as `unsupportedQRCodeWarningEnabled`
  / `ingredientBrandScreens` tests) — two new `@Test` cases assert
  `weroQRCodeScanningEnabled` lands in `GiniCaptureUserDefaultsStorage` after `startSDK`
  (true / false parity).

- **`ClientConfigurationTests`** (updated in `BankAPILibrary`) — existing `init` cases gain
  the new parameter; JSON fixtures gain the new key; one dedicated test
  (`weroQRCodeScanningEnabledDefaultsToFalse`) pins the fail-closed default.

- **Shared storage-flag mutex** added to the existing `GiniCaptureTestsHelper` class
  (`withWeroFlag(_:_:)`, `acquireFlagLock()`, `releaseFlagLock()` plus a private
  `NSLock`). Swift Testing suites (parallel by default) and XCTest classes serialise
  through this single lock so they can't race on the shared storage keys. No new file.

- **Fixtures** — consolidated into
  `CaptureSDK/.../Tests/.../Resources/wero_extraction_fixtures.json`, a single top-level
  object keyed by variant name. Flat (no subdirectory) to match the rest of the test
  resources.

Not in this PR (follow-up tickets):
- XCUITests in `GiniBankSDKExampleUITests` — mirrors the Ingredient Brand PP-3477 pattern.
- Example-app Wero handoff / deep-linking.

## Rollout sequencing

1. **This PR (`feat/PP-3857-wero-qr-support`):** config field + storage + gate + mapper +
   AC6 fallback + unit tests. No hardcoded flag. Default `false` for every client.
2. **PP-3860 (CVIE) backend classification ships:** `/analysis` extractions begin carrying
   `paymentQRCodeType = wero` for payloads matching the Sparkasse Wero URL list. Until this
   lands, every unknown URL falls through to the AC6 camera fallback by design — the mobile
   code is contract-complete and self-activates once CVIE ships, no SDK release required.
3. **Backend flip for Sparkasse (ops):** operations flips `weroQRCodeScanningEnabled: true`
   for the Sparkasse `client_id` so the per-client flag is on in `/configurations`.
4. **GiniBankSDKExample integration (separate task):** example app reads
   `weroPaymentQRCodeUrl` from the callback and opens / logs the Wero URL. Needed for QA
   case `M-TC-F` (integrator handoff).

## Out of scope

- Android (PP-3858), backend classification (PP-3860), backend client flag implementation
  (PP-3856 — done).
- Example-app Wero deep-link routing — tracked as a separate follow-up on the bank-integration
  side.
- Changing the "unsupported QR code" copy or UX.
- Accessibility review of new UI — there is no new UI; the flow reuses existing screens.
- UI customisation docs / release notes — handled by `/gini-release` / `/gini-doc` at
  release time.

## Implementation plan

Ordered to keep the build green at every step: config model + fixtures first (so
`ClientConfigurationTests` keeps passing), then storage, then the bridge, then the two
read sites in CaptureSDK, then the mapper, then UI-test harness, then new test suites.

1. **ClientConfiguration (BankAPILibrary):** add `public let weroQRCodeScanningEnabled: Bool`
   and init parameter (default `false`). Update doc block. One-parameter-per-line formatting.
2. **ClientConfiguration JSON fixtures (BankAPILibrary tests):** add
   `"weroQRCodeScanningEnabled": true|false` to every fixture that today decodes
   successfully. Leave `clientConfigurationMissing.json` and
   `clientConfigurationMissingCreditNoteHint.json` alone — their test contract is "decode
   fails on an earlier missing key", and the new field (added last in CodingKeys declaration
   order) does not interfere with that contract.
3. **`ClientConfigurationTests` (BankAPILibrary):** add `weroQRCodeScanningEnabled: true`
   to the two `init(...)` cases, add a `#expect` on the new field, add a decode assertion,
   add a round-trip assertion.
4. **`NetworkingScreenApiCoordinatorTests.ClientConfiguration` convenience init
   (GiniBankSDK tests):** add `weroQRCodeScanningEnabled: Bool = false` + pass-through.
5. **`RemoteConfigPropagationTests.makeClientConfiguration` (GiniBankSDK tests):** same.
6. **`GiniCaptureUserDefaultsStorage` (CaptureSDK):** add the `@GiniUserDefault` property
   for `weroQRCodeScanningEnabled`.
7. **`GiniBankNetworkingScreenApiCoordinator.startSDK` (BankSDK) around line 312:** persist
   `configuration.weroQRCodeScanningEnabled` into the new storage property.
8. **`QRCodesExtractor` (CaptureSDK):** add
   `weroPaymentQRCodeUrlKey = "weroPaymentQRCodeUrl"`, `paymentQRCodeTypeKey`,
   `weroPaymentQRCodeTypeValue`.
9. **`GiniQRCodeDocument` (CaptureSDK):** drop `fileprivate` on `scannedString`, add internal
   `scannedPayload` accessor with a `/** */` doc block.
10. **`GiniCaptureDocumentValidator.validate(qrCode:)` (CaptureSDK) `.none` branch:** read
    `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false`; throw today's error
    only when it's `false`. No new import (no `GiniBankAPILibrary` dependency added).
11. **`GiniNetworkingScreenAPICoordinator` (CaptureSDK):** add pure static
    `mapWeroExtractions(_:scannedPayload:)` + instance wrapper
    `mapWeroExtractionsIfApplicable(_:)` that reads the first `GiniQRCodeDocument` from
    `pages`. Invoke the wrapper in the `startAnalysis` success branch, before `deliver(...)`.
    Flag is read inside the mapper via `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled`.
12. **`UITestMockBackend` (GiniBankSDKExample):** add `weroQRCodeScanningEnabled` to the
    override-key list and the flag factory. Default `false`.
13. **`GiniQRCodeDocumentTests` (CaptureSDK tests):** update the three "unknown payload →
    throws" cases to seed `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = true`
    and assert `XCTAssertNoThrow`. Add a `tearDown` that resets the flag so other suites
    are not polluted.
14. **New Swift Testing suites folded into existing SUT-named files:**
    `GiniCaptureDocumentValidatorWeroGateTests` appended to
    `GiniCaptureDocumentValidatorTests.swift`;
    `GiniNetworkingScreenAPICoordinatorWeroMapperTests` appended to
    `GiniScreenAPICoordinatorTests.swift`.
    R10 overlay parity inherits coverage from the existing `QRCodeOverlayTests`.
    A single consolidated fixture
    `CaptureSDK/.../Tests/.../Resources/wero_extraction_fixtures.json` keyed by variant
    (`wero_type_only`, `wero_with_payment_extractions`, `wero_mixed_case`,
    `non_wero_classification`, `missing_payment_qr_code_type`) feeds the mapper suite.
    Shared storage-flag mutex lives on `GiniCaptureTestsHelper` (`withWeroFlag`,
    `acquireFlagLock`, `releaseFlagLock`) so Swift Testing and XCTest don't race.
15. **AC6 UX wiring:** `AnalysisDelegate.tryDisplayInvalidQRMessage` (`@objc optional`),
    `GiniScreenAPICoordinator+Analysis` impl (pop + alert), `CameraViewController`
    public `showUnsupportedQRCodeFeedback()`, gate narrowed to `qrCodeFormat == nil`.
16. **Build + test:** `xcodebuild clean test` on `GiniBankAPILibraryTests`,
    `GiniCaptureSDKTests`, and `GiniBankSDKTests` per the CLAUDE.md command.
    `make lint` is currently broken on this machine by a local Ruby/bundler mismatch —
    not a code issue; verify compilation + tests pass instead.
