# gini-spec-feature platform conventions — iOS (gini-mobile-ios)

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has its
  own platform.md with the same section headings but Android content. If you
  add a section here that the shared workflow depends on, add the matching
  section to the Android platform.md too.
-->

## Module map

Swift Package Manager monorepo inside a single workspace,
`GiniMobile.xcworkspace`. Affected modules are identified by these SPM package
product names (see `CLAUDE.md` for the dependency graph):
GiniBankAPILibrary, GiniHealthAPILibrary, GiniUtilites, GiniCaptureSDK,
GiniInternalPaymentSDK, GiniBankSDK, GiniHealthSDK.

Inter-module dependencies are SPM package dependencies — a change in
GiniUtilites or GiniBankAPILibrary ripples into GiniCaptureSDK and then into
GiniBankSDK; GiniInternalPaymentSDK sits under GiniHealthSDK. Name the
affected modules by product name (e.g. `GiniBankSDK`, `GiniCaptureSDK`), not
by directory. Note the minimum deployment target for each touched module
(iOS 15+ default; iOS 17+ for GiniHealthSDK and GiniHealthAPILibrary).

## Public API assessment

Integrator-visible means `public` (or `open`) Swift declarations exported from
a package's `.library()` product. There is no `.swiftinterface` baseline or
api-diff tool in this repo — assess source-level visibility instead.

New integrator-facing entry points MUST follow the "single static factory
returning a `UIViewController`" rule from `CLAUDE.md`. Fluent value-type
builders (`GiniBankAPI.Builder` and siblings) are the only accepted post-init
configuration pattern for SDK entry points.

## Architecture patterns in use

MVVM + Coordinator is mandatory for all new feature code (`CLAUDE.md` — MyApp
Standards → Architecture). The spec must name the coordinator, view model,
delegate, and view controller types for new code and match a precedent that
actually exists in the touched module:

- ViewModel ↔ Coordinator: weak delegate protocol (e.g.
  `<Feature>ViewModelDelegate`) — post-init injection is only allowed for
  this delegate back-reference.
- View ↔ ViewModel: closure-based binding (`addStateChangeHandler`); the
  ViewModel MUST NOT import UIKit.
- ViewController: layout + event forwarding only, no business logic.

UIKit is the only UI framework used inside SDK targets. Do not introduce
SwiftUI in SDK sources; example apps and utility surfaces are the only place
SwiftUI appears. No Objective-C; Xamarin support has been removed and code
marked "Xamarin only" is dead — don't treat it as a live ABI constraint.

Liquid Glass is being rolled out in a sequenced pair of release branches
(`release/liquid_glass_health_sdk` first, `release/liquid_glass_bank_sdk`
after). When the spec touches UI on either branch, call out Liquid Glass
adoption impact explicitly (previews, glass effects, materials).

## Language rules

- New code in Swift; `internal` (the default) unless deliberately part of the
  public API. `public`/`open` require justification in the spec's public API
  impact section.
- Multi-parameter initializers and functions follow the `CLAUDE.md` code
  style: the first parameter stays on the opening-paren line; each following
  parameter starts on a new line and is vertically aligned; the closing
  paren and opening brace remain on the same line.
- Swift doc comments follow the `AGENTS.md` house style: `/** ... */` for
  declaration documentation; `///` reserved for inline explanatory comments
  inside function bodies.

## UI rules

- New UI: UIKit — `UIViewController` / `UIView` with AutoLayout. State
  whether XIBs/storyboards are added or removed (prefer programmatic UI to
  match the majority of the codebase).
- Colors: `UIColor.GiniBank.*` / `UIColor.GiniCapture.*` namespaces. Dark
  mode is required via `GiniColor(lightModeColor:darkModeColor:).uiColor()`
  — never a raw hex or asset without a dark counterpart.
- Fonts: Dynamic Type via `textStyleFonts[textStyle]` from the design
  system.
- Spacing: local `private enum Constants` inside the view/view controller —
  no magic numbers.
- Liquid Glass: when the spec targets a `release/liquid_glass_*` branch,
  list which glass effects / materials the new UI adopts and any fallbacks
  for older OS versions.

## Wiring

- DI: constructor injection is mandatory. The delegate back-reference
  described above is the only permitted post-init injection. SDK entry
  points expose a fluent value-type builder (`GiniBankAPI.Builder`
  precedent).
- Async: Swift concurrency (`async`/`await`, `Task`, `@MainActor` where the
  neighbor code already uses it); fall back to closure-based callbacks only
  where the module hasn't adopted concurrency yet. Match neighboring code.
- Strings: typed `LocalizableStringResource` enums under the key convention
  `<sdk>.<feature>.<screen>.<element>`. All strings go through the 3-level
  lookup chain (host app → custom bundle → SDK bundle). Never raw
  `NSLocalizedString`. State which locale `.strings` files under
  `Sources/<SDK>/Resources/` gain entries.

## Test stack

- New tests use Swift Testing (`@Suite`, `@Test`, `#expect`) per the MyApp
  Standards → Testing rule in `CLAUDE.md`. XCTest remains in legacy files
  (GiniHealthSDK tests are still largely XCTest) — match the neighboring
  file when extending an existing test suite; only new files are Swift
  Testing by default.
- Mocks: manual protocol conformances. No third-party mocking framework.
- Fixtures: JSON files in `Tests/Resources/`, referenced via `.process`/
  `.copy` in the package's test target.
- Integration tests hitting the real API need `TEST_CLIENT_ID` and
  `TEST_CLIENT_SECRET` environment variables (see `CLAUDE.md`).
- Every new ViewModel and Service gets a unit test. Coverage is currently
  weakest on ViewControllers and Coordinators — the spec should not use
  that weakness as an excuse to omit tests for new coordinators.

## Conventions checklist for the spec

The spec's "Technical conventions" section must cover, grounded in the
modules actually touched:

1. Language and access control: Swift, `internal` by default; `public` /
   `open` only where the public API impact section justifies it; doc-comment
   style (`/** */` for declarations, `///` inline) per `AGENTS.md`.
2. UI: UIKit (`UIViewController` / `UIView`) in `UIColor.GiniBank.*` /
   `UIColor.GiniCapture.*` with `GiniColor(light:dark:)` for dark mode,
   Dynamic Type via `textStyleFonts[textStyle]`, spacing in a local
   `enum Constants`; Liquid Glass adoption if on a `release/liquid_glass_*`
   branch.
3. Architecture: MVVM + Coordinator; name the `<Feature>Coordinator`,
   `<Feature>ViewModel`, `<Feature>ViewModelDelegate`, and
   `<Feature>ViewController` types; entry point is a single static factory
   returning a `UIViewController` when the feature is integrator-visible.
4. Wiring: constructor injection only (delegate back-reference is the sole
   post-init exception); async style (Swift concurrency where the module
   already uses it, closures otherwise); fluent value-type builder for any
   new SDK entry point.
5. Localization: `LocalizableStringResource` enum, keys under
   `<sdk>.<feature>.<screen>.<element>`, list the `Sources/<SDK>/Resources/`
   locale `.strings` files that gain entries.
6. Quality gates: `make lint scheme=<Scheme>` clean per `AGENTS.md`
   (`GiniBankSDK` / `GiniCaptureSDK` at minimum for touched SDKs); Swift
   Testing coverage expectations for every new class; multi-parameter
   formatting rule from `CLAUDE.md`.
