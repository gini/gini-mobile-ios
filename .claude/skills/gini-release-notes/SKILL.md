---
name: gini-release-notes
description: Draft GitHub release notes for a Gini SDK release from its Jira fix version — work out which bumped packages need a note, pull the tickets assigned to each fix version, turn them into integrator-facing bullets, and render them in this repo's house format. Use when asked to "create/write/draft a release note" or "release notes", with or without a package and version — e.g. "create a release note for this RC", "release notes for this branch", "draft the release notes for <package> <version>". Drafts only; never publishes without explicit confirmation.
---

<!--
  MIRRORED FILE — this file must stay byte-identical to
  .claude/skills/gini-release-notes/SKILL.md in the other platform repo
  (gini-mobile-android <-> gini-mobile-ios).
  If you change it here, open a paired PR in the other repo with the same
  content. CI (shared-skills.check.yml) fails when the copies diverge.
  Platform-specific rules do NOT belong here — they live in the sibling
  platform.md, which is intentionally different per repo.
-->

# /gini-release-notes — draft GitHub release notes from the Jira fix version

The content of a release note comes from **the Jira fix version**, not from git history. Git is only used to find the bumped packages (§1) and as a cross-check (§5).

This skill **only ever produces a draft** — never a published release. Even when the user asks to put it on GitHub, it is created with `--draft` (§8) so a person reviews and publishes it.

Throughout, **package** means one releasable unit as listed in `platform.md` § *Release targets* — a Gradle project on Android, a Swift package on iOS.

## How to run it

Run it from the release branch, or from any branch where the version bumps are visible.

```
/gini-release-notes                       # detect the bumped packages on this branch, draft a note for each
/gini-release-notes <package> <version>   # draft one specific note
/gini-release-notes <package> <version>, <package> <version>
```

It also triggers on plain requests, which is the normal way to reach it:

- "create a release note for this RC"
- "release notes for this branch"
- "draft the release notes for `<package> <version>`"

**"a release note" (singular) does not mean one note.** The number of notes is decided by §1 and by `platform.md` § *Release targets* — never by the phrasing of the request. A release that bumps an SDK and the library beneath it produces a note for each, and in some repos a single package produces more than one note. Likewise "create" means *create the draft*, not publish (§8).

"this RC" / "this branch" / "this release" all mean: use the version bumps on the current branch, no arguments.

With **no arguments** it runs the whole chain: detect bumps (§1) → confirm the list with the user → resolve each fix version (§2) → draft (§3–§6) → present for review and offer to put them on GitHub (§7). With arguments, §1 is used only to confirm the given packages were really bumped and to find their previous versions.

Nothing is created anywhere until §7 has been reviewed. Presenting the notes always ends by **offering** to create them on GitHub — the user should never have to know to ask. Only a "yes" runs §8, which needs the tags to exist and still only ever creates drafts.

What it needs: the `gh` CLI authenticated for the `gini` org, and the Atlassian connector for `ginis.atlassian.net`.

## 0. Load platform conventions — REQUIRED FIRST

Read `platform.md` in this skill's directory. It defines where versions live, which packages get notes and where, how a Jira fix version maps to a release title, the note templates, the documentation and dependency link formats, and the tag/draft commands. Every platform-specific decision below MUST come from that file, never from your own defaults. If the file is missing, stop and tell the user this repository is not set up for the shared release-notes workflow.

## 1. Determine which packages need a release note

A note is needed for every package that satisfies **both**:

- **(a)** its version was bumped in this release, and
- **(b)** it is listed as producing a release note in `platform.md` § *Release targets*.

A bump alone is not enough.

### Find the bumped packages

Use the version-file location and diff commands in `platform.md` § *Where versions live*. Run the form for an open branch, or the form comparing against the previous tag once the release is tagged.

The removed version line gives the **previous version**, needed for the git cross-check (§5) and to confirm the fix-version number.

`platform.md` also names files that change during a release but are **not** a package's own version — dependency-pinning files. Do not treat those as bumps; they are the source for the Dependencies section (§6).

### Decide per bumped package

Look each bumped package up in `platform.md` § *Release targets*. That table is authoritative for whether it gets a note at all, and for where each note goes.

Packages that get no note are internal dependencies that integrators never add directly. They also have no Jira fix version — the same fact seen from the other side. Use that as a consistency check: **a bumped package with no fix version is expected for those, and a mistake for any package that should have one** (someone forgot to set the fixVersion in Jira — flag it).

