# gini-review platform conventions — iOS (gini-mobile-ios)

<!--
  NOT SHARED — this file is iOS-specific by design, and it is the only file in
  this skill that may differ between the two repos.
  The Android repo does NOT have a matching platform.md yet: its gini-review
  still carries the older layout, with the local rules split across
  references/android-checklist.md and references/android-api-surface.md, and a
  nested pr-review/ copy of the shared files. Converging it is pending work.
  So if you add a section here that the shared engine depends on, make sure the
  Android side covers it too — in whichever file plays this role there.
  Nothing in here belongs in SKILL.md or references/ — those are the shared,
  platform-neutral part. See references/general-rules.md for the contract they
  follow and for how the copies are kept in sync.
-->

**Platform layer for `/gini-review`** — read at **§0** of `SKILL.md`, applied at **§3**, on every
review.

**Purpose:** the repo-specific rules a generic code reviewer would miss, and the noise it must refuse
to report.

**Sections:** 1 published API surface · 2 dependencies and manifests · 3 release mechanics · 4 module
ripple · 5 architecture and style · 6 test conventions · 7 commit hygiene · 8 **the do-not-flag
list** · 9 API compatibility (conditional — only when the diff touches a releasable module) · plus the
three sharpened dimensions.

**Canonical, citable sources in this repo.** A finding quotes one of these by line, or it is a bare
preference and gets dropped: `AGENTS.md` (doc/comment style, the compile gate, the PR workflow and PR
template requirement), `CLAUDE.md` (dependency graph, module layout, commit format, release process, and
the **"MyApp Standards"** section whose rules are written as `MUST`), the sibling
`.claude/skills/gini-build/platform.md` and `gini-fix/platform.md` (build, test and reproduction
conventions), `.git-stuff/commit-msg-template.txt`, `.swiftlint.yml`, `RELEASE-ORDER.md`, and any
`CLAUDE.md` in a directory the diff touches.

**Nothing here is tied to a particular PR, ticket, branch or release, and it must stay that way.** This
file is read on every review in this repository, so it holds only standing conventions. Ticket keys,
version numbers and API names that appear below are **format placeholders**, never live values — do not
carry one into a review as if it came from the PR. Where a count or a version is quoted, it is
approximate and as-of-writing: re-check it against the tree rather than citing it as fact.

**Where those instructions have drifted from the code.** Cite them anyway — they are what the team agreed
— but know the gaps, so a finding doesn't collapse under one reply from the author:

- `CLAUDE.md` mandates the `UIColor.GiniBank.*` / `UIColor.GiniCapture.*` colour namespaces, but the
  newer `GiniColorScheme` — declared in `GiniUtilites`
  (`GiniComponents/Utilities/GiniUtilites/…/Color/GiniColorScheme.swift`) and reached through a per-SDK
  factory on `UIColor`, today only `giniBankColorScheme()`, as
  `.giniBankColorScheme().text.primary.uiColor()` — is already in real use across the Bank SDK.
  `.claude/rules/mandatory-rules.md` §"Design system" now prefers it where a matching token exists, while
  `CLAUDE.md` still has not been updated. See §5.
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
- **All seven modules ship to a release repo, but only five of those are customer-facing API.**
  Customer-facing: `GiniBankSDK` → `gini/bank-sdk-ios`, `GiniCaptureSDK` → `gini/capture-sdk-ios`,
  `GiniHealthSDK` → `gini/health-sdk-ios`, `GiniBankAPILibrary` → `gini/bank-api-library-ios`,
  `GiniHealthAPILibrary` → `gini/health-api-library-ios`.
- **`GiniUtilites` → `gini/utilites-ios` and `GiniInternalPaymentSDK` → `gini/internal-payment-sdk-ios`
  are internal packages.** They have public release repos only because SPM needs a resolvable URL for
  the customer-facing SDKs to depend on — `gini/utilites-ios` describes itself as "Release repo for
  internal package". So **treat their `public` surface as internal shared code**: a new or widened
  `public` symbol there is not a customer-facing API decision, and needing one is not by itself a
  finding. What still is a finding: a symbol from either module re-exported through a customer-facing
  SDK's public surface, since that is the point it becomes a published contract.
- `@testable import` reaches `internal`, so **a test never justifies making something `public`.** A
  diff that widens visibility "for testing" is a finding.
- Once a `<Package>;<version>` tag ships, that symbol is in a public release repo
  (`gini/bank-sdk-ios`, `gini/capture-sdk-ios`, …) and integrators pin it with `.exact()`. Removing or
  renaming it is a breaking change for them.
