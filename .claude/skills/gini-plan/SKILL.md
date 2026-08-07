---
name: gini-plan
description: Fetch a ticket, clarify open questions, and write a feature spec before any code. Pass the ticket id as argument (e.g. PP-1234, IPC-42 — any board).
---

<!--
  MIRRORED FILE — this file must stay byte-identical to
  .claude/skills/gini-plan/SKILL.md in gini-mobile-ios.
  If you change it here, open a paired PR in the other repo with the same
  content. CI (shared-skills.check.yml) fails when the copies diverge.
  Platform-specific rules do NOT belong here — they live in the sibling
  platform.md, which is intentionally different per repo.
-->

You are writing a feature spec for ticket $ARGUMENTS. Do NOT implement anything —
this command ends when the spec file is written and the user has confirmed it.

## 0. Load platform conventions — REQUIRED FIRST

Read `platform.md` in this skill's directory. It defines this repository's
module map, architecture patterns, language rules, wiring conventions, test
stack, and the conventions checklist the spec must cover. Every
platform-specific decision below MUST come from that file, never from your own
defaults. If the file is missing, stop and tell the user this repository is not
set up for the shared spec workflow.

## 1. Fetch the ticket

Fetch $ARGUMENTS from Jira (any board — PP or otherwise). Read the summary,
description, acceptance criteria, comments, and linked issues. If the ticket
cannot be fetched, ask the user to paste its content instead of guessing.

## 2. Explore the code

Identify which modules are affected, using the module map in `platform.md`.
Read the relevant existing code so your questions and spec are grounded in
how things actually work today. In particular, establish:

- Public API surface: which touched declarations are visible to integrators.
  Assess this the way `platform.md` prescribes for this repository.
- The architecture pattern of the screens/components being touched.
  `platform.md` lists the patterns in use and where. The spec must name the
  pattern for new code and it must match a precedent that actually exists in
  the touched module — don't prescribe a pattern the module doesn't use.
- Existing precedents to imitate (similar sheet/dialog/screen/use case in the
  same module) and the test stack of neighboring tests (see `platform.md`
  for the frameworks in use).
- How new code in that module is wired: dependency injection, string
  resources/localization, and theming, per `platform.md`.

Grade your confidence in each of these findings as you go: HIGH means you
read the actual declaration or precedent in this session; LOW means you are
inferring from convention, naming, or memory. Keep track of the LOW ones —
they are exactly what step 3 must ask about. A LOW-confidence flag is worth
more than a confident guess.

## 3. Ask clarifying questions — REQUIRED, before writing the spec

Use the AskUserQuestion tool. Never skip this step, even if the ticket seems
clear. Ask about the things the ticket leaves open, for example:

- Ambiguous or conflicting requirements in the ticket
- Scope boundaries: what is explicitly OUT of scope?
- Public API changes: additive only, or is a breaking change acceptable?
- Which SDK consumers are affected (bank vs. health vs. capture integrators)?
- Backwards compatibility and migration expectations
- Testing expectations (unit only, or integration/UI tests too?)
- Anything where you would otherwise have to assume
- Any LOW-confidence finding from step 2 that the user can settle faster
  than further code archaeology can

Only ask questions whose answers change the spec. If a second round of
questions is needed after the first answers, ask again.

## 4. Write the spec

