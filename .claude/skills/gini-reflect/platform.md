# gini-reflect platform conventions — iOS (gini-mobile-ios)

<!--
  NOT MIRRORED — this file is iOS-specific by design. The Android repo has its
  own platform.md with the same section headings but Android content. If you
  add a section here that the shared workflow depends on, add the matching
  section to the Android platform.md too.
-->

## Standing convention documents (learning targets)

- `AGENTS.md` (repo root) — verification gates, PR workflow, Swift
  documentation style, and the graphify workflow, loaded into every agent
  session (`CLAUDE.md` defers to it). Keep entries terse and imperative;
  extend the existing section that fits (e.g. "Verification" for gates,
  "Swift Documentation and Comment Style" for doc rules) instead of adding
  new sections.
- `CLAUDE.md` (repo root) — build/test commands, module layout, commit
  format, MyApp Standards (architecture, DI, design system, testing,
  localization), and code style. A repo-wide rule that agents keep
  getting wrong belongs here or in AGENTS.md, whichever already owns the
  topic. If the rule is also stated in `.claude/rules/mandatory-rules.md`,
  update that file in the same pass — CLAUDE.md/AGENTS.md win when they
  drift.
- `.claude/skills/gini-plan/platform.md`,
  `.claude/skills/gini-build/platform.md`,
  `.claude/skills/gini-fix/platform.md`,
  `.claude/skills/gini-reflect/platform.md` — iOS-specific guidance for
  the shared skills. Target the skill whose step the learning improves.
- `.claude/skills/*/SKILL.md` — only for flaws in the shared workflow
  itself. These are mirrored byte-identical with gini-mobile-android
  (CI: shared-skills.check.yml in that repo), so every change needs a
  paired Android PR.

NOT learning targets:

- `README.md`, `RELEASE.md`, `RELEASE-ORDER.md` — human-maintained
  release-process docs; surface a suggestion to the user instead of
  editing.
- The assistant's private memory — durable learnings belong in the repo,
  where the whole team and CI benefit from them.

## Evidence sources

- The session conversation itself: failed attempts, retries, surprises,
  instructions that were worked around.
- `specs/<ticket>-feature.md` / `specs/<ticket>-bug.md` — open questions
  that stayed open, implementation-plan steps that needed rework.
- `git diff` / `git log` on the branch — what actually changed versus what
  the spec predicted.
- `make lint scheme=<Scheme>` and `xcodebuild ... test` output — which
  verification gate failed and why. A local-pass/CI-fail split often traces
  to the destination mismatch (`make lint` on iPhone 15 Pro / iOS 17.2 vs
  CI's iPhone 17 / iOS 26.2 — see `.github/workflows/shared-config.yml`).

## Commit conventions

Learnings are AI-tooling changes (see `.git-stuff/commit-msg-template.txt`):

```
ai: <subject>

<body: the learning and the session evidence behind it>

<ticket-id of the session's ticket, if any>
```
