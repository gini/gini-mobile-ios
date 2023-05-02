Distributing Gini Bank SDK XCFrameworks using CocoaPods
======================================================

How to release new versions
---------------------------

1. After the `.xcframeworks` have been created compress them into a zip named `GiniBankSDK-XCFrameworks.zip`.
2. Update the version in the `GiniBankSDK.podspec`, for example `spec.version = 2.2.1`.
3. Clone the `https://github.com/gini/gini-podspecs` repository.
4. Go into the `gini-podspecs` repository folder and create a subfolder in `GiniBankSDK` which is named after the version, for example `GiniBankSDK/2.2.1`.
5. Copy the `GiniBankSDK-XCFrameworks.zip` and the `GiniBankSDK.podspec` into the new folder.
6. Commit and push the new folder and its contents.

How to use the Gini Bank SDK pod
--------------------------------

1. Add the following to your `Podfile`:
   1. `source 'https://github.com/gini/gini-podspecs.git'`
   2. `pod GiniBankSDK`
2. Run `pod update` to fetch the latest Gini Bank SDK pod version.