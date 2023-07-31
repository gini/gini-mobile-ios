Distributing Gini Bank SDK XCFrameworks using CocoaPods
======================================================

How to release new versions
---------------------------

1. After the `.xcframeworks` have been created compress them into a zip named `GiniBankSDK-XCFrameworks.zip`.  
   IMPORTANT: On MacOS the zip needs to be created by selecting all the XCFrameworks and compressing them. It won't work
   if you compress the folder containing the XCFrameworks[^1].  
   You can also use the following `zip` command inside the folder where all the XCFrameworks are (make sure you include
   all the required XCFrameworks, this example might be outdated):
   ```
   zip -r GiniBankSDK-XCFrameworks.zip \
   GiniBankAPILibrary.xcframework \
   GiniBankSDK.xcframework \
   GiniCaptureSDK.xcframework
   ```
2. Clone the `https://github.com/gini/gini-podspecs` repository.
3. Go into the `gini-podspecs` repository folder and create a subfolder in `GiniBankSDK` which is named after the
   version, for example `2.2.1`.
4. Copy the `GiniBankSDK-XCFrameworks.zip` into the new folder.
5. Copy the `GiniBankSDK.podspec` file from the folder where this readme is located into the new folder and update the
   version with the corresponding one, for example `spec.version = 2.2.1`.
6. Commit and push the new folder and its contents to `gini-podspecs` repo.

[^1]: If we put the XCFrameworks into a folder and then zip that folder then the `unzip` command Cocoapods uses[^2] will
put all the XCFrameworks into a subfolder with the same name as the zipped folder. This breaks adding the XCFrameworks
to the project because Cocoapods can't find XCFrameworks in subfolders.

[^2]: Cocoapods unzip command: `unzip GiniBankSDK-XCFrameworks.zip -d output-dir`

How to use the GiniBankSDK pod
------------------------------

1. Add the following to your `Podfile`:
   1. `source 'https://github.com/gini/gini-podspecs.git'`
   2. `pod GiniBankSDK`
2. Run `pod update` to fetch the latest Gini Bank SDK pod version.

How to test the GiniBankSDK pod
-------------------------------

1. Clone the `cocoapods-xcframework-tester` repository: https://github.com/gini/cocoapods-xcframework-tester
2. Go to your local `cocoapods-xcframework-tester` repo folder.
3. Update the `Podfile` to use the `GiniBankSDK` pod.
4. Run `pod update` to get the newest version of the pod.
5. Open the `.xcworkspace` to build and run the project.
