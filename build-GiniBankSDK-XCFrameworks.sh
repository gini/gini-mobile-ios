#!/bin/bash

# Function to copy .swiftmodule files manually
cp-modules() {
    local frName=$1
    local srcPath=$2
    local dstPath=$3

    echo "Copying modules for $frName from $srcPath to $dstPath"
    mkdir -p "$dstPath/$frName.framework/Modules"
    cp -a "$srcPath/$frName.swiftmodule" "$dstPath/$frName.framework/Modules/$frName.swiftmodule"
}

# Function to archive a Swift Package
archive() {
    local scheme=$1
    local platform=$2
    local sdk=$3
    local derivedDataPath=$4
    local outputPath=$5

    local resultFrameworksPath="$outputPath/Products/Library/Frameworks"
    local modulesPath="$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/BuildProductsPath/Release-$sdk"

    echo "Archiving for $platform ($sdk)"
    xcodebuild archive -scheme "$scheme" \
    -destination "generic/platform=$platform" \
    -archivePath "$outputPath" \
    -derivedDataPath "$derivedDataPath" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGNING_REQUIRED=NO \
    OTHER_SWIFT_FLAGS="-disable-implicit-swiftmodule-verification"

    cp-modules "$scheme" "$modulesPath" "$resultFrameworksPath"
}

# Function to create an XCFramework
make-xcframework() {
    local frName=$1
    local srcPath=$2
    local srcPathSim=$3

    local frameworkPath="$srcPath/Products/Library/Frameworks/$frName.framework"
    local frameworkPathSim="$srcPathSim/Products/Library/Frameworks/$frName.framework"

    echo "Creating XCFramework for $frName"
    xcodebuild -create-xcframework \
        -framework "$frameworkPath" \
        -framework "$frameworkPathSim" \
        -output "$frName.xcframework"
}

# telling swift packages in the environment that they need to produce dynamic libraries
export GINI_FORCE_DYNAMIC_LIBRARY=1

# Build and Archive for iOS and iOS Simulator
archive "GiniBankSDKPinning" \
    "iOS" \
    "iphoneos" \
    "build-bank-iphoneos" \
    "iphoneosBankPinning.xcarchive"

archive "GiniBankSDKPinning" \
    "iOS Simulator" \
    "iphonesimulator" \
    "build-bank-pinning-iphonesimulator" \
    "iphonesimulatorBankPinning.xcarchive"

# Create XCFrameworks
make-xcframework "GiniBankAPILibrary" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"
make-xcframework "GiniCaptureSDK" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"
make-xcframework "GiniBankSDK" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"
make-xcframework "GiniBankSDKPinning" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"
make-xcframework "GiniCaptureSDKPinning" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"
make-xcframework "GiniBankAPILibraryPinning" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"
make-xcframework "TrustKit" "iphoneosBankPinning.xcarchive" "iphonesimulatorBankPinning.xcarchive"

# Optional: Cleanup
echo "Cleaning up intermediate archives..."
rm -rf "build-bank-iphoneos"
rm -rf "build-bank-pinning-iphonesimulator"
rm -rf "iphoneosBankPinning.xcarchive"
rm -rf "iphonesimulatorBankPinning.xcarchive"

# swift package checks for "1" so making it empty is enough to clean it
export GINI_FORCE_DYNAMIC_LIBRARY=""