<!--
  SHARED FILE — platform-neutral by design. Meant to stay byte-identical to
  .claude/skills/gini-review/references/general-rules.md in gini-mobile-android.
  Change it in one repo and open a paired PR in the other.
  Anything naming a language, linter, framework or module belongs in
  ../platform.md, never here.
  Mirror enforcement status and the current path divergence between the two
  repos: §"How the two copies are kept in sync" below.
-->

# General rules — the shared engine and how a platform layer plugs into it

**Reference for `/gini-review`** — read only when writing or extending a `platform.md`. Not needed to
run a review.

**Why this file is called `general-rules.md`.** Everything in `references/` is general: it holds only the
rules that hold on **every** repo the skill runs in — `gini-mobile-android`, `gini-mobile-ios`, and
whatever comes next. Nothing platform-specific lives here; that is what the sibling `../platform.md` is
for. This file is the neutral contract each platform layer is written against, not the rules of any one
platform.

**Purpose:** define the contract between the platform-neutral engine (`../SKILL.md`) and one repo's
local rules (`../platform.md`), so any platform — Android/Kotlin, iOS/Swift, and whatever comes next
(web, backend) — plugs in without touching the engine.

**Supports:** the nine sections a layer must supply · where it lives · what belongs in the layer versus
the engine · how the shared copies stay in sync · how to verify a layer is doing its job

**Does not cover:** the review procedure → `../SKILL.md` · ticket handling → `ticket-context.md` ·
comment wording → `comment-style.md`

## Why the split exists

The review *method* does not vary by language. Reading the whole file instead of the hunk, tracing the
ticket's repro steps, checking the opposite direction, dropping findings CI already catches, keeping the
posted comment short — none of that is Kotlin- or Swift-specific, which is why `../SKILL.md` and every
file in `references/` are shared verbatim between the Android and iOS repos.

What does vary: what counts as published API, which files may not be hand-edited, which linters run in
CI, what "the module ripple" means, and what a missing test implies. Those are the layer.

**The test for where something belongs:** if the sentence would still be true on a repo in another
language, it belongs in the engine. If it names a tool, a file path, a language feature or a module,
it belongs in the layer.

## Shape of a platform layer

One file, next to the engine:

```
.claude/skills/gini-review/
  SKILL.md                    ← the engine. Shared byte-identical across repos — never
                                put a platform rule in here
  platform.md                 ← the layer. This file's subject. Never shared
  references/
    ticket-context.md         ← shared
    comment-style.md          ← shared
    general-rules.md          ← shared (this file)
```

**The rule the layout encodes: `platform.md` is the only file in this directory that may differ between
repos.** `SKILL.md` and everything under `references/` are the general part. If you find yourself
wanting to write "on Android…" or "in Swift…" in any of them, the sentence belongs in `platform.md`.

This matches the layout the other shared skills use — each pairs a shared `SKILL.md` with a per-repo
`platform.md`, so a reviewer opening any of them finds the same files in the same places. Which skills
those are differs by repo (the two repos do not carry an identical skill set), so check the local
`.claude/skills/` rather than trusting a list here.

Keep `platform.md` in the repo it describes, not in a shared location. It is versioned with the code
whose conventions it encodes, and it should change in the same PR as any convention it documents.

`platform.md` runs long — it carries nine sections and is read on every review. That is expected and it
is why it is a separate file: the engine stays readable, and the layer can grow without anyone having to
re-read the procedure to find a local rule.

## How the two copies are kept in sync

The mechanism is real but **it does not cover this skill yet**, so do not rely on it and do not repeat
the claim that CI enforces it.

What exists today:

- **`.github/mirrored-skills.txt`** — one repo-relative path per line, the authoritative list of files
  that must stay byte-identical. It lives in `gini-mobile-android`.
- **`.github/workflows/shared-skills.check.yml`** — fetches each listed path from
  `gini-mobile-ios@main` and diffs it against the local copy. Divergence is a **warning** on
  `pull_request` and `push` (expected while a sync PR is in flight) and a hard **error** on the weekly
  schedule and on manual dispatch, where it means lasting drift.
- **`.github/workflows/shared-skills.sync.yml`** — after a merge to `main`, opens the paired PR in
  `gini-mobile-ios`.

Three gaps to know about before citing any of this:

1. **`gini-review` is not in `mirrored-skills.txt`.** Nothing in this skill is checked. Adding it is the
   action item; until then the two copies drift silently.
