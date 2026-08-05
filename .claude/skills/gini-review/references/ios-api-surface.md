# iOS published API and compatibility — gini-mobile-ios

**Platform layer for `/gini-review`** — read at **§3**, **only when the diff touches a releasable
module**: `GiniBankSDK`, `GiniCaptureSDK`, `GiniHealthSDK`, `GiniBankAPILibrary`,
`GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`.

**Skip entirely for:** example apps, `*Tests/`, `*UITests/`, `.github/`, `scripts/`, `Documentation/`,
`.claude/`, `Makefile`, `fastlane/`.

<!--
  NOT MIRRORED — iOS-specific by design. The Android counterpart is
  references/android-api-surface.md.
-->

**Supports:** what guards this branch (spoiler: nothing) · deriving the public-surface diff by hand ·
source- vs binary-breaking changes in Swift · judging a new `public` symbol · the deprecation cycle

**Does not cover:** repo conventions and the do-not-flag list → `ios-checklist.md`

**Nothing here is tied to a particular PR, ticket, branch or release.** This file is read on every review
that touches a shipping module. Module names are real; every version, symbol and declaration shown is a
**format placeholder** — take the actual values from the diff, and re-run the greps below rather than
trusting a count or a line number quoted here.

## First: confirm nothing in CI is guarding this

Android has `apiCheck` and committed `.api` dumps, so review is a second opinion there. **On iOS it is
the only opinion.** Verify rather than assume — if someone has since added a guard, your report should
say so:

```bash
# Is there a committed API snapshot, or any surface check in CI?
git ls-files | grep -iE '\.(api|swiftinterface)$'
grep -rniE 'swift-api-digester|api-diff|swiftinterface|abi-baseline' .github/ scripts/ Makefile fastlane/ 2>/dev/null
```

As of writing both come back empty, and no linter covers the gap — SwiftLint is only a warning-level build
phase on the example projects (`ios-checklist.md` §8). So:

> **No automated check will tell anyone that this PR changed the public API surface.** State that
> explicitly in the report whenever the diff adds, removes or alters a `public` or `open` declaration —
> it is the single most useful sentence you can give the reviewer.

## Derive the surface diff yourself

This is the substitute for reading an `.api` dump. Run it **first**, before reading files — it is the
highest-signal thing available on the PR:

**Diff against the PR's own base branch, not `main`.** Fixes for older majors ship from a release branch
(`ios-checklist.md` §3), so hardcoding `main` would compare against the wrong history and invent breaking
changes that aren't there. Take the base from `gh pr view --json baseRefName` at §1:

```bash
BASE_REF="<baseRefName from the PR, or the default branch when reviewing a local diff>"
BASE=$(git merge-base HEAD "origin/$BASE_REF")

# Added or widened public surface
git diff "$BASE"...HEAD -- '*/Sources/*.swift' | grep -nE '^\+\s*(public|open)\s'

# Removed or narrowed public surface — every hit is a potential breaking change
git diff "$BASE"...HEAD -- '*/Sources/*.swift' | grep -nE '^-\s*(public|open)\s'
```

Then read each hit in its file. `grep` on a diff cannot tell a moved line from a new one, so confirm in
context before reporting anything.

**Scope rule: only declarations this PR added or modified are in scope.** A pre-existing `public` symbol
the diff merely moved past is not a finding.

Current baseline facts, so you can recognise a departure from the norm: `open` appears 3 times in the
whole repo, and there is **no `@_spi`, no `package` access level, and no `@frozen`** anywhere. A diff
introducing any of those is doing something unusual and deserves a question.

## Both distribution modes recompile against you

| Mode | Built by | What breaks consumers |
|---|---|---|
| **SPM source** (the normal path) | Integrator's Xcode, from the release repo pinned with `.exact()` | **Source compatibility.** Their code is recompiled against your headers. |
| **XCFramework** (`build-GiniBankSDK-XCFrameworks.sh`, tag `<Pkg>;<ver>;xcframeworks`) | Us, with `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` and `GINI_FORCE_DYNAMIC_LIBRARY=1` | Source compatibility **plus** the emitted `.swiftinterface` — library evolution is on, so the module's public interface is a published contract, and the binary is code-signed and shipped as-is. |

Practical consequence: **source compatibility is what you review.** Library evolution buys resilience
for adding stored properties to non-frozen public structs, but it does not make a renamed method or a
changed signature safe for anybody.

## Source-breaking in Swift — the list worth checking

