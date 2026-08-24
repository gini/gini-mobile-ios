---
name: gini-review
description: Run a complete PR review so a human reviewer can spend minutes instead of an hour — resolves the PR from the current branch, a PR number, or a Jira ticket key (e.g. PP-1234, IPC-42 — any board), reviews every changed file against the ticket's acceptance criteria and this repo's platform rules, reports a coverage ledger plus triaged findings, then asks whether to post them as PR comments. Use when asked to "review this PR", "review PP-1234", or to pre-review your own branch before pushing. Never casts an approve / request-changes verdict.
---

<!--
  SHARED FILE — platform-neutral by design. Meant to stay byte-identical to
  .claude/skills/gini-review/SKILL.md in gini-mobile-android. If you change it
  here, open a paired PR in the other repo with the same content. The same
  applies to everything under references/ — those are shared too.
  Platform-specific rules do NOT belong here or in references/ — they live in
  the sibling platform.md, which is intentionally different per repo. If a
  sentence would name a language, linter, framework or module, it goes there.
  Mirror enforcement status and the current path divergence between the two
  repos: references/general-rules.md §"How the two copies are kept in sync".
-->

# /gini-review — complete PR review, then offer to post

Goal: do the thorough pass so the human reviewer reads a short triaged list instead of a raw diff —
and can trust that list, because the review says exactly what it covered and what it could not.

**This file is platform-neutral on purpose.** It holds the procedure, the standard, the honesty rules
and the posting mechanics — everything that is the same whether the diff is Kotlin, Swift, TypeScript
or Ruby. Everything language- or build-system-specific lives in the sibling `platform.md` (§0).

## How to use

```
/gini-review              # the PR for the current branch
/gini-review 1234         # by PR number
/gini-review ABC-1234     # by ticket key — which is also the branch-name prefix
```

**The ticket key and the branch name are the same string.** Branches are often
`<TICKET>-<kebab-description>`, but the key can also sit under a path segment
(`<segment>/ABC-1234-…`), and it appears as the commit trailer either way. So:

- **On the branch already** → just `/gini-review`. The key is read straight off the branch name; you
  do not need to pass it.
- **Reviewing someone else's work** → pass the key or the PR number, whichever you have.

If the branch has no PR, it offers to review the local diff against the default branch instead.

**Many branches legitimately have no ticket key** — skill, CI, release, refactor and docs branches
often do not. That is a normal path, not a failure: the review proceeds without acceptance-criteria
verification and says so under **Not checked**.

**What happens, in order:** load the platform layer (§0) → resolve the PR (§1) → gather the diff,
existing review comments, the ticket and its links (§2) → read every changed file and verify the
logic against the ticket (§3) → filter findings (§4) → print the review (§5) → ask whether to post
it (§6).

**It stops and asks you** when: the ticket key matches more than one PR; the PR is closed or merged; a
screenshot or config file attached to the ticket is central to the review and needs you to paste it
in; a large diff would be better served by a review team (§3); and always before anything is posted
to GitHub.

**It never:** casts an approve or request-changes verdict, modifies any file, runs builds or tests (CI
covers those), or posts to GitHub without your explicit yes.

**Output is terminal-first.** Nothing reaches the PR until you choose to post in §6.

## Files in this skill

**`SKILL.md`** (this file) — the platform-neutral procedure. Shared across repos.

- Steps 0–6: platform layer → resolve → gather context → review → filter → report → ask before posting
- The 13 review dimensions and the two design calls
- The optional review-team fan-out for large diffs
- The confidence filter and the report template
- The hard rules: never cast a verdict, never modify files

**`platform.md`** — the local rules, read at **§0** and applied at **§3**. **Not** shared; each repo
has its own. Published API surface, dependency and build-file rules, release mechanics, downstream
module ripple, architecture and style, test conventions, commit format, and the **do-not-flag** list.

**`references/ticket-context.md`** — read at **§2**, on every review. Shared.

- Supports: fetching the ticket · knowing which fields matter · the fallback when there is no Jira
  connector · parsing the bug template · handling attachments · following links out of the ticket ·
  converting the ticket into logic checks
- Does not cover: repo coding rules, API rules, comment wording

**`references/comment-style.md`** — read at **§5**, before writing any comment. Shared.

- Supports: the inline comment format · **the category prefix** · **the length budget** · the
  summary-review skeleton · what never appears in a comment · improvements versus defects · GitHub
  `suggestion` blocks
- Does not cover: what to look for, or how to decide a finding is real

