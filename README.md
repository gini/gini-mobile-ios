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

The **Health example app** (`GiniHealthSDKExample`) uses the same mechanism, with its own gitignored `HealthSDK/GiniHealthSDKExample/.env.local`:

1. `cp HealthSDK/GiniHealthSDKExample/.env.example HealthSDK/GiniHealthSDKExample/.env.local`
2. Fill in the 4 required keys: `GINI_CLIENT_ID`, `GINI_CLIENT_PASSWORD`, `GINI_CLIENT_DOMAIN`, `FIREBASE_API_KEY`. Health does not have CX or stage credentials.
3. The pre-commit hook already covers the Health path once `git config core.hooksPath .githooks` has been activated.
4. Bootstrap the generated file before the first build:
   `SRCROOT="$PWD/HealthSDK/GiniHealthSDKExample" ./scripts/generate_credentials.sh`
5. Open `GiniMobile.xcworkspace` and build `GiniHealthSDKExample`.

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