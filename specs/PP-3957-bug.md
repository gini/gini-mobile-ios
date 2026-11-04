# PP-3957: [iOS] Wero QR code is extracted when "weroQRCodeScanningEnabled" flag is removed from /configurations

Status: fixed
Ticket: https://ginis.atlassian.net/browse/PP-3957

## Symptom

With the `weroQRCodeScanningEnabled` key stripped from the `/configurations`
response (QA repro via Charles), scanning a valid Wero QR code still succeeds
end-to-end: the SDK uploads the partial document, the backend returns
`paymentQRCodeType = wero`, and the SDK delivers the extracted
`weroPaymentQRCodeUrl` through the usual callback.

Expected behaviour (per ticket): the "This is not a payment QR code" dialog
pops up — i.e. the Wero format is treated as unsupported, the same path a
plain unrecognised QR follows when the feature flag is OFF.

Reproduced on RC 1.0 build 1552 (28 Oct 2026), iPhone XR / iOS 18.7.7.

## Reproduction

Static-trace reproduction (sufficient — the root cause is in model decoding
and does not need a simulator run):

1. Checkout branch `fix/PP-3957` (worktree
   `/Users/home/Documents/ios projects/gini-mobile-ios/PP-3957`, tracking
   `origin/release/q4_26`).
2. Open `clientConfigurationMissingCreditNoteHint.json` in
   `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/Resources/`
   — this is the fixture pinning the current fail-closed behaviour for a
   missing non-optional field (see
   `ClientConfigurationTests.decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent`
   at `ClientConfigurationTests.swift:146`).
3. Verify that an equivalent fixture omitting `weroQRCodeScanningEnabled`
   would currently throw `DecodingError.keyNotFound`, by inspection of
   `ClientConfiguration.swift:33`
   (`public let weroQRCodeScanningEnabled: Bool` — non-optional, no custom
   `init(from:)`).

On-device reproduction (bugfix verification path):

1. Launch `GiniBankSDKExample` once with Charles disabled so the real
   backend returns `weroQRCodeScanningEnabled: true` and persists it to
   `UserDefaults`.
2. Restart with Charles rewriting the `/configurations` response to omit
   the `weroQRCodeScanningEnabled` key.
3. Scan a valid Wero QR code.
   Observed: Wero link extracted. Expected: "This is not a payment QR code"
   dialog.

## Root cause

`BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/Documents/Configuration/ClientConfiguration.swift:33`
declares the flag as a bare non-optional `Bool`:

```swift
public let weroQRCodeScanningEnabled: Bool
```

There is no custom `init(from:)`, so Swift's synthesised `Codable`
conformance calls `container.decode(Bool.self, forKey:
.weroQRCodeScanningEnabled)` and throws `DecodingError.keyNotFound` when
the key is absent. That failure is observed and intentional —
`ClientConfigurationTests.decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent`
(same file, lines 146–161) pins the "every feature flag is non-optional,
missing key fails the whole decode" behaviour as a known limitation.

The downstream mechanism from decode failure to the observed symptom:

1. `ClientConfigurationService.fetchConfigurations` wraps the decoded
   configuration in a `Result`. On `keyNotFound` it returns `.failure(error)`.
2. `BankSDK/GiniBankSDK/Sources/GiniBankSDK/Core/GiniBankNetworkingScreenApiCoordinator.swift:301-323`
   is the only call site. The `.success(let configuration)` branch at
   line 304 writes `configuration.weroQRCodeScanningEnabled` into
   `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled` (line 313).
   The `.failure` branch at line 317 only logs — it does not touch storage.
3. `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled` is a
   `@GiniUserDefault("ginicapture.defaults.clientConfigurations.weroQRCodeScanningEnabled", defaultValue: nil)`-wrapped
   `Bool?` (`CaptureSDK/.../Core/Storage/GiniCaptureUserDefaultsStorage.swift:48-50`),
   persisted in `UserDefaults`. When decode fails, the previous session's
   value survives.
4. Four production read sites consult that stored value:
   - `CaptureSDK/.../Core/Helpers/GiniCaptureDocumentValidator.swift:132`
   - `CaptureSDK/.../Networking/GiniNetworkingScreenAPICoordinator.swift:137`
   - `CaptureSDK/.../Networking/GiniNetworkingScreenAPICoordinator.swift:222`
   - `CaptureSDK/.../Core/Screens/Help/DataSources/HelpFormatsDataSource.swift:35`

   All read `… ?? false`. On a device that previously saw the flag as
   `true` and now receives a response without the key, the stored `true`
   is read, Wero processing proceeds, and the ticket's observed symptom
   results.

The invariant the current design assumes — "the backend will always ship
the key once this SDK is deployed" — is exactly what QA breaks via Charles,
and is exactly what will break in production if the backend ever ships a
client whose configuration omits the key (misconfigured tenant, staged
rollout, rollback). The PR body of #1303 flags this risk explicitly.

## Proposed fix

Make the backend's omission a representable state in `ClientConfiguration`
and let the propagation line already in place carry that state through to
`UserDefaults`, so the gates default closed when the backend is silent.