**`references/general-rules.md`** — read only when writing or extending a `platform.md`. Shared.

- Supports: the contract between this engine and a platform layer, the nine sections a `platform.md`
  must supply, how the shared copies stay in sync, and how to write a layer for a new language or
  build system
- Not needed to run a review

## The standard you are held to

Adopted from Google's [Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html):

> **Approve once the change improves the overall code health of the system.** There is no such thing
> as perfect code — only better code. Do not block on polish. Where a suggestion is genuinely
> optional, say so plainly.

Thorough and pedantic are opposites here. Thorough means **every changed file gets looked at with its
surrounding context**; pedantic means reporting everything you looked at. Coverage is complete, output
is triaged. Fifty undifferentiated comments waste more human time than they save — that is the failure
this skill exists to avoid.

**The one hard rule: never cast a verdict.** No `gh pr review --approve`, no `--request-changes`, no
equivalent `gh api` call with `event=APPROVE` or `REQUEST_CHANGES`. Those satisfy or block
branch-protection gates under the user's name; a machine does not get that authority. Posting
*comments* is allowed, but only after the user says yes in step 6.

Never modify files. The output is a review.

## 0. Load the platform layer — REQUIRED FIRST

**Read `platform.md` in this skill's directory.** It holds the local rules — what counts as published
API, which build files are off limits, which linters CI already runs, what the module ripple means,
what a missing test implies here. Every platform-specific judgement below MUST come from that file,
never from your own defaults.

Also read the repo's agent instructions — `AGENTS.md` / `CLAUDE.md` at the root, plus any `CLAUDE.md`
in the directories the diff touches. Those are canonical: a finding cites them or `platform.md` by
line, or it is a bare preference and gets dropped.

If `platform.md` is missing, say so plainly at the top of the report, review on the generic dimensions
alone, and offer to draft one from `references/general-rules.md`. Do not invent local conventions
from the diff, and do not silently review as if the layer existed.

Whatever `platform.md` says wins over generic instinct. Its **do-not-flag list** especially — that list
is what keeps the output readable.

## 1. Resolve the PR

First match wins:

**No argument** — current branch:

```bash
gh pr list --head "$(git branch --show-current)" --state all \
  --json number,title,headRefName,state,isDraft
```

**All digits** — that PR number:

```bash
gh pr view <number> --json number,title,body,author,state,isDraft,baseRefName,headRefName
```

**Ticket key** (matches `^[A-Z]{2,5}-[0-9]+$`) — branches are `<TICKET>-<kebab-description>`, but the
key is not always at position 0: it can sit under a path segment. Which segments a repo uses varies, so
anchor on start-or-slash and let any segment through rather than matching a list of them. Substitute the
key the user gave for `<TICKET>`:

```bash
gh pr list --state all --limit 200 --json number,title,headRefName,state \
  --jq '[.[] | select(.headRefName | test("(^|/)<TICKET>(-|$)"; "i"))]'
```

Only if that is empty, widen to text search — it also matches tickets named in a title or body, so it
can return unrelated PRs:

```bash
gh pr list --state all --search "<TICKET>" --json number,title,headRefName,state
```

- **One match** → state which PR you resolved to (`#<N> — <title>`) before reviewing.
- **Several** → list them, ask. Never guess.
- **None** → say so; offer to review the local branch diff instead (step 2 fallback).
- **Closed / merged** → say so, ask whether to continue. **Draft** → continue, note it.

## 2. Gather context before reading a single hunk

```bash
gh pr view <number> --json title,body,author,baseRefName,headRefName,additions,deletions,files
gh pr diff <number>
```

**Existing review activity — read this before forming your own findings:**

```bash
gh api repos/{owner}/{repo}/pulls/<number>/reviews \
  --jq '.[] | {user: .user.login, state, body}'
gh api repos/{owner}/{repo}/pulls/<number>/comments \
  --jq '.[] | {user: .user.login, path, line, body}'
```

`copilot-pull-request-reviewer[bot]` reviews PRs automatically on many repos, and humans reply to it.
**Do not restate a finding a bot or a human already made.** Instead, in your report, either confirm it
in one line, or push back if it is a false positive — telling the reviewer "the existing finding on
`<file:line>` is wrong because X" saves more time than a fresh duplicate. Track which of your
candidate findings are already covered.

