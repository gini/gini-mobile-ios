# iOS review checklist — gini-mobile-ios

**Platform layer for `/gini-review`** — read at **§3** of `pr-review/SKILL.md`, on every review.

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has
  references/android-checklist.md covering the same nine sections with Android
  content. Nothing in here belongs in pr-review/, which stays byte-identical
  across both repos.
-->

**Supports:** published API surface · dependencies and manifests · release mechanics · module ripple ·
architecture and style · test conventions · commit hygiene · **the do-not-flag list**

**Does not cover:** ABI and binary compatibility → `ios-api-surface.md` · the review procedure →
`pr-review/SKILL.md`

**Nothing here is tied to a particular PR, ticket, branch or release, and it must stay that way.** This
file is read on every review in this repository, so it holds only standing conventions. Ticket keys,
version numbers and API names that appear below are **format placeholders**, never live values — do not
carry one into a review as if it came from the PR. Where a count or a version is quoted, it is
approximate and as-of-writing: re-check it against the tree rather than citing it as fact.

**Canonical, citable sources in this repo.** A finding quotes one of these by line, or it is a bare
preference and gets dropped: `AGENTS.md` (doc/comment style, the compile gate, the PR workflow and PR
template requirement), `CLAUDE.md` (dependency graph, module layout, commit format, release process, and
the **"MyApp Standards"** section whose rules are written as `MUST`), the sibling
`.claude/skills/gini-build/platform.md` and `gini-fix/platform.md` (build, test and reproduction
conventions), `.git-stuff/commit-msg-template.txt`, `.swiftlint.yml`, `RELEASE-ORDER.md`, and any
`CLAUDE.md` in a directory the diff touches.

**Where those instructions have drifted from the code.** Cite them anyway — they are what the team agreed
— but know the gaps, so a finding doesn't collapse under one reply from the author:

- `CLAUDE.md` mandates the `UIColor.GiniBank.*` / `UIColor.GiniCapture.*` colour namespaces, but a newer
  `GiniColorScheme` family has reached ~25 files without the doc being updated. See §5.
- `CLAUDE.md` says new tests MUST use Swift Testing, while XCTest is still the majority by file count.
  See §6.
- `CLAUDE.md` describes test fixtures as JSON; several modules ship `.pdf`, `.jpg`, `.txt` and `.png`
  fixtures too.
- `CLAUDE.md` §"Working on All Tasks" tells agents not to run tests by default and to wait for
  confirmation. That aligns with the engine's hard rule — **this review never runs builds or tests** — so
  there is no conflict to resolve, and "did not run the tests" is not a gap to apologise for in the report.

If a review turns up a fresh drift like these, the fix is a line in this file, not a per-review
correction.

## 1. Published API surface

**Swift is `internal` by default — the exact inverse of Kotlin's public-by-default trap.** Nothing
leaks by accident here. That flips what review is for: every `public` or `open` in the diff is a
deliberate decision, so review it as one rather than hunting for accidents.

- Visibility ladder: `open` > `public` > `package` > `internal` (default) > `fileprivate` > `private`.
- **All seven modules ship to a public release repo** — there is no internal-only module:
  `GiniBankSDK` → `gini/bank-sdk-ios`, `GiniCaptureSDK` → `gini/capture-sdk-ios`, `GiniHealthSDK` →
  `gini/health-sdk-ios`, `GiniBankAPILibrary` → `gini/bank-api-library-ios`, `GiniHealthAPILibrary` →
  `gini/health-api-library-ios`, `GiniUtilites` → `gini/utilites-ios`, and — **despite the name** —
  `GiniInternalPaymentSDK` → `gini/internal-payment-sdk-ios`. Treat a new `public` symbol in
  `GiniInternalPaymentSDK` as published API, not as internal shared code.
- `@testable import` reaches `internal`, so **a test never justifies making something `public`.** A
  diff that widens visibility "for testing" is a finding.
- Once a `<Package>;<version>` tag ships, that symbol is in a public release repo
  (`gini/bank-sdk-ios`, `gini/capture-sdk-ios`, …) and integrators pin it with `.exact()`. Removing or
  renaming it is a breaking change for them.
- **There is no `apiCheck` equivalent and no committed API snapshot.** Nothing in CI tells you the
  public surface changed. Review is the only gate — see `ios-api-surface.md`.

## 2. Dependencies and manifests

Two manifests per module, and **keeping them in step is the highest-value mechanical check in this
repo**:

