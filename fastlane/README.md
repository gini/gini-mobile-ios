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

On the 'main' branch it updates the package root index.html (at <gh_pages_url>/<package_folder>/index.html) 
to automatically redirect to the released version.

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


----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