**The ticket — read `references/ticket-context.md` and follow it.** This is not optional background;
the ticket is the specification you are reviewing against. In short: extract the key from the branch —
first match of `[A-Z]{2,5}-[0-9]+` anywhere in the name, since it may sit under a path segment — then
fetch it and pull the description, comments, parent epic, labels, attachments and issue links. **If the Jira connector is unavailable, that file's fallback applies: ask
the user to paste the ticket in rather than skipping acceptance-criteria verification.**

Then follow the links. Design tool (Figma and similar) → design intent for UI changes. Confluence →
specs that may themselves need updating. Other ticket keys → related context, one level deep only.
Automated build-distribution links are artefacts, not specification — ignore them. A human comment
that narrows or contradicts the description **wins**, and you should say so in the report, because the
reviewer may not have read it.

**Attachments.** Ticket `attachment` metadata is readable (filename, type, size, author, date) but the
file contents are **not** — the content URLs need OAuth and return 403. List what is attached, and
when an image or config file is central to the review — a UI bug's screenshot, a theme resource file
on a colour bug — **pause and ask the user to paste it into the conversation** rather than filing it
under "not checked". If they give a local path, read it with `Read`.

No key, or a failed fetch with nothing pasted → note `Not checked: acceptance criteria` and continue.
Never infer the requirements from the diff and then check the diff against them; that is circular.

**Fallback, no PR:**

```bash
git diff $(git merge-base HEAD origin/<default-branch>)...HEAD
```

## 3. Review every changed file

Work the file list from step 2. For each file, in order:

1. **Read the file, not just the hunk.** Diff context is truncated — a "missing null check" or "state
   never reset" claim is unverifiable from a hunk alone. This is the single biggest source of false
   positives.
2. **Read its history** when the change is non-trivial or the file looks well-trodden:
   `git log --oneline -15 -- <file>`, and `git log -3 -p -- <file>` when intent is unclear.
3. Apply the dimensions below and `platform.md` from §0.

Maintain a **coverage ledger** as you go — file → `reviewed` / `skimmed` / `skipped (reason)`. Valid
skip reasons: generated file, lockfile, binary asset, pure version bump, vendored code. "Large" is not
a valid skip reason; large diffs are where bugs hide. The ledger goes in the report, so a human can see
nothing was silently dropped.

### Optional: fan out to a review team

A single context reading forty files loses the early ones by the end. When the diff is large —
**more than ~15 changed files, more than ~500 changed lines, or spanning more than one module** — stop
and offer the user a team pass with `AskUserQuestion`:

> This PR touches <N> files across <M> modules. Run the review as a team?
> - **Single pass** — one reviewer context, faster and cheaper (default)
> - **Review team** — parallel subagents, one per dimension, each finding then challenged

Only fan out if they say yes; it costs materially more. When they do:

1. **Split by dimension, not by file.** One subagent per lens — correctness and acceptance criteria,
   design and architecture, concurrency and lifecycle, tests and coverage, published API and release
   mechanics — each over the **whole** diff. Splitting by file is what loses cross-file defects, which
   are the ones a single reader misses too.
2. **Give every subagent the same context**: the PR number, the ticket's expected behaviour as
   propositions, `platform.md`, and the do-not-flag list. A subagent without the do-not-flag list
   reports noise the rest of this skill exists to suppress.
3. **Require the same evidence.** Each returns findings as `file:line` → fact → consequence → fix.
   A finding with no line, or with a claim inferred from the hunk rather than the file, is dropped.
4. **Then challenge each finding.** Run a second pass whose job is to *refute*: is the line one this PR
   modified, does the cited rule actually say that, is it already handled elsewhere or already raised by
   an existing reviewer. Findings that survive refutation go into §4; the rest are dropped without
   reaching the report.
5. **Synthesize yourself.** Merge duplicates across lenses, keep the coverage ledger in your own
   context, and write the report. Subagents research; they do not report.
6. **No subagent touches GitHub or the working tree.** Posting stays in §6, under the user's yes.

If the user declines, or the diff is small, do the whole thing in one pass — the dimensions below are
the same either way.

### Verify the logic against the ticket

The primary pass, and the one that finds defects nothing else will. Full method in
`references/ticket-context.md` §"Turning the ticket into logic checks". The shape of it:

1. **Write down the expected behaviour as concrete propositions *before* reading the diff** — from
   Expected Result for a bug, acceptance criteria for a story. Vague expectations produce vague
   reviews, and deriving them after reading the diff just launders the diff's own assumptions.
2. **Trace the ticket's reproduction steps through the changed code** — entry point, each state
   change, the branch that decides the outcome.
