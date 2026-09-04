# gini-plan platform conventions — iOS (gini-mobile-ios)

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

MVVM + Coordinator, the ViewModel↔Coordinator weak-delegate pattern,
closure-based ViewModel binding, and view-controller responsibilities are
enforced by **gini-orchestrator** per `.claude/rules/mandatory-rules.md` — read
it, don't restate it here. The spec must still name the coordinator, view
model, delegate, and view controller types for new code and match a precedent
that actually exists in the touched module.

SwiftUI is the default framework for new standalone views and feature
entry points. SwiftUI is already the norm in **GiniInternalPaymentSDK**
(payment review, keyboard accessory, carousels) and in the shared
`GiniUtilites/SwiftUI/` helpers (font, color, layout, height preference
keys). UIKit remains the existing pattern in GiniBankSDK, GiniCaptureSDK
screens, and GiniHealthSDK view controllers — match neighboring code when
extending an existing UIKit screen there. A new coordinator or feature
entry point is SwiftUI unless there's a specific reason (e.g. a UIKit-only
API dependency); integrator-facing SDK entry points still return a
`UIViewController` per `CLAUDE.md`, wrapping the SwiftUI root in a
`UIHostingController` when the feature is SwiftUI-native.

Liquid Glass adoption is planned per SDK. When the spec targets a UI
change that adopts Liquid Glass, call out impact explicitly (previews,
glass effects, materials, older-OS fallbacks).

## Language rules

- New code in Swift; `internal` (the default) unless deliberately part of the
  public API. `public`/`open` require justification in the spec's public API
  impact section.
- Multi-parameter formatting and doc-comment style (`/** */` vs `///`) are
  enforced by **gini-orchestrator** per `.claude/rules/mandatory-rules.md` —
  read it, don't restate it here.

## UI rules

- New UI framework: **SwiftUI** by default for new standalone views and
  feature entry points. Match the touched module — extending an existing
  UIKit screen inside GiniBankSDK, GiniCaptureSDK, or GiniHealthSDK stays
  UIKit (`UIViewController` / `UIView` with AutoLayout — prefer
  programmatic UI). SwiftUI is already the norm in GiniInternalPaymentSDK
  and `GiniUtilites/SwiftUI/`. Call out in the spec which framework new
  views use and why.
- Colors/fonts/spacing: enforced by **gini-orchestrator** per
  `.claude/rules/mandatory-rules.md` (`GiniColorScheme` first, legacy
  `UIColor.GiniBank.*`/`UIColor.GiniCapture.*` still the norm inside
  CaptureSDK — match neighboring code; `textStyleFonts[textStyle]`; local
  `Constants` enum). Read it, don't restate it here.
- Liquid Glass: when the spec targets a UI change that adopts Liquid
  Glass, list which glass effects / materials the new UI adopts and any
  fallbacks for older OS versions.

## Wiring

- DI: constructor injection, delegate back-reference as the sole post-init
  exception, and the fluent value-type builder pattern for SDK entry points
  are enforced by **gini-orchestrator** per `.claude/rules/mandatory-rules.md`
  — read it, don't restate it here.
- Async: Swift concurrency (`async`/`await`, `Task`, `@MainActor` where the
  neighbor code already uses it); fall back to closure-based callbacks only
  where the module hasn't adopted concurrency yet. Match neighboring code.
- Strings: key convention and 3-level lookup chain are enforced by
  **gini-orchestrator** per `.claude/rules/mandatory-rules.md`. State which
  locale `.strings` files under `Sources/<SDK>/Resources/` gain entries.

## Test stack

