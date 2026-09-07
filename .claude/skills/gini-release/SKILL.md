---
name: gini-release
description: Guide an iOS package release per the Mobile Release Process, in two phases. Phase 1 (`rc`) is Jira only — confirm the release branch, dispatch the XCFramework build against it, create the Jira Releases + `x.x` placeholders, create the RC ticket with the QA build (Firebase link + QR code) and hand it to QA. Phase 2 (`release`) is git — bump versions on the release branch, open the bump PR, then behind the QA + review gate run `create_release_tags` from the release branch, build XCFrameworks, draft GitHub releases in the mono repo + individual release repos, publish after user review, push the podspec, publish Jira, merge back to main and post to #mobile-releases. Use when asked to "create the RC", "prepare the RC ticket", "get the release ready for QA", "release GiniBankSDK", "bump versions for a release", or "cut the release".
---

# /gini-release — iOS package release, in two phases

Follows the [Mobile Release Process](https://ginis.atlassian.net/wiki/spaces/PLMO/pages/83689511/Mobile+Release+Process), iOS side. A release runs in **two phases**, days apart. This skill holds both; pick one and read only that file.

| Phase | File | What it does | Invoke |
|---|---|---|---|
| 1 | [`phase-1-rc.md`](phase-1-rc.md) | **Jira only.** Confirm the release branch, dispatch the XCFramework build against it, create the Jira Releases + `x.x` placeholders, create the RC ticket with the QA build (Firebase link + QR code), sprint + hand to QA. Gets the release ready for testing. | `/gini-release rc` |
| 2 | [`phase-2-tag-and-publish.md`](phase-2-tag-and-publish.md) | **Git.** Bumps on the release branch, bump PR, then (behind QA + review gate) `create_release_tags` from the release branch, XCFrameworks, draft GitHub releases, user-review gate, publish, podspec, Jira, merge back to main, Slack. | `/gini-release`, or `/gini-release release` |

The same two-phase split is used on Android — see [PR #984](https://github.com/gini/gini-mobile-android/pull/984). Phase 1 stays close to the Android version; phase 2 is iOS-specific (XCFrameworks, podspec, `Package-release.swift` pin bumps).

## Pick the phase

Read the argument, then **read that phase's file in full and follow it**. Do not work from this table alone — the real instructions, and every hard-won gotcha, live in the phase files.

- Argument contains `rc`, `ticket`, `prepare`, `qa`, `phase 1`, `phase1` → **phase 1**, read `phase-1-rc.md`.
- Argument contains `bump`, `tag`, `release`, `publish`, `cut`, `phase 2`, `phase2`, or is a package list / version numbers → **phase 2**, read `phase-2-tag-and-publish.md`.
- **No argument, or ambiguous:** infer from what the user asked — "create the RC" / "get it ready for QA" is phase 1; "release GiniBankSDK" / "bump the versions" / "publish the release" is phase 2. If still unclear, ask which phase; never guess, because phase 2 writes commits and pushes tags.

If the user asks for the whole release in one go, explain that it cannot be one run: phase 2 needs the RC ticket from phase 1, and the tag gate needs both QA sign-off and bump-PR approval in between. Run phase 1 now, and phase 2 when QA and review are done.

## Rules that hold for both phases

- The [Mobile Release Process](https://ginis.atlassian.net/wiki/spaces/PLMO/pages/83689511/Mobile+Release+Process) Confluence page is the source of truth — read it if anything in the phase files seems out of date. `RELEASE-ORDER.md` follows the dependency graph in `CLAUDE.md`.
- Several steps are irreversible. **Never push a release tag or a podspec without explicit user confirmation in this session** — a pushed `<Package>;<version>` tag triggers that package's release workflow, which force-pushes into its public release repo.
- **The release branch already exists** (`release/<theme>`, e.g. `release/qr-code-improvements`, `release/liquid_glass_bank_sdk`). Neither phase creates it. **Always release from that branch, never from `main`.**
- Jira lives at `ginis.atlassian.net`. The Atlassian connector can read and write a ticket's `fixVersions`, but it has **no API for release versions** — reading and creating those is a browser step.
- Per-repo release-notes templates and a worked Jira → GitHub example belong in the (planned) `/gini-release-notes` companion skill. Until it exists, both phases fall back to "previous release of the same package as the template".
