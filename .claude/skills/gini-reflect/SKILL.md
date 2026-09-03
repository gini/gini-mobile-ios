---
name: gini-reflect
description: Capture durable learnings after a completed task — conventions that proved wrong, missing, or misleading get folded back into the repo's standing docs. Run after /gini-build or /gini-fix wraps up, or after any substantial session. Zero learnings is a valid outcome.
---

<!--
  MIRRORED FILE — this file must stay byte-identical to
  .claude/skills/gini-reflect/SKILL.md in gini-mobile-ios.
  If you change it here, open a paired PR in the other repo with the same
  content. CI (shared-skills.check.yml) fails when the copies diverge.
  Platform-specific rules do NOT belong here — they live in the sibling
  platform.md, which is intentionally different per repo.
-->

You are reflecting on work just completed in this session (typically a
/gini-build or /gini-fix run). The goal is to fold what this session learned
the hard way back into the repository's standing documentation, so no future
session rediscovers it. This is a documentation task — do not change any
production code.

## 0. Load platform conventions — REQUIRED FIRST

Read `platform.md` in this skill's directory. It names this repository's
standing convention documents (where durable learnings live) and the
evidence sources to check. If the file is missing, stop and tell the user
this repository is not set up for the shared reflect workflow.

## 1. Reconstruct what happened

From this session and the artifacts it left behind (the spec or diagnosis in
specs/, the diff, verification output — see `platform.md` for the evidence
sources), list the moments where reality pushed back:

- a documented convention that turned out wrong or outdated
- something you had to discover that the docs should have told you upfront
- a fix or verification loop that stalled or burned several attempts
- a skill step you had to work around rather than follow

If the session was smooth and the docs held up, say so and stop here.
**Zero learnings is the normal outcome** — inventing learnings pollutes the
docs, and most sessions should end at this step.

## 2. Distill learnings — at most 3, evidence required

For each surviving candidate write:

- **Learning**: one sentence, an actionable directive in the imperative
  ("Run X before Y", "Module Z uses A, not B"). If it needs a paragraph,
  it is analysis, not a learning — cut it down or drop it.
- **Evidence**: what concretely happened in this session that proves it.

Reject anything that is already documented, one-off trivia tied to this
ticket, a style opinion without a failure behind it, or a guess.

## 3. Route each learning to its home

Choose the target using the map of standing documents in `platform.md`:

- platform-specific guidance on how to plan, build, or fix → the relevant
  skill's `platform.md`
- a repo-wide fact every session needs → the repository's agent
  instructions file
- a flaw in the shared workflow itself → the relevant mirrored `SKILL.md`,
  flagging that the change needs the paired PR in the sibling repo
- fits none of these durably → drop it

## 4. Confirm with the user — REQUIRED before writing

Present each learning with AskUserQuestion: the one-sentence directive, the
evidence, the target file, and the exact edit. Apply only what the user
approves — never self-edit skills or standing docs silently.

## 5. Apply and wrap up

Make the approved edits, matching each target file's existing structure and
tone — extend an existing section before inventing a new one. Summarize what
was written where. Offer to commit following the commit conventions in
`platform.md`, but do not commit or push unless the user asks.
