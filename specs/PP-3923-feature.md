# PP-3923: [iOS] Switch to use swift files & env file for credentials in GiniHealthSDK

Status: implemented
Ticket: https://ginis.atlassian.net/browse/PP-3923
Parent epic: PP-1811 "iOS Tech debt and improvements"
Sibling: PP-1073 (Bank, this PR stacks on top of it)
Branch: `PP-3923` off `chore/env-credentials`

## Problem

`HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/CredentialsManager.swift`
ships three hardcoded Swift globals that every developer edits in place
with real values:

```swift
let clientID = "client_id"
let clientPassword = "client_password"
let clientDomain = "client_domain"
```

Because the file is tracked, a careless `git add -u` or `git add .` can
sweep real credentials into a commit — same failure mode PP-1073 fixed on
the Bank side. CI also still mutates this file in place today (`sed -i ''`
in both `health-sdk.publish.example.app.testflight.yml` and
`health-sdk.publish.example.apps.firebase.yml`) and plutil-replaces
`API_KEY` on the source-tree `GoogleService-Info.plist`.

PP-3923 ports PP-1073's env + generated-Swift mechanism to Health:
`HealthSDK/GiniHealthSDKExample/.env.local` becomes the (gitignored) source
of truth; a build-phase script generates `Credentials.swift` into a
gitignored `Generated/` directory; the Firebase `API_KEY` is injected into
the built `.app`'s plist copy, not the source tree. The same scripts, hook,
and pre-commit backstop PP-1073 ships are reused — Health just adds its own
paths.

Public SDK API is untouched. All work is example-app and tooling.

## Requirements

Numbered contract. Each MUST ties to a named check in the Testing section.

- **R1 (MUST, happy).** Given `HealthSDK/GiniHealthSDKExample/.env.local`
  has `GINI_CLIENT_ID`, `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`, and
  `FIREBASE_API_KEY` populated, when `GiniHealthSDKExample` is built, then
  `HealthSDK/GiniHealthSDKExample/Generated/Credentials.swift` is written
  with those values as `enum Credentials { static let … }`.
- **R2 (MUST, entry).**
  `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/CredentialsManager.swift`
  defines `let clientID = Credentials.clientID`,
  `let clientPassword = Credentials.clientPassword`,
  `let clientDomain = Credentials.clientDomain`. All 7 existing call sites
  (`AppCoordinator.swift` × 4, `TestCredentials.swift` × 3) continue to
  compile and resolve to the env values.
- **R3 (MUST, error — missing file).** Build fails non-zero with
  `error: .env.local not found at …/HealthSDK/GiniHealthSDKExample/.env.local`
  if the file is absent.
- **R4 (MUST, error — missing required key).** Build fails non-zero and
  stderr names every missing required key (`GINI_CLIENT_ID`,
  `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`, `FIREBASE_API_KEY`).
- **R5 (MUST, Firebase).** When `FIREBASE_API_KEY` is present, the built
  `GiniHealthSDKExample.app`'s `GoogleService-Info.plist` has `API_KEY`
  replaced with that value. All other plist fields and the source-tree
  plist are byte-unchanged.
