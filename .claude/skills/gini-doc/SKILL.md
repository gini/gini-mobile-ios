---
name: gini-doc
description: "Generate a plain Markdown feature documentation page for Confluence from GiniBankSDK code changes on the current branch. Use when asked to document a GiniBankSDK feature or generate Confluence docs from the current branch."
argument-hint: --platform <platform> --feature-slug <slug> [--note "..."]
---

<!--
  MIRRORED FILE — this file must stay byte-identical to
  .claude/skills/gini-doc/SKILL.md in gini-mobile-ios.
  If you change it here, open a paired PR in the other repo with the same
  content. CI (shared-skills.check.yml) fails when the copies diverge.
  Platform-specific rules do NOT belong here — they live in the sibling
  platform.md, which is intentionally different per repo.
-->

# Skill: /gini-doc

Generate a plain Markdown (`.md`) feature documentation page for Confluence from GiniBankSDK source code changes on the current branch.

This skill always targets **GiniBankSDK**. The output is standard Markdown with no Docusaurus frontmatter, admonitions, or site-specific syntax.

---

## Usage

```
/gini-doc --platform <platform> --feature-slug <slug> [--note "..."]
```

`--platform` and `--feature-slug` are **required**.

If any required argument is missing, stop and ask the user. Do not infer or guess.

---

## Arguments

### `--platform`

