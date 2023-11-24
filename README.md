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