Every one of these compiles fine here and breaks an integrator:

- **Removing or renaming** any `public`/`open` symbol, or changing its access level downward.
- **Changing a signature**: parameter type, return type, argument label, throwing-ness, `async`-ness,
  adding a parameter *without* a default value. Adding one *with* a default is safe for callers but still
  changes the interface.
- **Adding a case to a public enum.** Consumer `switch` statements over it stop being exhaustive. No
  enum here is `@frozen`, so treat every public enum as one integrators switch over.
- **Adding a requirement to a public protocol without a default implementation** — every external
  conformer breaks. Ship it as a protocol extension default, or it is a blocking finding.
- **Adding a required member to a public struct's memberwise init.** The synthesised memberwise init is
  `internal`; a `public init` is written by hand, so adding a stored property means either adding a
  defaulted parameter or breaking every caller. Check which happened.
- **Making a public method `final`**, or removing `open`, where a subclass could exist.
- **Tightening a nullability or generic constraint**, or changing a `var` to `let`.
- **Renaming a `LocalizableStringResource` key or a public asset name** — integrators override these to
  customise, so a rename silently drops their customisation. This is a real and easily-missed break.

Safe: adding a new `public` symbol, adding a defaulted parameter, adding a stored property to a
non-frozen public struct, widening a return type's optionality to non-optional, anything `internal`.

## Judging a new public symbol

`internal` is the default in Swift, so `public` was typed on purpose. Ask:

1. **Does an integrator need it?** If it exists to let a sibling module or a test reach in, it should be
   `internal` with `@testable import`, or the modules should be arranged differently. Say which.
2. **Is it the smallest thing that works?** A `public` stored `var` where a computed read-only property
   would do; a whole type exposed where a protocol would do.
3. **Does it match the module's existing entry-point shape?** Configuration goes through the
   `GiniConfiguration` / `GiniBankConfiguration` objects; SDK construction goes through a fluent
   value-type builder (`GiniBankAPI.Builder`). A new top-level `public` function beside those is a design
   question.
4. **Is it documented?** `AGENTS.md` requires `/** ... */` on declarations, with extra care for public
   API, and it is what Jazzy publishes to integrators. An undocumented new public symbol is a legitimate
   finding with a citable rule behind it.
5. **Is `GiniUtilites` the right home?** It is the one module both SDK chains depend on, so anything
   public there is public everywhere. Raise the blast radius explicitly.

## Deprecation

The practice here is thin — at the time of writing exactly **one** `@available(*, deprecated…)` exists in
the whole repo, on a method of `GiniConfiguration` in `GiniCaptureSDK`. Find the current precedent rather
than trusting a line number:

```bash
grep -rn "@available(\*, deprecated" --include="*.swift" --exclude-dir=.build .
```

It is the pattern to follow — a `message:` that names the replacement calls in the order they must be
made, not just the fact of deprecation. Hold new deprecations to that bar:

- **Never delete a public symbol in the same PR that deprecates it.** Deprecate, ship a release, remove
  in the next major. A diff that does both at once is a blocking finding.
- The `message:` must name the replacement. "Deprecated" alone is not actionable for an integrator.
- A deprecation or removal needs the affected module's documentation updated in the same PR — that is
  what integrators read when they bump the pin. **Check which file exists before asking for one:**
  `Documentation/source/Migration guide.md` exists only for **GiniBankAPILibrary** and
  **GiniHealthAPILibrary**. GiniHealthSDK has a `Documentation/source/` but no migration guide.
  GiniBankSDK and GiniCaptureSDK have neither — their only doc surface is
  `Documentation/{s,S}ections/Documentation.md`. Name the real file, or say plainly that no migration
  guide exists for this module and one should be added.
- If the removal is intentional and the version bump is a major, say so in the report and check
  `<SDK>Version.swift` and `RELEASE-ORDER.md` agree with that.

## What to write in the report

When the diff touches published surface, the report's overview should carry one plain sentence a reviewer
can act on. The shape of it — **every angle-bracketed slot comes from the PR under review; never carry a
value from this file into a report**:

> Public surface: `<Module>` gains `<declaration>` on `<Type>` (additive, safe) and changes
> `<method>` to add a defaulted parameter (source-compatible). Nothing removed. No CI check covers
> this — verified by reading the diff.

If nothing public changed, say that too: *"Public API surface unchanged — no `public`/`open` declarations
added, altered or removed."* It is short, and it is exactly what the reviewer would otherwise have to
check by hand.
