# Comment format

**Reference for the review engine** — read at **§5**, before writing any comment. Used on every review.

**Purpose:** word a finding so the author can act on it in one read, and keep improvements distinct
from defects.

**The three rules that matter most:**

1. **Stay inside the length budget.** A long comment is not a more thorough comment; it is a comment
   that gets skimmed. See §"Length budget" — it is a hard cap, not a target.
2. **Open a posted comment with its category** — `**Blocker:**`, `**Suggestion:**` or `**Question:**`.
   The author needs to know what is being asked of them before reading the finding.
3. **No other internal machinery in a comment a human reads** — no confidence scores, no dimension
   names, no severity words beyond the three categories.

**Supports:**

- **Length budget** — the hard cap, how to compress into it, what to drop first
- **Inline comment format** — the three-part shape (fact → consequence → concrete fix)
- **Writing rules** — the category prefix, third person, no inline praise, present tense, always
  actionable
- **Summary review** — overview paragraph, changes grouped by behaviour, `Reviewed X out of Y`,
  per-file table in `<details>`
- **Improvements** — the five categories and how to frame one as deferrable so it gets adopted
- **GitHub suggestion blocks** — when a one-click fix is safe to attach

**Does not cover:** what to look for → `../SKILL.md` §3 plus the platform layer · deciding whether a
finding is real → `../SKILL.md` §4

## Length budget

**Inline comment: 3–4 rendered lines. Two sentences. 400 characters, hard cap.**

Count before posting. A code block attached as a `suggestion` does not count — the prose above it does.

The budget is not a style preference. An inline comment appears in a narrow column beside the diff, and
the author reads it while holding the code in their head. Past about four lines they stop reading the
sentences and start scanning for the ask, so the *fix* is the only part that lands — a long comment
loses exactly the reasoning it spent its length on.

**How to compress, in order:**

1. **Fuse fact and consequence into one sentence.** "X happens, so Y breaks" is one sentence doing two
   jobs. This alone usually gets you inside the cap.
2. **Cut the mechanism to its result.** The author does not need the derivation, only enough to check
   your work. "Unloading removes the definition rather than restoring it" replaces a paragraph about
   how the registry is keyed.
3. **Drop the corroboration.** A second piece of evidence for a claim the author can verify in ten
   seconds is padding. One is enough.
4. **Drop the alternatives.** Give the fix you would take. Offering a second option is idiomatic only
   when both are genuinely equal and the choice is the author's.
5. **Still over?** The mechanism is too complex for the margin. Post the claim and the fix inline and
   leave the explanation out; the author will ask. Never solve a too-long comment by writing more.

Worked example — the same finding, over budget and inside it:

> **730 characters.** The `@After` hook unloads the test module, but the container's unload operation is
> implemented as a removal keyed by definition index rather than as a restore of the previously
> registered factory, which means the production singleton that the test module overrode is deleted from
> the shared container instead of being reinstated, and because that container is a process-wide object
> shared by every test class in the same process, any later test class that resolves that type will fail
> with a resolution error depending on the order the test classes happen to run in, which is exactly the
> order-dependence the hook was added to prevent. Consider either reloading the production module
> afterwards, or re-declaring the singleton, or restructuring the test so it does not need to override
> the container at all.

> **340 characters.** Unloading only removes the overriding definition — it does not restore the
> production singleton, so the shared container is left without one for the rest of the process and a
> later test that resolves it fails depending on class order. Reload the production module after
> unloading.

Same finding, same actionability. The second one gets read.

**The summary body has its own, separate budget** — three paragraphs, under 1500 characters, with its
own cut list. It is in `../SKILL.md` §6.

## Inline comments

The structure, every time:

1. **State what the code does, as fact.** Name the exact symbol, file, or setting in backticks.
   "`pinnedValue` is written on init" — not "there may be an issue with initialisation".
2. **State the consequence.** What goes wrong for whom — the user, the consumer, the next maintainer.
   This is the clause that justifies the comment existing.
3. **Give a concrete fix.** Name the API, file, or pattern.

Two real bot comments in this shape, as a calibration target:

> The snippet under "Self-managed authentication" uses Kotlin syntax (`val`, lambda), but the code block
> is marked as `java`, which leads to misleading syntax highlighting and copy/paste for readers. Either
> switch the directive to `kotlin` or rewrite the snippet in Java syntax.

