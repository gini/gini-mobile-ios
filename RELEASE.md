To publish releases follow these steps:
1. Make sure you are on the `main` branch.
2. Bump the version in each to-be-released package's (don't forget to update also extended package with Pinning!):
    1. `{PackageName}Version.swift` file,
    2. documentation file.
3. Check `RELEASE-ORDER.md` to find out which projects contain the to-be-released packages in their release order.
   These will be the dependent packages.
4. Bump the version in each dependent package's:
    `Package-release.swift` file
5. Commit and push the changes to `main`.
6. Create and push release tags by running: `bundle exec fastlane create_release_tags`.
7. Each package will be released in dedicated release repo: 
    E.g. `https://github.com/gini/capture-sdk-pinning-ios`
8. Create a release with release notes for each to-be-released package on their GitHub releases page.
    E.g. [releases page for Gini Capture SDK Pinning for iOS](https://github.com/gini/capture-sdk-pinning-ios/releases).
