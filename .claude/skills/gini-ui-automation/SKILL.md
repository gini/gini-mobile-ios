---
name: gini-ui-automation
description: Write, audit, and de-flake XCUITest UI tests in the gini-mobile-ios monorepo. Use this whenever someone wants to add a UI test, add a page object or Screen class, migrate a test off hardcoded German/English strings onto accessibility identifiers, add accessibility identifiers to SDK views, investigate a flaky or failing UI test, review UI test code before merging, or run the BrowserStack test scripts. Trigger it even when the request is phrased casually — "add a test for the Skonto screen", "this camera test keeps failing on BrowserStack", "why does this only break in German", "write a page object for the new screen" — and whenever a diff touches GiniBankSDKExampleUITests or any file under a Screens/ or AccessibilityIdentifiers/ folder.
---

# UI testing in gini-mobile-ios

This skill is for the XCUITest suite in `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/`. Roughly 82 test methods across 4,500 lines, organised as page objects plus test classes, run on real devices and BrowserStack rather than the simulator.

Before writing anything, read `references/repo-map.md` — it describes the suite's layout, the base class contract, and how tests are actually executed. `references/xcuitest.md` is the API and query reference; consult it rather than recalling XCUITest APIs from memory, because the failure mode of guessing here is code that compiles and then silently matches the wrong element.

## The one thing that matters most

This suite looks up elements by localised visible text far more often than by accessibility identifier — currently about 170 string-literal lookups against 11 identifier-based ones. That single fact explains most of its maintenance cost:

```swift
// Screens/SkontoScreen.swift — the prevailing pattern
switch locale {
case "en": confirmButton = app.buttons["Confirm and proceed"]
case "de": confirmButton = app.buttons["Bestätigen und weiter"]
default:   fatalError("Locale \(locale) is not supported")
}
```

Every one of these couples a test to copy that a writer may reword, to a language the team may add, and to a translation that may change. `fatalError` on the default branch means adding a third locale breaks every page object at once.

The suite already contains the destination pattern. `Screens/CXExtractionScreen.swift` is the newest page object and it has no locale switch at all, because the CX extraction fields carry accessibility identifiers — it addresses 26 fields by name and works in any language. `MainScreen` and `SettingScreen` are partway there via `AccessibilityIdentifiers/*.swift` enums.

So the default move, whenever touching a page object: convert what you touch onto identifiers rather than adding another locale branch. Don't rewrite whole files unasked — migrate the elements the current task involves, and note the rest.

## Where identifiers have to be set

This is the part that surprises people. All 18 `accessibilityIdentifier` assignments in the repo are in the example app (`GiniBankSDKExample/`). **Zero are in the SDK sources.** But the screens the tests actually exercise — camera, review, onboarding, Skonto, return assistant, error, help, transaction docs — are SDK UI, living in `CaptureSDK/GiniCaptureSDK/Sources/` and `BankSDK/GiniBankSDK/Sources/`.

Adding an identifier for those screens is a change to shipped SDK code, not to test code. That means:

- It goes through normal SDK review and follows the repo's commit and PR conventions in `AGENTS.md`.
- It propagates down the dependency chain — a change in `GiniCaptureSDK` reaches `GiniBankSDK`. See `CLAUDE.md`'s dependency graph.
- `accessibilityIdentifier` is internal-only and is not read aloud by VoiceOver, so it does not affect the accessibility experience for users. `accessibilityLabel` does — never repurpose a label as a test hook.

Set them close to where the view is configured, and mirror each one into the matching `AccessibilityIdentifiers/<Screen>AccessibilityIdentifiers.swift` enum so tests reference a symbol instead of a loose string. The existing enums use `case photoPaymentButton = "photoPaymentButtonIdentifier"` — keep that shape so the two halves stay greppable.

New SDK UI in this repo is SwiftUI-first — see the `gini-swiftui` skill for the conventions. That makes new screens the cheap case: adding `.accessibilityIdentifier("…")` as the view is written costs nothing, while retrofitting an existing UIKit screen means touching shipped code. Anything new should arrive identifier-ready rather than joining the backlog.

## Writing a test

**Start from the page object, not the test.** If a `Screens/<Name>Screen.swift` exists, add the element there and keep the test method describing a user journey. Tests that reach into `app.buttons[...]` directly bypass the abstraction the suite is built on.

