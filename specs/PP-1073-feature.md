# PP-1073: [iOS] Switch to use swift files & env file for credentials in GiniBankSDK

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-1073
Parent epic: PP-1811 "iOS Tech debt and improvements"
Sibling: PP-3923 (Health mirror)
Branch: `chore/env-credentials` off `main`

## Problem

The three Bank example app targets ship hand-edited credential files
(`Credentials.plist` × 2, hardcoded Swift globals × 1) that every developer
modifies in place with real values. Because the files are tracked, a
careless `git add -u` or `git add .` can sweep real credentials into a
commit — and once pushed, they are on the remote even if later force-
removed. There is no safety net at the git layer today.

PP-1073 moves credentials to `BankSDK/GiniBankSDKExample/.env.local` — a
per-project, gitignored file — read at build time by a script that
regenerates `Credentials.swift` into a gitignored `Generated/` directory
on every build. `GoogleService-Info.plist` stays tracked with an empty
`API_KEY`; the real key gets injected into the built `.app`'s copy via
`plutil -replace`, so the source-tree plist never carries a secret. A
tracked pre-commit hook refuses commits that stage protected paths as a
belt-and-suspenders backstop.

Public SDK API is untouched. All work is example-app and tooling.

## Requirements

Numbered contract. Each MUST ties to a named check in the Testing section.

- **R1 (MUST, happy).** Given `BankSDK/GiniBankSDKExample/.env.local` has
  `GINI_CLIENT_ID`, `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`,
  `FIREBASE_API_KEY` populated (CX + stage optional), when any of the 3
  Bank targets is built, then `BankSDK/GiniBankSDKExample/Generated/Credentials.swift`
  is written with those values as `enum Credentials { static let … }`.
- **R2 (MUST, entry).** The 3 `CredentialsManager.swift` files consume
  `Credentials.<key>`. `fetchClientFromBundle()` / `fetchCXClientFromBundle()`
  / `fetchStageClientFromBundle()` return `Client(id:secret:domain:)` from
  the enum. The SwiftUI target's 3 globals re-export the enum values.
- **R3 (MUST, error — missing file).** Build fails non-zero with
  `error: .env.local not found at …` if the file is absent.
- **R4 (MUST, error — missing required key).** Build fails non-zero and
  stderr names every missing required key.
- **R5 (MUST, Firebase).** When the Firebase API_KEY env value is present,
  the built `.app`'s `GoogleService-Info.plist` has `API_KEY` replaced with
  the env value. All other plist fields and the source-tree plist are
  byte-unchanged.
- **R6 (MUST, hook).** With `git config core.hooksPath .githooks` set, a
  commit staging `BankSDK/GiniBankSDKExample/.env.local` or either of the
  removed `Credentials.plist` paths is rejected non-zero.
- **R7 (MUST, CI).** The 2 TestFlight workflows + Firebase workflow build
  green with existing GitHub Secrets via a rewritten `Setup .env.local`
  step. Health's reusable-workflow callers keep working unchanged via the
  legacy `credentials_plist_path` / `credentials_manager_path` /
  `google_services_plist_path` branches.
- **R8 (MUST, no public API).** No `public`/`open` declaration in any
  shipping SPM product is added, altered or removed.
- **R9 (SHOULD, onboarding).** Repo-root `README.md` documents the setup
  (`cp .env.example .env.local`, fill values, `git config core.hooksPath
  .githooks`, bootstrap, build).

## Resolved design decisions

- **Env file**: per-project at `BankSDK/GiniBankSDKExample/.env.local`
  (next to the Xcode project). Not repo root. PP-3923 adds Health's at
  `HealthSDK/GiniHealthSDKExample/.env.local`. All 3 Bank targets share
  the same `SRCROOT` and therefore the same `.env.local`.
