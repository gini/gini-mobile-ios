# PP-3907: [iOS] Add Wero to supported formats on the No results screen

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3907
Parent epic: PP-2666 "[Q4] Wero QR code support"
Sibling: PP-3857 "Return Wero URL for unrecognised QR codes" — provides the
`weroQRCodeScanningEnabled` flag storage and the camera-side fallback. This
ticket is the UI label follow-up on the same epic.
Branch: `PP-3907` off `feat/PP-3857-wero-qr-support`
Figma: https://www.figma.com/design/H8lHbhBB23gsGg6dlOMkmS/iOS-Gini-Bank-SDK-4.6-UI-Customisation?node-id=2502-12690

## Problem

Sparkasse's customers can now scan Wero QR codes thanks to PP-3857, but when a
scan returns no payment info and the No results screen is shown, the "Supported
QR codes" list does not include Wero. A user who scanned a Wero code and sees it
missing from the list reasonably concludes Wero is unsupported, even though the
flag is ON and the flow would have worked for a backend-classified Wero payload.

The ticket adds "Wero QR code" as the fifth entry in that list, immediately
after Girocode (DE), gated on the same `weroQRCodeScanningEnabled` flag that
PP-3857 already surfaces through `ClientConfiguration` →
`GiniCaptureUserDefaultsStorage`. When the flag is OFF or missing (fail-closed),
the list is unchanged from today.

## Requirements

- **R1 (MUST, happy path).** Given `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled`
  is `true`, when a `HelpFormatsDataSource` is initialised with
  `isQRCodeContent: true`, then its `qrCodeItemSections[0].formats` contains
  exactly 11 entries in this order: `BezahlCode, eps Überweisung, Stuzza (AT),
  Girocode (DE), QR by Gini, Swiss QR Code (CH), SPD (CZ), Pay by Square (SK),
  UPN QR (SI), HUB3 (HR), Wero QR code`. The "Wero QR code" entry is the
  localized value of key `ginicapture.help.supportedFormats.qrcode.item.11`.
- **R2 (MUST, flag off).** Given `weroQRCodeScanningEnabled` is `false`, when a
  `HelpFormatsDataSource` is initialised with `isQRCodeContent: true`, then
  `qrCodeItemSections[0].formats` contains exactly 10 entries — the pre-PP-3907
  list (BezahlCode … HUB3 (HR)), byte-identical to today's order. No Wero entry
  is present.
- **R3 (MUST, flag missing).** Given `weroQRCodeScanningEnabled` is `nil` (the
  backend never returned the field — fail-closed per PP-3857 R4), the result is
  identical to R2: 10 entries, no Wero entry.
- **R4 (MUST, pdfItemSections untouched).** Given a `HelpFormatsDataSource`
  initialised with the default `isQRCodeContent: false`, then `pdfItemSections`
  is identical to today for every combination of `weroQRCodeScanningEnabled` ∈
  `{true, false, nil}`. The No results screen's PDF/image path and the Help ›
  Supported formats screen (`HelpFormatsViewController`) are not affected.
- **R5 (MUST, cell rendering parity).** The row rendered for "Wero QR code" uses
  `Images.supportedFormatsIcon` (same icon as the other ten rows), the same
  `textStyleFonts[.body]` font, and the same light/dark `GiniCapture.dark1/light1`
  text color. Its `accessibilityLabel` equals the localized Wero string. No
  new asset ships.
- **R6 (MUST, localization).** The key
  `ginicapture.help.supportedFormats.qrcode.item.11` exists in both
  `Sources/GiniCaptureSDK/Resources/en.lproj/Localizable.strings` and
  `Sources/GiniCaptureSDK/Resources/de.lproj/Localizable.strings`, with value
  `"Wero QR code"` (identical string in both locales — confirmed by user; the
  phrase is treated as a brand label like `BezahlCode` or `Girocode (DE)`).
- **R7 (SHOULD, config-propagation unchanged).** No new call site is needed for
  the flag — the propagation chain established by PP-3857
  (`ClientConfiguration.weroQRCodeScanningEnabled` →
  `GiniBankNetworkingScreenApiCoordinator.startSDK` →
  `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled`) already lands the
  value before the user can navigate to the No results screen. No new
  `GiniBankAPILibrary` import from `HelpFormatsDataSource`.

## Affected modules

