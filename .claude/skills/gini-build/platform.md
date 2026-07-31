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
- Tests: `Tests/<SDK>Tests/` (Swift Testing preferred for new files,
  `<ClassUnderTest>Tests.swift`; XCTest legacy remains in many files —
  match neighboring tests when extending a suite). JSON fixtures in
  `Tests/<SDK>Tests/Resources/`, referenced via `.process("Resources")` /
  `.copy` in the test target.
- Minimum deployment target: iOS 15+ (default), iOS 17+ for GiniHealthSDK
  and GiniHealthAPILibrary.

## Building and running tests during implementation

Prefer `xcodebuild` against the example app's Xcode project (CI parity):

```bash
xcodebuild clean test \
  -project BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj \
  -scheme "GiniBankSDKExampleTests" \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=26.2" \
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

CI environment: Xcode 26.2, iPhone 16 simulator on iOS 26.2, macOS-latest
runner. Local runs on the same simulator remove one variable.

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

## Coding conventions

The spec's "Technical conventions" section is the feature-specific contract.
Repo-wide rules live in `AGENTS.md` and `CLAUDE.md`; the ones most often
violated:

- New Swift, `internal` by default; `public`/`open` only where the spec's
  Public API impact justifies it.
- Doc comments follow `AGENTS.md`: `/** ... */` for declarations, `///` only
  inline inside function bodies.
- Multi-parameter initializers and methods: first parameter on the opening
  paren line, remaining parameters aligned vertically on new lines
  (`CLAUDE.md` code style).
- MVVM + Coordinator: every feature gets `<Feature>Coordinator`,
  `<Feature>ViewModel`, `<Feature>ViewModelDelegate`,
  `<Feature>ViewController`. ViewModels MUST NOT import UIKit.
- Constructor injection; delegate back-references are the only permitted
  post-init injection. SDK entry points expose a fluent value-type builder
  (`GiniBankAPI.Builder` precedent).
- Colors via `UIColor.GiniBank.*` / `UIColor.GiniCapture.*`; dark mode via
  `GiniColor(light:dark:).uiColor()`. Dynamic Type via
  `textStyleFonts[textStyle]`. Spacing in a local `enum Constants`.
- Strings via typed `LocalizableStringResource` enums under
  `<sdk>.<feature>.<screen>.<element>`; never raw `NSLocalizedString`.
- No SwiftUI in SDK sources — UIKit only. No Objective-C. Xamarin has been
  removed; treat "Xamarin only" as dead code.

## Commit conventions

Format (`CLAUDE.md` → Commit Message Format):

```
<type>(<project>): <subject>

<body>

<ticket-id>
```

`type` ∈ `feat` | `fix` | `refactor` | `ci` (`chore` for cross-cutting).
`project` is the module name (e.g. `GiniBankSDK`); omit the parentheses for
multi-module changes. Subject in imperative mood, no period. Ticket ID
($ARGUMENTS) is required on the last line, e.g. `PP-4102`. Never push
release tags — `{PackageName};{version}` tags trigger release workflows.