2. **Both workflows live only in `gini-mobile-android`.** The flow is one-directional: Android is the
   source, iOS receives the sync PR. An edit made directly to the iOS copy is caught only by Android's
   weekly run, not by iOS CI — there is none.
3. **The check compares the same path in both repos, and the paths currently differ.** The shared files
   sit at `.claude/skills/gini-review/references/…` in `gini-mobile-ios` and at
   `.claude/skills/gini-review/pr-review/references/…` in `gini-mobile-android`. A missing counterpart
   returns 404, which the workflow reports as a warning ("no counterpart yet") rather than a failure — so
   adding the paths to the list before converging them would look green while checking nothing.

**So: converge the paths first, then add them to `mirrored-skills.txt` in both repos.** Until both are
done, treat a paired PR as a manual obligation, and say so rather than implying a gate exists.

## The nine sections a layer must supply

Each one exists because the engine explicitly defers to it. Answer for your platform; omit nothing
without saying why.

1. **Published API surface.** What makes a declaration public here — is it explicit, or public by
   default? Which visibility modifier makes it internal? Does an accidentally-public helper ship
   forever? Name the mechanism, because "don't leak API" is unactionable without it.
2. **Dependencies and build files.** Where versions are declared, and what must never appear in a
   module's build file. Name the file paths.
3. **Release mechanics.** Which files are generated and must not be hand-edited, which modules
   version-bump together, where a module's version lives, and how fixes for older majors are targeted.
4. **Module ripple.** A table: changed module → downstream consumers. This is what turns "tests only in
   the changed module" into a concrete question about blast radius. Say explicitly where CI does *not*
   follow the dependency graph, because that is where the reviewer is the only gate.
5. **Architecture and style.** The expected pattern for new code, the DI stance, and — importantly —
   the **legacy carve-outs**: which directories hold old code whose style must be followed rather than
   modernised. Without this, the review files noise on every legacy file it meets.
6. **Test conventions.** Where tests live, the naming pattern, which frameworks (and which are legacy),
   and **when a missing test is genuinely blocking versus unreachable** — some UI, camera, or hardware
   paths cannot be unit-tested, and insisting is a false positive.
7. **Commit hygiene.** The commit-message format and where it is defined, plus what an auto-generated
   PR title looks like, since the title becomes the merge-commit subject.
8. **The do-not-flag list.** The most valuable section. At minimum: every check CI runs (name the
   linters, formatters and the compiler — findings they catch are noise), pre-existing lines the PR did
   not touch, deliberate suppressions, intentionally-gitignored config, vendored and generated paths,
   and known-broken-on-purpose targets. Be specific; a vague list does not suppress anything.
9. **Published API and binary compatibility.** Whether an API-surface snapshot is committed and checked
   in CI, how to read its diff, which edits are source-breaking versus binary-breaking for consumers,
   the deprecation cycle, and the scope rule that only added-or-modified declarations are in scope.
   Read conditionally — only when the diff touches a published module — so keep it as its own section
   with a clear "skip this unless" opener.

## Sharpening the generic dimensions

Three rows of the engine's dimensions table are deliberately vague because their specifics are
platform-bound. A good layer sharpens them in one line each:

| Dimension | What the layer should name |
|---|---|
| **Concurrency** | The local async model and its failure modes — structured-concurrency scope and cancellation, the shared-observable-state primitive that races, what must not run on the UI thread |
| **Lifecycle** | The local teardown callbacks, what leaks a reference here, and which state is lost across a configuration or scene change |
| **Documentation** | The reference-doc tool consumers actually read, and where the integration guides live |

## Keep it branch-aware and PR-agnostic

`platform.md` is read on every review in the repo, so it holds only standing conventions:

- **Never record the state of one PR, ticket or release in it.** Version numbers and ticket keys that
  appear are format placeholders, never live values.
- **Parallel major-version branches drift.** Tell the review to read the repo's agent instructions and
  build files *on the branch under review* and let those win over anything written in the layer.
- **Document known drift rather than silently resolving it.** Where the repo's own instructions have
  fallen behind the code, say so in the layer — a finding that cites a rule the codebase abandoned
  collapses under one reply from the author.

## Verifying a layer works

A layer is doing its job when:

- Every finding the review produces can cite either the layer or the repo's agent instructions by line.
  If a finding cites nothing, either the layer is missing a rule or the finding is a bare preference.
- The do-not-flag list actually fires — review a PR that touches legacy code or a generated file and
  confirm nothing was reported about it.
- A reviewer on the team reads the output and does not have to correct local conventions. Each
  correction they make is a missing line in the layer; add it rather than fixing it per review.