- Unit tests: `Tests/<SDK>Tests/` (e.g.
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/`),
  `<ClassUnderTest>Tests.swift`. Swift Testing (`@Suite`, `@Test`, `#expect`)
  is fully adopted in GiniInternalPaymentSDK and used for most new suites in
  GiniBankAPILibrary and GiniCaptureSDK; GiniBankSDK, GiniHealthSDK, and
  GiniHealthAPILibrary tests remain mostly XCTest. Match the neighboring
  test file when extending; for new files, follow the module's dominant
  framework.
- UI tests: `<SDK>Example/<SDK>ExampleUITests/` (e.g.
  `GiniBankSDKExampleUITests`). Existing UI suites use a Page Object
  pattern — screen selectors live under `Screens/` (`MainScreen.swift`,
  `OnboardingScreen.swift`, …). Extend an existing screen object rather
  than adding raw selectors. `GiniBankSDKExampleSwiftUIUITests/` covers the
  SwiftUI example variant. No snapshot-testing library is in use.
- Mocks: manual protocol conformances per `.claude/rules/mandatory-rules.md`
  (gini-orchestrator-enforced). No third-party mocking framework.
- Fixtures: `Tests/<SDK>Tests/Resources/`, referenced via `.process`/`.copy`
  in the package's test target. Not only JSON — CaptureSDK ships `.pdf`
  (rotated variants, multi-page), `.jpg`, and `.txt` extraction fixtures;
  API libraries ship `.pdf` and `.png` payloads. Reuse an existing fixture
  when possible.
- Integration tests hitting the real API need `TEST_CLIENT_ID` and
  `TEST_CLIENT_SECRET` environment variables (see `CLAUDE.md`). Example
  apps have their own integration/unit split under
  `BankSDK/GiniBankSDKExample/Tests/{IntegrationTests, UnitTests}/`
  (SSL-pinning tests live under `IntegrationTests/SSLPinningTests/`).
- Every new ViewModel and Service gets a unit test. Coverage is currently
  weakest on ViewControllers and Coordinators — the spec should not use
  that weakness as an excuse to omit tests for new coordinators.

## Conventions checklist for the spec

The spec's "Technical conventions" section must cover, grounded in the
modules actually touched:

1. Language and access control: Swift, `internal` by default; `public` /
   `open` only where the public API impact section justifies it. Doc-comment
   style per `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced).
2. UI: name the framework (SwiftUI by default for new views; UIKit
   `UIViewController`/`UIView` when extending existing UIKit screens in
   GiniBankSDK/GiniCaptureSDK/GiniHealthSDK); colors/fonts/spacing per
   `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced); Liquid
   Glass adoption impact (glass effects, materials, older-OS fallbacks) when
   the spec targets it.
3. Architecture: MVVM + Coordinator per `.claude/rules/mandatory-rules.md`
   (gini-orchestrator-enforced); name the `<Feature>Coordinator`,
   `<Feature>ViewModel`, `<Feature>ViewModelDelegate`, and
   `<Feature>ViewController` types; entry point is a single static factory
   returning a `UIViewController` when the feature is integrator-visible.
4. Wiring: DI and builder pattern per `.claude/rules/mandatory-rules.md`
   (gini-orchestrator-enforced); async style (Swift concurrency where the
   module already uses it, closures otherwise).
5. Localization: key convention and lookup chain per
   `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced); list the
   `Sources/<SDK>/Resources/` locale `.strings` files that gain entries.
6. Quality gates: `make lint scheme=<Scheme>` clean per `AGENTS.md`
   (`GiniBankSDK` / `GiniCaptureSDK` at minimum for touched SDKs). Note
   the local-vs-CI destination drift: `make lint` runs on `iPhone 15 Pro /
   iOS 17.2` (see `Makefile`) while CI (`.github/workflows/shared-config.yml`)
   uses `iPhone 17 / iOS 26.2` — re-run failing checks in CI parity before
   pushing. Test-framework coverage expectation per the module's dominant
   framework (Swift Testing for GiniInternalPaymentSDK / new suites in
   GiniBankAPILibrary and GiniCaptureSDK; XCTest for GiniBankSDK,
   GiniHealthSDK, GiniHealthAPILibrary). Multi-parameter formatting rule
   per `.claude/rules/mandatory-rules.md` (gini-orchestrator-enforced).
