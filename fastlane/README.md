fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios publish_swift_package
```
fastlane ios publish_swift_package
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
```
fastlane ios build_docs
```
Build a documentation.
 
Parameters:
  project_folder        - the folder of the project to be released (e.g., HealthAPILibrary, HealthSDK)
  package_folder        - the folder to the swift package to be released (e.g., GiniHealthAPILibrary, GiniHealthAPILibraryPinning)

### ios publish_docs
```
fastlane ios publish_docs
```
Publish a documentation to gh-pages.

Parameters:
  project_folder        - the folder of the project to be released (e.g., HealthAPILibrary, HealthSDK)
  package_folder        - the folder to the swift package to be released (e.g., GiniHealthAPILibrary, GiniHealthAPILibraryPinning)
  version_file_path     - the path to the file containing the package version
  git_tag               - the git tag name used to release the project
  repo_user             - the username to use for authentication
  repo_password         - the password to use for authentication
  ci                    - set to "true" if running on a CI machine



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
