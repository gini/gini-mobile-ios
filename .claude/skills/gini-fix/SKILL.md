---
name: gini-fix
description: Diagnose and fix a non-trivial bug ticket - reproduce it, find the root cause, write the diagnosis to specs/, then implement the fix with a regression test. Pass the ticket id as argument (e.g. PP-1234, IPC-42 - any board).
---

<!--
  MIRRORED FILE — this file must stay byte-identical to
  .claude/skills/gini-fix/SKILL.md in gini-mobile-ios.
  If you change it here, open a paired PR in the other repo with the same
  content. CI (shared-skills.check.yml) fails when the copies diverge.
  Platform-specific rules do NOT belong here — they live in the sibling
  platform.md, which is intentionally different per repo.
-->

You are diagnosing and fixing bug ticket $ARGUMENTS. Root cause comes before
any fix: no code change until the diagnosis is written down and confirmed.
Never fix a symptom whose cause you haven't found.

## 0. Load platform conventions — REQUIRED FIRST

Read `platform.md` in this skill's directory. It defines how to reproduce
bugs in this repository (apps, build variants, logging), how to run tests,
how to verify, and the commit conventions. Every platform-specific decision
below MUST come from that file, never from your own defaults. If the file is
missing, stop and tell the user this repository is not set up for the shared
fix workflow.

## 1. Fetch the ticket

Fetch $ARGUMENTS from Jira (any board — PP or otherwise). Read the summary,
description, comments, and linked issues, and mine them for: observed vs.
expected behavior, stack traces or logs, affected SDK/app versions, device or
OS specifics, and reproduction hints. If the ticket cannot be fetched, ask
the user to paste its content instead of guessing.

## 2. Reproduce the bug

Reproduce it the way `platform.md` prescribes — prefer the cheapest faithful
reproduction (a failing unit test beats launching an app). If you cannot
reproduce it, do NOT start changing code on speculation: report what you
tried and ask the user (via AskUserQuestion) for the missing detail —
exact version, configuration, input document, locale, and so on.

## 3. Find the root cause

Run a disciplined hypothesis loop:

- Form an explicit hypothesis about the cause; state it before testing it.
- Gather evidence: read the involved code, follow the data flow, check the
  git history of the suspicious lines (when did this last work?), add a
  narrowing test or targeted logging where `platform.md` suggests.
- Reject or confirm, then iterate. Keep going until you can name the root
  cause at file-and-line precision and explain the mechanism from cause to
  observed symptom.
- Distinguish the root cause from where the symptom surfaces — they are
  usually in different places. Fixing at the symptom site needs explicit
  justification.

## 4. Write the diagnosis

Write `specs/$ARGUMENTS-bug.md` (create `specs/` if needed):

```markdown
# <Ticket ID>: <Title>

Status: draft
Ticket: <link to the Jira ticket>

## Symptom
Observed vs. expected behavior, in your own words.

## Reproduction
Exact steps or the failing test that demonstrates the bug.

## Root cause
The defect and its mechanism, referencing code with file paths and lines.
How the cause produces the symptom.

## Proposed fix
What changes and where. Minimal — no drive-by refactoring. Note public API
impact (should normally be "none" for a bug fix).

## Regression test plan
The test(s) that fail before the fix and pass after, their location, and the
test stack to use (match neighboring tests — see platform.md).

## Out of scope
Related issues noticed but deliberately not fixed here (file tickets instead).

## Open questions
Anything still unresolved.
```

## 5. Checkpoint — confirm before fixing

Show the user the root cause and proposed fix (via AskUserQuestion). They can:

- confirm — continue to step 6 in this session, or
- stop here — the diagnosis file stands on its own; the fix can be
  implemented later with `/gini-build $ARGUMENTS` in a fresh session.

Do not proceed to code changes without confirmation.

## 6. Implement the fix, regression test first

- Write the regression test first and run it: it MUST fail for the reason
  the diagnosis describes. A regression test that passes before the fix
  proves nothing — rework it until it fails correctly. If after 3 reworks
  the test still cannot be made to fail for the diagnosed reason, the
  diagnosis is probably wrong: go back to step 3 instead of forcing the
  test.
- Apply the minimal fix from the diagnosis. Match the style of the file you
  touch. No opportunistic refactoring, no scope creep into "Out of scope".
- Re-run the regression test (now passing) and the tests around the touched
  code.

## 7. Verify

Run the verification steps defined in `platform.md` for the affected modules,
and re-check the original reproduction from step 2 no longer occurs. Fix what
fails and re-run — with bounds:

- Keep a running list of the fixes attempted for each distinct failure, and
  never retry a fix already on that list.
- After 3 failed fix attempts on the same failure, STOP. Show the user the
  failure, each attempted fix and why it didn't work, and ask how to
  proceed. Past that point you are thrashing, and a "fix" that merely
  silences the symptom is worse than an honest stop.

Report results honestly — if something still fails or was skipped, say so
explicitly.

## 8. Wrap up

- Update the diagnosis file's `Status:` line from `draft` to `fixed`.
- Summarize for the user: root cause, the fix (file paths), the regression
  test, verification results, and anything left to manual QA.
- Offer to commit following the commit conventions in `platform.md`, but do
  not commit or push unless the user asks.
