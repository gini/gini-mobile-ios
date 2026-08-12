# gini-fix platform conventions — iOS (gini-mobile-ios)

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has its
  own platform.md with the same section headings but iOS content. If you add a
  section here that the shared workflow depends on, add the matching section
  to the Android platform.md too.
-->

## Reproducing bugs

Prefer the cheapest faithful reproduction, in this order:

1. **Unit test** — most SDK logic is testable without a simulator. Put the
   repro test where the regression test will live (`Tests/<SDK>Tests/` of the
   module owning the root cause). Swift Testing (`@Suite`/`@Test`/`#expect`)
   is dominant in GiniInternalPaymentSDK and used for most new suites in
   GiniBankAPILibrary and GiniCaptureSDK; GiniBankSDK, GiniHealthSDK, and
   GiniHealthAPILibrary remain mostly XCTest. Match the neighboring file's
   framework.
2. **UI test / example-app instrumentation** when the bug needs real UIKit
   or lifecycle behavior — run via the example app's UI test scheme on the
   CI simulator (iPhone 17, iOS 26.2). Existing UI tests live in
   `<SDK>Example/<SDK>ExampleUITests/` (e.g. `GiniBankSDKExampleUITests`)
   and use a Page Object pattern — screen selectors live under `Screens/`
   (`MainScreen.swift`, `OnboardingScreen.swift`, `CameraAccessScreen.swift`,
   …). Extend an existing screen object rather than adding raw selectors.
   `BankSDK/GiniBankSDKExample/GiniBankSDKExampleSwiftUIUITests/` covers the
   SwiftUI example variant.
3. **Example app on the simulator** as a last resort:
   - Bank: open `GiniMobile.xcworkspace`, run `GiniBankSDKExample` on iPhone
     17 / iOS 26.2.
   - Health: `GiniHealthSDKExample`. Real API access needs credentials in
     `Credentials.plist` / `CredentialsManager.swift` (see the example
     target). Without them, network-backed flows fail closed.
   - Capture: `GiniCaptureSDKExample`.
   - Console logs: run from Xcode and read the debug console, or filter
     `Console.app` by the app's bundle identifier.

Version-specific bugs: check the ticket's SDK version against
`Sources/<SDK>/<SDK>Version.swift`. Fixes for older major branches ship from
the matching release branch, not `main` — see `RELEASE.md` /
`RELEASE-ORDER.md`.

## Root-cause tools

- Narrow to a single test class while iterating:
  ```bash
  xcodebuild test \
    -project <SDK>/<SDK>Example/<SDK>Example.xcodeproj \
    -scheme "<SDK>ExampleTests" \
    -destination "platform=iOS Simulator,name=iPhone 17,OS=26.2" \
    -only-testing:<SDK>ExampleTests/<TestClassOrSuiteName>
  ```
- History of a suspicious file: `git log --follow -p -- <path>` and
  `git blame <path>`. Release tags follow `<PackageName>;<version>`
  (e.g. `GiniBankSDK;4.1.1`) — they tell you which release introduced a
  change.
- Inter-module effects: a bug surfacing in GiniBankSDK may root-cause in
  GiniCaptureSDK, GiniBankAPILibrary, or GiniUtilites — see the dependency
  graph in `CLAUDE.md`. GiniHealthSDK's chain goes through
  GiniInternalPaymentSDK + GiniHealthAPILibrary.

## Regression test conventions

- Unit tests in `Tests/<SDK>Tests/` (e.g.
  `BankSDK/GiniBankSDK/Tests/GiniBankSDKTests/`), `<ClassUnderTest>Tests.swift`.
  Swift Testing (`@Suite`, `@Test`, `#expect`) is fully adopted in
  GiniInternalPaymentSDK and used for most new suites in GiniBankAPILibrary
  and GiniCaptureSDK; GiniBankSDK, GiniHealthSDK, and GiniHealthAPILibrary
  remain mostly XCTest. Match the neighboring test file when extending;
  for a fresh location, follow the module's dominant framework.
- Manual protocol-conformance mocks — no third-party mocking framework. No
  snapshot-testing library in use.
- Fixtures in `Tests/<SDK>Tests/Resources/`. Not only JSON — CaptureSDK
  ships `.pdf` (rotated variants, multi-page), `.jpg`, and `.txt` extraction
  fixtures; API libraries ship `.pdf` and `.png` payloads. Prefer an
  existing fixture when your regression test needs a real document.
- Name the test after the behavior. Reference the ticket in a comment only
  if the file's existing tests already do so — match local style.
- Integration tests: SDK-embedded integration tests hitting the Gini API
  need `TEST_CLIENT_ID` / `TEST_CLIENT_SECRET` in the environment
  (`CLAUDE.md`). Example apps have their own integration/unit split under
  `BankSDK/GiniBankSDKExample/Tests/{IntegrationTests, UnitTests}/`
  (SSL-pinning tests live under `IntegrationTests/SSLPinningTests/`).

## Verification (step 7 of the workflow)

For every affected module, run:

```bash
make lint scheme=<Scheme>     # AGENTS.md gate — compile check
```

e.g. `make lint scheme=GiniBankSDK` for BankSDK, `make lint scheme=GiniCaptureSDK`
for CaptureSDK. Then run the unit tests of the touched module
(`xcodebuild ... test` or `bundle exec fastlane run_unit_tests`). If the
regression test is a UI test, run the example app's UI-test scheme on iPhone
17 / iOS 26.2. Re-check the original reproduction from step 2 no longer
occurs.

**Local vs CI destination:** `make lint` runs on `iPhone 15 Pro / iOS 17.2`
(see `Makefile`) for faster iteration; CI's `shared-config.yml` uses
`iPhone 17 / iOS 26.2`. Re-run failing checks in CI parity before pushing —
behavior can differ on iOS-26-only APIs.

## Commit conventions

Follow the template at `.git-stuff/commit-msg-template.txt` with `type` = `fix`.
`project` is the module name (e.g. `GiniBankSDK`), omit the parentheses for
multi-module fixes; the body says what was broken, the root cause, and what
the fix does; the ticket id ($ARGUMENTS) goes in the footer. Never push
release tags — `<PackageName>;<version>` tags trigger release workflows.