| File | Role |
|---|---|
| `<SDK>/Package.swift` | Local development. Dependencies by `path:` (`../../CaptureSDK/GiniCaptureSDK`). Product type is conditional on `GINI_FORCE_DYNAMIC_LIBRARY` for XCFramework builds. |
| `<SDK>/Package-release.swift` | The manifest shipped to the release repo. Dependencies by `url:` with `.exact("<x.y.z>")` pins. |

- **A dependency or target added to `Package.swift` without the matching edit to
  `Package-release.swift` breaks the release build — and no PR check catches it.** `*.check.yml` only
  runs `swift package update` against the local manifest. If the diff touches one manifest and not the
  other, say so and name the missing edit.
- A **new third-party dependency** in an SDK target is a design question, not a detail: it propagates
  to every integrator and must resolve inside the XCFramework graph, which has no transitive
  resolution (see the comment in `BankSDK/GiniBankSDK/Package.swift`). Raise it under Design.
- `platforms: [.iOS(.v15)]` — iOS 15 minimum, **iOS 17 for GiniHealthSDK and GiniHealthAPILibrary**. An
  iOS-16+ API used without `if #available` in an iOS-15 module is a correctness defect, not a nit.
- `swift-tools-version:5.5`. Strict concurrency checking is **not** on; don't cite Swift 6 isolation
  rules as if the compiler enforced them here.
- `*.xcodeproj/project.pbxproj` is tracked (everything else under `*.xcodeproj/` is gitignored).
  Project-file diffs are noisy but real — check that a new source file was actually added to the right
  target, and that no scheme or build setting changed silently.

## 3. Release mechanics

- Version lives in `Sources/<SDK>/<SDK>Version.swift` as a single `public let` (e.g.
  `public let GiniBankSDKVersion = "<x.y.z>"`). A feature PR normally should **not** touch it — a stray
  version bump in a feature branch is a scope finding.
- Tags: `<PackageName>;<version>` (e.g. `GiniBankSDK;<x.y.z>`); XCFramework builds use
  `<PackageName>;<version>;xcframeworks`. Tags trigger publish workflows. **Never suggest pushing one.**
- Release order follows the dependency chain in `RELEASE-ORDER.md`; the `.exact()` pins in each
  dependent's `Package-release.swift` are bumped in that order.
- Fixes for older majors ship from the matching release branch, not `main`. If the ticket names an
  older SDK version, check the base branch is right — an older-major fix targeting `main` is a
  blocking finding no linter will catch.
- Generated / vendored, never hand-edited: `graphify-out/` (gitignored), `.build/`, `.swiftpm/`,
  `Documentation/jazzy-theme/assets/js/` (bundled jQuery, lunr, typeahead).

## 4. Module ripple

```
GiniBankAPILibrary ──┐
GiniUtilites ────────┼──→ GiniCaptureSDK ──→ GiniBankSDK
                     │
GiniHealthAPILibrary─┤
GiniUtilites ────────┼──→ GiniInternalPaymentSDK ──→ GiniHealthSDK
```

| Changed | Downstream consumers |
|---|---|
| `GiniComponents/Utilities/GiniUtilites` | **Everything** — both SDK chains |
| `BankAPILibrary/GiniBankAPILibrary` | GiniCaptureSDK, GiniBankSDK |
| `CaptureSDK/GiniCaptureSDK` | GiniBankSDK |
| `HealthAPILibrary/GiniHealthAPILibrary` | GiniInternalPaymentSDK, GiniHealthSDK |
| `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK` | GiniHealthSDK |
| `BankSDK/GiniBankSDK`, `HealthSDK/GiniHealthSDK` | Example apps only |

**The CI gap you must cover manually.** Check workflows trigger on paths, and the paths do not follow
the dependency graph:

- `bank-sdk.check.yml` → `BankSDK/**`, `CaptureSDK/**`, `BankAPILibrary/**`
- `health-sdk.check.yml` → `HealthSDK/**`, `HealthAPILibrary/**`
- `utilites.check.yml` → `GiniComponents/Utilities/GiniUtilites/**` only

So a PR touching **only `GiniUtilites`** runs `utilites.check.yml` and nothing else — no dependent
SDK's tests run, even though every SDK depends on it. Same for `GiniInternalPaymentSDK`: HealthSDK's
suite does not run. On such a PR, **the reviewer is the only gate on downstream breakage.** Trace the
changed symbol's call sites into each dependent and say in the report that you did — or that CI did
not.