3. **Answer literally: following those steps, does the new code produce Expected instead of Actual?**
   If you cannot tell, put it in "Needs a human" rather than guessing.
4. **Root cause or symptom?** A guard that satisfies the repro steps while leaving the underlying
   state wrong will resurface. Raise it even when the repro would pass.
5. **Check the opposite direction.** A fix for "flag false must show the old warning" must not break
   "flag true must show the new pop-up". Tickets describe one direction; inverted conditions commonly
   break the other. **Highest-yield check in this skill** — do not skip it.
6. **Check state and lifecycle** whenever the repro involves closing and reopening, rotating, or
   backgrounding. Persisted state surviving when it should reset is usually the real defect.
7. **Is there a test encoding the ticket's steps?** Its absence is a legitimate blocking finding for a
   bug fix — but check `platform.md` first for whether the path is reachable in an automated test
   at all.

### Then the platform rules

Apply `platform.md` from §0: published API surface, dependency and build-file rules, release
mechanics, downstream module ripple, architecture and style, test conventions, commit format, and the
**do-not-flag** list.

If the PR changes a committed API-surface snapshot file, read that diff **first**: it states the public
API change explicitly, and it is the highest-signal thing in the PR.

Generic dimensions, on top of the platform layer. Ordered by
[what to look for](https://google.github.io/eng-practices/review/reviewer/looking-for.html) — design
first, because it is the one thing that is expensive to fix later:

| Dimension | Looking for |
|---|---|
| **Design** | Do the interactions between pieces make sense? Is this in the right module/layer? Does this change belong in the codebase at all? |
| **Acceptance criteria** | Does the diff do what the ticket asked? What is missing? |
| **Scope** | Work unrelated to the ticket — drive-by refactors, stray formatting, debug leftovers |
| **Correctness** | Logic errors, off-by-one, null handling, wrong branch, state not reset between uses |
| **Complexity** | Can a future reader understand this quickly? Over-engineering — generality or configurability for needs that do not exist yet |
| **Concurrency** | Task scope and cancellation, races on shared observable state, work on the UI thread |
| **Error handling** | Swallowed exceptions, empty catch, fallbacks that mask failure |
| **Lifecycle** | Leaked references (context, listeners, observers), work surviving teardown, state lost across a configuration or scene change |
| **Tests** | Is there a test that would fail without this change? Will it catch a future break without firing falsely? |
| **Naming** | Do identifiers say what the thing is, without becoming unwieldy? |
| **Comments** | Do they explain **why**, not what? Is a comment compensating for code that should be clearer? Are existing comments now stale? |
| **Documentation** | Does this change how consumers use, build, or test the library — and are the reference docs and guides updated to match? Is something being deprecated without a migration note? |
| **Clarity** | Would the next reader understand this without asking the author? |

`platform.md` sharpens **Concurrency**, **Lifecycle** and **Documentation** for this repo — those three
rows are deliberately vague here because their specifics are platform-bound.

Two calls the design dimension permits, both from the
[Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html):

- A change can be **well-implemented and still not belong** — wrong module, a feature this library
  should not own, an abstraction the codebase does not need. Raise that as a question about the design
  rather than reviewing the implementation of something that may not ship.
- **Net code health is the bar.** A diff that fixes the ticket while making the surrounding design
  harder to work with has not met it. Say so explicitly rather than approving on the fix alone.

Neither is licence for pedantry. Both need a stated, concrete reason — "this belongs in `<module>`
because X" — never a bare preference.

Then one **cross-cutting pass** over the whole diff, which per-file reading cannot catch: does the
change hold together across files, is downstream module impact handled, is published API surface
affected, does a version bump belong here, is the PR doing two unrelated things that should be split.

### Look for improvements, not only defects

A review that lists only faults is half a review. Separately from the defect hunt, ask what would make
this change better — `references/comment-style.md` §"Improvements, not just defects" has the categories
and the framing. In short: **reuse** (duplicates something, or is generic enough to belong in a shared
file — name the destination), **simplification** (a standard-library or framework one-liner exists —
name it and confirm it is already available here), **robustness** (correct today, fragile under a
plausible change), **clarity** (reads as if it does something it does not), **test coverage** (name the
untested path).

Default to follow-up framing. Reviewers deliberately avoid widening an open PR, so an improvement
offered as optional and deferrable gets adopted where a blocker gets argued about. And if a cleaner
shape exists but the churn outweighs it, say that instead of raising it.

## 4. Verify each finding before it survives

**Defects** get the confidence filter below. **Improvements do not** — they are not claims about
brokenness, so scoring them for "is this really a bug" deletes all of them. Judge an improvement on
three things instead: is it concrete (names a real API, file, or pattern), is it correct about the
current code, and is the payoff worth the churn. If it fails any of those, drop it. Keep at most a
handful — a long optional list reads as noise and buries the blocking findings.

For defects, score confidence 0–100 that the finding is real, reachable, and worth the author's time:

- **0–25** false positive, pre-existing, or handled elsewhere
- **26–50** stylistic nit with no backing rule in the repo's agent instructions or `platform.md`
- **51–75** real but low impact
- **76–90** important, author should address
- **91–100** clear bug, or an explicit documented-rule violation

**Drop below 75.** Then adversarially check each survivor — try to *refute* it:

- Did you read the whole file, or infer from the hunk?
- If you cited a repo rule, quote the line that says it. If you can't, drop it.
- Is the line one this PR actually modified?
- Is it already covered by a bot or a human reviewer? → move it to the "On existing review activity"
  section as a confirmation, don't duplicate it as a fresh finding.
- Would the repo's linters, formatter, or compiler catch it? → drop, CI runs those. `platform.md`
  names which ones.

If nothing survives, say so plainly. "No blocking issues — acceptance criteria met, published API
surface clean, repo conventions followed, all 7 files reviewed" is a valid and genuinely useful result.

## 5. Report

**Read `references/comment-style.md` before writing a single comment.** It holds the comment format,
**the hard length budget**, the bracketed category prefix every posted comment opens with, and the rule
that internal machinery — confidence scores, dimension names — never appears in a comment a human reads.

**Everything in this section is the terminal report — it is not what gets posted.** This is the long
form: it carries the coverage count, the per-file table and the section headings, and a finding here may
spend as many sentences as the mechanism needs. §6 strips it down for the PR, and its cut list is
explicit that the full call chain *belongs* here.

So the length budget in `references/comment-style.md` applies **when a finding is posted**, not here.
Do not truncate the terminal report to fit it, and do not pad a posted comment because the terminal one
was long.

Structure: overview, grouped changes, coverage count, per-file table in `<details>`, then the findings.
Each finding body uses the three-part form: **fact about the code → consequence → concrete fix**,
impersonal. In the terminal report the section headings carry the category, so no prefix is needed here;
a comment *posted* to the PR gets the bracketed category prefix instead, since it arrives without them.

Everything in angle brackets below is a slot to fill from the PR under review. Substitute all of
them — never carry an example value through into a real review.

```markdown
## Pull request overview

<one paragraph: what this PR changes and why>

**Changes:**
- <change grouped by behaviour, one line covering however many files>
- <change grouped by behaviour>

### Reviewed changes

Reviewed <X> out of <Y> changed files and generated <N> comments.

<details>
<summary>Show a summary per file</summary>

| File | Description |
| ---- | ----------- |
| `<path/to/ChangedFile>` | <what this file's change does> |

</details>

### Ticket: <KEY> (<issue type> · epic <PARENT-KEY> · labels: <labels>)

**Expected:** <from the ticket's Expected Result>
**Actual:** <from the ticket's Actual Result>
**Traced:** <repro steps run through `<File:lines>` → produces Expected / does not>
**Opposite direction:** <the inverse condition still behaves correctly, or does not>
**Root cause:** <addressed, or only the symptom is guarded>
**Context followed:** <epic · design link or "none given" · comment count and whether any carried spec>

<!-- Story/task instead → acceptance-criteria checkboxes.
     A comment overrode the description → say so here.
     Ticket pasted by the user instead of fetched → say so here.
     Fetch failed and nothing was pasted → "<KEY> — not available, logic not verified." -->

### Requests

**`<path/to/ChangedFile:LINE>`**
<fact about the code, naming the exact symbol> <consequence — what goes wrong and for whom>
<concrete fix, naming the API, file or pattern>

### Suggestions

**`<path/to/ChangedFile:LINE>`**
<fact> <consequence> <concrete fix, framed as deferrable where it is>

### Clarifications

**`<path/to/ChangedFile:LINE>`**
<what the code does> <why the intent is unclear> <the question only the author can answer>

### On existing review activity

<Existing reviewer or bot comment on `<File:LINE>`> still applies — <one line on why>.
<Existing comment on `<File:LINE>`> does not hold: <why>.

### Needs a human

- <product/UX judgement, device-only behaviour, design intent>
- <verification you cannot perform, and what would settle it>

**Not checked:** <unseen attachments by filename, generated files, skipped ticket fetch, missing platform.md>
```

The three finding sections map one-to-one onto the categories a posted comment opens with — **Requests**
→ `[Request]`, **Suggestions** → `[Suggestion]`, **Clarifications** → `[Clarification]` — so §6 can post
without re-triaging.

Two sections carry the honesty load and must never be padded or omitted: **Needs a human** and **Not
checked**. Likewise the `Reviewed X out of Y` count — state real numbers, and when X < Y name which
files were skipped and why.

## 6. Ask before posting

Nothing has been sent anywhere yet. Now ask the user, with `AskUserQuestion`:

> Post this review to #<N>?
> - **Don't post** — terminal only (default)
> - **Post requests only** — inline, on their lines
> - **Post everything** — requests + suggestions + clarifications, inline
> - **Post as one summary comment** — no inline anchors

Posted comments use the same prose voice as the terminal report, each opening with its bracketed
category prefix (`[Request]` / `[Suggestion]` / `[Clarification]`) per `references/comment-style.md`,
never any internal scoring, and always inside the length budget in that same file. For mechanical
changes, attach a GitHub ```suggestion block so the author gets one-click apply — but only where you
are confident it compiles as written and the span is small; see `references/comment-style.md`
§"Posting to GitHub".

If they decline, stop. Say the review stayed local.

### The summary body comes first

Whatever is posted, the review's `body` is the message the author reads **before** any inline
suggestion — the same slot a review bot fills with "Pull request overview". Write it in the reviewer's
own voice, following the house style human reviewers use on the repo.

**Hard budget: three paragraphs, at most three sentences each, under 1500 characters total.** Count
the characters before posting. Over budget does not mean trim adjectives — it means something in the
body belongs somewhere else, so find it in the cut list below.

1. **Acknowledge, then answer the ticket.** One clause of acknowledgement, genuinely meant — "Looks
   good overall —", "Thanks for the quick turnaround" — then the traced path compressed to a single
   arrow chain and whether Expected is produced, then containment (published API surface, version
   bump, downstream modules) as one clause. Never a cold open; the author reads this before anything
   else and it lands as a rejection.
2. **Only the findings that cannot be inline.** A finding on a line the diff modified is an inline
   comment, full stop — never restate it in the body. What is left is a finding whose line sits
   outside the diff, or a PR-level point (base branch, split, scope); state it once, and say whether
   it is deferrable.
3. **The asks before merge.** Manual device checks, design questions, follow-up tickets — phrased as
   requests rather than blockers where that is the truth.

**Cut list — these belong in the terminal report and never in the posted body:**

- The full call chain. One arrow line naming the deciding branch is enough for the author to check
  your work; `file:line` for every hop is not.
- Reasoning that confirms the author was right. Verifying their design is the job; narrating the
  verification is padding. If their approach holds, that is one clause, not a paragraph.
- `Reviewed X out of Y`, the per-file table, the `### Requests` / `### Suggestions` headings,
  checkbox lists, confidence scores, dimension names, **Not checked**.
- Anything already said in an inline comment on the same PR.

If they accept, post **comments only, never a verdict**. Inline comments — write the JSON to a temp
file in the scratchpad directory, not inline in the shell:

```bash
# review.json: {"body": "...", "event": "COMMENT",
#   "comments": [{"path": "...", "line": 88, "side": "RIGHT",
#                 "body": "[Request] <fact -> consequence -> fix>"}]}
gh api repos/{owner}/{repo}/pulls/<N>/reviews --method POST --input review.json
```

`event=COMMENT` attaches comments with **no** approve/request-changes verdict — it neither satisfies
nor blocks branch protection. That is the only event value permitted.

Constraints:
- `line` must be a line present in the diff on the `RIGHT` (new) side, or the API returns 422. If a
  finding sits outside the diff, put it in the summary `body` instead of an inline comment.
- Show the user the exact comment bodies before posting, and post in **one** API call so the PR gets a
  single review, not N notifications.
- **Never attribute the review to an assistant.** It is posted under the user's name and they are the
  reviewer of record — no "assistant-generated", no tool name, no slash-command name in the body.
  Write the summary in the reviewer's own voice.
- After posting, print the PR URL and confirm no verdict was cast.
- To correct something already posted: `PUT .../pulls/<N>/reviews/<review_id>` edits the summary body,
  `PATCH .../pulls/comments/<comment_id>` edits one inline comment. Editing sends no notification, so
  say what changed.