- **Required vs optional keys**: `GINI_CLIENT_ID`, `GINI_CLIENT_PASSWORD`,
  `GINI_CLIENT_DOMAIN`, `FIREBASE_API_KEY` are **required** (build fails
  non-zero without them). `GINI_CX_CLIENT_ID`/`PASSWORD` and
  `GINI_STAGE_CLIENT_ID`/`PASSWORD` are **optional** (empty values
  accepted; the corresponding Settings toggle 401s silently at runtime,
  by the user's explicit "no louder signals" decision).
- **Generated file location**: `$SRCROOT/Generated/Credentials.swift`
  (deviation from the first draft that used `$DERIVED_FILE_DIR`). The
  directory is gitignored. All 3 targets share one generated file.
- **Firebase**: tracked `GoogleService-Info.plist` has empty `API_KEY`
  forever. Build-phase script runs `plutil -replace API_KEY -string …`
  on `$BUILT_PRODUCTS_DIR/<TARGET>.app/GoogleService-Info.plist` after
  Copy Bundle Resources. Source-tree plist never mutated.
- **Xcode build phases**: two per target.
  (1) *Generate Credentials.swift* runs before Compile Sources — writes
  the Swift file, skips plist injection (plist not copied yet).
  (2) *Inject Firebase API_KEY* runs after Copy Bundle Resources — same
  script, idempotent, injects API_KEY. `ENABLE_USER_SCRIPT_SANDBOXING =
  NO` set on each target so the pre-compile phase can write to the
  source tree.
- **CI shape**: Option B (per-key secrets on the reusable workflow). New
  `use_env_local: boolean` input opts a caller into the new path; legacy
  `credentials_plist_path` / `credentials_manager_path` /
  `google_services_plist_path` branches stay intact for Health.
- **Pre-commit hook**: tracked at `.githooks/pre-commit`. Activated per
  clone via `git config core.hooksPath .githooks`. Documented in README.

## Affected files

| Scope | File | Change |
| --- | --- | --- |
| New | `BankSDK/GiniBankSDKExample/.env.example` | 8-key template, tracked |
| New | `scripts/generate_credentials.sh` | Generator; reads env, writes Swift, injects API_KEY |
| New | `scripts/test_generate_credentials.sh` | 7 shell test cases |
| New | `scripts/test_pre_commit_hook.sh` | 4 shell test cases |
| New | `.githooks/pre-commit` | Rejects protected paths |
| New | `BankSDK/GiniBankSDKExample/Tests/UnitTests/CredentialsSmokeTests.swift` | 3 XCTest cases |
| New | `specs/PP-1073-feature.md` | This file |
| Rewritten | `BankSDK/GiniBankSDKExample/GiniBankSDKExample/CredentialsManager.swift` | Consumes `Credentials.*` enum |
| Rewritten | `BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Helpers/CredentialsManager.swift` | Same |
| Rewritten | `BankSDK/GiniBankSDKExample/GiniBankSDKExampleSwiftUI/CredentialsManager.swift` | Re-exports enum |
| Modified | `BankSDK/GiniBankSDKExample/GiniBankSDKExample.xcodeproj/project.pbxproj` | 2 Run Script phases × 3 targets + file ref + sandboxing off |
| Modified | `.gitignore` | Add `.env.local` + `Generated/` + 2 Credentials.plist paths |
| Modified | `README.md` | Credentials setup section |
| Modified | 4 workflows | Rewrite credential-injection steps |
| Deleted | `BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist` | — |
| Deleted | `BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist` | — |

Example app code outside `CredentialsManager.swift` and the SDK itself
are untouched. Health is out of scope (PP-3923).

## Testing

| Test | Where | Covers |
| --- | --- | --- |
| 7 shell cases, 19 assertions | `scripts/test_generate_credentials.sh` | R1, R3, R4, R5 |
| 4 shell cases, 8 assertions | `scripts/test_pre_commit_hook.sh` | R6 |
| 3 XCTest cases | `CredentialsSmokeTests` | R1, R2 |
| 3 target builds | `xcodebuild build` on each of the Bank example targets | R1, R2, R5 end-to-end |
| CI | GitHub Actions on push | R7 |

**Verification results**: shell 19/19 + 8/8 + 3/3 Swift smoke + 3/3 target
builds + 4/4 workflow YAMLs parse. `make lint` skipped — local Ruby/bundler
mismatch, CI runs it on push.

**Not tested**: Xcode's build-phase ordering (no automated harness
exists). CI YAML runtime (will land on merge). Firebase SDK's own
behavior with an injected `API_KEY` (framework-level).

## Rollout

This PR has no runtime dependency. PP-3923 (Health sibling) depends on
this PR's `.env.local` schema. On merge, team devs need to run the
one-time setup documented in README.

## Out of scope

- Health SDK example app (PP-3923).
- Removing the Cross-border Settings toggle (separate ticket if desired).
- Rotating any credentials that may have been exposed through the old
  tracked-file pattern — Ops task.
- Google Cloud Console API-key restrictions — Ops task.
- Cleanup of any dangling SHAs on the remote (if an exposure is
  discovered) — GitHub Support ticket.