## 5. Architecture and style

`CLAUDE.md` §"MyApp Standards" states these as **MUST**s, which makes them the strongest citations
available in this repo. Quote the line.

- **MVVM + Coordinator.** Every feature gets its own `*Coordinator`. **The SDK entry point is always a
  single static factory returning a `UIViewController`** — a new public initialiser used as an entry
  point instead is a citable design finding.
- **ViewModels MUST NOT import UIKit.** Binding is closure-based (`addStateChangeHandler`).
  ViewModel→Coordinator goes through a **weak** delegate protocol. **View controllers only lay out UI
  and forward events — no business logic.** That last one is the most frequently violated rule in the
  set; check any new `UIViewController` method that makes a decision rather than delegating it.
- Constructor injection is mandatory. Delegate back-references are the only acceptable post-init
  injection. `GiniBankAPI.Builder` (value-type fluent builder) is the required pattern for SDK entry
  points.
- **Doc comments — `AGENTS.md` is explicit and citable:** `/** ... */` for declarations,
  `///` **only** for inline comments inside function bodies. A new `///` doc comment on a declaration is
  a real finding with a line to quote.
- **Multi-parameter initializers and methods MUST be one parameter per line**, first parameter staying on
  the opening-paren line, the rest aligned vertically. `CLAUDE.md` §"Code Style" spells this out with
  explicit ❌/✅ rules and a worked example — an unusually safe finding to raise.
- Strings via typed `LocalizableStringResource` enums keyed `<sdk>.<feature>.<screen>.<element>`; never
  raw `NSLocalizedString`. Lookup is a 3-level chain — host app → custom bundle → SDK bundle — so a key
  added without going through the typed enum silently breaks an integrator's override. When a diff adds a
  key, check it exists in the `Resources/*.strings` files the module already ships, not just the German
  default.
- **Colours — cite `CLAUDE.md`, and know that the code has drifted from it.** `CLAUDE.md` §"Design
  System" says colours **MUST** be accessed via the `UIColor.GiniBank.*` / `UIColor.GiniCapture.*`
  namespaces, with dark mode via `GiniColor(light:dark:)`, fonts via `textStyleFonts[textStyle]` with
  Dynamic Type, and spacing in a local `enum Constants` (no magic numbers). In the code,
  `GiniColor(light:dark:)` is widespread (~76 files) and the namespaces are alive (~29 files), but a
  newer `GiniColorScheme` family in
  `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/Color/GiniColorScheme.swift` has reached
  ~25 files without `CLAUDE.md` blessing it. Practical rule: **match the file you are in**; you can cite
  `CLAUDE.md` against a raw `UIColor(...)` or a hard-coded hex, but do not demand a migration in either
  direction — the convention is genuinely unsettled and a PR is the wrong place to settle it. Flag the
  drift under **Needs a human** if the diff makes it worse.
- **UIKit vs SwiftUI is a carve-out, not a preference.** UIKit is the pattern in GiniBankSDK,
  GiniCaptureSDK screens and GiniHealthSDK view controllers. SwiftUI is the norm in
  GiniInternalPaymentSDK and `GiniUtilites/SwiftUI/`. Don't ask for a UIKit screen to be rewritten in
  SwiftUI, and don't accept a UIKit view controller dropped inside a SwiftUI feature.
- Spacing and magic numbers belong in a local `private enum Constants`. Dynamic Type via
  `textStyleFonts[textStyle]`.

**Legacy carve-outs — follow the local style, don't improve it:** CaptureSDK's UIKit screens, existing
XCTest suites (see §6), and anything under `Documentation/jazzy-theme/`. Note that the
`UIColor.Gini*` namespaces are **not** a carve-out — `CLAUDE.md` still mandates them, so treat them as
current, not as legacy to be migrated.

## 6. Test conventions

- Unit tests in `<SDK>/Tests/<SDK>Tests/`, named `<ClassUnderTest>Tests.swift`. Fixtures in
  `Tests/<SDK>Tests/Resources/`, wired via `.process("Resources")` — reuse an existing fixture rather than
  adding a near-duplicate. (`CLAUDE.md` says "JSON fixtures"; in practice CaptureSDK also ships `.pdf`
  rotated and multi-page variants, `.jpg` and `.txt`, and the API libraries ship `.png` payloads. Don't
  cite the JSON wording against a PDF fixture.)
