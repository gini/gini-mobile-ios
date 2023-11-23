# gini-mobile-ios
Monorepo for Gini iOS SDKs

## Generate SBOM JSONs

To generate SBOM JSONs for our Swift Packages you need to do the following steps:
1. Clone the release repo of the swift package.  
   You can find the repo url in the package's release workflow in the `.github/workflows` folder. For example for the Health SDK the release workflow is located at `.github/workflows/health-sdk.release.yml`.
2. Make sure you have node 21+ and ruby 3.2.0+ available in your terminal.
3. Run the `generate-sbom.rb` in your terminal and pass it the path to the folder where you previously cloned the release repo of the swift package (see step 1).  
   For example for Health SDK you should execute the following command in your terminal (assuming the swift package repo folder is at `/tmp/health-sdk-ios`):  
   `ruby generate-sbom-rb /tmp/health-sdk-ios`
4. The sbom will be located in the repo folder and will be named after the swift package name.  
   Using the previous example the sbom would be located at `/tmp/health-sdk-ios/GiniHealthSDK-sbom.json`
