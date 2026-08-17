<!--
  MIRRORED FILE — must stay byte-identical to
  .claude/skills/gini-review/references/ticket-context.md in gini-mobile-ios.
  Change it in one repo and open a paired PR in the other; CI
  (shared-skills.check.yml) fails when the copies diverge.
-->

# Reading the ticket and its links

**Reference for `/gini-review`** — read at **§2**, and again at §3 for the logic method.
Used on every review.

**Purpose:** get the ticket — from Jira, or from the user when Jira is not reachable — and turn it
into concrete checks against the diff.

**Supports:**

- **Fetching the issue** — Jira site, resolving the cloudId, which fields to request, the scope quirk
- **Working without Jira** — the paste-in fallback for a missing connector, a failed fetch, or a
  reviewer who has no Jira access
- **Extracting the key** — first `[A-Z]{2,5}-[0-9]+` anywhere in the branch name, and treating a
  ticketless branch as normal
- **Field triage** — which of `issuetype`, `labels`, `parent`, `components`, `fixVersions`, `status`,
  `attachment` change how you review
- **Bug-template parsing** — Steps to Reproduce / Actual / Expected, and the empty-section and ADF
  artefacts to expect
- **Attachments** — metadata is readable, content is not; when to stop and ask for a file
- **Link following** — Figma, Confluence, other tickets, `issuelinks`, and which links are build noise
- **Comment triage** — when a comment overrides the description
- **Logic checks** — the 8-step method, including the opposite-direction check

**Does not cover:** repo coding rules and published API surface → `../platform.md` · comment wording →
`comment-style.md`

The ticket is the specification. Reviewing a diff without it verifies only that the code is
*well-formed*, not that it is *correct*. **So the ticket is never optional — but Jira is.** This file
covers three ways to get it, what to extract, and how to turn it into logic checks.

## Fetching from Jira

Site is **`ginis.atlassian.net`** (note the trailing `s` — `gini.atlassian.net` returns
403 "app is not installed on this instance"). Use the Atlassian MCP tool `getJiraIssue`:

- `cloudId`: **resolve it at run time — do not hard-code it.** Call
  `getAccessibleAtlassianResources` and take the id of the `ginis.atlassian.net` entry. It is a
  workspace identifier, not a credential: it is inert without an authorised OAuth session, and every
  Atlassian client discovers it the same way. Looking it up also keeps this file correct if the site is
  ever migrated.
- `issueIdOrKey`: the key from the branch name — the **first match of `[A-Z]{2,5}-[0-9]+` anywhere in
  the name**, not anchored at the start. Branches are usually `<TICKET>-<kebab-description>`, but the
  key can sit under a segment (`backup/PP-1234-…`, `feature/FEAT-001-…`), and an anchored pattern
  silently misses those. The PR title and commit trailer carry the same key if the branch does not.
- `responseContentFormat`: `markdown`
- `fields`: `["summary","description","status","issuetype","priority","labels","components","comment","issuelinks","parent","fixVersions","attachment"]`

**The scope quirk:** `getAccessibleAtlassianResources` lists the same site **twice** with the same id —
once with Confluence scopes, once with Jira scopes (`read:jira-work`). Only the Jira-scoped grant works
for issues. If a call is rejected, re-read that list and use the Jira entry; if the connector was
authorised for Confluence only, every issue call fails until Jira scopes are granted.

**A branch with no ticket key is normal, not an error.** Plenty of branches here carry none — skill,
CI, release, docs and refactor work. Do not hunt for a ticket that does not exist, and do not guess
one from the diff. Note it under **Not checked** and review on the PR description alone.

## When Jira is not available — ask, don't skip

A missing Atlassian MCP connector, an expired session, a rejected cloudId or a reviewer without Jira
access are all common, and none of them is a reason to review blind. **A ticket key exists and the
fetch did not work → ask the user for the content before giving up.** Use `AskUserQuestion` or a plain
request:

> I couldn't reach Jira for `<KEY>`. Paste the ticket in and I'll review against it — description plus
> Steps to Reproduce / Actual / Expected is enough. Or say "skip" and I'll review without acceptance
> criteria and mark it under Not checked.

