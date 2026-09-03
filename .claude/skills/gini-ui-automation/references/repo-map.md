# The gini-mobile-ios UI test suite

## Where it lives

Everything is under `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/`. No other SDK in the monorepo has a UI test suite — CaptureSDK, HealthSDK, and the API libraries have unit tests only, under their own `Tests/` directories.

```
GiniBankSDKExampleUITests/
├── GiniBankSDKExampleUITests.swift      base class — every test class subclasses this
├── Screens/                             14 page objects
├── AccessibilityIdentifiers/            2 enums (MainScreen, SettingScreen)
├── Crossboder Payments/                 9 CX test classes (note: folder name is misspelled in the repo)
├── Gini*ScreenUITests.swift             per-screen test classes
├── TestFixtures.swift
├── TestSamples/TestSamplesForBS/        invoice PDFs and PNGs used as inputs
├── Scripts/                             BrowserStack runners
└── Frameworks/BrowserStackTestHelper.xcframework
```

Roughly 38 Swift files, 4,550 lines, 82 test methods.

## The base class contract

`GiniBankSDKExampleUITests` is the superclass for every test class. Its `setUpWithError()`:

1. Throws `XCTSkip` when running on the simulator.
2. Sets `continueAfterFailure = false`.
3. Copies fixture PDFs into the app container so the Files picker can reach them.
4. Resets camera and photos authorisation.
5. Launches with `["-StartFromCleanState", "YES"]` plus whatever the subclass adds.
6. Instantiates all 14 page objects with the current locale.

Subclasses add launch arguments by overriding `additionalLaunchArguments`, not by re-launching the app.

`tearDownWithError()` attaches a screenshot with `.deleteOnSuccess` and terminates the app. Both are wrapped in `#if !targetEnvironment(simulator)`.

Useful inherited helpers: `waitForAnalysisIfNeeded()`, `uploadLatestPhotoFromGallery(offset:)`, `tapDoneInAnyKnownContext()`, and the localised title properties `galleryTitle`, `analysisScreenTitle`, `analysisLoadingText`, `galleryDoneButtonTitle`.

`galleryDoneButtonTitle` returns `"\u{0010}Done"` for English — a control character prefix on a system button title. It is a workaround, it is not documented anywhere, and it is the kind of thing an identifier would make unnecessary if the button were ours. It isn't; it belongs to the system photo picker.

## Page objects

One class per screen in `Screens/`, constructed as `init(app:locale:)`, exposing elements as properties.

State of each, by how it finds elements:

| Screen | String literals | Identifiers | Locale switch |
|---|---|---|---|
| CXExtractionScreen | 1 | identifier-driven | no |
| SettingScreen | 0 | 6 | no |
| MainScreen | 24 | 3 | yes |
| CaptureScreen | 20 | 0 | yes |
| ReturnAssistantScreen | 20 | 0 | yes |
| TransactionDocsScreen | 15 | 0 | yes |
| SkontoScreen | 14 | 0 | yes |
| ErrorScreen | 10 | 0 | yes |
| HelpScreen | 10 | 0 | yes |
| ReviewScreen | 10 | 0 | yes |
| CameraAccessScreen | 8 | 0 | yes |
| OnboardingScreen | 6 | 0 | yes |
| TransactionSummaryScreen | 4 | 0 | yes |
| NoResultsScreen | 2 | 0 | yes |

`CXExtractionScreen` is the reference implementation. It addresses 26 extraction fields by identifier (`creditorName`, `creditorIBAN`, `instructedAmount`, …), needs no `locale` parameter, and carries doc comments explaining the screen. It is also the newest file in the folder, which suggests the team has already worked this out — the pattern just hasn't reached the older screens.

`SettingScreen` is fully identifier-driven because the settings UI belongs to the example app, where identifiers were easy to add.

Everything else matches on localised copy, with `fatalError("Locale \(locale) is not supported")` on the default branch.

## Why the older screens are stuck

The screens without identifiers are SDK UI, not example-app UI. Their views live in:

- `CaptureSDK/GiniCaptureSDK/Sources/` — camera, review, onboarding, help, error, no-results, analysis
- `BankSDK/GiniBankSDK/Sources/` — Skonto, return assistant, transaction docs, transaction summary

There are currently **zero** `accessibilityIdentifier` assignments anywhere in the SDK sources. All 18 in the repo are in `GiniBankSDKExample/` — `DemoViewController`, `SettingsViewController`, and two table view cells.

So migrating one of these screens off localised strings is a two-part change: add identifiers to SDK source, then rewrite the page object to use them. The first part goes through SDK review, follows the dependency order in `CLAUDE.md`, and propagates to dependents. That's the real reason this hasn't happened incrementally, and it's worth naming when scoping the work.

## Running

**The simulator is not a valid target.** The base class skips there. A local `xcodebuild test` will report success having executed nothing.

Real runs go through the scripts in `Scripts/`:

- `bs_run_smoke_journeys.sh`
- `bs_run_smoke_screens.sh`
- `bs_run_skonto.sh`
- `bs_run_ra.sh` (return assistant)
- `bs_run_cx_normal.sh`, `bs_run_cx_multipage.sh`, `bs_run_cx_no_results.sh`
- `bs_shared.sh` (shared setup)
- `setup_test_fixtures.sh`

Read the scripts README in `Scripts/` before running any of them. These consume BrowserStack minutes — don't launch one without being asked.

When a new test class ships, offer to generate a matching `bs_run_<feature>.sh` (see SKILL.md › "Generating a BrowserStack run script for new tests") — sourcing `bs_shared.sh`, uploading the class's fixtures, and scoping `only-testing` to the new class.

The practical consequence: there is no fast local feedback loop. Correctness comes from reading the accessibility tree and the existing page objects carefully, not from re-running until green.

## Repo conventions

`AGENTS.md` at the repo root governs commits and pull requests — PR body from `.github/pull_request_template.md`, Jira ticket extracted from the commit message, human reviewers always asked for rather than inferred, Copilot review requested via the REST API. `CLAUDE.md` covers build and test commands and the SDK dependency graph. Follow both.

## Unfinished scaffolding

`GiniBankSDKExampleSwiftUIUITests/` holds an untouched Xcode template — `testExample()` with a comment where the assertions would go, and `testLaunchPerformance()`. `GiniBankSDKExampleSwiftUITests/` holds a Swift Testing target with a single empty `example()`.

Neither tests anything. They're worth raising with the user as a decision — fill in or delete — rather than quietly leaving in place, since a target that always passes is worse than no target.