**Find out what is really on screen before writing queries.** Reading source and guessing element names produces tests that compile and fail. The reliable move is a throwaway probe test that dumps the accessibility tree, run once against the screen in question:

```swift
func testProbe() {
    // navigate to the screen under test, then:
    print(app.debugDescription)
}
```

Read the dump, write queries against what is actually there, then delete the probe. This matters more here than in most suites, because the SDK screens have few identifiers — you are reading the tree to find out what a control's label or type actually is, and often to discover that it needs an identifier.

**Assert something.** A test that taps through a flow without an assertion passes whenever the app fails to crash. Each test should end knowing something specific: an element exists, a value equals, a screen was reached.

**Prefer `waitForExistence(timeout:)` to bare `exists`.** The suite already does this well — 276 uses, no bare `exists` inside an assertion. Keep that record intact. UI is fluid; `exists` asks whether an element is there at this instant, which is a race.

## Audit rules

When reviewing or de-flaking, these are the checks worth running, roughly in order of how much trouble they cause. `references/xcuitest.md` explains the reasoning behind each.

| Check | Current count | What to do |
|---|---|---|
| Element matched by localised string | ~170 | Migrate to an identifier; add it to SDK source if missing |
| `fatalError` on unknown locale | 12 page objects | Disappears once the screen is identifier-driven |
| `sleep(n)` | 5 | Replace with `waitForExistence` or an `XCTNSPredicateExpectation` |
| `firstMatch` | 38 | Fine when genuinely unique; otherwise it hides a non-uniqueness error rather than fixing it |
| `element(boundBy: n)` | 16 | Index into a live UI — reorder the layout and the test silently tests something else |
| `springboard.buttons[...]` for permissions | 12 refs | Two page objects carry a TODO to move to `addUIInterruptionMonitor`; that TODO is correct |
| `descendants(matching:)` | 2 | Scans the whole tree; prefer `children(matching:)` when the parent is known |
| `XCTContext.runActivity` | 0 | Long flows are hard to read in reports without grouping |
| Named `XCTAttachment` screenshots | 1 | Only the teardown screenshot exists; named shots at decision points make BrowserStack failures readable |

Report findings with file and line and a concrete fix. Don't bulk-rewrite the suite because the audit found something — surface it, fix what the current task touches, and let a human decide the rest.

## Running tests

These tests **skip on the simulator by design.** The base class opens with:

```swift
#if targetEnvironment(simulator)
    throw XCTSkip("Skipping test on simulator")
#endif
```

So a green local run may mean nothing ran. Never report a simulator run as a pass. Real execution happens on a device or through the BrowserStack scripts in `GiniBankSDKExampleUITests/Scripts/` (`bs_run_smoke_tests.sh`, `bs_run_skonto.sh`, `bs_run_cx_*.sh`, and so on) — read `Scripts/README.md` before invoking one, and don't launch a paid BrowserStack run without the user asking.

This constraint shapes how to work: you cannot iterate quickly by running the suite. Get the code right by reading the accessibility tree and the existing page objects, and treat each real run as expensive.

## Generating a BrowserStack run script for new tests

Whenever you create a new UI test class (or a new group of tests with their own fixtures), **ask the user whether they want to run these tests on BrowserStack**. If yes, generate a dedicated `Scripts/bs_run_<feature>.sh` alongside the tests — don't leave the new class unreachable from the existing runners. The script must follow the established shape:

1. Source `bs_shared.sh` (set `SCRIPT_DIR` first) and add a `BUILD_LABEL` case for the new script name in `bs_shared.sh`'s `case` block.
2. `upload_media` each fixture the tests need. Routing matters: `.pdf` lands in Files → `Custom_Files` (tests pick it via `tapFileFromBestAvailableSource`/`tapFileWithNameFromBSCustomFiles`), `.png`/`.jpg` lands in the Photos gallery (tests pick it via `uploadLatestPhotoFromGallery(offset:)` — upload order controls the offset). **Every gallery-path test needs a PNG in `uploadMedia`** — with an empty Photos library the picker query freezes until the runner times out, which reads as a mysterious 200s hang. Max **5 files per build's `uploadMedia`**; if a scenario needs more, split it into two builds.
3. `bs_build`, `bs_upload_app_and_suite`, then trigger the build with `only-testing` scoped to exactly the new class(es) (`GiniBankSDKExampleUITests/<ClassName>`), a `buildName` matching the script name, `uploadMedia` with every uploaded URL, and `resignApp: "true"`. Camera-injection tests additionally need `enableCameraImageInjection` + `cameraInjectionMedia`.
4. `bs_cleanup` at the end, and register the new script in `Broswerstack_README.md`'s overview table and usage section, including any fixture preconditions.