What to do with what they give you:

- **Pasted text** — treat it exactly as a fetched description: parse the same template sections, run
  the same logic checks. Note in the report that the ticket was **pasted, not fetched**, so the
  reviewer knows the field metadata (labels, epic, status, links) was not available.
- **A partial paste** — a summary line and Expected Result is still worth far more than nothing. Work
  with it and say which parts were missing.
- **A URL only** — that is not content. `WebFetch` on a Jira issue URL returns the login page, not the
  issue. Ask for the text.
- **"Skip"** — proceed, and record `Not checked: acceptance criteria` in the report. That is an honest
  outcome; silently reviewing as if you had the ticket is not.

The same offer applies to attachments (see below) and to a linked Confluence page you cannot reach.

Never invent ticket content, and never infer requirements from the diff and then "verify" the diff
against them — that is circular and produces confident nonsense.

## Fields that change how you review

| Field | Why it matters |
|---|---|
| `issuetype` | **Bug** → the description is Expected/Actual/Steps (see below). **Story/Task** → acceptance criteria. Different review questions. |
| `labels` | Platform labels (`Android`, `iOS`, `mobile`, `backend`). A ticket labelled for a different platform than the repo under review is worth asking about. |
| `parent` | The epic. Often carries design intent the ticket itself omits. Fetch it when the ticket's own description assumes context. |
| `components` | Which SDK the ticket concerns. Compare against which modules the PR actually touches. |
| `fixVersions` | Ties to release planning; a per-platform "Unknown Fix Version" placeholder means unscheduled. |
| `status` | A ticket still in **In Progress** with a PR up is normal; **Done** with an open PR is worth questioning. |
| `attachment` | Screenshots and screen recordings for UI bugs. Often the only statement of correct appearance. |

## The bug-report template

Bug tickets in this Jira use a fixed template. Parse these sections out of `description`:

- **Steps to Reproduce** — the exact code path to trace. This is the most useful part of the ticket.
- **Actual Result** — the wrong behaviour. The diff must eliminate it.
- **Expected Result** — the correct behaviour. The diff must produce it.
- **Figma Link** — design intent for UI bugs.
- **Screenshot/Screen-recording** — visual evidence.
- **Additional Information** — often has the real constraint.

Caveats from live data:

- Template sections are frequently **left empty**, holding only a zero-width `‌` placeholder or a
  commented-out hint like `_<!-- Any relevant details -->_`. An empty Figma section means *no design
  reference was given*, not that you failed to find one. Do not claim a link exists.
- `markdown` format leaves ADF artifacts such as
  `<custom data-type="emoji" data-id="id-0">:flag_on:</custom>` in the text. Ignore them; they are
  section markers, not content.

A well-filled bug template reads as a complete, testable specification — a sequence of steps, the
wrong outcome, and the right one. Pay particular attention when the steps include state transitions
like closing and reopening the app, toggling a setting between runs, or rotating: those details are
usually what makes the bug reproducible, and they are the part an implementation most often misses.

When the template is filled thinly — steps but no Expected, or a summary line only — say so, and
derive what you can without inventing the rest.

## Attachments — metadata yes, content no

`getJiraIssue` with `attachment` in `fields` returns full metadata per file: `filename`, `mimeType`,
`size`, `author`, `created`, plus `content` and `thumbnail` URLs. **The content URLs cannot be
read.** They require OAuth; `WebFetch` gets `403 Forbidden`, and the Atlassian MCP `fetch` tool takes
only ARIs for issues and pages, not attachments.

So: always list what is attached, never pretend to have seen it.

```
<KEY> attachments (<count>):
  <filename>   <size>   <author>   <created>
```

Triage them, because what is attached tells you a lot even unread:

- **Screenshots / screen recordings** — for a UI bug these are often the only statement of correct
  appearance. If the review turns on visual behaviour, **stop and ask the user to paste the image
  into the conversation**, naming the specific file. Do not quietly file it under "not checked" when
  it is the crux of the ticket.