- **There is no `apiCheck` equivalent and no committed API snapshot.** Nothing in CI tells you the
  public surface changed. Review is the only gate — §9 has the method.

## 2. Dependencies and manifests

Two manifests per module — **except `GiniBankAPILibrary`, which has only `Package.swift`** — and
**keeping the pair in step is the highest-value mechanical check in this repo**:

| File | Role |
|---|---|
| `<SDK>/Package.swift` | Local development. Dependencies by `path:` (`../../CaptureSDK/GiniCaptureSDK`). Product type is conditional on `GINI_FORCE_DYNAMIC_LIBRARY` for XCFramework builds. |
| `<SDK>/Package-release.swift` | The manifest shipped to the release repo. Dependencies by `url:` with `.exact("<x.y.z>")` pins. |

- **A dependency or target added to `Package.swift` without the matching edit to
  `Package-release.swift` breaks the release build — and no PR check catches it.** `*.check.yml` only
  runs `swift package update` against the local manifest. If the diff touches one manifest and not the
  other, say so and name the missing edit. Confirm the module actually has a release manifest first
  (`ls <SDK>/Package-release.swift`) — asking for an edit to a file that does not exist is a false
  positive.
- A **new third-party dependency** in an SDK target is a design question, not a detail: it propagates
  to every integrator and must resolve inside the XCFramework graph, which has no transitive
  resolution (see the comment in `BankSDK/GiniBankSDK/Package.swift`). Raise it under Design.
- `platforms:` — iOS 15 (`.iOS(.v15)`) for GiniBankAPILibrary, GiniBankSDK, GiniCaptureSDK and
  GiniUtilites; **iOS 17 (`.iOS("17.0")`) for GiniHealthAPILibrary, GiniHealthSDK and
  GiniInternalPaymentSDK**. An iOS-16+ API used without `if #available` in an iOS-15 module is a
  correctness defect, not a nit — so check the module's own manifest before raising or dismissing one.
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

**`.claude/rules/mandatory-rules.md` is the merged source for this section** — architecture, design
system, the CaptureSDK layout DSL, localization, formatting, documentation, accessibility and testing in
one file, derived from `CLAUDE.md` §"MyApp Standards" and `AGENTS.md`, with those two winning on any
drift. Read it first. Cite `CLAUDE.md`/`AGENTS.md` alongside it wherever the rule is written there as a
**MUST**, since that is the strongest citation available in this repo — quote the line.

The list below is a reviewer's index into that file, not a second source: it records which of those rules
get broken often and how hard each one is to defend. Where the two disagree, `mandatory-rules.md` has been
updated and this has not.

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
- **Colours — the two docs disagree, so know which one you are quoting.** `CLAUDE.md` §"Design System"
  says colours **MUST** go through the `UIColor.GiniBank.*` / `UIColor.GiniCapture.*` namespaces.
  `.claude/rules/mandatory-rules.md` §"Design system" is newer and states the order: prefer the shared
  semantic tokens in `GiniColorScheme` (declared in `GiniUtilites`) via the SDK's scheme factory —
  `UIColor.giniBankColorScheme()`, used as `.giniBankColorScheme().text.primary.uiColor()`, the only
  factory that exists today — and fall back to the per-SDK namespace with `GiniColor(light:dark:)` when no
  matching token exists. All three coexist in the code — `GiniColor(light:dark:)` is the most widespread,
  the per-SDK namespaces are still in wide use, and the scheme is the newest and smallest. Counting them
  is a one-liner, so re-run it instead of quoting a number that has already drifted once:
  `grep -rl --include="*.swift" --exclude-dir=.build "<pattern>" . | wc -l`. Practical rule: **match the
  file you are in**; both
  docs agree a raw `UIColor(...)` or a hard-coded hex is a finding, and dark mode is required either way,
  but do not demand a migration in either direction — a PR is the wrong place to settle it. Flag the drift
  under **Needs a human** if the diff makes it worse.
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

**Two existing sources, both citable — read them rather than trusting a list.**
`.github/instructions/commit-message-guideline.instructions.md` is the written guideline (format, the
module names in use, subject and body rules, the ticket-id rule), and it defers explicitly to
`.git-stuff/commit-msg-template.txt` as the **single source of truth for the allowed `<type>` values** and
what each one covers. Quote the guideline for shape, the template for types.

```
<type>(<project>): <subject>

<body>

<ticket-id>
```

