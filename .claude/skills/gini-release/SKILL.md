---
name: gini-release
description: Guide an iOS package release end-to-end — ask the user for the packages with their new versions, create the Jira RC ticket(s) in PP/HEAL, bump versions plus the Package-release.swift pins and documentation in dependency order with one commit per package, then gate the tag push (tags trigger the release workflows). Use when asked to "release GiniBankSDK", "bump versions for a release", or "prepare an RC" in gini-mobile-ios.
---

# /gini-release — prepare and execute an iOS package release

`RELEASE.md` is the nominal source of truth, but it is 15 lines and **parts of it are stale** — see
"Where RELEASE.md is wrong" at the end before trusting it. This skill encodes what the repo and the
fastlane lanes actually do. It automates the local git steps, creates the Jira RC ticket(s), and walks
the user through the external steps (QA, GitHub releases, Jira).

Several steps are irreversible — **never push a release tag without explicit user confirmation in this
session.** A pushed tag immediately triggers that package's release workflow, which force-pushes the
package into its public release repo.

## 1. Ask for the packages and their new versions

Ask the user for the packages being released with their **new versions**, one per line:

```
GiniCaptureSDK 4.4.1
GiniBankSDK 4.4.1
GiniUtilites 2.6.0
```

That list is the single input — do not walk the user through chain questions. From it, determine:

- **Which side(s)**: bank (`GiniBankAPILibrary`, `GiniUtilites`, `GiniCaptureSDK`, `GiniBankSDK`) or
  health (`GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`, `GiniHealthSDK`). This
  decides the Jira project(s) in step 2. `GiniUtilites` sits in **both** chains.
- **Release order**, from `RELEASE-ORDER.md`:
  - bank: `GiniBankAPILibrary` → `GiniUtilites` → `GiniCaptureSDK` → `GiniBankSDK`
  - health: `GiniHealthAPILibrary` → `GiniUtilites` → `GiniInternalPaymentSDK` → `GiniHealthSDK`

The seven releasable packages, their version files and their release repos:

| Package | Version file | Release repo |
|---|---|---|
| `GiniBankAPILibrary` | `BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/GiniBankAPILibraryVersion.swift` | `gini/bank-api-library-ios` |
| `GiniHealthAPILibrary` | `HealthAPILibrary/GiniHealthAPILibrary/Sources/GiniHealthAPILibrary/GiniHealthAPILibraryVersion.swift` | `gini/health-api-library-ios` |
| `GiniUtilites` | `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/GiniUtilitesVersion.swift` | `gini/utilites-ios` |
| `GiniCaptureSDK` | `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/GiniCaptureSDKVersion.swift` | `gini/capture-sdk-ios` |
| `GiniInternalPaymentSDK` | `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/GiniInternalPaymentSDKVersion.swift` | `gini/internal-payment-sdk-ios` |
| `GiniBankSDK` | `BankSDK/GiniBankSDK/Sources/GiniBankSDK/GiniBankSDKVersion.swift` | `gini/bank-sdk-ios` |
| `GiniHealthSDK` | `HealthSDK/GiniHealthSDK/Sources/GiniHealthSDK/GiniHealthSDKVersion.swift` | `gini/health-sdk-ios` |

**Spell `GiniUtilites` with one `i` in the middle** — that is the real package name. Past commits and one
tag used `GiniUtilities`, and a mis-spelled tag is invisible to `create_release_tags`, which derives the
name from the `*Version.swift` filename.

Sanity-check the list against the current versions in those files and flag — don't silently fix:

- **`GiniBankSDK` and `GiniCaptureSDK` share a version number.** Every bank release in the 4.x line —
  4.0.0, 4.1.0, 4.1.1, 4.2.0, 4.2.2, 4.3.0 — tagged both at the same version. If the user lists one
  without the other, or at a different number, flag it. `GiniBankAPILibrary` joins the lock on **minor and
  major** releases (4.0.0, 4.1.0, 4.2.0, 4.3.0) but usually sits out **patches** (it has no 4.1.1 or
  4.2.2 tag).
- **The health chain is not locked.** `GiniHealthSDK` frequently releases alone (5.6.1, 6.1.0);
  `GiniHealthAPILibrary` joined only at 6.0.0. Do not "correct" a health list to match.
- **`GiniUtilites` and `GiniInternalPaymentSDK` have their own version lines** (currently 2.x and 3.x) and
  never share the SDK numbers. A list mixing them at an SDK's version is a mistake.
