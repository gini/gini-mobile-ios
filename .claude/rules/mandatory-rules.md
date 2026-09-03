# Mandatory Rules (Gini iOS monorepo)

Single shared source of truth for the repo's non-negotiable standards. Referenced by the agents in `.claude/agents/`, the `gini-task` command, and the skills in `.claude/skills/`. Derived from `CLAUDE.md` (MyApp Standards) and `AGENTS.md` — if this file ever drifts from those, `CLAUDE.md`/`AGENTS.md` win.

## Implementations must be real

- **No placeholder or stub implementations in production code.** Every shipped line must be real and functional. If information is missing, ask the user.
- **Test mocks are allowed — and required — per the repo testing standard:** manual protocol conformances (no third-party mocking framework), with test data loaded from JSON fixtures in `Tests/Resources/`. "No placeholders" never blocks writing tests.
- **Use built-in features.** Do not reimplement what UIKit/SwiftUI/Swift already provide.

## Architecture

- MVVM + Coordinator; every feature gets its own `*Coordinator`.
- SDK entry point = single static factory returning a `UIViewController`.
- Constructor injection; delegate back-references are the only acceptable post-init injection; `GiniBankAPI.Builder` value-type fluent builder for SDK entry points.
- ViewModels never import UIKit; closure-based binding (`addStateChangeHandler`); ViewModel→Coordinator via a weak delegate protocol; VCs only lay out UI and forward events.

## UI direction (BankSDK, CaptureSDK & HealthSDK)

- **New UI is SwiftUI-first** where feasible at the target's baseline (iOS 15+; HealthSDK & HealthAPILibrary iOS 17+). Fall back to UIKit when a needed API can't be gated cleanly at the baseline, the screen is camera/`AVFoundation`-heavy capture, or it needs deep UIKit interop the SDK already implements. Not a mandate to rewrite existing UIKit screens.
- The SDK entry point stays a static factory returning a `UIViewController`; SwiftUI screens are embedded via `UIHostingController`.
- **Gate APIs by deployment target:** `NavigationStack` only on iOS 16+ targets (`NavigationView` is the correct choice on iOS 15); `@Observable`/`@Bindable` only on iOS 17+ (`ObservableObject`/`@StateObject` below). Never flag the older API when the target sits below the replacement's minimum iOS.

## Design system — colors, fonts, spacing

- **Colors:** prefer the shared semantic tokens in `GiniColorScheme` (GiniUtilites) via the SDK's scheme factory (e.g. `UIColor.giniBankColorScheme()`) when a matching token exists; otherwise fall back to the per-SDK namespace — `UIColor.GiniBank/GiniCapture.*` with `GiniColor(light:dark:)`. Dark mode support is required. In SwiftUI bridge with `Color(uiColor:)`. Never hardcode.
- **Fonts:** via `textStyleFonts[textStyle]` with Dynamic Type.
- **Spacing:** via a local `enum Constants` — no magic numbers.

## CaptureSDK UIKit layout — the Gini layout DSL

- "Gini layout DSL" = the repo's own Auto Layout builder that lives under `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/Core/Layout`, exposed as `view.gini.make { }`:
  `view.gini.make { $0.edges.equalToSuperview().constant(16) }`
  Attributes: top/bottom/leading/trailing/left/right/centerX/centerY/width/height, plus compound edges/center/size/horizontal/vertical; relations `.equalTo`/`.equalToSuperview()`/`.constant()`; `+`/`-` offset operators.
- Do not hand-roll `NSLayoutConstraint`/anchor code in new CaptureSDK UIKit views.

## Localization

- Typed `LocalizableStringResource` enums, never raw `NSLocalizedString`.
- 3-level lookup chain (host app → custom bundle → SDK bundle).
- Keys follow `<sdk>.<feature>.<screen>.<element>`.

## Formatting

- Multi-parameter initializers/functions use one-parameter-per-line: first parameter on the opening-paren line, subsequent parameters vertically aligned — see `CLAUDE.md` › Code Style.

## Documentation

- `/** ... */` for declarations, `///` for inline body comments — see `AGENTS.md` › Swift Documentation and Comment Style.

## Accessibility

- Accessibility is not optional. Never skip `mobile-a11y-specialist` review for user-facing UI code (UIKit or SwiftUI). Targets: WCAG 2.2 / BFSG.

## Testing

- New tests use **Swift Testing** (`@Suite`, `@Test`, `#expect`); XCTest only for XCUITest and Objective-C suites.
- Mocks = manual protocol conformances; test data = JSON fixtures in `Tests/Resources/`.
- All ViewModels and Services must have unit tests; coverage is weakest on ViewControllers and Coordinators — push for those.
- **Integration tests** (hitting the real Gini API) require `TEST_CLIENT_ID`/`TEST_CLIENT_SECRET` environment variables; they should skip cleanly (conditional `.enabled(if:)`) when credentials are absent.
- Invoke `testing-specialist` for **all new or changed code**, not only when tests are explicitly requested.