**BrowserStack project name — verify before every run.** The convention is `GiniBankSDK-iOS-<x.x.x>` where `x.x.x` is the release version under test. The value lives in ONE place: `BS_PROJECT` in `bs_shared.sh` (env-overridable). Before triggering a run, compare it against the **release branch name only** (e.g. `release/GiniBankSDK-4.5` → `GiniBankSDK-iOS-4.5.x`) — do NOT use `GiniBankSDKVersion.swift`, it may not be bumped yet at this point in the release. The branch gives major.minor; the patch digit isn't derivable from it, so when the current `BS_PROJECT` doesn't match the branch or the full `x.x.x` isn't obvious, **ask the user for the version once**, then update the `bs_shared.sh` default so subsequent runs inherit it — never invent a version, and never leave a stale one silently grouping new runs under an old release.

**Every BrowserStack build needs a distinct, meaningful name.** The dashboard derives the display name from the uploaded IPA's filename, so name = the script's `BUILD_LABEL` (standalone scripts) or the per-scenario IPA filename (`bs_run_all.sh`). One name per scenario/feature — two builds sharing a name are indistinguishable in the build list. When creating a new script and the right name isn't obvious from the feature, **ask the user what the build should be called** rather than defaulting to something generic.

Every build request should also carry these execution settings (see `bs_run_credit_note.sh`/`bs_run_all.sh` for the canonical shape):

- `"timeout": 7200` — the default 30-minute session cap kills long suites mid-run and everything unexecuted shows as **skipped**; a suite of ~9 full-flow tests already brushes 30 minutes.
- `"singleRunnerInvocation": "true"` — one runner process for all tests instead of one per test (~30–60s saved per test, logs stay segregated). Safe here because every test relaunches the app in `setUp` with `-StartFromCleanState`; trade-off: the retry-failed-tests API stops working in this mode.
- Sharding (`"shards"` with a `mapping` of named `only-testing` groups) parallelizes within a build, but **only helps when licenses ≥ shards × devices**: `deviceSelection: "any"` sacrifices device coverage, `"all"` multiplies sessions. On the current plan (2 licenses, always the 2-device pair) sharding is a no-op — every unsharded build already consumes the full budget, so builds run sequentially. Revisit when the plan grows; `bs_run_all.sh`'s `trigger_scenario` already accepts a shards block + shard count. `singleRunnerInvocation` composes with shards (applies within each shard). Don't combine shards with camera injection untested.
- **License-aware pacing is mandatory for multi-build sweeps.** BrowserStack cancels queued jobs after 15 minutes of waiting — shorter than a scenario build's runtime — so firing more sessions than the account's parallel licenses silently kills the overflow. `bs_run_all.sh` is the pattern: track triggered build_ids with their session weights (shards, or device count when unsharded), poll build status, and wait for free licenses before each trigger. The license count lives in `BS_PARALLELS` (default 2 — the current plan); when the plan or suite grows, follow the "Execution strategy & scaling" section in the scripts README (widen shards past ~20-minute sessions, raise `BS_PARALLELS`, split scenarios at the 5-media cap).
- Support `BS_DEVICE` (single device override) and `BS_TEST` (single test/class override) environment variables — the cheap smoke-run path every new script should offer.

For locale-dependent flows, support an optional `BS_LANGUAGE` environment variable that injects the `language` field into the build request, so the German Xray variants can run without a second script. Generating the script is cheap and safe; **launching it is not** — it consumes BrowserStack minutes, so never execute a `bs_run_*.sh` without the user explicitly asking.

### Reading BrowserStack results — decoding the statuses