- A released package forces every package **above** it in its chain to at least update its
  `.exact()` pin — and since that pin change is itself a source change that has to ship, the dependent
  normally needs releasing too. If a dependent is missing from the list, say so: otherwise the pin edit
  lands on the branch and never reaches an integrator.
- A new version that isn't a semver increment of the current one.
- Anything not in the table above. `GiniMerchantSDK` is archived; there are **no Pinning packages** any
  more (see the end of this file).

Read the current values rather than trusting anything here — the numbers above are as-of-writing:

```bash
for f in $(find . -name "*Version.swift" -not -path "*/.build/*"); do
  echo "$(basename $f | sed 's/Version.swift//') $(grep -oE '"[^"]+"' $f | tr -d '\"')"
done
```

Show a summary table (package, old → new) and get explicit confirmation before creating anything.

## 2. Create the RC ticket(s) in Jira

Use the Atlassian connector, `ginis.atlassian.net`. One ticket per side — bank in project **PP**
("Banking Team"), health in **HEAL** ("Health"); a release covering both creates **two tickets**. Older
health releases carry `IPC-` ids from a since-removed project, which is why you will see
`release/IPC-789-…` branches in the history.

**Start by reading the two most recent RC tickets in the target project and matching their shape** — that
is what keeps this step correct as conventions drift, and it beats anything written below:

```
project = <KEY> AND issuetype = "Release Candidate" AND summary ~ "iOS" ORDER BY created DESC
```

Fetch the top result with its `description`, `labels` and `fixVersions`. Where it disagrees with the
guidance here, the ticket wins — and mention the difference so this file can be corrected.

- **Issue type:** `Release Candidate`. **Resolve it by name, never by id** — it is `10145` in PP and
  `11087` in HEAL, and ids do not transfer between projects.
- **Title:** `[iOS] Release candidate for Gini Bank SDK <version>` /
  `[iOS] RC for Gini Health SDK <version>`. Both spellings are in use; match the most recent ticket in
  that project. The version is the **main SDK's** new version. Where the release has a theme, recent
  tickets append it (e.g. `… 4.2.0 CX (Cross-border Payment)`) — ask the user rather than inventing one.
- **Labels:** recent PP tickets carry `iOS` and `mobile`; HEAL tickets are often unlabelled. Match the
  most recent ticket in the target project.
- **Description** — the iOS shape is simpler than Android's. Three sections, built from the tickets that
  share this release's fix versions, not from your reading of the diffs:

  1. `**Issue Summary**` — the line "Here is the list of tickets for the release." then one
     `https://ginis.atlassian.net/browse/<TICKET-KEY>` link per ticket (PP tickets are numbered, HEAL
     tickets are usually a plain list). A short trailing note on a link is normal where a ticket picked up
     an extra fix. Find the tickets with `fixVersion in ("<version-name>", …)`.
  2. `**Listed Releases**` — one Jira release-report link per fix version:
     `https://ginis.atlassian.net/projects/<KEY>/versions/<version-id>/tab/release-report-all-issues`
  3. `**Attachments**:` — "Build for testing can be found here:" plus the Firebase App Distribution
     console link and the tester-app link for the example app. **Ask the user for these** — they come from
     the CI/Firebase build and cannot be generated here.

  There is no "Modules released" or "Scope of testing" section in current iOS tickets. Don't add one
  unless the user asks.

**Check the Jira releases (fix versions) exist and create the missing ones.** These track the
**customer-facing products**, not every tagged package — the 4.4.0 bank release carried exactly three
(`iOS Gini Bank SDK`, `iOS Gini Capture SDK`, `iOS Gini Bank API Library`) and none for `GiniUtilites`,
even though Utilites gets its own git tag and GitHub release. Naming is `iOS Gini <Product> <version>`,
optionally with the release theme appended — e.g. `iOS Gini Bank SDK 4.4.0 QR code improvements`.
**Keep the `iOS` prefix** so the version does not collide with the Android release of the same product.

Note the two projects are inconsistent here: recent PP tickets carry their fix versions properly, while
some HEAL RC tickets have **none set at all** and only link the release report from the description. Set
them anyway — without them the release report is empty — but don't treat a past HEAL ticket's empty field
as the convention.

Open the project's Releases page at
`https://ginis.atlassian.net/projects/<KEY>?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page&status=all`
— `status=all` matters, the default filter hides released versions. Match on **name**, not the last row:
permanent placeholder `UNRELEASED` versions are kept for parking tickets.

