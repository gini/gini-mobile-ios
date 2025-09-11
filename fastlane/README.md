fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios generate_certificates

```sh
[bundle exec] fastlane ios generate_certificates
```

Generate certificates and provisioning profiles for app development.

This lane creates new development certificates and provisioning profiles from scratch.
Use this when setting up code signing for the first time or when certificates have expired.

Parameters:
  distribution_type - Type of distribution: "development", "adhoc", "appstore" (default: "development")

Environment Variables:
  APP_IDENTIFIER    - Bundle identifier for the app (e.g. com.company.app)
  MATCH_GIT_URL     - Git URL with authentication token for the match certificates repository
                      Format: https://<token>@github.com/organization/repo.git


### ios refresh_profiles

```sh
[bundle exec] fastlane ios refresh_profiles
```

Refresh provisioning profiles without generating new certificates.

This lane updates existing provisioning profiles to include new devices or 
refresh expired profiles while keeping the existing certificates intact.
Use this when you need to add new devices or refresh profiles without creating new certificates.

Parameters:
  distribution_type - Type of distribution: "development", "adhoc", "appstore" (default: "development")

Environment Variables:
  APP_IDENTIFIER    - Bundle identifier for the app (e.g. com.company.app)
  MATCH_GIT_URL     - Git URL with authentication token for the match certificates repository
                      Format: https://<token>@github.com/organization/repo.git


### ios register_new_devices

```sh
[bundle exec] fastlane ios register_new_devices
```

Register new devices from a devices file.

This lane reads device UDIDs and names from a text file and registers them
with your Apple Developer account. The devices file should contain one device
per line in the format: "UDID<tab>Device Name" or just "UDID".

Parameters:
  devices_file - Path to the devices file (default: "./devices.txt")

Example devices.txt format:
  1234567890abcdef1234567890abcdef12345678	John's iPhone
  abcdef1234567890abcdef1234567890123456	Jane's iPad


### ios run_unit_tests

```sh
[bundle exec] fastlane ios run_unit_tests
```

Runs unit tests for a given target using the `scan` action (a wrapper around xcodebuild).

Parameters:
- `target`: The name of the target whose test scheme will be executed. Example: `GinBankSDK`.
- `destination`: The destination for the tests. Example: `platform=iOS Simulator,name=iPhone 15,OS=17.4`.
- `clientSecret`: The clientSecret for the hosting app


### ios setup_provisioning

```sh
[bundle exec] fastlane ios setup_provisioning
```

Set up provisioning profiles for app distribution.

This lane handles code signing setup by downloading and installing the necessary
provisioning profiles from the match repository.

Parameters:
  distribution_type - Type of distribution: "adhoc" or "development" (default: "adhoc")

Environment Variables:
  APP_IDENTIFIER    - Bundle identifier for the app (e.g. com.company.app)
  MATCH_GIT_URL     - Git URL with authentication token for the match certificates repository
                      Format: https://<token>@github.com/organization/repo.git


### ios build_app_match

```sh
[bundle exec] fastlane ios build_app_match
```

Build and export app as an IPA.

This lane compiles the specified app scheme, archives it, and exports it as an IPA file 
ready for distribution. The build includes cleaning and detailed logging for debugging.

Parameters:
  export_method - Export method: "ad-hoc" or "development" (default: "ad-hoc")
  configuration - The configuration from the Xcode project setup: "Release", "Debug"

Environment Variables:
  APP_SCHEME    - Xcode scheme to build
  IPA_FILE      - Output name for the generated IPA file (without extension)


### ios setup_temp_keychain

```sh
[bundle exec] fastlane ios setup_temp_keychain
```

Create a temporary keychain for CI builds and expose its credentials to the environment.

Parameters:
  keychain_name       - Name of the keychain to create.
  keychain_password   - Password for the keychain.
  default_keychain    - Whether to set the keychain as the default.
  timeout             -Auto-lock timeout in seconds. Default: 3600 (1 hour).

Behavior:
  - Creates and unlocks the keychain.
  - Exposes keychain_name and keychain_password for reuse in other lanes (e.g., match/gym).


### ios unlock_temp_keychain

```sh
[bundle exec] fastlane ios unlock_temp_keychain
```

Unlock the signing keychain and set it as the default so codesign can access identities.

Parameters:
  path            - Keychain name or full path. Example: "app-signing" or "app-signing.keychain-db".
  password        - Password used to unlock the keychain.
  set_default     - Whether to make the unlocked keychain the default for this session. Here: true.

Behavior:
  - Unlocks the keychain at `path` with the provided password.
  - Sets it as the default keychain (because set_default: true), which is often required in CI.

Environment:
  - KEYCHAIN_PASSWORD must be set to the keychain’s password.


### ios delete_temp_keychain

```sh
[bundle exec] fastlane ios delete_temp_keychain
```

Delete temp signing keychain

### ios build_app_with_provisioning

```sh
[bundle exec] fastlane ios build_app_with_provisioning
```