- **Build "unknown"**: the `only-testing` filter matched nothing — usually a class whose methods were parked (renamed `manualTest*`) or a typo'd class name. Grep for `func test` in the class before blaming the infrastructure.
- **Tests "skipped"**: the session ended before they got their turn (tests run sequentially per session). Look at what happened immediately before the first skipped test: a crash there, or a session timeout (30-minute default — see `timeout` above). XCTSkip is almost never the reason on device — the suite's only real skips are iPad-gated.
- **Build named after the IPA** (`Something.ipa v1.0#N`): the dashboard derives the build display name from the uploaded IPA's filename; `buildName` isn't honored. To distinguish concurrent builds, upload the same IPA under per-scenario filenames (`bs_run_all.sh` does this) and set `buildTag`.
- **Freeze in the photo picker**: empty gallery (missing PNG in `uploadMedia`) — see step 2.
- **Queue rejections**: BrowserStack accepts only a few queued builds beyond running ones; extra POSTs are rejected. Retry with a delay (`bs_run_all.sh`'s `trigger_scenario` retry loop is the pattern).
- The app must launch clean without secrets: the repo ships masked `GoogleService-Info.plist`/`Credentials.plist`, `FirebaseApp.configure()` is guarded on a real API key, and real-backend tests need real credentials in `Credentials.plist` before building — masked credentials fail auth at analysis time, not at launch.

## Backend-flag test cases (the Charles replacement)

Manual Xray cases that toggle a backend `ClientConfiguration` flag "with Charles" cannot use a proxy on BrowserStack devices. The working substitute is the **generic mock backend in the example app** — `GiniBankSDKExample/UITestSupport/UITestMockBackend.swift` — no SDK change needed: it rides the public entry point `GiniBank.viewController(importedDocuments:configuration:resultsDelegate:...networkingService:configurationService:)`, implementing `GiniCaptureNetworkService` (canned upload/analyse outcomes) and `ClientConfigurationServiceProtocol` (any flag combination). A test activates it with two launch arguments:

```swift
override var additionalLaunchArguments: [String] {
    ["-UITestMockScenario", "creditNote",
     "-UITestMockClientConfig", "creditNoteHintEnabled=true,skontoEnabled=false"]
}
```

- `-UITestMockScenario <name>` selects the canned analysis outcome from the `UITestMockScenario` enum (`creditNote`, `invoice`, `analysisError`, …) — **add a new enum case with its payload or error to support a new feature**; scenarios are compile-checked, and error cases make error-screen tests deterministic.
- `-UITestMockClientConfig "flag=true,flag=false"` overrides any `ClientConfiguration` flag over an all-false baseline — no code change for new flag combinations.
- Unknown scenario names or flag keys hit `assertionFailure` — a typo must fail loudly, not silently test the wrong matrix cell.
- Limits: `layout`/`pages`/`documentPage` are no-ops, so flows awaiting a document preview (TransactionDocs preview) need those implemented first; CX compound-extraction payloads are unverified; the real pipeline (auth, upload) is bypassed — keep real-backend smoke tests alongside.

Reference usage: the `GiniCreditNoteMockBackend*UITests` classes under `GiniBankSDKExampleUITests/CreditNote/` — name mock-backend test classes with a `MockBackend` marker so they're distinguishable from real-backend suites at a glance; one test class per launch-argument combination (a class is the unit of launch arguments), toggling the SDK-side flag via the Settings screen within tests. Test-writing rules learned there: anchor on the positive end-state screen before asserting a dialog's absence instead of paying a fixed `waitForExistence` timeout, and document any mock config value a test's flow silently depends on at its declaration.

## Scope

UI tests are the slowest and least stable layer of the pyramid, and the cost of a bad one is not zero — it is a test the team learns to ignore. Write them for journeys that matter: a flow a user completes, a regression that reached production, a screen whose breakage would ship. When a request could be satisfied by a unit test against a view model or a parser instead, say so; those live in the SDK `Tests/` directories and run in seconds on any machine.

If asked to generate tests in bulk, push back once with a concrete alternative before doing it.

## Things to leave alone unless asked

`GiniBankSDKExampleSwiftUIUITests/` and `GiniBankSDKExampleSwiftUITests/` are unmodified Xcode boilerplate — an empty `testExample()`, a launch-performance measure, and an empty Swift Testing `example()`. They test nothing. Worth mentioning to the user as either "fill these in" or "delete them", but don't decide that unilaterally.

Note that Swift Testing (`import Testing`, `@Test`, `#expect`) is for unit tests only. UI testing is still XCTest and `XCUIApplication`, so a UI test always subclasses `XCTestCase`.