- Read the allowed `<type>` values off the template on the day you review — the set has grown before.
  The one worth knowing is **`ai`**, which covers AI tooling and assets: Claude Code skills, agents,
  commands and their markdown, i.e. anything under `.claude/` or `.github/instructions/`.
- `<project>` is the module name (`GiniBankSDK`); omit the parentheses entirely for multi-module changes
  or when no single module is affected. The guideline lists the names in use — use one of those spellings.
- `<subject>` imperative mood, no trailing period. `<body>` says what changed and why, never how.
- Ticket id alone on the **last** line. Take the key off the branch or PR rather than assuming a board;
  `PP-` and `HEAL-` are what appear in practice, but the key is whatever the ticket is.
- The PR title becomes the merge-commit subject, so hold it to the same standard.
- **`AGENTS.md` mandates the PR body follow `.github/pull_request_template.md`** — Pull Request
  Description with the ticket, plus Notes for Reviewers covering how it was verified, devices and iOS
  versions, and tests added. An empty or free-form PR body is a citable finding.

## 8. Do NOT flag — this list is what keeps the output readable

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
  their `.swiftinterface` files for a snapshot of our own API (see §9). A PR that *replaces* such a
  binary is a different matter: that is a dependency bump and belongs under Design.
- Pre-existing lines the PR did not modify, and deliberate suppressions carrying a comment.
- Example-app config: `BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist` and
  `GoogleService-Info.plist` are **tracked** and routinely carry each developer's local values. An
  unintended diff on them is one line under scope, not a paragraph. **But a real client secret committed
  there is a blocking finding** — check the values, not just the filename.
- Translation wording in `Resources/*.strings`. Check that a new key is present and correctly
  referenced; do not critique the German copy.

## 9. Published API and compatibility — conditional

**Read this section only when the diff touches a releasable module** — `GiniBankSDK`, `GiniCaptureSDK`,
`GiniHealthSDK`, `GiniBankAPILibrary`, `GiniHealthAPILibrary`, `GiniUtilites`,
`GiniInternalPaymentSDK`. **Skip entirely for:** example apps, `*Tests/`, `*UITests/`, `.github/`,
`scripts/`, `Documentation/`, `.claude/`, `Makefile`, `fastlane/`.

**The bar is not the same for all seven.** Per §1, `GiniUtilites` and `GiniInternalPaymentSDK` are
internal packages: the checks below apply to them as *internal* blast radius across both SDK chains, not
as a contract with integrators. Reserve the breaking-change language for the five customer-facing
modules, or for an internal symbol the diff re-exports through one of them.

Every version, symbol and declaration shown below is a **format placeholder** — take the actual values
from the diff, and re-run the greps rather than trusting a count or a line number quoted here.

### First: confirm nothing in CI is guarding this

Android has `apiCheck` and committed `.api` dumps, so review is a second opinion there. **On iOS it is
the only opinion.** Verify rather than assume — if someone has since added a guard, your report should
say so:

```bash
# A committed API snapshot for one of OUR modules? Vendored binaries carry their own
# .swiftinterface files, so exclude them or every hit is a false positive.
git ls-files | grep -iE '\.(api|swiftinterface)$' | grep -viE '\.(xc)?framework/|Frameworks/'

# Any surface check wired into CI or the build scripts?
grep -rniE 'swift-api-digester|api-diff|abi-baseline' .github/ scripts/ Makefile fastlane/ 2>/dev/null
```

As of writing the first command returns nothing and the second finds no check. Note what the filter is
doing: the repo **does** track `.swiftinterface` files, but all of them belong to the vendored
`BrowserStackTestHelper.xcframework` under `BankSDK/GiniBankSDKExample/GiniBankSDKExampleUITests/Frameworks/`
— a third-party UI-testing binary, not a snapshot of our public API. Unfiltered, that grep looks like the
repo has an API baseline when it has none. So the honest statement is **"no committed API snapshot and no
surface guard for our SDKs"**, not "no `.swiftinterface` files in the repo".

No linter covers the gap either — SwiftLint is only a warning-level build phase on the example projects
(§8). So:

> **No automated check will tell anyone that this PR changed the public API surface.** State that
> explicitly in the report whenever the diff adds, removes or alters a `public` or `open` declaration —
> it is the single most useful sentence you can give the reviewer.

### Derive the surface diff yourself

This is the substitute for reading an `.api` dump. Run it **first**, before reading files — it is the
highest-signal thing available on the PR:

