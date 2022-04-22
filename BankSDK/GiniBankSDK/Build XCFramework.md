# Gini Bank SDK XCFrameworks for iOS

**Note: Xcode 13.2 required. If you don't have it installed you can download it as shown 
[here](https://medium.com/a-swift-misadventure/how-to-install-multiple-versions-of-xcode-on-the-same-macos-machine-a2836387e57f) 
and then use [xcode-select](https://riptutorial.com/xcode/example/19193/switching-command-line-tools-with-xcode-select) to make Xcode 13.2 the default while building the XCFramework. Don't forget to reset it after you're done.**

Before starting you need to install [swift-create-xcframework](https://github.com/unsignedapps/swift-create-xcframework/tree/main#installation).

1. Navigate to the `cd GiniBankSDK` directory and run `swift create-xcframework`

2. In terminal open the newly generated project `open .build/swift-create-xcframework/GiniBankSDK.xcodeproj`

3. In `Project` -> `Build Settings` set `Base SDK` parameter to `iOS`

4. In `Project` -> `Info` -> `Deployment Target` set `iOS Deployment Target` to `11`

5. For each dependency target in `Build Settings` set `Base SDK` parameter to `iOS`

6. For each dependency target in `General` -> `Deployment Info` select `iPad` and deselect `Mac Catalyst`

7. For each dependency target in `Build Settings` -> `Build Options` set `Build Libraries for Distribution` to `Yes`

8. For each dependency target in `Build Settings` -> `Deployment` set `Skip install` parameter to `No`

9. For each dependency target in `Build Phases` -> `Compile Sources` add Resources and check that the target is checked the `Target Membership` in info tab.

10. Navigate to the `cd .build/swift-create-xcframework/` directory and create archives for GiniBankSDK for device and simulator:

```
xcodebuild archive -project GiniBankSDK.xcodeproj -scheme GiniBankSDK -sdk iphonesimulator -configuration Release -archivePath "iphonesimulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive -project GiniBankSDK.xcodeproj -scheme GiniBankSDK -sdk iphoneos -configuration Release -archivePath "iphoneos.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
```

11. Create XCFrameworks for GiniBankSDK and dependant packages:

```
xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankAPILibrary.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankAPILibrary.framework -output GiniBankAPILibrary.xcframework

xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniCaptureSDK.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniCaptureSDK.framework -output GiniCaptureSDK.xcframework

xcodebuild -create-xcframework -framework iphoneos.xcarchive/Products/Library/Frameworks/GiniBankSDK.framework -framework iphonesimulator.xcarchive/Products/Library/Frameworks/GiniBankSDK.framework -output GiniBankSDK.xcframework
```
