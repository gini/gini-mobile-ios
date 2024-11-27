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

# Function to archive a target
archive() {
    local srcPath=$1
    local platform=$2
    local sdk=$3
    local derivedDataPath=$4
    local outputPath=$5

    local resultFrameworksPath="$outputPath/Products/usr/local/lib"
    local modulesPath="$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/BuildProductsPath/Release-$sdk"

    echo "Archiving for $platform ($sdk)"
    xcodebuild archive -workspace "$srcPath" \
        -scheme GiniHealthSDK \
        -configuration Release \
        -destination "generic/platform=$platform" \
        -archivePath "$outputPath" \
        -derivedDataPath "$derivedDataPath" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGNING_REQUIRED=NO

    cp-modules "GiniHealthSDK" "$modulesPath" "$resultFrameworksPath"
    cp-modules "GiniHealthAPILibrary" "$modulesPath" "$resultFrameworksPath"
    cp-modules "GiniInternalPaymentSDK" "$modulesPath" "$resultFrameworksPath"
    cp-modules "GiniUtilites" "$modulesPath" "$resultFrameworksPath"

    # Copy bundle resources
    local bundlePath="$modulesPath/../../IntermediateBuildFilesPath/UninstalledProducts/$sdk/GiniHealthSDK_GiniHealthSDK.bundle"
    if [ -d "$bundlePath" ]; then
        cp -a "$bundlePath" "$resultFrameworksPath/GiniHealthSDK.framework/GiniHealthSDK_GiniHealthSDK.bundle"
    else
        echo "Resource bundle not found: $bundlePath"
    fi
}

# Function to create an XCFramework
make-xcframework() {
    local frName=$1
    local srcPath=$2
    local srcPathSim=$3

    local frameworkPath="$srcPath/Products/usr/local/lib/$frName.framework"
    local frameworkPathSim="$srcPathSim/Products/usr/local/lib/$frName.framework"

    echo "Creating XCFramework for $frName"
    xcodebuild -create-xcframework \
        -framework "$frameworkPath" \
        -framework "$frameworkPathSim" \
        -output "$frName.xcframework"
}

# Archive for iOS and iOS Simulator
archive "HealthSDK/GiniHealthSDK" \
    "iOS" \
    "iphoneos" \
    "build-health-iphoneos" \
    "iphoneosHealth.xcarchive"

archive "HealthSDK/GiniHealthSDK" \
    "iOS Simulator" \
    "iphonesimulator" \
    "build-health-iphonesimulator" \
    "iphonesimulatorHealth.xcarchive"

# Create XCFrameworks
make-xcframework "GiniHealthSDK" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
make-xcframework "GiniHealthAPILibrary" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
make-xcframework "GiniInternalPaymentSDK" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
make-xcframework "GiniUtilites" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