- **R6 (MUST, hook).** With `.githooks/pre-commit` active, a commit
  staging `HealthSDK/GiniHealthSDKExample/.env.local` is rejected
  non-zero. (Hook's protected-paths list grows by one.)
- **R7 (MUST, CI).** `health-sdk.publish.example.app.testflight.yml` and
  `health-sdk.publish.example.apps.firebase.yml` build green with the
  existing GitHub Secrets. TestFlight caller passes `use_env_local: true`
  and the new `env_local_path` input; Firebase workflow's legacy
  `Setup Credentials` + `Setup Firebase API Key` sed/plutil steps are
  replaced with a `Setup .env.local` heredoc.
- **R8 (MUST, no public API).** No `public`/`open` declaration in any
  shipping SPM product (`GiniHealthSDK`, `GiniHealthAPILibrary`,
  `GiniInternalPaymentSDK`, `GiniUtilites`) is added, altered or removed.
- **R9 (SHOULD, onboarding).** Repo-root `README.md` grows a short note
  under PP-1073's "Credentials setup" section pointing at Health's
  `.env.local` path.

## Resolved design decisions

- **Env file**: per-project at `HealthSDK/GiniHealthSDKExample/.env.local`
  (sibling of Bank's at `BankSDK/GiniBankSDKExample/.env.local`). Shared
  nothing — key names like `GINI_CLIENT_ID` are reused inside each file
  but the files themselves are independent.
- **Required keys** (all four): `GINI_CLIENT_ID`,
  `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`, `FIREBASE_API_KEY`. No
  CX, no stage — Health doesn't have those variants.
- **Generated file location**: `$SRCROOT/Generated/Credentials.swift`,
  matching Bank. `$SRCROOT` for `GiniHealthSDKExample` =
  `HealthSDK/GiniHealthSDKExample/`.
- **Firebase**: `GoogleService-Info.plist` stays tracked with empty
  `API_KEY`. Build-phase script runs `plutil -replace API_KEY -string …`
  on `$BUILT_PRODUCTS_DIR/GiniHealthSDKExample.app/GoogleService-Info.plist`
  after Copy Bundle Resources. Source-tree plist never mutated. Same
  `ginibank-ca4f2` Firebase project as Bank; different `GOOGLE_APP_ID` so
  it's registered as a separate iOS app in the same project — the shared
  `FIREBASE_API_KEY` secret works for both.
- **Xcode build phases**: two Run Script phases on the
  `GiniHealthSDKExample` target.
  (1) *Generate Credentials.swift* runs before Compile Sources —
  declares `inputPaths = $(SRCROOT)/.env.local` and
  `outputPaths = $(SRCROOT)/Generated/Credentials.swift` so Xcode's new
  build system schedules it correctly on fresh checkouts.
  (2) *Inject Firebase API_KEY* runs after Copy Bundle Resources.
  `ENABLE_USER_SCRIPT_SANDBOXING = NO` set on the target.
- **CI reusable workflow**: `publish.example.app.testflight.yml` gains
  one new input, `env_local_path` (string, default
  `BankSDK/GiniBankSDKExample/.env.local` so PP-1073 Bank callers
  continue to work unchanged). The `Setup .env.local` step writes to
  `${{ inputs.env_local_path }}`. Health TestFlight caller sets
  `use_env_local: true` + `env_local_path: 'HealthSDK/GiniHealthSDKExample/.env.local'`.
- **CI Firebase workflow**: `health-sdk.publish.example.apps.firebase.yml`
  replaces the two legacy steps (sed on CredentialsManager, plutil on
  plist) with one `Setup .env.local` heredoc writing Health's path.
- **CredentialsManager.swift shape**: 3 global `let` constants
  re-exporting `Credentials.*`. Call sites in `AppCoordinator.swift` and
  `TestCredentials.swift` are byte-identical after this change — zero
  diff outside `CredentialsManager.swift`.

## Affected files

| Scope | File | Change |
| --- | --- | --- |
| New | `HealthSDK/GiniHealthSDKExample/.env.example` | 4-key template, tracked |
| New | `HealthSDK/GiniHealthSDKExample/Generated/Credentials.swift` | Produced at build time, gitignored |
| Rewritten | `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/CredentialsManager.swift` | 3 globals re-export `Credentials.*` |
| Modified | `HealthSDK/GiniHealthSDKExample/GoogleService-Info.plist` | Reset `API_KEY` to empty (if non-empty on `main`) |
| Modified | `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample.xcodeproj/project.pbxproj` | 2 Run Script phases + file ref + sandboxing off + input/output paths declared |
| Modified | `.gitignore` | Add Health's `.env.local` + `Generated/` paths |
| Modified | `.githooks/pre-commit` | Add Health's `.env.local` to protected-paths list |
| Modified | `.github/workflows/publish.example.app.testflight.yml` | New `env_local_path` input (default = Bank's path for backward compat) |
| Modified | `.github/workflows/health-sdk.publish.example.app.testflight.yml` | Set `use_env_local: true` + `env_local_path: 'HealthSDK/GiniHealthSDKExample/.env.local'`, pass 3 required secrets |
| Modified | `.github/workflows/health-sdk.publish.example.apps.firebase.yml` | Replace Setup Credentials + Setup Firebase API Key steps with Setup .env.local heredoc |
| Modified | `README.md` | Append Health paragraph to the Credentials setup section |

Not touched:
- Bank example apps (PP-1073 already covers them).
- Any SDK source under `HealthSDK/GiniHealthSDK/Sources/`, `HealthAPILibrary/`,
  `GiniComponents/` — public API frozen.
- `TestCredentials.swift` — the env-var fallback mechanism continues to work
  since `clientID`/`clientPassword`/`clientDomain` are still available (just
  from a different source).
- `health-sdk.check.yml` (if it exists and builds the example app) — same
  gap PP-1073 hit on `bank-sdk.check.yml`. Audit on build; if present, add
  the Setup .env.local step there too.

## Public API impact

**None.** All changes are in the example app and tooling. No `public` /
`open` declaration in any shipping SPM product is added, removed, or
altered.

## Technical conventions

1. **Language and access control**: Swift. The new generated `enum
   Credentials` and the rewritten globals stay `internal` (default).
2. **Architecture**: `CredentialsManager.swift` keeps its current 3-globals
   shape, driven from the generated enum. No new coordinator / view model
   introduced.
3. **Wiring**: no DI change. `AppCoordinator.swift` call sites
   (`GiniHealth(id:secret:domain:)`,
   `GiniHealthAPILibrary.Client(id:secret:domain:)`, debug print,
   `selectAPIViewController.clientId = clientID`) are byte-identical after
   the refactor.
4. **Formatting / doc style**: `/** */` on the generated enum declaration
   (one line). Multi-parameter formatting rule doesn't apply (no
   multi-parameter signatures introduced).
5. **Quality gates**: `make lint scheme=GiniHealthSDK` clean (no SDK
   source touched, trivial pass). `xcodebuild build -scheme
   GiniHealthSDKExample` succeeds on `iPhone 17 / iOS 26.2` CI parity
   with a locally-populated `.env.local`. The 3 touched CI workflows must
   build green against existing GitHub Secrets.

## Design

### Env file schema

`HealthSDK/GiniHealthSDKExample/.env.local` (gitignored). 4 keys, all
required:

```bash
GINI_CLIENT_ID=
GINI_CLIENT_PASSWORD=
GINI_CLIENT_DOMAIN=gini.net
FIREBASE_API_KEY=
```

`HealthSDK/GiniHealthSDKExample/.env.example` has the same keys with
empty values (except `GINI_CLIENT_DOMAIN=gini.net`).

### Generator script

**Reuse `scripts/generate_credentials.sh` from PP-1073 unchanged.** The
script already reads `$SRCROOT/.env.local` and writes
`$SRCROOT/Generated/Credentials.swift`, so switching from the Bank
project's SRCROOT to the Health project's SRCROOT just works. The
`required_keys` list in the script already matches what Health needs
(client id/password/domain + FIREBASE_API_KEY) — CX and stage keys stay in
the optional list and are tolerated as empty values from Health's
`.env.local`.

**No change needed to `scripts/generate_credentials.sh`,
`scripts/test_generate_credentials.sh`, or `scripts/test_pre_commit_hook.sh`.**

### CredentialsManager rewrite

```swift
import Foundation

/**
 Re-exports from the compile-time `Credentials` enum generated by
 `scripts/generate_credentials.sh` on every build.
 */
let clientID = Credentials.clientID
let clientPassword = Credentials.clientPassword
let clientDomain = Credentials.clientDomain
```

Mirrors `BankSDK/GiniBankSDKExample/GiniBankSDKExampleSwiftUI/CredentialsManager.swift`,
converted to `/** */` per AGENTS.md's declaration-doc style.

### Xcode build phases

Via `xcodeproj` Ruby gem, same shape as PP-1073:
- Add Run Script `Generate Credentials.swift` **before** Compile Sources
  with `inputPaths = ['$(SRCROOT)/.env.local']` and
  `outputPaths = ['$(SRCROOT)/Generated/Credentials.swift']`,
  `alwaysOutOfDate = YES`. Script body:
  `"${SRCROOT}/../../scripts/generate_credentials.sh"`.
- Add Run Script `Inject Firebase API_KEY from .env.local` **after** Copy
  Bundle Resources, same script body (idempotent).
- Add shared file reference to `Generated/Credentials.swift` under a new
  `Generated` group, link it to the `GiniHealthSDKExample` target's
  Sources phase.
- Set `ENABLE_USER_SCRIPT_SANDBOXING = NO` on all configs of
  `GiniHealthSDKExample`.

### CI reusable workflow parameterization

`publish.example.app.testflight.yml` gains one new input:

```yaml
env_local_path:
  description: 'Path to the .env.local file to write when use_env_local is true'
  required: false
  default: 'BankSDK/GiniBankSDKExample/.env.local'
  type: string
```

The `Setup .env.local` step changes from
`cat > BankSDK/GiniBankSDKExample/.env.local <<ENV` to
`cat > ${{ inputs.env_local_path }} <<ENV`. All existing Bank callers
continue to work without change — they pick up the default. Health adds:

```yaml
use_env_local: true
env_local_path: 'HealthSDK/GiniHealthSDKExample/.env.local'
```

### Health Firebase workflow

`health-sdk.publish.example.apps.firebase.yml` currently has two steps
(sed on CredentialsManager.swift, plutil on GoogleService-Info.plist).
Replace with one `Setup .env.local` step mirroring Bank's firebase workflow:

```yaml
- name: Setup .env.local
  env:
    GINI_CLIENT_ID: ${{ secrets.GINI_MOBILE_CI_USERNAME }}
    GINI_CLIENT_PASSWORD: ${{ secrets.GINI_MOBILE_CI_PASSWORD }}
    FIREBASE_API_KEY: ${{ secrets.FIREBASE_API_KEY }}
  run: |
    cat > HealthSDK/GiniHealthSDKExample/.env.local <<ENV
    GINI_CLIENT_ID=$GINI_CLIENT_ID
    GINI_CLIENT_PASSWORD=$GINI_CLIENT_PASSWORD
    GINI_CLIENT_DOMAIN=gini.net
    FIREBASE_API_KEY=$FIREBASE_API_KEY
    ENV
```

### Pre-commit hook

Append one path to the protected list in `.githooks/pre-commit`:

```bash
protected_paths=(
    "BankSDK/GiniBankSDKExample/.env.local"
    "HealthSDK/GiniHealthSDKExample/.env.local"   # NEW
    "BankSDK/GiniBankSDKExample/GiniBankSDKExample/Credentials.plist"
    "BankSDK/GiniBankSDKExample/GiniBankSDKExampleBank/Credentials.plist"
)
```

### `.gitignore` additions

```
HealthSDK/GiniHealthSDKExample/.env.local
HealthSDK/GiniHealthSDKExample/Generated/
```

### README

Append one paragraph under PP-1073's `## Credentials setup` section:

> **Health example app** uses the same mechanism, with its own
> `HealthSDK/GiniHealthSDKExample/.env.local`. Run
> `cp HealthSDK/GiniHealthSDKExample/.env.example HealthSDK/GiniHealthSDKExample/.env.local`
> then fill in your values. Health's `.env.local` requires 4 keys
> (`GINI_CLIENT_ID`, `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`,
> `FIREBASE_API_KEY`) — no CX or stage.

## Test plan

Re-use PP-1073's shell test suites unchanged — the generator is the same
script, so `scripts/test_generate_credentials.sh` 19/19 and
`scripts/test_pre_commit_hook.sh` 8/8 continue to prove R1, R3, R4, R5
(hook test may add one case for Health's new path).

**New Swift smoke test**:
`HealthSDK/GiniHealthSDKExample/GiniHealthSDKExampleTests/CredentialsSmokeTests.swift`,
XCTest to match neighboring suites, 2 cases:

1. `credentialsEnumExposesAllKeys` — compile-time proof the generated
   enum has `clientID`, `clientPassword`, `clientDomain`.
   `XCTAssertFalse(Credentials.clientID.isEmpty)` to make it runnable.
2. `globalsMatchGeneratedEnum` — asserts `clientID == Credentials.clientID`
   etc. Pins R2.

**Hook test** (optional extension): add a 5th case to
`scripts/test_pre_commit_hook.sh` covering `HealthSDK/.../\.env.local`
rejection. Mirrors existing Bank cases.

**Target build check**: `xcodebuild build -scheme GiniHealthSDKExample`
on CI parity simulator, with a locally-written `.env.local`. Proves R1,
R2, R5 end-to-end.

### Not tested

- Xcode build-phase ordering across pre-compile / post-copy — same gap
  PP-1073 noted. Verified manually in /gini-build by building clean on
  simulator and inspecting the resulting `.app`'s `GoogleService-Info.plist`.
- CI YAML runtime behavior — will land on push. If anything 401s on
  the real CI run, iterate on the workflow after merge.
- Firebase SDK's behavior with an injected API_KEY — framework-level.
- `.gitignore` behavior — framework-level.

### Manual QA

- Fresh clone + bootstrap for Health:
  `cp HealthSDK/GiniHealthSDKExample/.env.example HealthSDK/GiniHealthSDKExample/.env.local`,
  fill in,
  `SRCROOT="$PWD/HealthSDK/GiniHealthSDKExample" ./scripts/generate_credentials.sh`,
  open `GiniMobile.xcworkspace`, build `GiniHealthSDKExample`. Confirm
  the Health example app launches and uses the right client credentials.
- Delete `.env.local`, rebuild, confirm the build fails with the R3
  message.
- Try `git add -f HealthSDK/GiniHealthSDKExample/.env.local && git
  commit` with the hook active — confirm rejection.
- Push to the branch; verify
  `health-sdk.publish.example.app.testflight.yml` and
  `health-sdk.publish.example.apps.firebase.yml` build green on CI.

## Rollout

Stacked on `chore/env-credentials` (PP-1073). This PR requires PP-1073 to
merge first (shares scripts, hook, reusable workflow). After merge, the
one-time Health setup is one additional `cp` command appended to the
Bank-side onboarding in `README.md`.

## Out of scope

- Bank example apps — covered by PP-1073.
- Any SDK production code.
- Removing the `TestCredentials.swift` env-var fallback mechanism — it
  continues to work with the new generated-enum backing.
- Rotating credentials potentially exposed via the old tracked-file
  pattern — Ops task.
- Any CX / stage credential sets for Health — Health doesn't have them.

## Open questions

None blocking. One soft call-out:

- If `health-sdk.check.yml` exists and builds the example app, it will
  need the same `Setup .env.local` injection fix PP-1073 applied to
  `bank-sdk.check.yml`. /gini-build should audit on first build; add
  the step if missing.

## Implementation plan

- [x] 1. Scaffold: add `HealthSDK/GiniHealthSDKExample/.env.example` (4-key template), `.gitignore` entries, and Health path in `.githooks/pre-commit` protected_paths (R6, prep for R1)
- [x] 2. `HealthSDK/GiniHealthSDKExample/GoogleService-Info.plist` already matches merged Bank sibling state (`<string>&quot;&quot;</string>`); PP-1073 did not touch Bank's plist either, so Health is left as-is (R5 source-tree invariant)
- [x] 3. Rewrite `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/CredentialsManager.swift` to re-export `Credentials.*` (R2)
- [x] 4. Wire `GiniHealthSDKExample.xcodeproj/project.pbxproj`: Generated/ group + `Credentials.swift` file ref, `Generate Credentials.swift` Run Script before Sources (with input/output paths), `Inject Firebase API_KEY from .env.local` Run Script after SwiftLint, `ENABLE_USER_SCRIPT_SANDBOXING = NO` on the target configs (R1, R5)
- [x] 5. Add `HealthSDK/GiniHealthSDKExample/GiniHealthSDKExampleTests/CredentialsSmokeTests.swift` (XCTest, 2 cases) — auto-included via `fileSystemSynchronizedGroups` on `GiniHealthSDKExampleTests` (R2 under test)
- [x] 6. Update reusable workflow `.github/workflows/publish.example.app.testflight.yml`: add `env_local_path` input (default = Bank's path) and change the `Setup .env.local` heredoc to write to `${{ inputs.env_local_path }}` (R7 prep)
- [x] 7. Update `.github/workflows/health-sdk.publish.example.app.testflight.yml`: drop `credentials_manager_path`/`google_services_plist_path`, set `use_env_local: true` + `env_local_path: 'HealthSDK/GiniHealthSDKExample/.env.local'` (R7)
- [x] 8. Rewrite `.github/workflows/health-sdk.publish.example.apps.firebase.yml`: replace legacy Setup Credentials + Setup Firebase API Key with a single `Setup .env.local` heredoc writing Health's path (R7)
- [x] 9. Add `Setup .env.local` step to `.github/workflows/health-sdk.check.yml` (gated on `matrix.target == 'GiniHealthSDKExampleTests'`) (R7 soft)
- [x] 10. Append Health paragraph to `README.md` under `## Credentials setup` (R9)
- [x] 11. Extend `scripts/test_pre_commit_hook.sh` with Case 5 covering Health's `.env.local` path (R6 extension)
- [x] 12. Verify: `xcodebuild build` + `build-for-testing` on `iPhone 17 / iOS 26.2` both `** BUILD SUCCEEDED **`, `scripts/test_generate_credentials.sh` 19/19, `scripts/test_pre_commit_hook.sh` 10/10, 4 touched YAMLs parse clean