**Diff against the PR's own base branch, not `main`.** Fixes for older majors ship from a release branch
(§3), so hardcoding `main` would compare against the wrong history and invent breaking changes that
aren't there. Take the base from `gh pr view --json baseRefName` at §1:

```bash
BASE_REF="<baseRefName from the PR, or the default branch when reviewing a local diff>"
BASE=$(git merge-base HEAD "origin/$BASE_REF")

# Added or widened public surface
git diff "$BASE"...HEAD -- '*/Sources/*.swift' | grep -nE '^\+\s*(public|open)\s'

# Removed or narrowed public surface — every hit is a potential breaking change
git diff "$BASE"...HEAD -- '*/Sources/*.swift' | grep -nE '^-\s*(public|open)\s'
```

Then read each hit in its file. `grep` on a diff cannot tell a moved line from a new one, so confirm in
context before reporting anything.

**Scope rule: only declarations this PR added or modified are in scope.** A pre-existing `public` symbol
the diff merely moved past is not a finding.

Current baseline facts, so you can recognise a departure from the norm. `open` is used in **five
declarations** across the shipping sources — the classes `GiniScreenAPICoordinator`,
`GiniBankNetworkingScreenApiCoordinator` and `BottomSheetViewController`, plus two `open override func`s
inside `BottomSheetViewController`. Grepping for `open` also hits the `open url:` argument label in
`GiniBankUtils.swift`, which is not a declaration — count declarations, not matches, and re-count before
citing the number. There is **no `@_spi`, no `package` access level, and no `@frozen`** anywhere.

Per the scope rule above, only an `open` this diff adds or changes is reviewable; a pre-existing one is
not a finding. A diff that introduces a new `open`, `@_spi`, `package` or `@frozen` is doing something
unusual and deserves a question.

### Both distribution modes recompile against you

| Mode | Built by | What breaks consumers |
|---|---|---|
| **SPM source** (the normal path) | Integrator's Xcode, from the release repo pinned with `.exact()` | **Source compatibility.** Their code is recompiled against your headers. |
| **XCFramework** (`build-GiniBankSDK-XCFrameworks.sh`, tag `<Pkg>;<ver>;xcframeworks`) | Us, with `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` and `GINI_FORCE_DYNAMIC_LIBRARY=1` | Source compatibility **plus** the emitted `.swiftinterface` — library evolution is on, so the module's public interface is a published contract, and the binary is code-signed and shipped as-is. |

Practical consequence: **source compatibility is what you review.** Library evolution buys resilience
for adding stored properties to non-frozen public structs, but it does not make a renamed method or a
changed signature safe for anybody.

### Source-breaking in Swift — the list worth checking

Every one of these compiles fine here and breaks an integrator:

- **Removing or renaming** any `public`/`open` symbol, or changing its access level downward.
- **Changing a signature**: parameter type, return type, argument label, throwing-ness, `async`-ness,
  adding a parameter *without* a default value. Adding one *with* a default is safe for callers but still
  changes the interface.
- **Adding a case to a public enum.** Consumer `switch` statements over it stop being exhaustive. No
  enum here is `@frozen`, so treat every public enum as one integrators switch over.
- **Adding a requirement to a public protocol without a default implementation** — every external
  conformer breaks. Ship it as a protocol extension default, or it is a blocking finding.
- **Adding a required member to a public struct's memberwise init.** The synthesised memberwise init is
  `internal`; a `public init` is written by hand, so adding a stored property means either adding a
  defaulted parameter or breaking every caller. Check which happened.
- **Making a public method `final`**, or removing `open`, where a subclass could exist.
- **Tightening a nullability or generic constraint**, or changing a `var` to `let`.
- **Renaming a `LocalizableStringResource` key or a public asset name** — integrators override these to
  customise, so a rename silently drops their customisation. This is a real and easily-missed break.

Safe: adding a new `public` symbol, adding a defaulted parameter, adding a stored property to a
non-frozen public struct, widening a return type's optionality to non-optional, anything `internal`.

### Judging a new public symbol

`internal` is the default in Swift, so `public` was typed on purpose. Ask:

1. **Does an integrator need it?** If it exists to let a sibling module or a test reach in, it should be
   `internal` with `@testable import`, or the modules should be arranged differently. Say which.
2. **Is it the smallest thing that works?** A `public` stored `var` where a computed read-only property
   would do; a whole type exposed where a protocol would do.
