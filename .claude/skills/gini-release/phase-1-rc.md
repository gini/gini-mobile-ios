# Phase 1 — prepare the release candidate (`/gini-release rc`)

A release runs in two phases:

| Phase | File | What it does |
|---|---|---|
| 1 | **this file** | Jira only: release-branch build, Jira Releases, `x.x` placeholders, RC ticket, sprint. Gets the release ready for QA testing. |
| 2 | [`phase-2-tag-and-publish.md`](phase-2-tag-and-publish.md) | Git: bumps on the release branch, `create_release_tags`, XCFrameworks, draft GitHub releases, user-review gate, publish, podspec, Jira, Slack. |

They are days apart — the RC exists so QA can start; bumps, tags and publishing only happen once QA (and the bump PR review) are done. The iOS split mirrors [Mozhgan's Android PR #984](https://github.com/gini/gini-mobile-android/pull/984); phase 1 stays close to the Android version, phase 2 is iOS-specific.

This phase is **Jira and CI-dispatch only**. It edits no `*Version.swift`, no `Package-release.swift`, no docs, makes no commit and pushes no tag. If you find yourself running `git commit` or `create_release_tags` here, you are in the wrong phase.

**Precondition:** the release branch already exists (e.g. `release/qr-code-improvements`, `release/liquid_glass_bank_sdk`). Neither phase creates it. Feature PRs for the release merge into that branch; QA tests a build made from it.

## 1. Ask for the packages and their new versions

Ask for the packages being released with their **new versions**, one per line. Example covering both chains:

```
GiniBankAPILibrary 4.4.0
GiniCaptureSDK 4.4.1
GiniBankSDK 4.4.1
GiniUtilites 2.6.0
GiniHealthAPILibrary 6.1.0
GiniInternalPaymentSDK 3.2.0
GiniHealthSDK 6.2.0
```

That list is the single input — do not walk the user through chain questions. From it, derive:

- **Which side(s)**: bank (`GiniBankAPILibrary`, `GiniUtilites`, `GiniCaptureSDK`, `GiniBankSDK`) or health (`GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`, `GiniHealthSDK`). Decides the Jira project(s) in step 5. `GiniUtilites` sits in **both** chains — infer the side from the non-Utilites entries, and only ask when `GiniUtilites` is the sole input.
- **Release order** from `RELEASE-ORDER.md`:
  - bank: `GiniBankAPILibrary` → `GiniUtilites` → `GiniCaptureSDK` → `GiniBankSDK`
  - health: `GiniHealthAPILibrary` → `GiniUtilites` → `GiniInternalPaymentSDK` → `GiniHealthSDK`

Packages, version files, release repos:

| Package | Version file | Release repo |
|---|---|---|
| `GiniBankAPILibrary` | `BankAPILibrary/GiniBankAPILibrary/Sources/GiniBankAPILibrary/GiniBankAPILibraryVersion.swift` | `gini/bank-api-library-ios` |
| `GiniHealthAPILibrary` | `HealthAPILibrary/GiniHealthAPILibrary/Sources/GiniHealthAPILibrary/GiniHealthAPILibraryVersion.swift` | `gini/health-api-library-ios` |
| `GiniUtilites` | `GiniComponents/Utilities/GiniUtilites/Sources/GiniUtilites/GiniUtilitesVersion.swift` | `gini/utilites-ios` |
| `GiniCaptureSDK` | `CaptureSDK/GiniCaptureSDK/Sources/GiniCaptureSDK/GiniCaptureSDKVersion.swift` | `gini/capture-sdk-ios` |
| `GiniInternalPaymentSDK` | `GiniComponents/InternalPaymentSDK/GiniInternalPaymentSDK/Sources/GiniInternalPaymentSDK/GiniInternalPaymentSDKVersion.swift` | `gini/internal-payment-sdk-ios` |
| `GiniBankSDK` | `BankSDK/GiniBankSDK/Sources/GiniBankSDK/GiniBankSDKVersion.swift` | `gini/bank-sdk-ios` |
| `GiniHealthSDK` | `HealthSDK/GiniHealthSDK/Sources/GiniHealthSDK/GiniHealthSDKVersion.swift` | `gini/health-sdk-ios` |

**`GiniUtilites` — one `i` in the middle.** The tag must mirror the package name exactly (`GiniUtilites;2.4.0`); the misspelling can be corrected in a future major release. `create_release_tags` derives the tag name from the `*Version.swift` filename, so a correctly-cased `Utilites` produces a matching tag.

Read the current values rather than trusting anything here:

```bash
for f in $(find . -name "*Version.swift" -not -path "*/.build/*"); do
  echo "$(basename $f | sed 's/Version.swift//') $(grep -oE '"[^"]+"' $f | tr -d '\"')"
done
```

Sanity-check and flag — don't silently fix:

- **Historically the bank chain often ships locked** — the 4.x line tagged `GiniBankSDK` and `GiniCaptureSDK` at the same number and `GiniBankAPILibrary` at the same on minor/major (but not on patches like 4.1.1, 4.2.2). This is a **pattern, not an agreement** — versions can diverge when source changes call for it. Surface the pattern if the list violates it, but don't force-align.
- **`GiniHealthSDK` regularly ships alone** (5.6.1, 6.1.0); do not "correct" a health list to match a bank pattern.
- **`GiniUtilites` and `GiniInternalPaymentSDK` have their own version lines** (2.x, 3.x) and never share the SDK numbers.
- A released package forces every dependent to at least bump its `.exact()` pin. If a dependent is missing from the list, say so.
- A new version that isn't a semver increment of the current one.
- Anything not in the table above (`GiniMerchantSDK` is archived; no Pinning packages exist).

Show a summary table (package, old → new) and get explicit confirmation before continuing.

## 2. Confirm the release branch

**Always release from a `release/<theme>` branch, never from `main`.** Feature PRs for the release merge into this branch; the theme usually matches the Jira fix-versions suffix (`release/qr-code-improvements`, `release/liquid_glass_bank_sdk`, `release/bank_sdk_release_4.2.2`).

Ask which release branch this release ships from — **do not assume**. Confirm it exists on the remote before continuing:

```bash
git fetch origin
git branch -r --list 'origin/release/*'
```

Confirm the branch is up to date with `main` (or the version branch it comes from). If it isn't, ask the user how they want to reconcile before proceeding — do not merge it yourself.

## 3. Dispatch the XCFramework build on the release branch

**Kick this off before the RC ticket** — it takes minutes to complete and its output is what the RC ticket needs to attach. Doing it first also catches XCFramework-side compile issues before QA: a red build here means QA won't have a shipping build even if the Firebase example app works.

The workflows don't auto-run on branch push — trigger via `workflow_dispatch`:

- `Build BankSDK XCFrameworks` — if the release includes `GiniBankSDK`.
- `Build HealthSDK XCFrameworks` — if the release includes `GiniHealthSDK`.

```bash
gh workflow run "Build BankSDK XCFrameworks" --ref release/<theme> --repo gini/gini-mobile-ios
gh workflow run "Build HealthSDK XCFrameworks" --ref release/<theme> --repo gini/gini-mobile-ios
```

Wait until the applicable runs finish green before continuing. Do not proceed to the RC ticket on a red build — file bugs against the release branch and get them fixed first.

Phase 2 later triggers the **same** workflows via a `<Package>;<X.Y.Z>;xcframeworks` tag push — that tag-triggered run is what produces the archives attached to the release drafts.

## 4. Which packages own a Jira Release

This matters for step 5 (fix versions) and step 6 (placeholders). Only these packages have a Jira release of their own:

| Jira project | Packages with their own Jira release |
|---|---|
| **PP** (Photopayment, bank side) | `GiniBankAPILibrary`, `GiniCaptureSDK`, `GiniBankSDK` |
| **HEAL** (Insurance, health side) | `GiniHealthAPILibrary`, `GiniHealthSDK` |

`GiniUtilites` and `GiniInternalPaymentSDK` still get their own git tag + GitHub release in phase 2, but **no Jira release** — their notes live in the parent SDK's release. Their release-notes source is defined in the (planned) `/gini-release-notes` skill; until it exists, follow the previous release of the same package as the template.

Don't take this table on faith if the release looks unusual: the project's Releases page (step 5) is the source of truth for which products have versions.

## 5. Create the Jira Releases (fix versions)

Atlassian tenant: `ginis.atlassian.net`. Bank releases live in project **PP**, Health releases in project **HEAL**. A release spanning both sides needs entries in **both** projects. Fix versions are project-scoped — a ticket in one project cannot carry the other's version.

Naming convention: **`iOS Gini <Product> <version>`**, optionally with the release theme appended (`iOS Gini Bank SDK 4.4.0 QR code improvements`). The `iOS` prefix is what stops the two platforms' releases colliding — keep it.

Create one Jira release per **customer-facing product owning notes** — for a bank release that's `iOS Gini Bank SDK`, `iOS Gini Capture SDK`, `iOS Gini Bank API Library`. Skip `GiniUtilites` and `GiniInternalPaymentSDK` (step 4).

**The Atlassian connector cannot list or create Jira release versions** — it has no version API at all, only `fixVersions` on an issue. So read the page and create anything missing **in the browser**. Jira also rejects an unknown `fixVersions` name (`Version name '…' is not valid`) instead of auto-creating it, so the version must exist first.

Open the project's Releases page:

```
https://ginis.atlassian.net/projects/<KEY>?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page&status=all
```

`status=all` matters — the default filter hides released versions. Match on **name**; permanent `UNRELEASED` placeholders are kept for parking tickets (step 6), so never take the last row.

In the `Create release` dialog: fill Release name and Description, and **clear the prefilled Release date** (defaults to today, wrong for an unshipped version — click field, `cmd+a`, `Backspace`, dismiss picker; setting an empty string via `form_input` does not work). After saving, **reload the page** — the table doesn't refresh, so success looks like failure. Don't click `Create release` twice either; the second click closes the dialog. Read each version's numeric id off its table link (`/projects/<KEY>/versions/<id>/tab/…`).

Once versions exist, assign them as `fixVersions` on all work tickets in the release using `editJiraIssue` (names work here). Without fix versions the release report is empty.

Add **release notes in markdown** to each release description. These notes are reused verbatim on GitHub releases in phase 2 — the per-repo templates and a worked Jira → GitHub example are owned by the (planned) `/gini-release-notes` skill; until it exists, copy the previous release and update.

## 6. Create the `x.x` placeholder versions for the next release

Once this release's version is claimed by the RC, tickets filed afterwards have nowhere to land. So every product that owns a Jira release also keeps one **open placeholder version** for the whole major line:

```
iOS Gini <Product> <major>.x.x
```

e.g. `iOS Gini Bank SDK 4.x.x`, `iOS Gini Capture SDK 4.x.x`, `iOS Gini APILibrary SDK 4.x.x` in PP; `iOS Gini Health API Library 6.x.x`, `iOS Gini Health SDK 6.x.x` in HEAL.

Rules:

- One per product listed in step 4 for the side(s) being released — **not** for `GiniUtilites` or `GiniInternalPaymentSDK`.
- **Create only if missing.** The placeholder lives for the whole major line and is *not* recreated every release. If `iOS Gini Bank SDK 4.x.x` already exists, leave it alone.
- `UNRELEASED`, no release date, no description needed. Created in the browser, same dialog and same gotchas as step 5.
- When a new major line starts (e.g. the first 5.0.0 release), the new placeholder is `5.x.x`; the old `4.x.x` stays until its remaining tickets are moved.
- **Do not touch** the existing `BAC - placeholder bugs` / `CVIE placeholder bugs` per-customer bug-parking versions. Different mechanism, different purpose — they are not per-product next-version placeholders and must not be renamed, reused or created by this skill.

Report which placeholders already existed and which you created.

## 7. Create the RC ticket

Create when the XCFramework build (step 3) and the Firebase build from the release branch are ready — one ticket per side.

**Start by reading the two most recent RC tickets in the target project** and match their shape:

```
project = <KEY> AND issuetype = "Release Candidate" AND summary ~ "iOS" ORDER BY created DESC
```

Fetch both results with `description`, `labels`, and `fixVersions`. Where the tickets disagree with the guidance here, the tickets win.

- **Issue type:** `Release Candidate`. Resolve by name, never by id — `10145` in PP, `11087` in HEAL, ids don't transfer across projects.
- **Title:** `[iOS] Release candidate for Gini Bank SDK <version>` or `[iOS] RC for Gini Health SDK <version>` — match the most recent ticket. Append the release theme when applicable.
- **Labels:** PP tickets carry `iOS` and `mobile`; HEAL is often unlabelled. Match the most recent ticket.
- **Description** — three sections:
  1. `**Issue Summary**` — the line "Here is the list of tickets for the release." then one `https://ginis.atlassian.net/browse/<TICKET>` link per ticket in the release. Find them with `fixVersion in ("<version-name>", …)`.
  2. `**Listed Releases**` — one Jira release-report link per fix version: `https://ginis.atlassian.net/projects/<KEY>/versions/<id>/tab/release-report-all-issues`
  3. `**Attachments**:` — "Build for testing can be found here:" plus the Firebase App Distribution console link and the tester-app link for the example app. **Ask the user** for both — they come from the CI/Firebase build.

Also attach a **QR code of the tester-app link** as an image (LLMs can generate one on request); QA scans it directly from the ticket to install the build without typing the URL. And, if the release includes `GiniBankSDK` or `GiniHealthSDK`, link the successful XCFramework workflow run(s) from step 3 so QA has a reference build for the frameworks side.

Set the same `fixVersions` on the RC ticket as on the work tickets.

## 8. Put the ticket in the active sprint and hand it to QA

A freshly created ticket has no sprint, so it appears only in the backlog and never on a board — expect to be asked why it "isn't there". The connector has no board or sprint listing tool, so derive it from an existing issue: run `project = <KEY> AND sprint in openSprints()`, fetch one result with `expand: names`, find the `customfield_*` whose name is `Sprint`. That is the field id to write; its value carries each sprint's numeric `id`, `state` and `boardId`. Take the entry whose `state` is `active` and set it on the RC ticket via `editJiraIssue`. The active sprint may belong to a board other than the project's own board, in which case the ticket legitimately won't show on the project board — point at the `boardId` from the sprint record. Note JQL against a value that doesn't exist returns an empty result set rather than an error, so "no results" never proves absence.

**Drive status via `transitionJiraIssue`** — resolve transitions per ticket by name, case-insensitively via `getTransitionsForJiraIssue`. Ids collide across projects and can silently move a ticket to `Cancelled`. Move the ticket to `In Progress`, then to `Waiting for QA` once the build links and QR code are on it.

Assign the RC ticket to the QA engineer.

## 9. Report

Summarize:

- the RC ticket key(s) created, with links — **they go into every bump commit in phase 2**
- the release branch the RC is for
- packages released, old → new
- which Jira Releases already existed and which you created, with their release-report links
- which `x.x` placeholders already existed and which you created
- the XCFramework workflow runs (green) and their links
- the sprint and status the ticket is now in
- what's attached to the RC ticket (Firebase console link, tester-app link, QR code, XCFramework run link) and what's still missing

Then state the next step explicitly: **once QA signs off and the version-bump PR is approved, run `/gini-release` (phase 2) with this RC ticket** to bump versions and push the release tags.