| Area | File | Why |
| --- | --- | --- |
| Data source | `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Screens/Help/DataSources/HelpFormatsDataSource.swift` | Change `let sections` to `var sections`; after the literal, append `Strings.qrcodeItem11` to `sections[0].formats` when `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false` is `true`. Mirrors the `eInvoiceEnabled` precedent on `pdfItemSections` (line 61). Add `Strings.qrcodeItem11` static constant pointing at the new localization key. |
| Localization (en) | `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/en.lproj/Localizable.strings` | Add `"ginicapture.help.supportedFormats.qrcode.item.11" = "Wero QR code";` after the `qrcode.item.10` line (around current line 158). |
| Localization (de) | `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Resources/de.lproj/Localizable.strings` | Same key, same value `"Wero QR code"` (brand label, not translated) — added after current line 192. |
| Unit tests | `CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/HelpFormatsDataSourceWeroTests.swift` (new) | Swift Testing suite covering R1/R2/R3/R4/R6. Uses the existing `GiniCaptureTestsHelper.withWeroFlag(_:_:)` helper for flag-mutex-safe parallel execution. |

Not touched by this PR:
- `HelpFormatsViewController` and `pdfItemSections` — unrelated path.
- `NoResultScreenViewController` — it reads from the data source; no behavioural
  change needed at this layer.
- `GiniCaptureUserDefaultsStorage` — the Wero flag property is already present
  from PP-3857.
- `ClientConfiguration` / `GiniBankNetworkingScreenApiCoordinator` — the
  propagation chain is already live (PP-3857).
- `SupportedFormatsViewControllerTests.swift` — it only exercises
  `HelpFormatsViewController` (PDF/image path, R4). Section/row counts there
  stay unchanged and no edit is needed.

## Public API impact

**None.** `HelpFormatsDataSource` is `internal` (no access modifier →
default `internal`). `qrCodeItemSections` is a `lazy var` on an internal class.
The new `Strings.qrcodeItem11` is `private`. The localization key is a new
string key — additive, keyed via `NSLocalizedStringPreferredFormat` through the
3-level lookup chain, which integrators can override in their own bundle
(no breakage; absent integrator override, the SDK bundle value wins).

## Technical conventions

1. **Language and access control.** Swift. All new declarations stay
   `internal` (default) or `private`. No `public`/`open` additions. Doc-comment
   style per `.claude/rules/mandatory-rules.md` (`/** */` on `Strings.qrcodeItem11`
   if any doc is added; the existing siblings carry only the `comment:` argument
   on `NSLocalizedStringPreferredFormat` and no `/** */` block — match that
   precedent and skip the doc).
2. **UI.** Existing UIKit screen; no new UI framework. No SwiftUI, no Liquid
   Glass surface here. Colors/fonts/spacing: reuse the existing `GiniColor`
   expressions and `textStyleFonts[.body]` already applied in
   `HelpFormatsDataSource.configureCell` (lines 93–104 today) — no changes to
   those lines. No new asset.
3. **Architecture.** The screen stays MVVM-flavoured UIKit with
   `NoResultScreenViewController` + `BottomButtonsViewModel`. The data source is
   not a view model; it's a `UITableViewDataSource` subclass. No new coordinator /
   view model / view controller types.
4. **Wiring.** No DI change. Flag is read via static accessor
   `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled` — same read
   pattern as `GiniCaptureUserDefaultsStorage.eInvoiceEnabled` at
   `HelpFormatsDataSource.swift:61`. No new import; `GiniCaptureUserDefaultsStorage`
   is in the same module. No `async`/`await` surface.
5. **Localization.** Key convention `ginicapture.help.supportedFormats.qrcode.item.11`
   matches existing items 1–10. 3-level lookup chain (host app → custom bundle →
   SDK bundle) applies automatically via `NSLocalizedStringPreferredFormat`.
   `.strings` files touched: `en.lproj` + `de.lproj` only (the two existing
   locales — no other `.lproj` folders ship in this SDK).
6. **Quality gates.** `make lint scheme=GiniCaptureSDK` clean (per `AGENTS.md`).
   `xcodebuild clean test` on `GiniCaptureSDKTests` on `iPhone 16 / iOS 26.2`
   (per `CLAUDE.md`) must stay green. Swift Testing framework for the new
   `HelpFormatsDataSourceWeroTests` suite; multi-parameter formatting rule
   doesn't apply (no new multi-parameter signatures introduced).

