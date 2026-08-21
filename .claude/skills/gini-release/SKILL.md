---
name: gini-release
description: Guide an iOS package release end-to-end following the Mobile Release Process — create the Jira Release(s) and RC ticket in PP/HEAL, gate on QA sign-off, bump versions and create tags on main, draft GitHub releases in the mono repo + individual release repos for user review, publish only after approval, then push the podspec, publish Jira, and post to #mobile-releases. Use when asked to "release GiniBankSDK", "prepare an RC", or "publish a release" in gini-mobile-ios.
---

# /gini-release — iOS package release end-to-end

Follows the [Mobile Release Process](https://ginis.atlassian.net/wiki/spaces/PLMO/pages/83689511/Mobile+Release+Process), iOS side. The skill creates the Jira Release(s) and RC ticket, gates the release on QA, and walks the user through the version bumps, tags, and post-release publishing.

Several steps are irreversible — **never push a release tag or a podspec without explicit user confirmation.** A pushed `<Package>;<version>` tag triggers that package's release workflow, which force-pushes into its public release repo.

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

- **Which side(s)**: bank (`GiniBankAPILibrary`, `GiniUtilites`, `GiniCaptureSDK`, `GiniBankSDK`) or health (`GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`, `GiniHealthSDK`). Decides the Jira project(s) in step 2. `GiniUtilites` sits in **both** chains — infer the side from the non-Utilites entries, and only ask when `GiniUtilites` is the sole input.
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

## 2. Create the Jira Release(s) and RC ticket

Atlassian tenant: `ginis.atlassian.net`. Projects:

- **PP** (Photopayment) for `GiniBankAPILibrary`, `GiniCaptureSDK`, `GiniBankSDK`
- **HEAL** (Insurance / Health) for `GiniHealthAPILibrary`, `GiniInternalPaymentSDK`, `GiniHealthSDK`

A release spanning both sides needs entries in **both** projects. Fix versions are project-scoped — a ticket in one project cannot carry the other's version.

### 2a. Jira Releases (fix versions)

Naming convention: **`iOS Gini <Product> <version>`**, optionally with the release theme appended (`iOS Gini Bank SDK 4.4.0 QR code improvements`). The `iOS` prefix avoids collisions with the Android release of the same product.

Create one Jira release per **customer-facing product** — for a bank release that's `iOS Gini Bank SDK`, `iOS Gini Capture SDK`, `iOS Gini Bank API Library`. `GiniUtilites` and `GiniInternalPaymentSDK` still get their own git tag + GitHub release but no Jira release.

Verify which releases already exist, then create the missing ones **through the Releases page in the browser** — the Atlassian connector cannot create Jira versions, and Jira rejects an unknown `fixVersions` name. Open:

```
https://ginis.atlassian.net/projects/<KEY>?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page&status=all
```

`status=all` matters — the default filter hides released versions. Match on name; permanent `UNRELEASED` versions are kept for parking tickets.

In the `Create release` dialog: fill Release name and Description, and **clear the prefilled Release date** (defaults to today, wrong for an unshipped version — click field, `cmd+a`, `Backspace`, dismiss picker). Reload the page after creating — the table doesn't refresh, so success looks like failure. Read each version's numeric id off its table link (`/projects/<KEY>/versions/<id>/tab/…`).

Once versions exist, assign them as `fixVersions` on all work tickets in the release using `editJiraIssue` (names work here). Without fix versions the release report is empty.

Add **release notes in markdown** to each release description. These notes are reused verbatim on GitHub releases (step 7) — copy from the previous release and update.

### 2b. RC ticket

Create when the Firebase build from the release branch is ready — one ticket per side.

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
  3. `**Attachments**:` — "Build for testing can be found here:" plus the Firebase App Distribution console link and the tester-app link for the example app. **Ask the user** — these come from the CI/Firebase build.

Set the same `fixVersions` on the RC ticket. Put it in the **active sprint**: fetch a ticket in `sprint in openSprints()` with `expand: names`, find the `Sprint` custom field, set the entry whose `state` is `active`.

**Drive status via `transitionJiraIssue`** — resolve transitions per ticket by name, case-insensitively via `getTransitionsForJiraIssue`. Ids collide across projects and can silently move a ticket to `Cancelled`.

Assign the RC ticket to the QA engineer.

Report the RC ticket key — it goes in the final release commit.

## 3. Create the release candidate branch

**Always release from a `release/<theme>` branch, never from `main`.** Feature PRs for the release merge into this branch; the theme usually matches the Jira fix versions suffix (`release/qr-code-improvements`, `release/liquid_glass_bank_sdk`, `release/bank_sdk_release_4.2.2`). Ask which branch this release ships from — do not assume.

Confirm the branch is up to date with `main` before proceeding.

## 4. Wait for QA — hard gate

Stop. The RC ticket is with QA. Do not touch versions or tags. Ask the user to confirm the outcome; never infer.

- **QA passes:** proceed to step 5.
- **QA fails, showstopper:** release postponed. Add details to the RC ticket and stop.
- **QA fails, minor:** release not postponed. Create bug tickets with the release version set as `affectedVersion` and proceed once fixed.

## 5. Merge, bump versions, create tags

Version bumps and tag creation happen **together on the same commit**, on `main`, after QA sign-off.

### 5a. Merge and switch to main

Merge the release PR into `main` (or confirm it has already merged). Then switch explicitly:

```bash
git checkout main
git pull --ff-only
```

Confirm `git log -1` points at the release merge commit — `create_release_tags` tags the current `HEAD`, so an out-of-date `main` tags the wrong commit.

### 5b. Verify the XCFramework build prerequisite

Verify the branch-triggered XCFramework build workflow run for the release branch that just merged into `main` is green:

- `bank-sdk.build.xcframeworks` — if the release includes `GiniBankSDK`.
- `health-sdk.build.xcframeworks` — if the release includes `GiniHealthSDK`.

Do not proceed before the applicable workflows are green. (Step 6 later triggers a separate tag-triggered run of these same workflows to produce the archives attached to the drafts.)

### 5c. Bump versions in dependency order

For each package in `RELEASE-ORDER.md` order, edit **up to four** places. Missing any of the last three is how iOS releases break silently:

1. **The version file** — `public let <Package>Version = "<x.y.z>"` in the path from step 1's table.
2. **Every dependent's `Package-release.swift`** — bump the `.exact("<x.y.z>")` pin. PR checks only resolve `Package.swift`, not `Package-release.swift`, so a missed pin lands silently:

   ```bash
   grep -rn '\.exact(' --include='Package-release.swift' .
   ```

3. **The installation doc, where the package has one** — `Documentation/source/Installation.md` hardcodes the SPM pin. `GiniBankAPILibrary`, `GiniHealthAPILibrary`, and `GiniHealthSDK` each have one:

   ```bash
   grep -rn '\.exact(' --include='Installation.md' .
   ```

4. **Versioned Figma links in the docs**, for a Health release — `GiniHealthSDK`'s `Documentation/source/Customization guide.md` and `Integration.md` embed Figma URLs carrying the SDK version (`…/iOS-Gini-Health-SDK-6.1.0?node-id=…`). Update only the version segment; preserve every `node-id` verbatim. Find them:

   ```bash
   grep -rEn 'iOS-Gini-Health-SDK-[0-9.]+' HealthSDK/GiniHealthSDK/Documentation/
   ```

### 5d. Validate the bumps

Compile each affected package via the `AGENTS.md` gate:

```bash
make lint scheme=GiniBankSDK      # or GiniCaptureSDK, GiniHealthSDK, etc.
```

`make lint` validates **compilation only**, not style. Run swiftlint separately if there are style concerns:

```bash
swiftlint --fix BankSDK/GiniBankSDK/Sources
```

Also run unit tests for the touched packages.

### 5e. Commit and push

One commit per package, in release order:

```
feat(<Package>): Bump version to <x.y.z>

<RC-ticket-id>
```

`<Package>` is the package name (`GiniBankSDK`). Use the RC ticket of that package's side; for `GiniUtilites` in a both-sides release include both ids. Valid commit types are in `.git-stuff/commit-msg-template.txt` — use `feat`, not `feature`.

Push `main`.

### 5f. Create and push release tags

From the repo root:

```bash
bundle exec fastlane create_release_tags
```

Run this **manually in the terminal** — the lane needs an interactive prompt (`! bundle exec fastlane create_release_tags`).

- The lane scans every `**/*Version.swift`, compares each package's version against its latest `<Package>;<version>` release tag, creates a local tag for every package that differs, and prompts **"Push release tag?"** per package.
- **The lane creates the local tag before asking to push.** If a push prompt is declined, the local tag stays and the lane sees the package as up-to-date on the next run. Delete the unpushed local tag before rerunning: `git tag -d "<Package>;<version>"` (quote it — the `;` in the tag name is a shell separator otherwise).
- **Tag format is strict:** `<Package>;X.Y.Z`, or (for `GiniBankAPILibrary`, `GiniCaptureSDK`, `GiniBankSDK` only) `<Package>;X.Y.Z-betaNN` with exactly two beta digits. Beta tags for `GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`, `GiniHealthSDK` are **not** matched by their release workflows and publish nothing.
- **Each pushed tag triggers that package's release workflow**, which clones the release repo, wipes it, copies the package in with `Package-release.swift` renamed to `Package.swift`, commits, and tags. Only push when the release is truly go.
- Verify the workflows started under GitHub Actions afterwards. Each release workflow also publishes Jazzy docs as a dependent job.

## 6. Build XCFrameworks (GiniBankSDK, GiniHealthSDK)

XCFrameworks are built for both `GiniBankSDK` and `GiniHealthSDK`. Skip either sub-step if that SDK isn't in this release; jump to step 7 if neither is.

Start the XCFramework builds now so the archives are ready by the time the release drafts are reviewed. On `main`, on the commit that already carries the release tags, create and push one tag per SDK being released — creating the tag locally is not enough, only pushing it triggers the workflow:

```bash
git tag "GiniBankSDK;<X.Y.Z>;xcframeworks"
git push origin "GiniBankSDK;<X.Y.Z>;xcframeworks"

git tag "GiniHealthSDK;<X.Y.Z>;xcframeworks"
git push origin "GiniHealthSDK;<X.Y.Z>;xcframeworks"
```

Each pushed tag triggers the matching workflow (`bank-sdk.build.xcframeworks` / `health-sdk.build.xcframeworks`). Verify the runs started under GitHub Actions before moving on.

While the workflows run, prepare the archives that will be attached to the draft releases:

**GiniBankSDK** — from the `bank-sdk.build.xcframeworks` run:

1. Download the generated artifact and unzip.
2. Create an archive `GiniBankSDK_<X.Y.Z>_XCFrameworks` containing only `GiniBankSDK`, `GiniCaptureSDK`, `GiniBankAPILibrary`, `GiniUtilites`.
3. Keep it locally — it will be attached in step 7 and reused for the podspec in step 10.

**GiniHealthSDK** — from the `health-sdk.build.xcframeworks` run:

1. Download the generated artifact (uploaded as `GiniHealthSDKFramework`) and unzip.
2. Create an archive `GiniHealthSDK_<X.Y.Z>_XCFrameworks` containing only `GiniHealthSDK`, `GiniHealthAPILibrary`, `GiniInternalPaymentSDK`, `GiniUtilites`.
3. Keep it locally — it will be attached in step 7.

See the [GiniBankSDK 3.0.0 release](https://github.com/gini/gini-mobile-ios/releases/tag/GiniBankSDK%3B3.0.0) for what the final attached archive looks like.

## 7. Draft the GitHub releases

For each pushed `<Package>;<X.Y.Z>` tag, create a **draft** GitHub release. Do not publish yet — the user reviews drafts before anything goes live.

Destinations per pushed tag:

- Mono repo `gini/gini-mobile-ios` — every `<Package>;<version>` tag gets a draft here.
- Individual release repo, if the package has one: `gini/bank-api-library-ios`, `gini/capture-sdk-ios`, `gini/bank-sdk-ios`, `gini/health-api-library-ios`, `gini/internal-payment-sdk-ios`, `gini/utilites-ios`, `gini/health-sdk-ios`.

**Use the previous release of the same SDK as the template.** Fetch its notes to mirror title formatting and section structure:

```bash
gh release view "<Package>;<previous-X.Y.Z>" --repo <repo> --json name,body
```

Fill the draft body from the Jira release description markdown, following the previous release's shape. Then create the draft:

```bash
gh release create "<Package>;<X.Y.Z>" \
  --repo <repo> \
  --draft \
  --title "<title from previous release, updated>" \
  --notes-file <notes.md>
```

For `GiniBankSDK` and `GiniHealthSDK` drafts in the mono repo, also attach the matching XCFrameworks archive built in step 6:

```bash
gh release upload "GiniBankSDK;<X.Y.Z>" \
  --repo gini/gini-mobile-ios \
  GiniBankSDK_<X.Y.Z>_XCFrameworks.zip

gh release upload "GiniHealthSDK;<X.Y.Z>" \
  --repo gini/gini-mobile-ios \
  GiniHealthSDK_<X.Y.Z>_XCFrameworks.zip
```

Collect and report every draft URL — the user needs them for review.

## 8. User review — hard gate

Stop. Present the list of draft release URLs and ask the user to review each one on GitHub. **Do not publish until the user explicitly confirms all drafts look correct.** If the user requests changes to any draft, edit it (`gh release edit --notes-file …`) and re-present.

## 9. Publish the GitHub releases

Only after explicit user approval. Publish each draft:

```bash
gh release edit "<Package>;<X.Y.Z>" --repo <repo> --draft=false
```

For the mono repo, **mark `GiniBankSDK` as the latest release**:

```bash
gh release edit "GiniBankSDK;<X.Y.Z>" --repo gini/gini-mobile-ios --latest
```

## 10. Publish CocoaPods podspec (GiniBankSDK only)

Skip if `GiniBankSDK` isn't in this release.

Copy the `GiniBankSDK_<X.Y.Z>_XCFrameworks` folder from step 6 into `BankSDK/GiniBankSDK/Pod/` locally. Then, from the `gini-mobile-ios` repo root:

```bash
pod cache clean --all
bundle exec fastlane publish_podspec \
  xcframeworks_folder_path:<abs>/gini-mobile-ios/BankSDK/GiniBankSDK/Pod/GiniBankSDK_<X.Y.Z>_XCFrameworks \
  pod_name:GiniBankSDK \
  podspecs_repo_sdk_folder_path:<abs>/gini-podspecs/GiniBankSDK \
  template_podspec_path:<abs>/gini-mobile-ios/BankSDK/GiniBankSDK/Pod/GiniBankSDK.podspec
```

Placeholders to replace with real absolute paths:

- `xcframeworks_folder_path` — where you dropped the `GiniBankSDK_<X.Y.Z>_XCFrameworks` folder.
- `pod_name` — always `GiniBankSDK`.
- `podspecs_repo_sdk_folder_path` — your local checkout of `gini/gini-podspecs`, subfolder `GiniBankSDK`.
- `template_podspec_path` — the checked-in podspec template in `gini-mobile-ios`.

Example with real paths:

```bash
bundle exec fastlane publish_podspec \
  xcframeworks_folder_path:/Users/you/Workspace/gini-mobile-ios/BankSDK/GiniBankSDK/Pod/GiniBankSDK_3.7.2_XCFrameworks \
  pod_name:GiniBankSDK \
  podspecs_repo_sdk_folder_path:/Users/you/Workspace/gini-podspecs/GiniBankSDK \
  template_podspec_path:/Users/you/Workspace/gini-mobile-ios/BankSDK/GiniBankSDK/Pod/GiniBankSDK.podspec
```

The `pod cache clean --all` step is required before the lane runs; skipping it can publish a stale spec.

The lane rewrites `spec.version` from the latest release tag and pushes to `gini/gini-podspecs`. **Do not bump `spec.version` in `BankSDK/GiniBankSDK/Pod/GiniBankSDK.podspec` by hand** — the checked-in value is intentionally stale.

## 11. Publish Jira releases

1. Mark each Jira release as **Released** in PP/HEAL. Confirm the fix versions have their tickets attached and the release notes match what shipped on GitHub.
2. Move the RC ticket(s) to `Done`.
3. Create next-release placeholders — one `UNRELEASED` version per product for the upcoming cycle so incoming tickets have somewhere to land.

## 12. Post to #mobile-releases on Slack

Announce the successful release in `#mobile-releases`: which SDKs shipped, a short summary of the changes, and the TestFlight link for the example app.

## 13. Report

At the end — or when stopping at the QA gate — summarize: packages bumped with old → new versions, every `Package-release.swift` and doc file touched, Jira releases and RC ticket(s) created, commits made, lint/test results, and what checklist steps remain. **State explicitly whether any tags were pushed.**