Complete build process for app distribution.

This lane combines provisioning setup and app building into a single workflow.
It first sets up the necessary code signing certificates and provisioning profiles,
then builds and exports the app as an IPA ready for distribution.

Parameters:
  distribution_type - Type of distribution for provisioning: "adhoc" or "development" (default: "adhoc")
  export_method     - Export method for build: "ad-hoc" or "development" (default: "ad-hoc")
  configuration     - The configuration from the Xcode project setup: "Release", "Debug"

Environment Variables:
  APP_IDENTIFIER    - Bundle identifier for the app
  APP_SCHEME        - Xcode scheme to build
  IPA_FILE          - Output name for the generated IPA file (without extension)
  MATCH_GIT_URL     - Git URL for the match certificates repository


### ios build_app_adhoc

```sh
[bundle exec] fastlane ios build_app_adhoc
```

Build app for ad-hoc distribution

### ios build_app_development

```sh
[bundle exec] fastlane ios build_app_development
```

Build app for development distribution

### ios distribute_to_firebase

```sh
[bundle exec] fastlane ios distribute_to_firebase
```

Distribute the app to Firebase App Distribution

### ios publish_swift_package

```sh
[bundle exec] fastlane ios publish_swift_package
```

Publish a swift package to our release repository.

Parameters:
  project_folder        - the folder of the project to be released (e.g., HealthAPILibrary, HealthSDK)"
  package_folder        - the folder to the swift package to be released (e.g., GiniHealthAPILibrary, GiniHealthAPILibraryPinning)"
  version_file_path     - the path to the file containing the package version
  git_tag               - the git tag name used to release the project
  repo_url              - the url of the release repository
  repo_user             - the username to use for authentication
  repo_password         - the password to use for authentication
  ci                    - set to "true" if running on a CI machine



### ios build_docs

```sh
[bundle exec] fastlane ios build_docs
```

Build a documentation.
 
Parameters:
  project_folder        - the folder of the project to be released (e.g., HealthAPILibrary, HealthSDK)
  package_folder        - the folder to the swift package to be released (e.g., GiniHealthAPILibrary, GiniHealthAPILibraryPinning)


### ios publish_docs

```sh
[bundle exec] fastlane ios publish_docs
```

Publish a documentation to gh-pages.

Releases the documentation into a folder hierarchy constructed from the package_folder and project version:
<gh_pages_url>/<package_folder>/<project_version>
Example: <gh_pages_url>/GiniCaptureSDK/1.11.0

If the 'is_stable_release' option is set to 'true', then it updates the package root index.html 
(at <gh_pages_url>/<package_folder>/index.html) to automatically redirect to the released version.

Parameters:
  project_folder        - the folder of the project to be released (e.g., HealthAPILibrary, HealthSDK)
  package_folder        - the folder to the swift package to be released (e.g., GiniHealthAPILibrary, GiniHealthAPILibraryPinning)
  version_file_path     - the path to the file containing the package version
  git_tag               - the git tag name used to release the project
  repo_user             - the username to use for authentication
  repo_password         - the password to use for authentication
  ci                    - set to "true" if running on a CI machine
  documentation_title   - the title used on the root index page
  is_stable_release     - set to "true" if it's a stable release that should be shown by default 
  dry_run               - (optional) executes without permanent side effects



### ios create_release_tags

```sh
[bundle exec] fastlane ios create_release_tags
```

Create release tags for all packages that have different versions than their latest release tag.


### ios create_documentation_release_tags

```sh
[bundle exec] fastlane ios create_documentation_release_tags
```

Create documentation release tags for all packages that have documentation that changed since their latest release.


### ios setup_manual_signing

```sh
[bundle exec] fastlane ios setup_manual_signing
```

Setup Manual Signing for project at path


### ios add_resources

```sh
[bundle exec] fastlane ios add_resources
```

Add Resources to Project file


### ios generate_sboms

```sh
[bundle exec] fastlane ios generate_sboms
```

Generate CycloneDX SBOMS for all swift packages. The SBOMs are zipped and uploaded to GitHub.

Parameters:
  swift_package_repo_urls     - the list of swift package repository urls
  repo_user                   - the username to use for authentication
  repo_password               - the password to use for authentication
  ci                          - set to "true" if running on a CI machine



### ios publish_podspec

```sh
[bundle exec] fastlane ios publish_podspec
```

Generate a release podspec and publish it on https://github.com/gini/gini-podspecs.

Parameters:
  xcframeworks_folder_path        - path to the folder which contains the .xcframeworks files
  pod_name                        - name of the pod, usually the same as the Swift package name, e.g. GiniBankSDK or GiniCaptureSDKPinning
  podspecs_repo_sdk_folder_path   - path to the folder which contains the local clone of the https://github.com/gini/gini-podspecs repo
  template_podspec_path           - path to the template podspec file, which is modified and used for the new pod version e.g: BankSDK/GiniBankSDK/Pod/GiniBankSDK.podspec



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