A package bumped only because a dependency moved, with no change of its own, **still gets a full note** listing the same user-facing changes as the SDK above it.

### Order the work

Draft in the dependency order given in `platform.md` § *Dependency order*, deepest dependency first, because each note links the release of the ones below it.

Confirm the resulting list with the user before continuing.

## 2. Resolve the fix version

The Jira fix version is the join key between Jira and the GitHub release. `platform.md` § *Jira fix version mapping* gives the exact rule for turning a fix-version name into a release title and tag — **it is a transformation, not always an identity**, so apply it rather than assuming the two strings match.

That section also gives the per-package fix-version prefixes and which Jira project each package belongs to. The Jira site is `ginis.atlassian.net`.

Both platforms' releases live in the same Jira projects, so the platform marker in the fix-version name is what separates them. Never match a fix version without it.

A fix version may carry a theme suffix after the version number. Match on the version number, then confirm the full string with the user.

## 3. Pull the tickets

One query per fix version:

```
searchJiraIssuesUsingJql
  cloudId: ginis.atlassian.net
  jql:     fixVersion = "<exact fix version name>" ORDER BY issuetype ASC
  fields:  ["summary", "issuetype", "status", "resolution", "fixVersions"]
```

Always pass an explicit `fields` list — the default set includes full descriptions and will overflow the token limit. If a response still spills to a file, extract with jq instead of reading it:

```bash
jq -r '.issues.nodes[] | "\(.key) [\(.fields.issuetype.name)/\(.fields.status.name)] \(.fields.summary)"' <saved-file>
```

An empty result almost always means the name is wrong, not that the release is empty — JQL on an unknown value returns nothing rather than an error. Re-check the exact string, including the platform marker and any theme suffix.

**One ticket, several fix versions.** A ticket is routinely assigned to two or three fix versions at once — an SDK and the library beneath it. Each note describes only the part that ships in *that* package: the lower package describes the API-level change, the SDK above it describes the user-visible behaviour, and sometimes a package has nothing to say about a ticket it is tagged with.

## 4. Turn tickets into bullets

### Drop these issue types entirely

`Release Candidate`, `Test Plan`, `Test Execution` — process tickets, never bullets. They are usually a large share of a fix version.

### The RC ticket is the outline, not a bullet

The Release Candidate ticket is the release's anchor. Its summary names the release theme, and its description lists the tickets in the release. One RC ticket often covers a whole product line, so the same key appears in several fix versions.

Read it first, along with the tickets its description names. A bullet that belongs in the notes but matches no ticket in the fix version usually comes from the release theme — check with the user rather than dropping it.

### Map the remaining tickets

| Issue type | Becomes |
|---|---|
| `Story`, `Task`, `Improvement` | its own named bullet |
| `Bug` | folded — see `platform.md` § *Bullet conventions* for how this repo folds bugs; give a bug its own bullet only when an integrator would notice the behaviour change on its own |

Group by what the integrator sees, not by ticket count. A fix version with eight bugs in one feature does not produce eight bullets.

Whether bullets are grouped under subheadings, and the exact wording of any fixed closing line, come from `platform.md` § *Bullet conventions*.

### Wording rules

- Third person, no leading pronoun: "Adds …", "Improves …", "Fixes …", "Replaces …". Match the tense used in that package's previous release; don't mix tenses within one list.
- Rewrite from the integrator's point of view. A user story ("As a User, I want …") becomes a statement of what changed in the SDK.
- Never paste a ticket summary verbatim, and **never include ticket keys or Jira links** — release notes are public.
- Put changed public API in backticks, using the symbol form given in `platform.md` § *Bullet conventions*.
- Where a change comes from a dependency, say so and point at that package's notes rather than repeating its changelog.
- Breaking changes first, saying what the integrator has to do.
- Never invent a change. Anything you cannot phrase confidently goes into an `Open questions` block below the draft.

### Tone

These bullets are read by customers, so write them a little more warmly than a changelog line — but keep them short. Each bullet is **what changed, then one clause on what the integrator gets from it**, used only where the ticket supports it:

```
- <verb> <what changed, with any public API in backticks> — <one clause: what it means for the integrator>
```

