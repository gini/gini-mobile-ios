---
name: gini-build
description: Implement a feature from its spec written by gini-spec-feature. Pass the ticket id as argument (e.g. PP-1234, IPC-42) — the spec must already exist in specs/.
---

<!--
  MIRRORED FILE — this file must stay byte-identical to
  .claude/skills/gini-build/SKILL.md in gini-mobile-ios.
  If you change it here, open a paired PR in the other repo with the same
  content. CI (shared-skills.check.yml) fails when the copies diverge.
  Platform-specific rules do NOT belong here — they live in the sibling
  platform.md, which is intentionally different per repo.
-->

You are implementing ticket $ARGUMENTS from its spec. The spec is the contract:
you build what it says, nothing more, and every requirement ends up tested.

## 0. Load platform conventions — REQUIRED FIRST

Read `platform.md` in this skill's directory. It defines how to build and
verify in this repository (check suite, test commands), where code and tests
live, and the commit conventions. Every platform-specific decision below MUST
come from that file, never from your own defaults. If the file is missing,
stop and tell the user this repository is not set up for the shared build
workflow.

## 1. Load the spec — no spec, no code

Read `specs/$ARGUMENTS-feature.md`, or — for a bug diagnosed with
`/gini-fix` — `specs/$ARGUMENTS-bug.md`. If neither exists, stop and tell
the user to run `/gini-spec-feature $ARGUMENTS` (features) or
`/gini-fix $ARGUMENTS` (bugs) first — do not improvise a spec from the
ticket.

From a feature spec, internalize: the numbered requirements, the affected
modules, the public API impact, the technical conventions, the design, the
test plan, and — just as important — the "Out of scope" section. From a bug
diagnosis: the root cause, the proposed fix, and the regression test plan
(the regression test must fail before the fix and pass after). If the "Open
questions" section is non-empty, surface those questions to the user with
AskUserQuestion before writing any code.

## 2. Verify the spec against the code

Read the code the spec's Design section references. Code may have drifted
since the spec was written. If reality contradicts the spec (a class was
renamed, a precedent was removed, an approach is no longer viable), stop and
show the user the conflict — let them decide whether to update the spec or
proceed differently. Do not silently deviate from the spec.

## 3. Plan the implementation

Produce an ordered list of changes, each mapped to the spec requirement(s) it
satisfies. Order it so tests can be written first and the build stays green
at every step. Keep the plan within the spec's affected modules; if you
discover a module not listed in the spec must change, tell the user before
touching it.

## 4. Implement, test-first

Work through the plan requirement by requirement:

- Write or extend the tests from the spec's test plan first, matching the
  test stack and locations of neighboring tests (see `platform.md`), then
  write the code that makes them pass.
- Follow the spec's "Technical conventions" section exactly — it was written
  for this feature and this repository.
- Match the style, naming, and idioms of the files you touch.
- Do not implement anything in "Out of scope". Do not widen public API beyond
  what "Public API impact" declares.

## 5. Verify

Run the verification steps defined in `platform.md` for the affected modules.
Fix what fails and re-run until clean. Report results honestly — if something
still fails or was skipped, say so explicitly.

## 6. Wrap up

- Update the spec's `Status:` line from `draft` to `implemented` (feature)
  or `fixed` (bug).
- Summarize for the user: each requirement and where it was implemented and
  tested (file paths), verification results, and anything left to manual QA
  per the spec's test plan.
- Offer to commit following the commit conventions in `platform.md`, but do
  not commit or push unless the user asks.
