# gini-mobile-ios
Monorepo for Gini iOS SDKs

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

Recommended user-level denies for your own `~/.claude/settings.json` (not enforced by the repo):

```json
{
  "permissions": {
    "deny": [
      "Read(~/.ssh/**)",
      "Read(~/Documents/**)",
      "Read(~/Downloads/**)",
      "Read(~/Desktop/**)",
      "Read(**/.env*)"
    ]
  }
}
```
