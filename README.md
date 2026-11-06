# gini-mobile-ios
Monorepo for Gini iOS SDKs

## Credentials setup (Bank example apps)

The three Bank example app targets (`GiniBankSDKExample`, `GiniBankSDKExampleBank`, `GiniBankSDKExampleSwiftUI`) consume credentials from a per-project `.env.local` file at `BankSDK/GiniBankSDKExample/.env.local`. The file is gitignored; on every build, a Run Script phase reads it and generates `BankSDK/GiniBankSDKExample/Generated/Credentials.swift` for the compiler.

First-time setup (per clone):

1. Copy the template:
   `cp BankSDK/GiniBankSDKExample/.env.example BankSDK/GiniBankSDKExample/.env.local`
2. Fill in the values — ask your tech lead for the current client credentials and Firebase API key. The stage keys are optional (local dev only).
3. Activate the pre-commit hook once: `git config core.hooksPath .githooks`. The hook refuses commits that stage `BankSDK/GiniBankSDKExample/.env.local` or any `Credentials.plist`.
4. Bootstrap the generated file so Xcode can resolve its reference before the first build:
   `SRCROOT="$PWD/BankSDK/GiniBankSDKExample" ./scripts/generate_credentials.sh`
5. Open `GiniMobile.xcworkspace` and build any Bank example target.

Common failures:

- `error: .env.local not found at …/BankSDK/GiniBankSDKExample/.env.local` — you missed step 1.
- `error: .env.local missing required keys: …` — the file has empty values for `GINI_CLIENT_ID`, `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`, or `FIREBASE_API_KEY`.

CI builds (TestFlight + Firebase App Distribution) write `.env.local` from GitHub Secrets in a `Setup .env.local` workflow step; no local file is checked in.

The Health example app will follow the same pattern at `HealthSDK/GiniHealthSDKExample/.env.local` as part of PP-3923.

## Generate SBOM JSONs manually

To manually generate SBOM JSONs for our Swift Packages you need to do the following steps:
1. Make sure you have node 21+ available in your terminal.
2. Run fastlane with the `generate_sboms` lane and pass in the release repo urls of the Swift Packages and the repo (GitHub) credentials.  
   You can find the release repo url in the package's release workflow in the `.github/workflows` folder. For example for the Health SDK the release workflow is located at `.github/workflows/health-sdk.release.yml`.  
   !!IMPORTANT!!: always set `ci` to `false`, otherwise your git user and email will be overriden in your git configuration.  
   For example for Health SDK you should execute the following command in your terminal:
   ```
   bundle exec fastlane generate_sboms \
   swift_package_repo_urls:"https://github.com/gini/health-sdk-ios.git, https://github.com/gini/health-sdk-pinning-ios.git" \
   repo_user:"GitHub user" repo_password:"GitHub password" \
   ci:"false"
   ```
3. The SBOM JSONs will be located at `fastlane/sbom-jsons.zip`

## AI coding agents and credential files

Local testing needs secrets inside the working copy (example-app `.env.local`, the generated `Credentials.swift`, `CredentialsManager.swift`, legacy `Credentials.plist`, signing material). Gini's Secure Development Procedure (3.3.2 / 7.5) forbids sharing secrets with AI tools, so the checked-in `.claude/settings.json` denies Claude Code read and edit access to those files for everyone who clones this repo. Builds and tests are unaffected: the Xcode build phase that regenerates credentials runs outside the agent.

Covered patterns (relative to the repo root, any depth):

| Pattern | What it protects |
| --- | --- |
| `.env`, `.env.local`, `.env.*.local` | Example-app credentials (`.env.example` stays readable) |
| `Generated/**` | `Credentials.swift` produced by `scripts/generate_credentials.sh` |
| `Credentials.plist` | Legacy example-app credentials |
| `CredentialsManager.swift` | Example-app source with client id/secret filled in locally (and by CI for the Health example) |
| `*.p12`, `*.p8`, `*.mobileprovision`, `*.pem`, `*.key` | Signing certificates, App Store Connect API keys, private keys |

When you add a new secret-bearing file, add a matching `Read(...)` and `Edit(...)` entry to the `permissions.deny` list in `.claude/settings.json` in the same PR.

Recommended user-level denies for your own `~/.claude/settings.json` (not enforced by the repo). Denying broad folders such as `~/Downloads` or `~/Documents` also blocks files you drag into the chat from there, so this list is kept to paths that only ever hold secrets:

```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)",
      "Read(**/.env*)"
    ]
  }
}
```
