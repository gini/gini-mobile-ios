# gini-build platform conventions — iOS (gini-mobile-ios)

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has its
  own platform.md with the same section headings but Android content. If you
  add a section here that the shared workflow depends on, add the matching
  section to the Android platform.md too.
-->

## Where code and tests live

- Swift Package Manager monorepo inside a single workspace,
  `GiniMobile.xcworkspace`. Reference modules by SPM product name
  (`GiniBankSDK`, `GiniCaptureSDK`, `GiniHealthSDK`, `GiniBankAPILibrary`,
  `GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`) — see
  `CLAUDE.md` for the dependency graph.
- Source: `Sources/<SDK>/` — `Core/`, `Extensions/`, `Resources/` (`.strings`,
  assets), `<SDK>Version.swift`, `PrivacyInfo.xcprivacy`.
- Unit tests: `Tests/<SDK>Tests/` (e.g.
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/`),
  `<ClassUnderTest>Tests.swift`. Swift Testing (`@Suite`/`@Test`/`#expect`)
  is fully adopted in **GiniInternalPaymentSDK** and used for most new suites
  in GiniBankAPILibrary and GiniCaptureSDK. GiniBankSDK, GiniHealthSDK, and
  GiniHealthAPILibrary tests remain mostly XCTest. Match the neighboring
  test file when extending; for new files, follow the module's dominant
  framework.
- UI tests: `<SDK>Example/<SDK>ExampleUITests/` (`GiniBankSDKExampleUITests`,
  `GiniHealthSDKExampleTests`, etc.). Existing UI suites use a Page Object
  pattern — screen selectors live under `Screens/` (`MainScreen.swift`,
  `OnboardingScreen.swift`, …). Extend an existing screen object rather
  than adding raw selectors. `GiniBankSDKExampleSwiftUIUITests/` covers the
  SwiftUI example variant. No snapshot-testing library is in use.
- Fixtures: `Tests/<SDK>Tests/Resources/`, referenced via
  `.process("Resources")` / `.copy` in the test target. Not only JSON —
  CaptureSDK ships `.pdf` (rotated variants, multi-page), `.jpg`, and
  `.txt` extraction fixtures; API libraries ship `.pdf` and `.png`
  payloads. Reuse an existing fixture when possible.
- Minimum deployment target: iOS 15+ (default), iOS 17+ for GiniHealthSDK
  and GiniHealthAPILibrary.

## Building and running tests during implementation

Prefer `xcodebuild` against the example app's Xcode project (CI parity):

```bash
xcodebuild clean test \
  -project BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj \
  -scheme "GiniBankSDKExampleTests" \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=26.2" \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

Swap the project/scheme for other SDKs (`GiniCaptureSDKExample`,
`GiniHealthSDKExample`, etc.). To iterate on a single test class or
`@Suite`, add `-only-testing:<Scheme>/<TestClassOrSuite>`.

Fastlane wrapper (same underlying commands):

```bash
bundle exec fastlane run_unit_tests
```

Integration tests hitting the Gini API require `TEST_CLIENT_ID` /
`TEST_CLIENT_SECRET` in the environment — they'll be skipped or fail without
them (`CLAUDE.md`).

CI environment: Xcode 26.2, iPhone 17 simulator on iOS 26.2, macOS-latest
runner (see `.github/workflows/shared-config.yml`). Local runs on the same
simulator remove one variable.

## Verification (step 5 of the workflow)

For every affected module, run:

```bash
make lint scheme=<Scheme>     # AGENTS.md gate — compile check
```

e.g. `make lint scheme=GiniBankSDK` for BankSDK changes,
`make lint scheme=GiniCaptureSDK` for CaptureSDK. Then run the unit tests
of the touched module (`xcodebuild ... test` above, or
`bundle exec fastlane run_unit_tests`). If the spec's test plan includes
UI tests, run them in the example app's UI-test target on the CI simulator.
All must pass.

**Local vs CI destination:** `make lint` runs on `iPhone 15 Pro / iOS 17.2`
(see `Makefile`) for faster iteration; CI's `shared-config.yml` uses
`iPhone 17 / iOS 26.2`. Behavior can differ on iOS-26-only APIs — re-run
failing checks in CI parity before pushing.

## Coding conventions

The spec's "Technical conventions" section is the feature-specific contract.
Architecture (MVVM + Coordinator), dependency injection, design-system usage
(colors/fonts/spacing), localization, multi-parameter formatting, and doc-comment
style are enforced by **gini-orchestrator** per `.claude/rules/mandatory-rules.md`
— read it, don't restate it here. What that shared rule set doesn't cover:

- New Swift, `internal` by default; `public`/`open` only where the spec's
  Public API impact justifies it.
- UIKit remains the pattern in GiniBankSDK, GiniCaptureSDK screens, and
  GiniHealthSDK view controllers. SwiftUI is the norm in
  **GiniInternalPaymentSDK** (payment review, keyboard accessory, carousels)
  and in the shared `GiniUtilites/SwiftUI/` helpers (font, color, layout,
  height preference keys). Match neighboring code in the touched module —
  don't rewrite a UIKit screen in SwiftUI opportunistically, and don't add
  a UIKit view controller inside a SwiftUI feature.

## Commit conventions

The template at `.git-stuff/commit-msg-template.txt` (repo root) is the source
of truth for the allowed `type` values and what each covers — read it rather
than relying on a list duplicated here. `project` is the module name
(e.g. `GiniBankSDK`), omit the parentheses for multi-module changes; the
ticket id ($ARGUMENTS) goes in the footer. Never push release tags —
`<PackageName>;<version>` tags trigger release workflows.