3. **Does it match the module's existing entry-point shape?** Configuration goes through the
   `GiniConfiguration` / `GiniBankConfiguration` objects; SDK construction goes through a fluent
   value-type builder (`GiniBankAPI.Builder`). A new top-level `public` function beside those is a design
   question.
4. **Is it documented?** `AGENTS.md` requires `/** ... */` on declarations, with extra care for public
   API, and it is what Jazzy publishes to integrators. An undocumented new public symbol is a legitimate
   finding with a citable rule behind it.
5. **Is `GiniUtilites` the right home?** It is the one module both SDK chains depend on, so anything
   public there reaches every SDK. That blast radius is internal, not customer-facing (§1) — raise it
   explicitly, but as a design and maintenance cost, not as a published-API decision.

### Deprecation

The practice here is thin — at the time of writing exactly **one** `@available(*, deprecated…)` exists in
the whole repo, on a method of `GiniConfiguration` in `GiniCaptureSDK`. Find the current precedent rather
than trusting a line number:

```bash
grep -rn "@available(\*, deprecated" --include="*.swift" --exclude-dir=.build .
```

It is the pattern to follow — a `message:` that names the replacement calls in the order they must be
made, not just the fact of deprecation. Hold new deprecations to that bar:

- **Never delete a public symbol in the same PR that deprecates it.** Deprecate, ship a release, remove
  in the next major. A diff that does both at once is a blocking finding.
- The `message:` must name the replacement. "Deprecated" alone is not actionable for an integrator.
- A deprecation or removal needs the affected module's documentation updated in the same PR — that is
  what integrators read when they bump the pin. **Check which file exists before asking for one:**
  `Documentation/source/Migration guide.md` exists only for **GiniBankAPILibrary** and
  **GiniHealthAPILibrary**. GiniHealthSDK has a `Documentation/source/` but no migration guide.
  GiniBankSDK and GiniCaptureSDK have neither — their only doc surface is
  `Documentation/{s,S}ections/Documentation.md`. Name the real file, or say plainly that no migration
  guide exists for this module and one should be added.
- If the removal is intentional and the version bump is a major, say so in the report and check
  `<SDK>Version.swift` and `RELEASE-ORDER.md` agree with that.

### What to write in the report

When the diff touches published surface, the report's overview should carry one plain sentence a reviewer
can act on. The shape of it — **every angle-bracketed slot comes from the PR under review; never carry a
value from this file into a report**:

> Public surface: `<Module>` gains `<declaration>` on `<Type>` (additive, safe) and changes
> `<method>` to add a defaulted parameter (source-compatible). Nothing removed. No CI check covers
> this — verified by reading the diff.

If nothing public changed, say that too: *"Public API surface unchanged — no `public`/`open` declarations
added, altered or removed."* It is short, and it is exactly what the reviewer would otherwise have to
check by hand.

## Sharpening the three platform-bound dimensions

| Dimension | On iOS here |
|---|---|
| **Concurrency** | Mixed model: `async`/`await` and `Task` in newer code, completion handlers still dominant in the API libraries. Look for `Task` not cancelled on teardown, UI mutated off the main thread (missing `@MainActor` or `DispatchQueue.main.async`), escaping closures capturing `self` strongly, and shared mutable state touched from two queues. Swift 5.5 tools version — **no strict concurrency checking**, so the compiler will not catch isolation bugs. |
| **Lifecycle** | `deinit` / `viewWillDisappear` teardown, Coordinator↔ViewController retain cycles, delegates that must be `weak`, and `NotificationCenter` observers never removed. Note that **`class_delegate_protocol` and `notification_center_detachment` are both disabled in SwiftLint** — nothing but review catches these two leak classes. Also: state lost across scene changes, and `UISheetPresentationController` detents behaving differently pre-iOS 15. |
| **Documentation** | **Jazzy** is what integrators read — `<SDK>/.jazzy.yaml`, built by `bundle exec fastlane build_docs`. Every SDK's landing page is `Documentation/{s,S}ections/Documentation.md` (the `readme:` in its `.jazzy.yaml`; **CaptureSDK is the only module that capitalises it as `Sections`** — every other module uses lowercase `sections`, so glob rather than hardcoding either spelling). The longer markdown guides — *Getting started*, *Installation*, *Migration guide* — live in `Documentation/source/`, which exists **only for GiniBankAPILibrary, GiniHealthAPILibrary and GiniHealthSDK**. GiniBankSDK and GiniCaptureSDK have no `source/`, so their landing page is the only doc surface. A public API change without the matching doc update is a legitimate finding — name the file that actually exists for that module. There is no Sphinx here. |
