# Gini Bank SDK XCFrameworks for iOS

1. Navigate to the `cd GiniBankSDK` directory 

2. In terminal, run `./build-GiniBankSDK-XCFrameworks.sh `. If it says `Permission denied`, try running `chmod +x build-GiniBankSDK-XCFrameworks.sh` to add permission to execute
**Note: running this will cleanup all intermediates and artefacts from the previous run, unless you specify `--no-cleanup` in arguments. You can run `./build-GiniBankSDK-XCFrameworks.sh  --help` for more info about how to use the script**

2. After the script from the step above has finished, there should be `GiniBankSDK.xcframework`, `GiniBankAPILibrary.xcframework`, `GiniCaptureSDK.xcframework`, and `GiniUtilites.xcframework` available.

## Using XCFrameworks in a testing project

1. Add all XCFrameworks to your Xcode project. Typically, this is done by creating a group called `Frameworks` somewhere in the project, and then drag-and-dropping XCFrameworks there.

2. Go to your target settings, scroll down to `Frameworks, Libraries, and Embedded Content`.

3. Click the `+` icon, select all XCFrameworks, and then click `Add`.

4. In the same section from step 2, make sure that `Embed` status of all XCFrameworks is `Embed & Sign`, otherwise your app may crash on launch, because XCFrameworks weren't embed in the app bundle. Additionally, make sure all XCFrameworks are present in `Build Phases -> Link Binary With Libraries`