> The example is written in Kotlin (`val`, lambda) but declared as a `java` code block. This produces
> incorrect syntax highlighting and may confuse integrators. Mark it as `kotlin` (or convert the snippet
> to Java).

Rules that follow from the format:

- **Impersonal and third-person.** "The snippet uses…", "This produces…". Never "you", never "why did
  you".
- **Open every posted comment with its category, in bold**, so the author knows what is being asked of
  them before reading the finding. Use exactly one of:
  - `**Blocker:**` — must be resolved before merge.
  - `**Suggestion:**` — optional and deferrable; the PR is mergeable without it.
  - `**Question:**` — the finding depends on an answer only the author has; no fix is being asked for yet.

  The prefix does not count against the 400-character prose budget. Nothing *else* internal goes in a
  comment — no confidence scores, no dimension names, no `issue:` prefixes, no severity words beyond the
  three categories above. Do not also write "Optional:" or "Small nit:" in the prose; `**Suggestion:**`
  already says it.
- **No praise comments inline.** They add noise to a PR thread. Keep anything positive to the
  acknowledgement clause in the summary body.
- **Present tense, declarative.** No hedging stacks ("might possibly perhaps"), no exclamation marks, no
  emoji.
- **Every comment ends with something actionable.** A comment that only describes a problem makes the
  author do the work twice.

## Summary review

Review bodies follow this shape — mirror it:

```markdown
## Pull request overview

<one paragraph: what this PR does and why, in the reviewer's own words>

**Changes:**
- <grouped change, not a file list>
- <grouped change>

### Reviewed changes

Reviewed <X> out of <Y> changed files and generated <N> comments.

<details>
<summary>Show a summary per file</summary>

| File | Description |
| ---- | ----------- |
| `<path/to/NewInterceptor>` | New request interceptor for session-backed auth injection |
| `<path/to/dependency-manifest>` | Adds validator plugin + test-server dependency entry |

</details>
```

Notes:

- The **"reviewed X out of Y"** line is the coverage ledger — it is what makes the review trustworthy.
  State the real numbers and, when X < Y, say which files were not reviewed and why.
- The per-file table goes in `<details>` so it does not dominate the thread.
- **Changes** groups by behaviour, not by file. "Add the session interceptor and update
  builders/repositories to rely on transport-layer auth" — one line covering many files.

**This full shape is the terminal report.** What gets *posted* is much shorter — see `../SKILL.md` §6
§"The summary body comes first". The per-file table, the coverage count and the section headings never go
on the PR.

## Improvements

Findings say what is wrong; improvements say what would be better. Keep them separate from defects so
the must-fix list stays short, and use the same three-part shape and the same length budget.

What is worth raising:

- **Reuse** — duplicates something that exists, or is generic enough to belong in a shared file. Name
  the destination file and the neighbouring function.
- **Simplification** — a standard-library or framework one-liner replaces hand-rolled code. Name the API
  and confirm it is already available in this target.
- **Robustness** — correct today but fragile under a plausible change. Say plainly that nothing is
  broken now.
- **Clarity** — code that reads as if it does something other than what it does.
- **Test coverage** — name the specific untested path, never "add more tests".

Framing, because it decides whether an improvement gets adopted:

- **Default to deferrable.** Reviewers actively avoid widening an open PR. Phrase improvements so they
  can be taken as a follow-up, and say when that is the better option.
- **Say when an improvement is not worth it.** If a cleaner shape exists but the churn outweighs it, say
  so rather than raising it.
- **Cap the list.** A handful at most. A long optional list reads as noise and buries the blocking
  findings.

## Posting to GitHub

For mechanical changes, attach a suggestion block so the author gets one-click apply:

````markdown
The code block is marked `java` but the snippet is Kotlin, which gives readers wrong highlighting.
Switch the directive to `kotlin`.

```suggestion
.. code-block:: kotlin
```
````

Only where you are confident it compiles or renders **as written** — check that every symbol it uses is
already imported or in scope in that file, since a suggestion cannot add an import on another line. Keep
the span small and self-contained. A suggestion block that does not work is worse than prose.

When a fix needs a change in two places (an import plus a call site), do not split it across two
suggestion comments on one finding. Either write the suggestion so it needs no second edit — a
fully-qualified reference, or a form using only what is already in scope — or drop the suggestion and
describe the change in prose.