Write the answers and your analysis into `specs/$ARGUMENTS-feature.md`
(create the `specs/` directory if it doesn't exist) with this structure:

```markdown
# <Ticket ID>: <Title>

Status: draft
Ticket: <link to the Jira ticket>

## Problem
What the user/integrator needs and why. In your own words, not a ticket copy-paste.

## Requirements
Numbered Given/When/Then statements, each tagged MUST or SHOULD and
categorized (entry / happy / error / async — see the format rules below).
Include decisions from the clarifying questions.

## Affected modules
Which modules change and how they relate.

## Public API impact
Changes to integrator-visible declarations per module, or "none". Note whether
changes are additive or breaking. Assess visibility as prescribed by platform.md.

## Technical conventions
Concrete, repo-grounded rules /gini-build must follow. Cover every item in the
conventions checklist in platform.md, grounded in the modules actually touched.

## Design
How it will work: key classes, data flow, integration points. Reference
existing code with file paths.

## Test plan
Which tests prove each requirement — every MUST requirement maps to at least
one named test. Name test classes/locations AND the test stack to use —
match neighboring tests in the module (see platform.md). State the
expectation that every new class gets a unit test.

For each test class, say whether it extends an existing test class or
creates a new one — prefer extending the neighboring class that already
covers the code being changed. Give a rough test count per class (a focused
class usually needs 3–6 tests; a multi-path component 6–12) and justify a
plan that calls for more — test count is not test quality.

### Not tested
What is deliberately not tested and why (framework behavior, third-party
code, trivial delegation), and what is left to manual QA. An explicit gap
a reviewer can see beats an accidental one.

## Out of scope
Explicitly excluded work, so /gini-build doesn't drift into it.

## Open questions
Anything still unresolved (should be empty or short after step 3).
```

Requirements format: write each requirement as Given/When/Then — e.g.
`R1 (MUST, entry): Given <integrator setup>, when <action>, then
<observable result>` — tagged MUST (the feature is broken without it) or
SHOULD (negotiable), and categorized so coverage is checkable:

- **entry** — how the integrator reaches the feature: the public call,
  callback, or configuration involved, and where its result becomes
  observable.
- **happy path** — the main flow with its concrete expected outcome.
- **error path** — each failure mode and the exact error surface the
  integrator sees (type/state/message), never just "an error is shown".
- **async** — for asynchronous flows: what is observable while the work is
  pending and how completion arrives.

Where the outcome is data (an extraction, an amount, a parsed document), the
"then" must depend on the "given": a criterion that would also pass with a
hardcoded return value verifies nothing.

Confidence marking: any claim in "Public API impact", "Technical
conventions", or "Design" that you could not verify against code read in
this session gets an explicit marker —
`(confidence: LOW — <what would confirm it>)`. Unmarked claims assert HIGH
confidence, and /gini-build will rely on them without re-checking. Every LOW
marker must either be resolved by a step-3 question or appear in "Open
questions" — a silent guess presented as fact is the one thing this spec
must never contain.

## 5. Concreteness gate — REQUIRED before handoff

A vague spec makes /gini-build improvise, which defeats the point of writing
one. Check the finished spec against every item below:

- [ ] Every requirement is testable as written — someone could write a
      failing test from the requirement alone, without asking what it means.
- [ ] The requirements cover entry, happy path, and error path (and async
      where the flow is asynchronous). A spec with no error-path
      requirement is almost never complete.
- [ ] No requirement hides behind vague words: "appropriate", "properly",
      "as needed", "correctly", "etc.", "and so on". Replace each with the
      concrete behavior meant.
- [ ] Affected modules are named exactly, using the module naming convention
      in `platform.md` — not "the bank SDK" but the precise module path.
- [ ] The integrator-visible entry point is named exactly: which public
      declaration an integrator calls, implements, or observes to use this
      feature — or the spec states the feature has no public entry point.
- [ ] "Public API impact" names each changed declaration and whether the
      change is additive or breaking — or states "none". No "minor API
      changes".
- [ ] The test plan names concrete test classes/locations and the test stack,
      not "add unit tests".
- [ ] The "Design" section references real, existing code by file path — and
      you have read those files in this session, not assumed them.
- [ ] Every `(confidence: LOW …)` marker left in the spec has a matching
      entry in "Open questions". If a LOW marker sits on something
      load-bearing (the entry point, the architecture pattern, the API
      impact), it must not be left — resolve it in step 2 or 3 first.

If any item fails, do NOT hand off: return to step 2 (re-explore) or step 3
(ask the user) and fix the spec. Only a spec that passes every item moves on.

## 6. Hand off

Show the user a short summary of the spec and where it was written. Remind
them to review/edit it, then run `/gini-build $ARGUMENTS` (ideally in a fresh
session) to build it. Do not start implementing yourself.
