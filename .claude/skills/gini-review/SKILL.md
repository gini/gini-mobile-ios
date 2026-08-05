---
name: gini-review
description: Run a complete PR review so a human reviewer can spend minutes instead of an hour — resolves the PR from the current branch, a PR number, or a Jira ticket key (PP-/HEAL-/XPL-/FEAT-), reviews every changed file against the ticket's acceptance criteria and this repo's iOS rules, reports a coverage ledger plus triaged findings, then asks whether to post them as PR comments. Use when asked to "review this PR", "review PP-1234", or to pre-review your own branch before pushing. Never casts an approve / request-changes verdict.
---

# /gini-review — iOS PR review

This skill is the **iOS platform layer** over a platform-neutral review engine. It adds this repo's
rules; it does not restate the procedure.

## How to use

```
/gini-review              # the PR for the current branch
/gini-review 1234         # by PR number
/gini-review PP-1234      # by ticket key — which is also the branch-name prefix
```

## Run the review

**Read `pr-review/SKILL.md` in this skill directory and follow it end to end.** That is the procedure:
resolve the PR (§1) → gather the diff, existing review activity and the Jira ticket (§2) → read every
changed file and verify the logic against the ticket (§3) → filter findings (§4) → print the report
(§5) → ask before posting (§6). It also holds the review dimensions, the confidence filter, the report
template, the posted-comment budgets, and the hard rules: **never cast an approve or request-changes
verdict, never modify a file, never run builds or tests.**

Its own references resolve against `pr-review/` — `pr-review/references/ticket-context.md` at §2 and
`pr-review/references/comment-style.md` at §5.

## The iOS layer — this is what §0 asks for

**`references/ios-checklist.md`** — read at **§3**, on every review.

- Supports: Swift visibility and the seven public release repos · the two-manifest `Package.swift` /
  `Package-release.swift` rule · release mechanics · module ripple and the CI path-trigger gap ·
  `CLAUDE.md`'s `MUST`-level architecture, style, colour and test rules — **including where they have
  drifted from the code** · test conventions across XCTest and Swift Testing · commit and PR-template
  format · **suppressing noise** (the do-not-flag list)
- Does not cover: ABI or published-surface judgement

**`references/ios-api-surface.md`** — read at **§3**, only when the diff touches a releasable module.

- Supports: deriving the public-surface diff by hand · source- vs binary-breaking changes in Swift ·
  judging a new `public` symbol · the deprecation cycle · both distribution modes (SPM source and
  XCFramework under library evolution)
- Opens with a check for whether anything in CI guards the public surface on this branch. **On iOS
  nothing does** — there is no `apiCheck` equivalent, no committed API snapshot, and SwiftLint is not in
  CI either. Run the check anyway rather than assuming; if that ever changes, the report should say so.
- Skip for: example apps, tests, CI, docs

**Repo instructions** — `AGENTS.md` and `CLAUDE.md` at the root, plus any `CLAUDE.md` in the directories
the diff touches. These are canonical: a finding cites them by line, or it is a bare preference and gets
dropped. `AGENTS.md` is unusually citable here — it fixes the doc-comment style, the compile gate, and
the requirement that a PR body follow `.github/pull_request_template.md`.

Sharpening the three platform-bound dimensions in the engine's table for this repo:

| Dimension | On iOS here |
|---|---|
| **Concurrency** | `Task` cancellation on teardown, UI mutated off the main thread, escaping closures capturing `self` strongly, shared state across queues. Swift tools version 5.5 — no strict concurrency checking, so the compiler catches none of it |
| **Lifecycle** | `deinit` / `viewWillDisappear` teardown, Coordinator↔ViewController retain cycles, delegates that must be `weak`, `NotificationCenter` observers never removed — and SwiftLint's `class_delegate_protocol` and `notification_center_detachment` are **disabled**, so review is the only gate |
| **Documentation** | Jazzy, since integrators read it (`<SDK>/.jazzy.yaml`, landing page `Documentation/{s,S}ections/Documentation.md`), plus the guides under `Documentation/source/` — which only GiniBankAPILibrary, GiniHealthAPILibrary and GiniHealthSDK have |

**What CI runs on a PR:** the Swift compiler, unit tests via `bundle exec fastlane run_unit_tests`,
example-app unit + integration tests via `xcodebuild`, SonarQube, CodeQL, a secret scan and SBOM
generation. Anything the compiler catches is noise — do not report it and do not run any of them yourself.
**SwiftLint is a build phase on the example projects, not a CI gate**, and it runs without `--strict`, so
it can only ever emit warnings. That changes how style findings are handled: `references/ios-checklist.md`
§8 has the precise rule, including the long list of SwiftLint rules this repo has deliberately disabled.

## Keeping `pr-review/` in sync with Android

`pr-review/` is platform-neutral and **byte-identical with `gini-mobile-android`** at the same path,
`.claude/skills/gini-review/pr-review/`. Android owns the mirror: `.github/mirrored-skills.txt` there
lists the shared files, `shared-skills.check.yml` diffs this repo's copies against it, and
`shared-skills.sync.yml` opens the sync PR here when they drift.

So:

- **Never edit anything under `pr-review/` in this repo.** Change it in `gini-mobile-android` and let the
  sync PR bring it over, or the weekly check fails on lasting drift.
- Its worked examples use Kotlin in a couple of places (`references/comment-style.md`). That is expected —
  they illustrate comment *format*, not language rules. Leave them; byte-identity requires it.
- Nothing iOS-specific belongs inside `pr-review/`. If a rule names SwiftPM, Swift, a module path, Xcode
  or an Apple API, it goes in `references/ios-*.md` instead.
- `pr-review/references/platform-rules.md` is the contract those two files satisfy — the nine sections a
  platform layer must supply. Read it if you are adding a section, not to run a review.

Nested here, `pr-review/` is a reference bundle rather than its own command, because Claude Code only
discovers `SKILL.md` one level under `.claude/skills/`. That is deliberate: keeping the path identical to
Android's is what makes the mirror check work. Type `/gini-review`.