Missing versions must be created **through that page in the browser** — the connector has no tool for
creating Jira versions, and Jira rejects an unknown `fixVersions` name (`Version name '…' is not valid`)
rather than auto-creating it. In the `Create release` dialog: fill Release name and Description, and
**clear the prefilled Release date** — it defaults to today, which is wrong for an unshipped version.
Clear it by clicking the field, `cmd+a`, `Backspace`, then click the dialog heading to dismiss the picker;
setting an empty string via `form_input` does not work. Don't click `Create release` twice — the second
click closes the dialog. **Reload the page afterwards**; the table does not refresh, so a success looks
like a failure. Read each version's numeric id off its table link (`/projects/<KEY>/versions/<id>/tab/…`).

Once the versions exist, set them as `fixVersions` on the RC ticket with `editJiraIssue` — names work at
that point. Do the same on the work tickets in this release, or the release report comes back empty. Fix
versions are **project-scoped**: a ticket in another project cannot carry this project's version.

**Put the ticket in the active sprint.** A fresh ticket has no sprint, so it sits in the backlog and never
appears on a board. The connector has no sprint-listing tool, so derive it: run
`project = <KEY> AND sprint in openSprints()`, fetch one result with `expand: names`, find the
`customfield_*` named `Sprint`, and set the entry whose `state` is `active`. The active sprint may belong
to a board other than the project's own — if so the ticket legitimately won't show on the project board;
point at the `boardId` from the sprint record. JQL against a non-existent value returns an empty result
rather than an error, so "no results" never proves absence.

**Drive the ticket's status yourself.** Move it to `In Progress` when the bumps start and to the
waiting-for-QA status at the step 5 gate, via `transitionJiraIssue`. **Resolve transitions per ticket by
name, case-insensitively** — call `getTransitionsForJiraIssue` on the actual ticket; the same status is
spelled differently between the two projects, and ids collide across projects, so a copied id can silently
move a ticket to `Cancelled`.

Report the created ticket key(s) — they go in every bump commit.

## 3. Pick the branch

`RELEASE.md` says to be on `main`. **In practice most releases happen on a long-lived
`release/<theme>` branch** that feature PRs have been merged into — e.g. `release/qr-code-improvements`,
`release/liquid_glass_bank_sdk`, `release/bank_sdk_release_4.2.2`. Naming is not standardised, and the
theme usually matches the suffix on the Jira fix versions.

So **ask which branch this release ships from**; do not assume. Two cases:

- **An existing `release/<theme>` branch** — the normal case when the release has a theme. Confirm it is
  up to date with `main` before bumping.
- **`main` directly** — for a patch release with no integration branch.

Do not invent an Android-style `PP-XXX-RC-…` branch; that convention does not exist in this repo.

## 4. Bump versions, one commit per package, in release order

For each package in the confirmed set, in `RELEASE-ORDER.md` order, edit **up to four** places. Missing
any of the last three is the most common way an iOS release breaks:

1. **The version file** — `public let <Package>Version = "<x.y.z>"` in the path from the step 1 table.
2. **Every dependent's `Package-release.swift`** — bump the `.exact("<x.y.z>")` pin that points at the
   package you just bumped. This is the step with no Android analogue and the one that breaks the release
   build when skipped, because the PR checks only resolve the local `Package.swift`. Find every pin:

   ```bash
   grep -rn '\.exact(' --include='Package-release.swift' .
   ```

3. **The installation doc, where the package has one** — `Documentation/source/Installation.md` hardcodes
   the SPM pin, e.g.
   `.package(url: "https://github.com/gini/bank-api-library-ios.git", .exact("4.3.0"))`. Only
   `GiniBankAPILibrary` and `GiniHealthAPILibrary` carry this today; verify rather than assume:

   ```bash
   grep -rn '\.exact(' --include='*.md' */*/Documentation/
   ```

4. **Versioned Figma links in the docs**, for a Health release — `GiniHealthSDK`'s
   `Documentation/source/Customization guide.md` and `Integration.md` embed Figma URLs carrying the SDK
   version (`…/iOS-Gini-Health-SDK-6.1.0?node-id=…`). Use the **`/update-figma-links`** skill in this repo
   rather than hand-editing; the node-ids differ per section and a naive find-and-replace corrupts them.

Then commit per package:

```
feat(<Package>): Bump version to <x.y.z>

<RC-ticket-id>
```

`<Package>` is the package name (`GiniBankSDK`). Use the ticket of that package's side; for
`GiniUtilites` in a both-sides release include both ticket ids. The valid `type` values live in
`.git-stuff/commit-msg-template.txt` — note the history contains `feature(...)`, which is **not** valid;
use `feat`.

Then run `make lint scheme=<Scheme>` for each affected package (the `AGENTS.md` gate) plus the touched
packages' unit tests, and push the branch. **No tags yet.**