- **`CLAUDE.md` §"Testing" says new tests MUST use Swift Testing (`@Suite`, `@Test`, `#expect`).** Cite
  it: a brand-new XCTest suite is a citable finding, not a preference. The honest qualifier is that the
  repo has not converged — XCTest is still the majority by file count (~150 vs ~48), fully replaced only
  in GiniInternalPaymentSDK and dominant-for-new-suites in GiniBankAPILibrary and GiniCaptureSDK, while
  GiniBankSDK, GiniHealthSDK and GiniHealthAPILibrary remain mostly XCTest. So: **a new test file should
  be Swift Testing; adding a case to an existing XCTest class should match that file.** Asking someone to
  convert an existing suite is out of scope for a PR review.
- **`CLAUDE.md` also states all ViewModels and Services must have unit tests**, and that coverage is
  weakest on ViewControllers and Coordinators. A new ViewModel or Service with no test is therefore a
  citable blocking finding; a new Coordinator without one is a fair improvement, not a blocker.
- Manual protocol-conformance mocks. **No mocking framework and no snapshot-testing library** — do not
  suggest one.
- UI tests in `<SDK>Example/<SDK>ExampleUITests/` use a Page Object pattern with selectors under
  `Screens/`. A raw selector added outside a screen object is a finding.
- Integration tests need `TEST_CLIENT_ID` / `TEST_CLIENT_SECRET`. CI supplies them; locally they are
  absent, so **a skipped or failing integration test is not evidence about this PR.**

**When a missing test is genuinely blocking:** a bug fix in decision logic, a view model, a mapper, an
API-library request/response path, or anything reachable from a plain unit test. Say which file the test
belongs in.

**When it is not** — insisting here produces false positives: camera and scanner hardware paths, Vision
/ QR detection against live frames, UIKit presentation and `UISheetPresentationController` behaviour,
photo-library and permission dialogs, anything needing a real device. The most those get is an example-app
UI test; ask for a manual verification note under **Needs a human** instead.

## 7. Commit hygiene

`.git-stuff/commit-msg-template.txt` is the source of truth — read it rather than trusting a list.

```
<type>(<project>): <subject>

<body>

<ticket-id>
```

- Types: `feat`, `fix`, `refactor`, `ci`, and **`ai`** — the last one covers Claude Code skills, agents
  and commands, i.e. anything under `.claude/` or `.github/instructions/`.
- `<project>` is the module name (`GiniBankSDK`); omit the parentheses entirely for multi-module changes.
- `<subject>` imperative, no trailing period. Ticket id alone on the **last** line — the key formats in
  use are `PP-`, `HEAL-`, `XPL-` and `FEAT-` followed by digits.
- The PR title becomes the merge-commit subject, so hold it to the same standard.
- **`AGENTS.md` mandates the PR body follow `.github/pull_request_template.md`** — Pull Request
  Description with the ticket, plus Notes for Reviewers covering how it was verified, devices and iOS
  versions, and tests added. An empty or free-form PR body is a citable finding.

## 8. Do not flag — this list is what keeps the output readable

**Read this before reporting anything stylistic. The CI story here is the opposite of Android's.**

- **SwiftLint runs, but it can never fail a build.** Be precise about this, because the loose version
  ("SwiftLint isn't in CI") is wrong and a reviewer will get contradicted. What is actually true:
  - No workflow step runs it, and `scripts/swiftlint.sh --strict` is wired into nothing.
  - It **is** a `SwiftLint` build phase in `BankSDK/GiniBankSDKExample` and
    `HealthSDK/GiniHealthSDKExample`'s `project.pbxproj`, invoked as
    `swiftlint --config "${SRCROOT}/../../.swiftlint.yml"` — **without `--strict`** — and the phase is
    wrapped in `if which swiftlint`, echoing a warning and skipping when the binary is absent.
  - CI builds those example projects (`xcodebuild ... -scheme GiniBankSDKExampleTests`), so the phase does
    fire there. But no `--strict` plus every `error:` threshold commented out in `.swiftlint.yml` means
    violations surface as **build warnings only**.

  So SwiftLint findings are neither "already blocked by CI" nor worth reporting on their own — and most
  are noise for a second reason:
  - **These rules are explicitly disabled in `.swiftlint.yml`:** `force_try`, `force_unwrapping`,
    `force_cast`, `empty_count`, `shorthand_operator`, `identifier_name`, `type_name`, `todo`,
    `switch_case_alignment`, `class_delegate_protocol`, `notification_center_detachment`,
    `empty_enum_arguments`, `multiple_closures_with_trailing_closure`. **A finding whose only basis is
    one of these cites a rule the repo turned off.** Drop it. In particular: do not report a force-unwrap
    or a `TODO` as a style violation.
  - **Exception, and it matters:** a force-unwrap or force-cast on a path that can actually be `nil` or
    the wrong type is a **correctness** finding. Report the crash, name the input that reaches it — never
    the rule.
  - Length and complexity limits are **warnings** with the error levels commented out (`line_length` 160
    ignoring comments and URLs, `file_length` 1000, `function_body_length` 100, `type_body_length` 300,
    `cyclomatic_complexity` 10). Crossing a warning threshold is not a blocking finding.