Single-file production change in
`BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/Documents/Configuration/ClientConfiguration.swift`:

- Change `public let weroQRCodeScanningEnabled: Bool` to
  `public let weroQRCodeScanningEnabled: Bool?`.
- Change the matching initializer parameter from `Bool` to `Bool?`.
- Update the doc comment to describe the optional semantics ("`nil` when
  the backend did not include the key").

The synthesised `Codable` conformance then uses `decodeIfPresent` for the
optional field: missing key → `nil`, present → preserved. The existing
propagation line
`GiniBankNetworkingScreenApiCoordinator.swift:313` already types to `Bool?`
and overwrites `UserDefaults` with `nil` when the backend omits the key —
clearing any stale `true` from a prior session. The four gates already
default to `false` via `?? false`, so no changes are needed at those read
sites.

Public API impact: the public initializer parameter and property type
change from `Bool` to `Bool?`. In practice:

- `BankSDK/.../GiniBankNetworkingScreenApiCoordinator.swift:313`
  (`GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled =
  configuration.weroQRCodeScanningEnabled`) — storage is already `Bool?`,
  no change.
- `BankSDK/GiniBankSDKExample/.../UITestSupport/UITestMockBackend.swift:205,454`
  — the `clientConfiguration(flag:)` helper currently returns `Bool`;
  update the call to pass through the optional unchanged (the mock already
  handles the "key absent" case via its own `flag` closure).
- Test fixtures that construct a `ClientConfiguration` programmatically
  (`ClientConfigurationTests.swift`,
  `NetworkingScreenApiCoordinatorTests.swift:709,725`,
  `RemoteConfigPropagationTests.swift:105-121`) — call sites compile
  unchanged because `Bool` is implicitly convertible to `Bool?`.

No other production file touched.

## Regression test plan

Three new tests, following the pattern of existing tests in the same
suites.

**`BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/ClientConfigurationTests.swift`**
— Swift Testing, matching the file's style:

- Fixture: add
  `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/Resources/clientConfigurationMissingWeroQRCodeScanning.json`
  — a copy of the main `clientConfiguration.json` with the
  `weroQRCodeScanningEnabled` key removed.
- Test: `"Decoding succeeds with nil weroQRCodeScanningEnabled when the key is absent"` →
  decode the new fixture, assert
  `config.weroQRCodeScanningEnabled == nil` and no throw.
- Test: `"Decoding preserves weroQRCodeScanningEnabled when present"` ×2
  (true / false) via inline JSON — assert
  `config.weroQRCodeScanningEnabled == .some(true)` / `.some(false)`.

Note: the existing
`decodingFailsWhenCreditNoteHintEnabledKeyIsAbsent` test stays as-is — its
"every flag is non-optional" claim is now scoped to the still-non-optional
flags; the doc comment on that test is tightened to say "except
`weroQRCodeScanningEnabled`, which is optional for backend-rollout
tolerance (PP-3957)".

**`BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/RemoteConfigPropagationTests.swift`**
— Swift Testing, extending the existing suite:

- Test: `"weroQRCodeScanningEnabled=nil from remote config clears persisted storage"` —
  seed `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = true`
  (simulating a prior session where the backend returned `true`), run
  `runStartSDK` with a `ClientConfiguration` whose
  `weroQRCodeScanningEnabled == nil`, assert
  `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled == nil`.

This test fails before the fix (programmatic construction with
`weroQRCodeScanningEnabled: nil` is not even expressible until the type
changes) and passes after.

## Out of scope

- Transient `fetchConfigurations` network failures — the
  `.failure(let error)` branch at
  `GiniBankNetworkingScreenApiCoordinator.swift:317` legitimately preserves
  the last-known-good value for a user mid-session with a flaky network.
  Conflating that with "backend responded without the key" would hurt the
  happy path (every spurious network blip would disable Wero). Not changing
  the `.failure` branch.
- The other feature flags (`skontoEnabled`, `transactionDocsEnabled`, …)
  are intentionally still non-optional. This fix is scoped to
  `weroQRCodeScanningEnabled` because it is the only field whose backend
  rollout timing lags the SDK release (per PR #1303 body). Making the
  other flags optional is a design question for a separate ticket if we
  ever hit the same rollout pattern again.
- Backend defect PP-3925 ("weroQRCodeScanningEnabled is missing in
  /configurations") — mobile and backend fixes are complementary. This fix
  makes the SDK robust; PP-3925 fixes the backend. Both should ship.
- The ticket's linked PP-3946 ("Test Execution for Test Plan for 4.7.0 Fix
  versions: Wero QR Code Feature Testing") — QA execution, no code change.

## Open questions

- Ticket is Backlog (not assigned, Priority Medium). Proceeding because
  (a) it is a release-blocker for 4.7.0 (same fix versions as PR #1303),
  (b) the diagnosis is unambiguous, (c) the fix is single-file and
  single-field.
- No release-notes change expected: the public type widening from `Bool`
  to `Bool?` is backwards-compatible for the propagation call sites in
  this repo, but it is a public API change in `GiniBankAPILibrary`.
  Flagging in PR body so release notes can mention it under 4.7.0 if the
  release owner wants.
