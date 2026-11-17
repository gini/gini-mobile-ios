# PP-3997: GiniOptionRow in GiniUtilites

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3997
Parent story: PP-3960 "[iOS] Fraud warning screen: IBAN mismatch"
Spike reference: PR [#1308 (PP-3938-fraud)](https://github.com/gini/gini-mobile-ios/pull/1308) ("Spike IBAN mismatch sheet-over-modal flow", branch `PP-3938-fraud`) — inline primitive in `BankSDK/.../FraudMismatch/IBANPickerSheet.swift` that this ticket promotes to shared `GiniUtilites`.
Branch: `PP-3997` off `release/fraud-prevention-phase`
Worktree: `/Users/home/Documents/ios projects/PP-3997/`
Figma: [node 38468-42450](https://www.figma.com/design/ZYpdKfpaHOpV7RV1TTWdEH/Gini-Photo-Payment--iOS---Android?node-id=38468-42450)

## Problem

Parent story PP-3960 ("[iOS] Fraud warning screen: IBAN mismatch") displays a post-analysis warning modal when the backend returns `QR_PRINTED_IBAN_MISMATCH` or `IBAN_COUNTRY_MISMATCH`. Its AC requires "screen parts are built as reusable components to be used in other scenarios also, with content set per case." The PP-3938 spike inlines a radio-button-with-label row inside the BankSDK's `IBANPickerSheet.swift`; that primitive must move into shared `GiniUtilites` so (a) the productionized fraud screen can consume it, (b) later features that need a selectable info row can reuse it without copying the spike.

The component must render four radio visual states — unselected, selected, disabled, error — with an optional red warning footer, plus a sibling `.informational` variant (no leading indicator; optional background) for the no-radio display row shown in the designs (images 7 & 8).

## Decisions (from Q&A during implementation)

| Question | Answer |
|---|---|
| PR scope | **Component + tests only** — no example-app showcase, no FraudMismatch swap. |
| iOS 16+ bump | **`@available`-gate, don't bump `Package.swift`** — GiniUtilites stays iOS 15; new type marked `@available(iOS 16.0, *)`. |
| Component name | **`GiniOptionRow`** — generic primitive; Gini-prefixed per repo convention for public GiniUtilites types. |
| Liquid Glass | **Dropped the dedicated `.glassEffect` branch** — row has no background of its own; the parent sheet (which is Liquid Glass on iOS 26+) owns the surface, so the row doesn't double-stack glass. |
| No-radio variant | Shaped as `Variant.informational` (vs. 5th `State` case) so radio states can't leak into the informational path. Accepts an optional `background: GiniColor?` since there's no leading indicator to anchor the row. |
| Discriminator-enum name | **`Variant`** (not `Kind`/`Role`/`Style`/`Type`) — explicitly chosen by user. |
| Colors param | Kept as explicit `giniColorScheme: GiniColorScheme` init param (env-based theming deferred to a follow-up ticket). |
| Fonts param | Collapsed to a single `fonts: FontConfig = .default` nested struct wrapping `title/content/footer: UIFont?`. Accepts fonts the host SDK already resolves (`giniBankConfiguration.textStyleFonts[.X]` or `giniHealthConfiguration.font(for: .X)`); `nil` falls back to SwiftUI system fonts. |

## Files

All under `GiniComponents/Utilities/GiniUtilites/`:

| Area | File |
|---|---|
| Component | `Sources/GiniUtilites/Views/GiniOptionRow/GiniOptionRow.swift` |
| Preview catalog (`#if DEBUG`) | `Sources/GiniUtilites/Views/GiniOptionRow/GiniOptionRowPreviewCatalog.swift` |
| Unit tests | `Tests/GiniUtilitesTests/Views/GiniOptionRowTests.swift` |
| Pre-existing utility moved | `Sources/GiniUtilites/SwiftUI/GiniHeightPreferenceKey.swift` → `Sources/GiniUtilites/Views/GiniHeightPreferenceKey.swift` (via `git mv` so history is preserved; the empty `SwiftUI/` folder was removed as part of the move) |

**Not touched:**
- `GiniUtilites/Package.swift` — deployment target stays `.iOS(.v15)`.
- `BankSDK/.../FraudMismatch/IBANPickerSheet.swift` — consumer swap deferred to a later PP-3960 subtask.
- Any SDK-side scheme factory (`UIColor.giniBankColorScheme()` etc.) — unchanged; caller passes the scheme in.
- Localization `.strings` files — primitive takes resolved strings.

## Public API impact

**`GiniUtilites` — additive only.** New public symbols:

1. `public struct GiniOptionRow: View` — marked `@available(iOS 16.0, *)`.
2. `public enum GiniOptionRow.RadioButtonState: Hashable` — `unselected`, `selected`, `disabled`, `error`.
3. `public enum GiniOptionRow.Variant: Hashable` — `radio(RadioButtonState)`, `informational`.
4. `public struct GiniOptionRow.FontConfig` — `title/content/footer: UIFont?` with `.default` static.
5. `public init(...)` on `GiniOptionRow`.

Public initializer:
```swift
public init(title: String,
            content: String,
            footer: String? = nil,
            variant: Variant,
            giniColorScheme: GiniColorScheme,
            background: GiniColor? = nil,
            fonts: FontConfig = .default,
            onTap: (() -> Void)? = nil)
```

No removals, no signature changes to existing types. `GiniColorScheme` and `GiniColor` are already `public` in `GiniUtilites` so no uplift is required. `GiniUtilites` is an internal shared package per `.claude/skills/gini-review/platform.md:68-78`, so none of this becomes customer-facing API unless a customer-facing SDK re-exports it — which does not happen here.

## Requirements

- **R1 (MUST, entry).** Importing `GiniUtilites` from any iOS 16+ target exposes `GiniOptionRow` with the init signature above. `GiniUtilites` SPM `platforms:` stays `.iOS(.v15)`.
- **R2 (MUST, radio state → icon + tint).** Four radio states map to the following leading icon:
  - `.radio(.unselected)` → SF Symbol `circle` / `icon.secondary`
  - `.radio(.selected)` → custom `Circle()` stroked with `text.accent` (blue, 2.5pt), hollow interior — matches the Figma thick-blue-ring design
  - `.radio(.disabled)` → SF Symbol `circle` / `text.tertiary`
  - `.radio(.error)` → custom `Circle()` filled with `message.backgroundError` (light pink) and stroked with `message.contentError` (red, 1.5pt) — the pink fill reads distinctly from the red stroke, matching the Figma design
- **R3 (MUST, informational variant).** `.informational` renders the title + content + optional footer with **no leading indicator**, applies the optional `background: GiniColor?` as a rounded-rect fill, and skips the radio-state logic entirely.
- **R4 (MUST, text tinting).** For any variant: the title color is `text.tertiary` iff `variant == .radio(.disabled)` otherwise `text.secondary`; the content color is `text.tertiary` iff disabled otherwise `text.primary`; the footer (when non-nil) is always `text.error`.
- **R5 (MUST, typography).** The title uses the font `fonts.title ?? .caption` (SwiftUI's `.caption` maps to iOS `.caption1`); the content uses `fonts.content ?? .body` (regular weight, **not** monospaced — matches Figma); the footer uses `fonts.footer ?? .footnote`. Non-nil `UIFont`s are bridged to SwiftUI via `Font(giniFont:)` from `GiniUtilites/Font/Font+Extensions.swift`.
- **R6 (MUST, interaction).** When `onTap != nil` and `variant.isDisabled == false`, the row is wrapped in a `Button` and invokes `onTap` on tap. When `onTap == nil`, no `Button` is used (plain non-interactive layout). When `variant.isDisabled == true`, the underlying `Button` carries `.disabled(true)`; `onTap` is not invoked.
- **R7 (MUST, accessibility).** The row reads as a single element via `.accessibilityElement(children: .combine)` with a label built from `"title, content"` or `"title, content, footer"`. The `.isSelected` trait is added iff `variant == .radio(.selected)`. The `.disabled()` modifier handles VoiceOver's "not enabled" announcement for `.radio(.disabled)`.
- **R8 (MUST, Reduce Motion).** `@Environment(\.accessibilityReduceMotion)` gates the state-transition animation: `0.2s .easeInOut` when motion is allowed, `nil` otherwise.
- **R9 (SHOULD, Dynamic Type).** SwiftUI system-font fallbacks (`.subheadline` / `.body.weight(.semibold)` / `.footnote`) carry Dynamic Type natively; `.fixedSize(horizontal: false, vertical: true)` keeps multi-line IBAN wrapping without height clipping. Parent screens must still verify their own layout at AX3+.
- **R10 (SHOULD, out-of-scope guardrails).** This ticket ships only the primitive and tests — no consumer migration in `BankSDK/.../IBANPickerSheet.swift`, no demo screen in `GiniBankSDKExampleSwiftUI`, no `Package.swift` deployment-target bump.

## Technical conventions

1. **Language and access control.** Swift. `public` on `GiniOptionRow`, its nested `RadioButtonState` / `Variant` / `FontConfig` enums+struct, and the initializer. Everything else — the `isDisabled`/`isSelected` extension on `Variant`, `Constants`, `GiniOptionRowAccessibility`, the preview catalog — is `internal`. Doc comments use `/** */` for declarations; `///` is reserved for single-line inline body comments and single-line enum-case docs (per `.claude/rules/mandatory-rules.md` §Documentation).
2. **UI.** SwiftUI. Colors resolve from the caller-passed `GiniColorScheme`, bridged via `GiniColor.swiftUIColor()` — no hardcoded `Color.blue` / `Color.red`. Fonts default to SwiftUI system styles (`.subheadline`, `.body.weight(.semibold)`, `.footnote`) which carry Dynamic Type natively; `FontConfig` lets host SDKs inject their own `UIFont`s. Spacing is centralized in a local `enum Constants`.
3. **Liquid Glass.** No row-level glass background. Parent sheet (which IS Liquid Glass on iOS 26+ per PP-3960's AC) owns the surface; the row sits on top with transparent background to avoid double-stacking.
4. **Architecture.** Standalone presentational SwiftUI primitive — no coordinator / view model / view controller apply. It is composed inside parent screens that follow MVVM + Coordinator (e.g. the PP-3960 fraud screen).
5. **Wiring.** No DI framework; all inputs flow through the public initializer. No concurrency — pure synchronous view body. No delegate back-reference.
6. **Localization.** No `.strings` entries. The primitive accepts already-localized `String`s; keys belong to the consuming screen's subtask.
7. **Quality gates.** CI-parity test command: `xcodebuild test -scheme GiniUtilites -destination "platform=iOS Simulator,name=iPhone 17 CI,OS=26.2"`. Swift Testing (`@Suite` / `@Test` / `#expect`) used for the new suite — matches neighboring GiniUtilites tests. Multi-parameter init formatting follows first-param-on-open-paren + aligned-subsequent per `.claude/rules/mandatory-rules.md`.

## Design

### Public view
`GiniOptionRow` stores its eight inputs as `let` properties; `body` emits `rowContent` with the animation / accessibility modifiers applied. `rowContent` branches on `onTap`: if non-nil, wraps `rowLayout` in a `Button(.plain)` with `.disabled(variant.isDisabled)`; otherwise renders `rowLayout` directly. `rowLayout` is an `HStack(alignment: .top)` containing — only for `.radio(_)` — the `stateIcon`, then the `textStack` VStack, then a `Spacer(minLength: 0)`, all padded by `Constants.contentPadding` with an optional `backgroundLayer` behind.

### State → token resolution
- `titleColor` / `contentColor` / `footerColor` are private computed properties on the view: they inspect `variant` and resolve colors from `giniColorScheme`.
- `Variant.isDisabled` / `Variant.isSelected` are lifted to an `extension GiniOptionRow.Variant` (file-scope, `@available(iOS 16.0, *)`) for reuse in view code — pure functions over the discriminator.
- `static func stateIcon(for: RadioButtonState, giniColorScheme: GiniColorScheme) -> some View` returns the SF Symbol image with its tint applied.

### Accessibility
`body` applies `.accessibilityElement(children: .combine)`, `.accessibilityLabel(...)`, and `.accessibilityAddTraits(variant.isSelected ? .isSelected : [])`. The label is composed by `GiniOptionRowAccessibility.makeLabel(title:content:footer:)` — a pure-string helper kept in a non-`@available`-gated namespace so Swift Testing `@Suite`/`@Test` macros can decorate the tests (the macros refuse `@available`-marked declarations).

### Font bridging
`FontConfig` fields are `UIFont?`. In the view's `init`, each is mapped through `{ Font(giniFont: $0) }` and falls back to the SwiftUI system font if nil. `Font(giniFont:)` is defined in `GiniUtilites/Font/Font+Extensions.swift:21`.

### Preview catalog
`GiniOptionRowPreviewCatalog` (`#if DEBUG`) wraps a `ScrollView` + `VStack` that renders 10 rows — 8 radio (4 states × 2 title variants) plus 2 informational with background — grouped by section header. A `static let previewScheme: GiniColorScheme` is built from iOS system colors (`UIColor.label`, `UIColor.systemBlue`, `UIColor.systemRed`, `UIColor.systemPink`, etc.) so the preview reflects semantic hues without an SDK-specific scheme factory. Three `#Preview` blocks in `GiniOptionRow.swift` consume it: light, dark, Dynamic Type `.accessibilityExtraLarge`.

## Test plan

New file: `Tests/GiniUtilitesTests/Views/GiniOptionRowTests.swift`, test stack **Swift Testing** (matches neighboring suites like `EmptyScrollViewTests.swift:11` `import Testing`).

Suite `GiniOptionRowAccessibilityLabelTests` (3 tests, covers R7's label composition):
- `accessibilityLabelOmitsFooterWhenNil` — verifies `"title, content"` when footer is nil.
- `accessibilityLabelIncludesFooter` — verifies `"title, content, footer"` when footer is present.
- `accessibilityLabelPassesThroughEmptyFooter(footer:expected:)` — parameterized over `("", "Title, Content, ")` and `("Warning", "Title, Content, Warning")`, documenting that an empty footer string is passed verbatim — callers must pre-filter to `nil` to omit.

### Not tested
- `Variant.isDisabled` / `isSelected` — pure functions on `Variant`, but the enum itself is `@available(iOS 16, *)` which Swift Testing macros cannot decorate. The logic is small and covered implicitly via preview inspection.
- State → SF Symbol / tint resolution (R2) — `stateIcon(for:giniColorScheme:)` returns `some View` which cannot be meaningfully introspected without a snapshot library (not used in this repo per `.claude/skills/gini-plan/platform.md:116`). Covered by `#Preview` eyeballing.
- Reduce Motion gating (R8) — `@Environment(\.accessibilityReduceMotion)` cannot be driven from a unit test without hosting the view. Manual QA in Settings → Accessibility → Motion.
- Dynamic Type AX3 layout (R9) — visual check in the "Dynamic Type — AX3" `#Preview`.
- `.disabled()` button short-circuit (R6) — framework behavior tested by Apple.

Consumer-screen coverage for state transitions in context lives in the later PP-3960 productionization subtasks, not here.

## Out of scope

- Any change to `GiniUtilites/Package.swift` deployment target.
- Replacing the PP-3938-fraud spike's inline radio in `BankSDK/.../FraudMismatch/IBANPickerSheet.swift` with `GiniOptionRow` — tracked for the productionization subtask under PP-3960.
- Any showcase / demo screen in `GiniBankSDKExampleSwiftUI` or the Bank example settings.
- Localization `.strings` entries — the primitive takes resolved strings.
- Environment-based theming (`.giniColorScheme(_:)` + `.fontConfig(_:)` modifiers) — worth a separate ticket before more GiniUtilites SwiftUI primitives land.

## Verification

- CI-parity build: `xcodebuild build -scheme GiniUtilites -destination "generic/platform=iOS Simulator"` → **BUILD SUCCEEDED**.
- CI-parity tests: `xcodebuild test -scheme GiniUtilites -destination "platform=iOS Simulator,name=iPhone 17 CI,OS=26.2"` → **3/3 new tests pass** (and 88 pre-existing tests continue to pass).
- Figma design verification against [node 38468-42450](https://www.figma.com/design/ZYpdKfpaHOpV7RV1TTWdEH/Gini-Photo-Payment--iOS---Android?node-id=38468-42450): radio icon size 24×24 confirmed, SF Symbol choices match the design's hollow / blue donut / pink states, IBAN typography confirmed as regular-body-not-monospaced (fix applied), vertical rhythm ~6pt (fix applied).
- `make lint scheme=GiniUtilites` — not run; this host lacks the `iPhone 15 Pro / iOS 17.2` simulator the Makefile hardcodes. CI will run it on the PR.

## Open questions

None. All open questions were resolved during iterative Q&A; decisions are captured in the "Decisions" table above.