Write the benefit clause only from what the ticket actually establishes. Typical material: a platform or store requirement the change keeps them compliant with, a dependency they no longer carry, a manual step they no longer need, a behaviour that now works where it previously did not. If a ticket supports no such clause, leave the bullet bare — a bare bullet is correct and normal, and better than a padded one.

Keep it restrained. One benefit clause per bullet, no second sentence, and never two adjectives where one works. No marketing vocabulary ("seamless", "powerful", "delightful", "revolutionises"), no exclamation marks, and no promises about speed, stability or reliability that the ticket does not support — a vague flourish is worse than the bare line, because an integrator cannot act on it. Every claim must trace to a ticket; the tone is in the framing, never in added substance.

Any fixed closing line defined in `platform.md` stays exactly as written there — never dress it up.

## 5. Cross-check against git

Only to catch tickets missing from the fix version — never as a source of bullets. Use the log command and source paths from `platform.md` § *Source paths*.

If a commit references a ticket that is not in the fix version, flag it: either the fixVersion is missing in Jira, or the change does not belong in this release.

## 6. Render

`platform.md` § *Note templates* holds the template for every note this repo produces, and says how many notes each package needs. Follow it exactly — the section set, their order and their headings are not interchangeable between repos.

Templates describe the shape. The **authority for any given note is that package's previous release**, which `platform.md` shows how to fetch. Read it before writing, and match its heading set, its tense, and whether optional blocks are present. Where a template and the previous release disagree, the previous release wins for that package.

Fill the documentation link from `platform.md` § *Documentation URLs* and the dependency links from § *Dependency links*.

**Always include every link.** Some documentation URLs are version-specific and some are fixed pages that carry no version — `platform.md` marks which is which. Substitute the version being released into the version-specific ones only; use a fixed URL verbatim and never splice a version into it.

A version-specific documentation link is published by the release workflow, and sibling release links point at releases that are often not published yet, so **those** links will 404 while drafting. That is normal and is **not** a reason to omit a link, change it, or fall back to an older version's URL. Never downgrade a link to an already-published older version just to make it resolve. Checking the links is the releasing person's job at the end — the draft just has to have them pointing at the right version.

Older published notes contain mistakes here. Do not copy a wrong version forward from the previous note.

## 7. Present the draft

For each package, show every note it produces — title and full body as fenced blocks — plus:

- which tickets were dropped and why (process tickets, folded bugs),
- any `Open questions`,
- any git/Jira mismatch from §5,
- a reminder that the documentation and dependency links point at the new versions and still need to be checked by the releasing person once the workflows have run.

### Check the tags before offering

A GitHub release attaches to a tag, so find out whether the tags exist *before* asking — otherwise the offer promises something that may be impossible. Use the checks in `platform.md` § *Tags and draft creation*, for every repo a note goes to.

These are read-only lookups: they only read tag names and create nothing. Running them before the user has answered does not breach §8's rule, which is about creating or editing releases.

### Then make the offer

**End by asking whether to create these as drafts on GitHub.** Ask every time — even when the user has not mentioned GitHub — so they never have to know that §8 exists or think to ask for it. Make the offer concrete, naming which repo each draft goes to, and fold the tag result into it:

- **Tags present** → name them, and say the drafts will be created with `--draft` and that publishing stays with the user.
- **A tag missing** → say so in the offer itself, since it changes the answer. Do not offer to create that draft; hand over its text and say it can be created once the tag is pushed. Offer the others as normal. **Never create or push the tag** — tags trigger the release workflows.

A "yes" is the explicit confirmation §8 requires; go straight into it. Anything else — silence, edits, a change of subject — is not, so keep iterating on the wording and ask again once the draft settles.

## 8. Creating the GitHub drafts (only on explicit confirmation)

A GitHub release is public and outward-facing, so do not create or edit one until the user has answered the §7 offer with a yes. When they have, the result is **always a draft** — this skill never publishes.

The tags were already checked in §7. Create a draft only where the tag exists; a note whose tag is missing was never offered, so skip it and leave its text with the user.

Use the commands in `platform.md` § *Tags and draft creation*.

`--draft` is mandatory — keep it even if the user says "publish it" or "put it on GitHub". Creating the drafts is the end of this skill's job; a person reviews the wording, checks that the documentation and dependency links now resolve, and presses publish. Say that explicitly when handing over.

Give the user each draft's URL from the command output so they can go straight to it.
