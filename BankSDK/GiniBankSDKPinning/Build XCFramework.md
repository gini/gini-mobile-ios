# Gini Bank SDK Pinning XCFrameworks for iOS

Before starting you need to install [swift-create-xcframework](https://github.com/unsignedapps/swift-create-xcframework/tree/main#installation).

**Note: Use at least version 2.2.0 of `swift-create-xcframework`, otherwise it won't work with Xcode 13.4.

1. Navigate to the `cd GiniBankSDKPinning` directory and run `swift create-xcframework`

2. In terminal open the newly generated project `open .build/swift-create-xcframework/GiniBankSDKPinning.xcodeproj`

3. In `Project` -> `Build Settings` set `Base SDK` parameter to `iOS`

4. In `Project` -> `Build Settings` set `Supported Platforms` parameter to `iOS`

5. In `Project` -> `Info` -> `Deployment Target` set `iOS Deployment Target` to `12`

6. For each dependency target in `Build Settings` set `Base SDK` parameter to `iOS`

7. For each dependency target in `Build Settings` set `Supported Platforms` parameter to `iOS`

8. For each dependency target in `General` -> `Deployment Info` select `iPad` and deselect `Mac Catalyst`

9. For each dependency target in `Build Settings` -> `Build Options` set `Build Libraries for Distribution` to `Yes`

10. For each dependency target in `Build Settings` -> `Deployment` set `Skip install` parameter to `No`

11. For each dependency target in `Build Phases` -> `Compile Sources` add Resources and check that the target is checked the `Target Membership` in info tab.

12. Navigate to the `cd .build/swift-create-xcframework/` directory and create archives for GiniBankSDKPinning for device and simulator (you can copy paste the whole snippet into your terminal and run it):

```
xcodebuild archive -project GiniBankSDKPinning.xcodeproj -scheme GiniBankSDKPinning -sdk iphonesimulator -configuration Release -archivePath "iphonesimulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES && \
\
xcodebuild archive -project GiniBankSDKPinning.xcodeproj -scheme GiniBankSDKPinning -sdk iphoneos -configuration Release -archivePath "iphoneos.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```

11. Create XCFrameworks for GiniBankSDKPinning and dependant packages (you can copy paste the whole snippet into your terminal and run it):

```
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankAPILibrary.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankAPILibrary.framework -output GiniBankAPILibrary.xcframework && \
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankAPILibraryPinning.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankAPILibraryPinning.framework -output GiniBankAPILibraryPinning.xcframework && \
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniCaptureSDK.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniCaptureSDK.framework -output GiniCaptureSDK.xcframework && \
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniCaptureSDKPinning.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniCaptureSDKPinning.framework -output GiniCaptureSDKPinning.xcframework && \
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankSDK.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankSDK.framework -output GiniBankSDK.xcframework && \
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankSDKPinning.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankSDKPinning.framework -output GiniBankSDKPinning.xcframework && \
\
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/TrustKit.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/TrustKit.framework -output TrustKit.xcframework
```
