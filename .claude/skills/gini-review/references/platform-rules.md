<!--
  MIRRORED FILE — must stay byte-identical to
  .claude/skills/gini-review/references/platform-rules.md in gini-mobile-ios.
  Change it in one repo and open a paired PR in the other; CI
  (shared-skills.check.yml) fails when the copies diverge.
-->

# Writing a platform layer

**Reference for `/gini-review`** — read only when writing or extending a `platform.md`. Not needed to
run a review.

**Purpose:** define the contract between the platform-neutral engine (`../SKILL.md`) and one repo's
local rules (`../platform.md`), so a new platform — iOS/Swift, web, backend — can be added without
touching the engine.

**Supports:** the nine sections a layer must supply · where it lives · what belongs in the layer versus
the engine · how to verify a layer is doing its job

**Does not cover:** the review procedure → `../SKILL.md` · ticket handling → `ticket-context.md` ·
comment wording → `comment-style.md`

## Why the split exists

The review *method* does not vary by language. Reading the whole file instead of the hunk, tracing the
ticket's repro steps, checking the opposite direction, dropping findings CI already catches, keeping the
posted comment short — none of that is Kotlin- or Swift-specific.

What does vary: what counts as published API, which files may not be hand-edited, which linters run in
CI, what "the module ripple" means, and what a missing test implies. Those are the layer.

**The test for where something belongs:** if the sentence would still be true on a repo in another
language, it belongs in the engine. If it names a tool, a file path, a language feature or a module,
it belongs in the layer.

## Shape of a platform layer

One file, next to the engine:

```
.claude/skills/gini-review/
  SKILL.md                    ← the engine. Mirrored byte-identical across repos — never
                                put a platform rule in here
  platform.md                 ← the layer. This file's subject. Never mirrored
  references/
    ticket-context.md         ← mirrored
    comment-style.md          ← mirrored
    platform-rules.md         ← mirrored (this file)
```

This mirrors the layout the other shared skills use — `gini-build`, `gini-fix`, `gini-spec-feature`
each pair a mirrored `SKILL.md` with a per-repo `platform.md` — so a reviewer opening any of them finds
the same two files in the same places.

Keep `platform.md` in the repo it describes, not in a shared location. It is versioned with the code
whose conventions it encodes, and it should change in the same PR as any convention it documents.

`platform.md` runs long — it carries nine sections and is read on every review. That is expected and it
is why it is a separate file: the engine stays readable, and the layer can grow without anyone having to
re-read the procedure to find a local rule.

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