## Design

### Data-source change — minimal diff

Convert the current `qrCodeItemSections` from a flat 10-element literal into a
builder that inserts the Wero entry conditionally. Pattern mirrors the existing
`eInvoiceEnabled` branch in `pdfItemSections` (`HelpFormatsDataSource.swift:61`).

Before (`HelpFormatsDataSource.swift:17-36`):

```swift
lazy var qrCodeItemSections: [HelpFormatsCollectionSection] = {
    let sections: [HelpFormatsCollectionSection] = [
        (title: Strings.section1Title,
         formats: [
            Strings.qrcodeItem1,
            Strings.qrcodeItem2,
            Strings.qrcodeItem3,
            Strings.qrcodeItem4,
            Strings.qrcodeItem5,
            Strings.qrcodeItem6,
            Strings.qrcodeItem7,
            Strings.qrcodeItem8,
            Strings.qrcodeItem9,
            Strings.qrcodeItem10
         ],
         formatsImage: Images.supportedFormatsIcon)
    ]

    return sections
}()
```

After:

```swift
lazy var qrCodeItemSections: [HelpFormatsCollectionSection] = {
    var formats: [String] = [
        Strings.qrcodeItem1,
        Strings.qrcodeItem2,
        Strings.qrcodeItem3,
        Strings.qrcodeItem4
    ]

    if GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false {
        formats.append(Strings.qrcodeItem11)
    }

    formats.append(contentsOf: [
        Strings.qrcodeItem5,
        Strings.qrcodeItem6,
        Strings.qrcodeItem7,
        Strings.qrcodeItem8,
        Strings.qrcodeItem9,
        Strings.qrcodeItem10
    ])

    return [
        (title: Strings.section1Title,
         formats: formats,
         formatsImage: Images.supportedFormatsIcon)
    ]
}()
```

And in the `Strings` struct, append (around line 219):

```swift
static let qrcodeItem11 = NSLocalizedStringPreferredFormat(
    "ginicapture.help.supportedFormats.qrcode.item.11",
    comment: "QR code type item 11"
)
```

**Lazy-var timing.** `qrCodeItemSections` is `lazy`, so the flag is read at the
first access per instance. `NoResultScreenViewController` constructs a fresh
`HelpFormatsDataSource(isQRCodeContent: true)` on each `init` (see
`NoResultScreenViewController.swift:73`), so a user who re-enters the No results
screen after a config refresh gets the up-to-date list. This matches the
`eInvoiceEnabled` precedent — same semantics, same reasoning.

### Localization

`en.lproj/Localizable.strings` — insert immediately after
`"ginicapture.help.supportedFormats.qrcode.item.10" = "HUB3 (HR)";` (current
line 158):

```
"ginicapture.help.supportedFormats.qrcode.item.11" = "Wero QR code";
```

`de.lproj/Localizable.strings` — same insertion after line 192:

```
"ginicapture.help.supportedFormats.qrcode.item.11" = "Wero QR code";
```

User confirmed the German string is identical to English — "Wero QR code" is
treated as a brand label (precedent: `BezahlCode`, `Girocode (DE)`,
`Swiss QR Code (CH)` keep the same brand/region string in both locales).

### Rendering

`HelpFormatsDataSource.configureCell` (`HelpFormatsDataSource.swift:90-111`)
already does the right thing: it reads `section.formats[indexPath.row]`, binds
it to `cell.descriptionLabel.text`, assigns `section.formatsImage` (which is
`Images.supportedFormatsIcon` for the QR section), applies the Capture
`body` font and dynamic light/dark colors, and sets `cell.accessibilityLabel`
equal to the item string. No change needed here. The last-row separator rule
(`cell.separatorView.isHidden = indexPath.row == items[indexPath.section].formats.count - 1`,
line 106) adapts to the new count automatically.

## Test plan

New Swift Testing suite file:
`CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/HelpFormatsDataSourceWeroTests.swift`.

