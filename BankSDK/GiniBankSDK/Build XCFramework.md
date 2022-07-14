# Gini Bank SDK XCFrameworks for iOS

Before starting you need to install [swift-create-xcframework](https://github.com/unsignedapps/swift-create-xcframework/tree/main#installation).

**Note: Use at least version 2.2.0 of `swift-create-xcframework`, otherwise it won't work with Xcode 13.4.

1. Navigate to the `cd GiniBankSDK` directory and run `swift create-xcframework`

2. In terminal open the newly generated project `open .build/swift-create-xcframework/GiniBankSDK.xcodeproj`

3. In `Project` -> `Build Settings` set `Base SDK` parameter to `iOS`

4. In `Project` -> `Info` -> `Deployment Target` set `iOS Deployment Target` to `11`

5. For each dependency target in `Build Settings` set `Base SDK` parameter to `iOS`

6. For each dependency target in `General` -> `Deployment Info` select `iPad` and deselect `Mac Catalyst`

7. For each dependency target in `Build Settings` -> `Build Options` set `Build Libraries for Distribution` to `Yes`

8. For each dependency target in `Build Settings` -> `Deployment` set `Skip install` parameter to `No`

9. Include resources in `Build Phases` -> `Compile Sources`.
Make sure to include GiniBankSDK Resources for GiniBankSDK target.
Make sure to include GiniCaptureSDK Resources for GiniCaptureSDK target and check that the target is checked the `Target Membership` in info tab.

10. Navigate to the `cd .build/swift-create-xcframework/` directory and create archives for GiniBankSDK for device and simulator (you can copy paste the whole snippet into your terminal and run it):

```
xcodebuild archive -project GiniBankSDK.xcodeproj -scheme GiniBankSDK -sdk iphonesimulator -configuration Release -archivePath "iphonesimulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES &&\
\
xcodebuild archive -project GiniBankSDK.xcodeproj -scheme GiniBankSDK -sdk iphoneos -configuration Release -archivePath "iphoneos.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```

11. Create XCFrameworks for GiniBankSDK and dependant packages (you can copy paste the whole snippet into your terminal and run it):

```
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankAPILibrary.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankAPILibrary.framework -output GiniBankAPILibrary.xcframework &&\
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniCaptureSDK.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniCaptureSDK.framework -output GiniCaptureSDK.xcframework &&\
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankSDK.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankSDK.framework -output GiniBankSDK.xcframework
```