If the release ships from a `release/<theme>` branch, open the PR into `main` now — the bumps merge like
any other change, and tags are created after that lands.

## 5. Wait for QA — hard gate

Stop here. Tags may only be created after QA signs the RC ticket off and assigns it back. Ask the user to
confirm; never infer it. The Firebase build QA tests is the one linked in the RC ticket.

## 6. Create and push release tags

```bash
bundle exec fastlane create_release_tags
```

The lane needs no arguments: it scans every `**/*Version.swift`, compares each package's version against
its latest `<Package>;<version>` release tag, and creates a tag for every package that differs —
prompting **"Push release tag?"** per package. It needs a terminal for those prompts, so suggest the user
runs it themselves (`! bundle exec fastlane create_release_tags`).

- Tag format is strict: `<Package>;X.Y.Z`, or `<Package>;X.Y.Z-betaNN` with **exactly two** beta digits.
  Anything else is ignored by the release workflows.
- **Each pushed tag immediately triggers that package's release workflow**, which runs the package's
  checks, then clones the release repo, wipes it, copies the package in with `Package-release.swift`
  renamed to `Package.swift`, commits and tags it. Only push when the release is truly go.
- Verify the workflows started under GitHub Actions afterwards. The release workflow also publishes that
  package's Jazzy documentation as a dependent job.

**XCFramework builds are separate and not part of this.** The `build-xcframeworks` job is commented out in
`bank-sdk.release.yml`; XCFrameworks are produced by pushing a `<Package>;<version>;xcframeworks` tag or
by manual dispatch. Only do this if the user asks.

## 7. Post-tag checklist — external, walk the user through it

1. **GitHub releases** — one per released package, on **its own release repo** (e.g.
   `github.com/gini/bank-sdk-ios/releases`), not on `gini-mobile-ios`. **All seven repos publish releases**,
   including `utilites-ios` and `internal-payment-sdk-ios`, so do not skip a package for being
   "internal" — unlike Jira fix versions, which only cover the customer-facing products. Use the markdown
   release notes from the Jira release description.
2. **Jira** — confirm each release has its tickets connected via "Fix versions" and notes in the
   description, then publish the releases in PP/HEAL.
3. **Docs** — the release workflow publishes Jazzy automatically. A **documentation-only** change between
   versions is released separately with `bundle exec fastlane create_documentation_release_tags`, which
   tags `<Package>;<version>;doc-<n>`.
4. **CocoaPods** — only `GiniBankSDK` has a podspec, and **no workflow publishes it**. It is a manual
   `bundle exec fastlane publish_podspec` that requires the XCFrameworks from step 6's note and pushes to
   `gini/gini-podspecs`. Do not bump `spec.version` in `BankSDK/GiniBankSDK/Pod/GiniBankSDK.podspec` by
   hand — the lane rewrites it from the latest release tag, which is why the checked-in value is stale.
5. Move the RC ticket(s) to `Done`, and merge the release branch into `main` if that has not happened yet.

## 8. Report

At the end — or when stopping at the QA gate — summarize: packages bumped with old → new versions, every
`Package-release.swift` and doc file touched, RC ticket(s) created, commits made, what the lint/tests
said, and which checklist steps remain. **State explicitly whether any tags were pushed.**

## Where RELEASE.md is wrong

Cite `RELEASE.md` for the shape of the process, but know these gaps — fix the file if the team agrees
rather than working around it every release:

- **"don't forget to update also extended package with Pinning!"** — there are no Pinning packages. No
  `Package.swift` declares one and no `*Pinning*Version.swift` exists; SSL pinning is now a source folder
  (`Sources/<Package>/SSLPinning/`) inside the main packages. The `ignored_packages = [/\/.+Pinning\//]`
  rule in `create_release_tags`, the `GiniBankSDKPinning` comment in `bank-sdk.check.yml`, and the
  `capture-sdk-pinning-ios` repo reference are all vestigial.
- **"Make sure you are on the `main` branch" / "Commit and push the changes to `main`"** — most releases
  actually run from a `release/<theme>` branch and reach `main` by PR. See step 3.
- **It does not mention `RELEASE-ORDER.md` being hand-maintained.** Unlike Android, where the equivalent
  file is generated by a Gradle task and must never be edited manually, **iOS's `RELEASE-ORDER.md` has no
  generator** — if a dependency changes, edit it by hand in the same commit.
- **It says "documentation file" without saying which.** It is `Documentation/source/Installation.md`, and
  only two packages have one. See step 4.3.