Framework: Swift Testing (`@Suite`, `@Test`, `#expect`) per
`.claude/rules/mandatory-rules.md`. Serialises on the shared
`GiniCaptureTestsHelper.withWeroFlag(_:_:)` mutex (file:
`CaptureSDK/GiniCaptureSDK/Tests/GiniCaptureSDKTests/GiniCaptureTestsHelper.swift`,
lines 85–120) so it can run alongside XCTest suites (which hold the same lock)
and other Swift Testing suites (which run in parallel) without racing on the
shared `UserDefaults` key.

### Suite: `HelpFormatsDataSourceWeroTests` (new file, ~6 tests)

Scope: `HelpFormatsDataSource` only — pure data-source behaviour. The No results
screen integration (presenting the data source via `NoResultScreenViewController`)
is covered by the existing coordinator-level test
`GiniScreenAPICoordinatorTests.swift:928-954` ("`tryDisplayNoResultsScreen`
actually pushes a `NoResultScreenViewController`") and does not need to be
duplicated here.

1. **`weroFlagOn_qrCodeSection_insertsWeroAtSlot5` — proves R1.**
   Seeds flag `true` via `withWeroFlag(true)`, creates
   `HelpFormatsDataSource(isQRCodeContent: true)`, reads
   `qrCodeItemSections[0].formats`, and `#expect`s:
   - `formats.count == 11`
   - `formats[4]` equals the resolved string for
     `ginicapture.help.supportedFormats.qrcode.item.11` (loaded via
     `NSLocalizedStringPreferredFormat` through the SDK bundle in the test
     process — equals `"Wero QR code"`)
   - the surrounding order matches: `formats[3]` is Girocode (DE),
     `formats[5]` is QR by Gini (today's item 5), `formats[10]` is HUB3 (HR).
2. **`weroFlagOff_qrCodeSection_isTenItemsNoWero` — proves R2.**
   Seeds flag `false`, same data source, `#expect`s:
   - `formats.count == 10`
   - `formats` equals today's 10-item array in exact order
   - the resolved Wero string is NOT present (`formats.contains(weroString) == false`).
3. **`weroFlagMissing_qrCodeSection_isTenItemsNoWero` — proves R3.**
   Seeds flag `nil` via `withWeroFlag(nil)`, same assertion as the flag-off case.
4. **`pdfItemSections_unchanged_underEveryFlagValue` — proves R4.**
   Three-case parameterised test over `[nil, false, true]`. For each value,
   build `HelpFormatsDataSource()` (default `isQRCodeContent: false`), compare
   `pdfItemSections` section-count and per-section `formats.count` against the
   same instance built with the Wero flag seeded to `false` as the baseline.
   `#expect` byte-equal across the three cases.
5. **`weroStringKey_resolvesInEnglish` — proves R6 (en).**
   `#expect(Strings.qrcodeItem11 == "Wero QR code")` after resolving via the
   SDK bundle. The bundle returned by `giniCaptureBundle()` already resolves
   under the test host's chosen locale; this test runs with the default
   bundle locale resolution that `SupportedFormatsViewControllerTests` already
   relies on (line 23). Does not force a locale.
6. **`weroRow_rendersSupportedFormatsIcon_andFontColors` — proves R5.**
   Seeds flag `true`, instantiates `HelpFormatsViewController`-style
   consumption: build a `UITableView(frame: .zero, style: .insetGrouped)`,
   call `dataSource.tableView(_:cellForRowAt:)` for
   `IndexPath(row: 4, section: 0)`, cast to `HelpFormatCell`, and
   `#expect`:
   - `cell.iconImageView.image === Images.supportedFormatsIcon` (identity on
     the cached `UIImageNamedPreferred` instance — if identity turns out to
     be fragile across runs, fall back to asserting
     `cell.iconImageView.image != nil` and `cell.descriptionLabel.text ==
     "Wero QR code"`; raise this as an open question if the first assertion
     flakes).
   - `cell.descriptionLabel.text == "Wero QR code"`
   - `cell.accessibilityLabel == "Wero QR code"`

### Fixtures

None. No JSON. No new `Tests/Resources/` entries. The tests consume `UserDefaults`
state through `withWeroFlag` and compare against locally-constructed string
arrays plus the already-shipped `.strings` resources.

### Not tested

- `NoResultScreenViewController` presenting a `HelpFormatsDataSource(isQRCodeContent: true)`
  — the init-switch at `NoResultScreenViewController.swift:65-74` is trivial
  delegation and already proven by the existing coordinator test
  (`GiniScreenAPICoordinatorTests.swift:928-954`) that pushes the correct
  screen type. Adding a presentation test here would re-cover a path PP-3857
  already pins.
- `HelpFormatsViewController` behaviour (PDF/image path) is already covered by
  `SupportedFormatsViewControllerTests` (XCTest) — no edit needed. R4 adds a
  Wero-specific no-op check on the same path.
- VoiceOver / Dynamic Type / dark-mode visual parity for the new row — the row
  reuses the existing cell configuration unchanged (verified by reading
  `configureCell`); regression risk here is zero. Manual QA will still run the
  flow on the Figma case.
- Snapshot/UI tests — no snapshot library in this repo (per `platform.md`).
  Visual verification is manual QA against the Figma mock on the ticket.

### Manual QA

- Device: Sparkasse-flavoured client / UI test harness with
  `UITestMockBackend.clientConfigurationOverrides.weroQRCodeScanningEnabled = true`
  (override wiring already in place from PP-3857).
- Reach the No results screen via the open-with picture / PDF path (per PP-3857
  D5 — camera-side Wero fallback bypasses this screen) with any file that
  returns no payment extractions.
- Verify "Wero QR code" appears as the fifth row in English and in German.
- Switch the flag off (second run) and verify the row disappears and the list
  returns to 10 items in the original order.

## Rollout sequencing

This ticket depends on PP-3857 (merged on `feat/PP-3857-wero-qr-support`, the
base branch) for the flag storage + propagation and on nothing else. No backend
dependency. No separate release note required beyond the one-line entry rolled
into the `GiniCaptureSDK` / `GiniBankSDK` release that ships PP-3857.

- Ship with the next GiniCaptureSDK release that includes PP-3857.
- Operations flips `weroQRCodeScanningEnabled: true` for the Sparkasse
  `client_id` in `/configurations` (same ops step PP-3857 waits on). No separate
  flip needed for PP-3907.

## Out of scope

- Android equivalent — tracked separately on PP-2666.
- The `qrcodeItem1`…`qrcodeItem10` ordering, strings, or icons.
- The Help › Supported formats screen (`HelpFormatsViewController`), which does
  not render the QR list (uses `pdfItemSections`).
- No results screen presentation / layout changes outside the formats list.
- Wero asset design (no custom icon; uses existing checkmark).
- Analytics tagging — `GiniAnalyticsManager.trackScreenShown(screenName: .noResults)`
  already fires on this screen; no new event is proposed.
- UI customisation docs / release notes — handled by `/gini-doc` and
  `/gini-release` at release time.

## Implementation plan

- [x] 1. Add localization key `qrcode.item.11 = "Wero QR code"` to `en.lproj/Localizable.strings` and `de.lproj/Localizable.strings` (R6)
- [x] 2. Add `Strings.qrcodeItem11` static constant in `HelpFormatsDataSource.swift` (prereq for R1/R5)
- [x] 3. Write Swift Testing suite `HelpFormatsDataSourceWeroTests.swift` under `Tests/GiniCaptureSDKTests/` with 6 tests (R1, R2, R3, R4, R5, R6) using `GiniCaptureTestsHelper.withWeroFlag(_:_:)` — tests fail against current `qrCodeItemSections`
- [x] 4. Modify `qrCodeItemSections` lazy init to insert `Strings.qrcodeItem11` at slot 5 when `GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled ?? false` (R1, R2, R3, R4) — tests pass
- [x] 5. Verify: `xcodebuild test` on `GiniCaptureSDK` scheme (`iPhone 16 / iOS 18.6` simulator). `make lint` skipped — broken by local Ruby/bundler mismatch (same issue noted in PP-3857 spec); re-run on CI parity before pushing.

## Open questions

None blocking. One soft call-out:

- The sixth test's assertion
  `cell.iconImageView.image === Images.supportedFormatsIcon` relies on
  `UIImageNamedPreferred` returning the same `UIImage` instance for the same
  name during a single test process run — true for `UIImage(named:)` under the
  default caching behaviour but worth re-checking during
  `/gini-build`. Fallback: assert `image != nil` and the row's text/icon pair
  via other means. Not load-bearing on R5; the row behaviour is driven by
  `section.formatsImage` which is set to `Images.supportedFormatsIcon`
  unconditionally in the data source — the test is covering a UI contract that
  the code already enforces by construction.