The valid value for this repository is defined in `platform.md` (in this skill's directory).

Retained as a required argument to keep the skill interface consistent with other Gini repositories.

### `--feature-slug`

Kebab-case name for the feature. Used as the output file name.

Example: `cross-border-payments` → output file `cross-border-payments.md`

### `--note` (optional)

A plain-text instruction telling the agent what to focus on. Use when the branch contains multiple features or unrelated changes and you only want to document one of them.

```
--note "Focus only on the QR code scanning feature. Ignore changes to the payment flow."
```

The note is the primary filter — any code outside its scope is skipped entirely, even if it is public API.

---

## Style Rules

Apply these rules to all output. They are authoritative over any default behavior.

### Audience

Documentation serves three audiences simultaneously:

| Audience | What they need |
|---|---|
| **Developers** | Precise inputs, outputs, conditions, dependencies, edge cases, and implementation examples |
| **QA engineers** | Expected behavior, validation rules, failure cases, and edge cases specific enough to derive test scenarios |
| **Product Managers / Product Owners** | Business intent, user outcomes, workflow, and scope — without unnecessary implementation detail |

- Define business intent before technical detail.
- Make behavior, rules, and outcomes explicit enough for both engineering and QA use.
- Do not assume all readers share the same technical context.

### Tone and Voice

- **Style:** Neutral, professional, and direct. No marketing language, casual wording, jokes, or sarcasm.
- **Voice:** Second person ("you"), present tense.
  - ✅ "Call `sendTransferSummary()` before calling `cleanup()`."
  - ❌ "In this guide, we will explore how to send the transfer summary."
- **Active voice:** Prefer active over passive.
  - ✅ "The SDK shows the no-results screen."
  - ❌ "The no-results screen is shown by the SDK."
- **Instructions:** Use imperative verbs for procedural content.
  - ✅ "Set the `productTag` property to the cross-border payments value."

### Plain Language

| Prefer | Avoid |
|---|---|
| use | utilize |
| create | initiate |
| update | perform an update operation on |
| remove | eliminate |
| return | — |

Do not use: simply · just · easily · obviously · normally · basically

### Terminology

| Use | Never use |
|---|---|
| SDK | library, module, framework |
| document | file (when referring to what Gini processes) |
| integration | implementation (when referring to customer work) |
| Return Assistant | RA (on first mention; RA acceptable after) |

Write platform and language names with their official capitalization (e.g. Android, Kotlin — never android, kotlin).

- Write the full term first, followed by the acronym in parentheses on first use.
- Use one term per concept consistently throughout. Do not alternate between synonyms.

### Formatting

- **Code blocks:** always specify the language tag (`bash`, `json`, and the platform tags defined in `platform.md`).
- **Tables:** use tables for parameters, properties, error codes, localization keys — not prose lists.
- **Paragraphs:** 1–4 sentences. Break longer explanations into sub-sections.
- **Numbered lists:** only when sequence matters.
- **Nesting:** no more than two levels of nested lists.
- **Placeholders:** use `<!-- TOBEADDED -->` for content that cannot be verified from source. Never use `TODO`.

### What to Avoid

- Vague intros: "In this guide, we will explore...", "This document covers..."
- Undocumented assumptions about environment setup
- Restating the section heading in the first sentence
- Over-explaining what the reader can infer from code
- Describing UI by position or color instead of by label

### Quality Rules

Apply before writing the output file:

1. **Match actual behavior.** Reflect actual source behavior — not assumptions or aspirations.
2. **Write so QA can test it.** Behavior descriptions must be specific enough for a QA engineer to derive test scenarios. "The system handles errors appropriately" is not acceptable.
3. **Eliminate ambiguity.** If a sentence can be interpreted more than one way, rewrite it.
4. **Make technical assumptions explicit.** State hidden system conditions, environment dependencies, or data flows.
5. **Distinguish required behavior from implementation suggestion.** Clearly separate what the system must do from how it may be implemented.
6. **Document edge cases explicitly.** For each feature: what happens if a field is empty? What if a permission is denied? What if the backend returns nothing?
7. **Write for maintainability.** Structure content so future updates can be made to individual sections without rewriting the entire page.

---

## Step-by-Step Instructions

You are given `$ARGUMENTS`. Parse it to extract `--platform`, `--feature-slug`, and `--note`, then follow these steps exactly.

### Step 0 — Load platform conventions — REQUIRED FIRST

Read `platform.md` in this skill's directory. It defines this repository's source roots, localization string locations, configuration surface, permission-to-manifest mapping, and symbols to skip. Every platform-specific decision below MUST come from that file, never from your own defaults. If the file is missing, stop and tell the user this repository is not set up for this skill.

### Step 1 — Identify changed GiniBankSDK source files on the current branch

Determine the base branch the current branch was cut from — usually the
default branch, but fixes for older majors branch from a parallel version
branch (see the repository's release docs). If the base is ambiguous, ask the
user instead of assuming. Then run:

```bash
git diff <base-branch>...HEAD --name-only
```

Keep only files under the source roots listed in `platform.md` — everything else is out of scope. Apply the skip list from `platform.md` (test files, example apps, CI scripts, and so on; localization strings are collected separately in Step 2).

Read each kept file. For large files, focus on the diff:

```bash
git diff <base-branch>...HEAD -- <file>
```

**If `--note` was provided**, apply it as the primary filter: only read and document files related to that scope. Skip everything else even if it is public API.

### Step 2 — Collect localization strings for the feature

Search the localization string locations defined in `platform.md` for keys matching the feature. Derive the key patterns from the feature slug using the key-naming convention defined in `platform.md` — never guess a naming style. `platform.md` also defines which file maps to which language column in the output tables.

Collect all matching keys. Typical groups:
- **Feature UI strings** — labels, titles, descriptions shown in the feature's views
- **Edge case / banner strings** — shown in banners or in-flow alerts
- **Permission / error alert strings** — shown when the user denies an OS permission

Omit a group if it has no keys. If you expect keys but cannot find them, add `<!-- TOBEADDED: verify localization keys against source -->`.

### Step 3 — Identify what to document

From the filtered source, extract:
- Public configuration properties on the configuration surface defined in `platform.md`, with their types/defaults
- Public methods or enums a consumer would call or reference
- Extraction result fields populated or modified by this feature
- Behavioral rules — what the SDK does and does not do when this feature is active
- OS APIs used in source — infer app-level setup requirements using the permission mapping in `platform.md`
- Edge cases and error states described in source or doc comments

**Skip:**
- The platform-specific symbols listed in `platform.md`
- Symbols used only in test files
- UI implementation details invisible to the SDK consumer

**Cross-feature impact:** if the branch modifies behavior of existing features (e.g. Skonto or Return Assistant suppressed when a new flag is set), document those changes in an `## Impact on Other Features` section.

**Flag for review:** any public API with no tests or usage examples — wrap it in a `> **Needs review:**` blockquote.

### Step 4 — Choose a template and write the Markdown file

Read the template files in `templates/` in this skill's directory. They are shared between the repositories (mirrored, like this file) and platform-agnostic: platform-specific content is resolved from `platform.md` at generation time via the rules below. Each template is derived from a published documentation page and encodes the house structure and boilerplate wording. Choose one:

| Template | Use when |
|---|---|
| `templates/major-feature.md` | The feature introduces a new extraction pipeline or result type, changes how results are delivered, or interacts with multiple existing features |
| `templates/flag-feature.md` | The feature is toggled by a single configuration property and adds no new extraction result fields. Also used once per sub-feature when documenting several small related features on one page |
| `templates/os-integration.md` | The feature requires app-level setup — manifest or entitlement declarations, new document formats, share-sheet entry points, or OS permissions |
| `templates/transfer-summary-extension.md` | The feature adds or changes a field in the extraction result and/or the transfer summary, without a new pipeline or UI flow |

If the feature spans categories, start from `templates/major-feature.md` and merge the sections you need from the other templates. If no template fits, stop and tell the user which kind of template is missing instead of inventing a structure.

**Resolve platform references.** Templates contain three kinds of platform references, all resolved from `platform.md`:

- `[term: name]` — replace with the value from the **Terms** table in `platform.md`.
- `[snippet: name]` — replace with the code block defined under that name in the **Snippets** section of `platform.md`, then fill the snippet's own `[placeholder]` markers from source.
- `<!-- platform: x -->` … `<!-- /platform -->` — keep the enclosed content only when `x` matches `--platform`; strip the markers. Content outside guards applies to every platform. Use guards in templates only for content that exists on a single platform — prefer terms and snippets everywhere else.

If a referenced term or snippet is not defined in `platform.md`, stop and tell the user exactly which entry is missing — never substitute your own value, and never let a `[term: ...]` or `[snippet: ...]` marker leak into the output.

Fill the chosen template: replace every `[placeholder]` with content derived from source, and resolve every bracketed instruction. Include a section only when the source provides evidence for it. Do not invent content — use `<!-- TOBEADDED -->` for anything unverifiable. Remove the template's leading HTML comment from the output.

Use only standard Markdown. No Docusaurus frontmatter, no `:::caution` / `:::tip` admonitions. Use `> **Note:**`, `> **Info:**`, `> **Warning:**` blockquotes where admonitions would otherwise appear.

> Published pages in the developer documentation space render these blockquotes as note/info/warning panels. The person publishing converts them manually (or via import) — do not attempt to emit Confluence storage-format macros from this skill.

### Step 5 — Resolve the output path

Output file: `docs/[platform]/features/[feature-slug]/[feature-slug].md` relative to the repository root.

Example for `--platform android --feature-slug cross-border-payments`:
```
docs/android/features/cross-border-payments/cross-border-payments.md
```

Create the directory if it does not exist.

### Step 6 — Write the file

Write the generated file. Confirm with a single line naming the template used:

```
✅ Written to <path> (template: <template-file>)
```

---

## Security

- Read any source file in this repository for context.
- Write only `.md` files inside `docs/` in the current repository.
- Never modify source code, CI configs, or any file outside `docs/`.
- Never run shell commands beyond `git diff`, `git show`, `grep`, and file reads.
- All output requires human review before publishing to Confluence.
