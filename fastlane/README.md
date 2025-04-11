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

Generate certificates


### ios refresh_profiles

```sh
[bundle exec] fastlane ios refresh_profiles
```



### ios register_new_devices

```sh
[bundle exec] fastlane ios register_new_devices
```



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