- **What CI actually runs** — the Swift compiler (via `make lint scheme=<Scheme>` and the package build),
  unit tests through `bundle exec fastlane run_unit_tests`, example-app unit + integration tests via
  `xcodebuild`, **SonarQube** (coverage + quality gate), **CodeQL**, a secret scan, and SBOM generation.
  Do not run any of them yourself. Anything the **compiler** catches is noise, full stop. For SonarQube
  and CodeQL, drop a finding that merely restates one of their rules — but do not assume they cover a
  logic or acceptance-criteria defect; they do not, and that is where this review earns its keep.
- **Never review these paths:** `**/.build/` (vendored checkouts — SWCompression, BitByteData, …),
  `**/.swiftpm/`, `**/Pods/`, `**/build/`, `DerivedData`, `xcuserdata/`, `graphify-out/`,
  `Documentation/jazzy-theme/assets/js/`. `.swiftlint.yml`'s own `excluded:` list is the reference.
- **Vendored binaries that are tracked in git**, which the ignore list does not cover: any
  `**/*.xcframework/` in the tree, notably `BrowserStackTestHelper.xcframework` under
  `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Frameworks/`. Its `.swiftinterface`,
  `Info.plist` and `.dylib` contents are third-party build output — never review them, and never mistake
  their `.swiftinterface` files for a snapshot of our own API (see `ios-api-surface.md`). A PR that
  *replaces* such a binary is a different matter: that is a dependency bump and belongs under Design.
- Pre-existing lines the PR did not modify, and deliberate suppressions carrying a comment.
- Example-app config: `BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist` and
  `GoogleService-Info.plist` are **tracked** and routinely carry each developer's local values. An
  unintended diff on them is one line under scope, not a paragraph. **But a real client secret committed
  there is a blocking finding** — check the values, not just the filename.
- Translation wording in `Resources/*.strings`. Check that a new key is present and correctly
  referenced; do not critique the German copy.

## Sharpening the three platform-bound dimensions

| Dimension | On iOS here |
|---|---|
| **Concurrency** | Mixed model: `async`/`await` and `Task` in newer code, completion handlers still dominant in the API libraries. Look for `Task` not cancelled on teardown, UI mutated off the main thread (missing `@MainActor` or `DispatchQueue.main.async`), escaping closures capturing `self` strongly, and shared mutable state touched from two queues. Swift 5.5 tools version — **no strict concurrency checking**, so the compiler will not catch isolation bugs. |
| **Lifecycle** | `deinit` / `viewWillDisappear` teardown, Coordinator↔ViewController retain cycles, delegates that must be `weak`, and `NotificationCenter` observers never removed. Note that **`class_delegate_protocol` and `notification_center_detachment` are both disabled in SwiftLint** — nothing but review catches these two leak classes. Also: state lost across scene changes, and `UISheetPresentationController` detents behaving differently pre-iOS 15. |
| **Documentation** | **Jazzy** is what integrators read — `<SDK>/.jazzy.yaml`, built by `bundle exec fastlane build_docs`. Every SDK's landing page is `Documentation/{s,S}ections/Documentation.md` (the `readme:` in its `.jazzy.yaml`; note BankSDK and CaptureSDK differ in the directory's capitalisation). The longer markdown guides — *Getting started*, *Installation*, *Migration guide* — live in `Documentation/source/`, which exists **only for GiniBankAPILibrary, GiniHealthAPILibrary and GiniHealthSDK**. GiniBankSDK and GiniCaptureSDK have no `source/`, so their landing page is the only doc surface. A public API change without the matching doc update is a legitimate finding — name the file that actually exists for that module. There is no Sphinx here. |
