Distributing Gini Bank SDK Pinning XCFrameworks using CocoaPods
======================================================

How to release new versions
---------------------------

1. After the `.xcframeworks` have been created compress them into a zip named `GiniBankSDKPinning-XCFrameworks.zip`.  
   IMPORTANT: On MacOS the zip needs to be created by selecting all the XCFrameworks and compressing them. It won't work
   if you compress the folder containing the XCFrameworks[^1].  
   You can also use the following `zip` command inside the folder where all the XCFrameworks are (make sure you include
   all the required XCFrameworks, this example might be outdated):
   ```
   zip -r GiniBankSDKPinning-XCFrameworks.zip \
   GiniBankAPILibrary.xcframework \
   GiniBankAPILibraryPinning.xcframework \
   GiniBankSDK.xcframework \
   GiniBankSDKPinning.xcframework \
   GiniCaptureSDK.xcframework \
   GiniCaptureSDKPinning.xcframework \
   TrustKit.xcframework
   ```
2. Update the version in the `GiniBankSDKPinning.podspec`, for example `spec.version = 2.2.1`.
3. Clone the `https://github.com/gini/gini-podspecs` repository.
4. Go into the `gini-podspecs` repository folder and create a subfolder in `GiniBankSDKPinning` which is named after the
   version, for example `GiniBankSDKPinning/2.2.1`.
5. Copy the `GiniBankSDKPinning-XCFrameworks.zip` and the `GiniBankSDKPinning.podspec` into the new folder.
6. Commit and push the new folder and its contents to `gini-podspecs`. You can discard the changes in the
   `gini-mobile-ios` repo.

[^1]: If we put the XCFrameworks into a folder and then zip that folder then the `unzip` command Cocoapods uses will put
all the XCFrameworks into a subfolder with the same name as the zipped folder. This breaks adding the XCFrameworks
to the project because Cocoapods can't find XCFrameworks in subfolders.

How to use the GiniBankSDK pod
------------------------------

1. Add the following to your `Podfile`:
   1. `source 'https://github.com/gini/gini-podspecs.git'`
   2. `pod GiniBankSDKPinning`
2. Run `pod update` to fetch the latest Gini Bank SDK pod version.



