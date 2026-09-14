# Phase 2 — bump, tag and publish the release (`/gini-release`)

A release runs in two phases:

| Phase | File | What it does |
|---|---|---|
| 1 | [`phase-1-rc.md`](phase-1-rc.md) | Jira only: release-branch build, Jira Releases, `x.x` placeholders, RC ticket, sprint. Gets the release ready for QA testing. |
| 2 | **this file** | Git: bumps on the release branch, `create_release_tags`, XCFrameworks, draft GitHub releases, user-review gate, publish, podspec, Jira, TestFlight upload, Slack. |

This phase is iOS-specific (Android's phase 2 uses `gradle.properties` and Sonatype instead).

Several steps are irreversible. **Never push a release tag or a podspec without explicit user confirmation in this session.** A pushed `<Package>;<version>` tag triggers that package's release workflow, which force-pushes into its public release repo. A pushed podspec goes to `gini/gini-podspecs` and is immediately fetched by CocoaPods users.

## 0. Take the RC ticket as input

Ask for the RC ticket key from phase 1 (e.g. `PP-1234`, or two keys for a "both" release). From the ticket, read back:

- the packages released and their new versions ("Modules released" or "Issue Summary" area)
- the release branch this RC is for
- the fix-version names — the same names get reused in the GitHub release drafts

If there is no RC ticket yet, stop and run `/gini-release rc` (phase 1) first — the bump commits must carry the RC ticket id, so there is nothing to commit without it.

Re-check the package list against the current `*Version.swift` values before touching anything, and flag (don't silently fix) anything that has drifted since the RC was created.

Show the package / old → new table and get explicit confirmation before the first commit.

## 1. Wait for QA and RC approval — hard gate

Stop. Tags may only be created once **both**:

1. QA has signed off on the RC ticket (it comes back to the user in Jira), and
2. the version-bump PR (opened in step 4 below) has been approved by a reviewer.

If the bump PR hasn't been opened yet, treat this as two sub-gates: QA sign-off before starting the bumps, then reviewer approval before pushing tags.

Ask the user to confirm each; **never infer**. A tag pushed early triggers a real release.

QA-failure paths:

- **Showstopper:** release postponed. Add details to the RC ticket and stop.
- **Minor:** release not postponed. Create bug tickets with the release version set as `affectedVersion` and proceed once fixed.

## 2. Bump versions on the release branch, in dependency order

**Do the bumps on the release branch, not on `main`.** The release branch is where a failing release can be fixed without touching main; `create_release_tags` will run from here in step 5. Merging into main happens in step 13, after the release ships.

```bash
git fetch origin
git checkout release/<theme>
git pull --ff-only
```

For each package in `RELEASE-ORDER.md` order, edit **up to five** places. Missing any of the last four is how iOS releases break silently:

1. **The version file** — `public let <Package>Version = "<x.y.z>"` in the path from phase 1's table.
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

5. **Doc URLs with tag paths, and hardcoded version strings in tests** — READMEs, Jazzy docs and example-app links point into GitHub with `<Package>;<x.y.z>` in the path, and a few tests hardcode the current library version. Both are easy to miss and only fail when someone follows the link or reads the assertion. Some of these have been drifting for major releases — `BankSDK/GiniBankSDK/README.md` still points at `GiniBankSDK;3.3.0` — so this step needs a real grep, not a checklist.

   Run a package-scoped grep for the **current** version *before* you bump the version file — the tag-path links use the version being released, not the previous one, so grep the current value and update per hit:

   ```bash
   git grep -nE '(%3B|;)<current-x.y.z>' -- <package-root>/ ':(exclude)*.pbxproj'
   git grep -nE '"<current-x.y.z>"' -- <package-root>/'*.swift'
   ```

   Known spots to double-check (non-exhaustive — grep is the source of truth):

   - `BankAPILibrary/GiniBankAPILibrary/Documentation/source/Getting started.md` — sample-test-case link of the form `.../gini/gini-mobile-ios/blob/GiniBankAPILibrary%3B<x.y.z>/...`.
   - `BankSDK/GiniBankSDK/README.md` — example-app + `Credentials.plist` links of the form `.../GiniBankSDK%3B<x.y.z>/...` (this file has drifted several majors in the past — verify it moves).
   - `BankAPILibrary/GiniBankAPILibrary/Tests/GiniBankAPILibraryTests/DocumentServiceTests.swift` — `apiLibVersion: "<x.y.z>"` inside `testLogErrorEvent`.

## 3. Validate the bumps

Compile each affected package via the `AGENTS.md` gate:

```bash
make lint scheme=GiniBankSDK      # or GiniCaptureSDK, GiniHealthSDK, etc.
```

`make lint` validates **compilation only**, not style. Lint and unit tests run on the bump PR (step 4) — do not run them here.

## 4. Commit, push and open the bump PR

One commit per package, in release order:

```
feat(<Package>): Bump version to <x.y.z>

<RC-ticket-id>
```

`<Package>` is the package name (`GiniBankSDK`). Use the RC ticket of that package's side; for `GiniUtilites` in a both-sides release include both ids. Valid commit types are in `.git-stuff/commit-msg-template.txt` — use `feat`, not `feature`.

Push the release branch (no tags yet), then open a PR from it (or from an RC branch cut off it) **into the branch it came from** — usually `main`, or the version branch that carries the older major line. Follow the PR-description rules in `AGENTS.md`.

**Ask the user which reviewer to assign** — do not guess. The bump is not self-reviewed; approval on this PR is one of the two gates in step 1.

**Then stop and exit.** There is no background waiting or polling — report the open PR link plus what's still pending (bump PR approval, QA sign-off if still open), and end the session. The user resumes phase 2 by re-invoking the skill (`/gini-release <RC-ticket>`) once the PR is approved; on resume, re-confirm both gates in step 1 before continuing to step 5.

## 5. Create and push release tags — from the release branch

From the repo root, on the release branch:

```bash
git checkout release/<theme>
git pull --ff-only          # pick up the approved bump commits
bundle exec fastlane create_release_tags
```

Run the lane **manually in the terminal** — it needs an interactive prompt (`! bundle exec fastlane create_release_tags`).

- **Run this from the release branch, not from `main`.** If a release starts crashing or a tag needs re-cutting, the fix goes into the release branch first; running the lane from main puts a tag on a commit that may not yet be reachable from a hotfix-able branch.
- The lane scans every `**/*Version.swift`, compares each package's version against its latest `<Package>;<version>` release tag, creates a local tag for every package that differs, and prompts **"Push release tag?"** per package.
- **The lane creates the local tag before asking to push.** If a push prompt is declined, the local tag stays and the lane sees the package as up-to-date on the next run. Delete the unpushed local tag before rerunning: `git tag -d "<Package>;<version>"` (quote it — the `;` in the tag name is a shell separator otherwise).
- **Tag format is strict:** `<Package>;X.Y.Z`, or (for `GiniBankAPILibrary`, `GiniCaptureSDK`, `GiniBankSDK` only) `<Package>;X.Y.Z-betaNN` with exactly two beta digits. Beta tags for `GiniHealthAPILibrary`, `GiniUtilites`, `GiniInternalPaymentSDK`, `GiniHealthSDK` are **not** matched by their release workflows and publish nothing.
- **Each pushed tag triggers that package's release workflow**, which clones the release repo, wipes it, copies the package in with `Package-release.swift` renamed to `Package.swift`, commits, and tags. Only push when the release is truly go.
- Verify the workflows started under GitHub Actions afterwards. Each release workflow also publishes Jazzy docs as a dependent job.

## 6. Build XCFrameworks (GiniBankSDK, GiniHealthSDK)

XCFrameworks are built for both `GiniBankSDK` and `GiniHealthSDK`. Skip either sub-step if that SDK isn't in this release; jump to step 7 if neither is.

Start the XCFramework builds now so the archives are ready by the time the release drafts are reviewed. On the release branch, on the commit that already carries the release tags, create and push one tag per SDK being released — creating the tag locally is not enough, only pushing it triggers the workflow:

```bash
git tag "GiniBankSDK;<X.Y.Z>;xcframeworks"
git push origin "GiniBankSDK;<X.Y.Z>;xcframeworks"

git tag "GiniHealthSDK;<X.Y.Z>;xcframeworks"
git push origin "GiniHealthSDK;<X.Y.Z>;xcframeworks"
```

Each pushed tag triggers the matching workflow (`bank-sdk.build.xcframeworks` / `health-sdk.build.xcframeworks`). **Wait until both runs finish successfully** under GitHub Actions before continuing — the generated artifacts feed the archive prep below and the draft attachments in step 7.

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

> **Release-notes content** — this skill covers the release *flow*. Per-repo release-notes templates **and a worked Jira → GitHub example** are owned by the (planned) `/gini-release-notes` skill. Until it exists, use the previous release as a template per the pattern below.

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

For the mono repo, **mark `GiniBankSDK` as the latest release** (only when `GiniBankSDK` is in this release):

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

## 11. Publish Jira releases and close out the RC

1. Mark each Jira release as **Released** in PP/HEAL. Confirm the fix versions have their tickets attached and the release notes match what shipped on GitHub.
2. Move the RC ticket(s) to `Done`.
3. The `<major>.x.x` placeholder versions created in phase 1 stay `UNRELEASED` — **never publish those**. They only get retired when a new major line starts.

## 12. Upload the example app(s) to TestFlight

The Slack announcement in step 13 links to a TestFlight build. Both example-app upload workflows run on a quarterly cron (2nd Monday of Feb, May, Aug, Nov at 09:00 UTC), but that cadence rarely lines up with a release — so trigger them manually now to make sure the announcement points at a build that actually contains the version you just shipped. Both workflows accept `workflow_dispatch`:

- [`bank-sdk.publish.example.app.testflight.yml`](https://github.com/gini/gini-mobile-ios/actions/workflows/bank-sdk.publish.example.app.testflight.yml) — uploads `GiniBankSDKExample`. Skip if `GiniBankSDK` isn't in this release.
- [`health-sdk.publish.example.app.testflight.yml`](https://github.com/gini/gini-mobile-ios/actions/workflows/health-sdk.publish.example.app.testflight.yml) — uploads `GiniHealthSDKExample`. Skip if `GiniHealthSDK` isn't in this release.

Trigger from `main` (or the branch being announced), then wait for both applicable runs to finish green under GitHub Actions before announcing:

```bash
gh workflow run bank-sdk.publish.example.app.testflight.yml --ref main --repo gini/gini-mobile-ios
gh workflow run health-sdk.publish.example.app.testflight.yml --ref main --repo gini/gini-mobile-ios
```

Apple's TestFlight processing takes a few extra minutes on their side after the workflow completes; the tester-facing URL is stable across builds, so it's safe to include it in the announcement even if the new build hasn't fully processed yet — testers will see it as soon as processing finishes.

## 13. Merge the release branch back and post to Slack

1. Merge the release branch into `main` (or the version branch it was cut from), following the repo's normal PR flow.
2. Announce the successful release in `#mobile-releases`. Follow the template below — derived from the Bank SDK 4.5.0 announcement — so the message stays scannable and consistent with prior releases.

**Slack message template**

Fill every angle-bracketed slot from the release. The TestFlight join URL is stable across builds, so include it even if Apple's TestFlight processing hasn't finished yet — testers see the new build the moment processing completes.

```
Happy <day of week>! :<light-celebratory-emoji>:
<platform> <SDK product name> <version> is live

 What's new

 • <Feature 1 name> — <one sentence: what it does + why + opt-in / default-on / default-off>.
<Confluence deep link to that feature's section>
 • <Feature 2 name> — <one sentence>.
<Confluence deep link>
 • <Bug fix or infra note — no link needed if there's no dedicated page>.

 Docs — <top-level Confluence overview URL for this SDK's space>
 Release notes — <release-repo tag URL for customer-facing SDK #1> · <release-repo tag URL for customer-facing SDK #2>
<install-tester-build sentence — see platform-specific guidance below>
```

**How to fill it**

- **`<platform>`:** `iOS` when this skill runs — because this file lives in the iOS repo. The Android release skill mirrors this template with `Android` in the same slot; posting in `#mobile-releases` needs the prefix so readers know which platform they're seeing.
- **Feature bullets:** source from the GitHub release notes for the top-level SDK; each bullet is a rephrased single-sentence version, not a copy-paste. Always name the opt-in/default state — that is the single most important piece for integrators.
- **Confluence deep links:** pull from the Jira release description, or from the per-feature Jira tickets under Documentation. Skip the link when the bullet is a bug fix.
- **Release notes:** one GitHub tag URL per **customer-facing** SDK that shipped (not `GiniUtilites` or `GiniInternalPaymentSDK`). Separate multiple URLs with ` · `.
- **Install-tester-build sentence — iOS:** `Testflight build <TestFlight join URL> to play with it` followed on a new line by `or directly scan the QR code.` The TestFlight join URL is per-example-app and stable across releases — reuse the value from the previous announcement rather than searching for a new one; you triggered the actual build in step 12.
- **QR code:** generate a QR image encoding the same TestFlight join URL and attach it to the Slack message so readers can install without copy-pasting on device. Any LLM can produce the image on request.

**Both-side releases:** if both Bank and Health SDKs shipped, post two separate messages (one per SDK) rather than merging them — each has its own TestFlight app, docs space and release-notes URLs, and readers subscribe by product.

## 14. Report

At the end — or when stopping at the QA gate — summarize: packages bumped with old → new versions, every `Package-release.swift` and doc file touched, Jira releases and RC ticket(s) closed, commits made, lint/test results, and what checklist steps remain. **State explicitly whether any tags were pushed.**