- **Config or resource files** (theme and colour resources, logs, `.har`) — frequently the actual
  evidence. A light-mode and a dark-mode resource file attached to a "section turns to black" bug point
  straight at a colour definition, and that reshapes where you look in the diff. Ask for these too;
  they are small and quotable.
- **Author and date matter.** An attachment added *after* the PR opened is usually a reviewer or QA
  responding to the current implementation — higher signal than the original report.

If the user supplies a local path to a downloaded attachment, read it with the `Read` tool — it
renders PNG and JPG visually and reads XML as text.

Optional setup that removes the friction permanently: a Jira API token
(`id.atlassian.com` → API tokens) makes attachments fetchable directly —
`curl -u <email>:<token> -L <content-url> -o <file>` then `Read` the file. Suggest it once if
attachments block a review repeatedly; do not nag.

Always record unseen attachments under **Not checked** in the report, by filename. "3 screenshots
not reviewed" is honest; silently omitting them implies visual verification that did not happen.

## Links in the description and comments

Extract every URL from `description` and every `comment.comments[].body`, then classify. What each
kind is good for:

| Link | Use |
|---|---|
| `figma.com/...` | Design intent. For UI changes, fetch it with the Figma MCP (`get_screenshot` / `get_design_context`) and compare against what the diff renders — spacing, colours, states, copy. |
| Confluence (`ginis.atlassian.net/wiki/...`) | Specs and integration guides. Fetch with `getConfluencePage`. If the PR changes documented behaviour, the doc may need updating too — that is an improvement to raise. |
| Another Jira key (`PP-1234`, `HEAL-99`) | Related work. Fetch it when the current ticket's logic depends on it, when it looks like a duplicate, or when it defines a term the ticket uses. Do not recurse more than one level. |
| `issuelinks[]` | Formal blocks/relates-to/duplicates relationships. A `blocks` link that is still open is worth flagging. |
| Build-distribution links (Firebase App Distribution, TestFlight and similar) | **Build artefacts, not specification.** Posted automatically by a service account on most tickets. Ignore for review purposes. |
| GitHub PR/commit links | Prior attempts or related PRs. Useful history. |

Comment triage: comments are a mix of bot build links and genuine clarification. A human comment that
narrows or contradicts the description **overrides the description** — requirements evolve in
comments and the description often is not updated. If a comment changes the spec, say so explicitly
in the report, because the reviewer may not have read it.

## Turning the ticket into logic checks

This is the point of all the above, and it works the same whether the ticket was fetched or pasted.
Do it in this order:

1. **State the expected behaviour as concrete propositions** before looking at the diff. For a bug,
   from Expected Result. For a story, from acceptance criteria. Write them down — vague expectations
   produce vague reviews.
2. **Trace the reproduction steps through the changed code.** Entry point → each state change → the
   branch that decides the outcome. Read the whole file, not the hunk, or the trace is fiction.
3. **Ask literally: following these steps, does the new code produce Expected instead of Actual?**
   If you cannot answer, say so in "Needs a human" rather than guessing.
4. **Root cause or symptom?** Does the fix correct *why* the wrong branch was taken, or add a
   special-case guard that hides it? A guard that happens to satisfy the repro steps but leaves the
   underlying state wrong will resurface. This is blocking, worth raising even when the repro
   passes.
5. **Check the opposite direction.** Fixing "flag false must show the old warning" must not break
   "flag true must show the new pop-up". Bug fixes that invert a condition commonly break the other
   branch, and the ticket only describes one. This check catches real regressions and is the single
   highest-yield item in this file.
6. **Check state and lifecycle explicitly** when the repro involves closing and reopening, rotating,
   or backgrounding. Persisted or cached state surviving when it should reset is
   the actual defect in that class of bug.
7. **Does a test encode the ticket's steps?** A regression test that mirrors Steps to Reproduce is
   what stops the bug returning. Its absence is a legitimate blocking finding for a bug fix.
8. **Scope:** anything in the diff that no proposition from step 1 required. Flag it — either the
   ticket is incomplete or the PR is doing extra work.
