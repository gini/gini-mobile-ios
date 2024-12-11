#!/bin/bash

# constants
iphonesimulatorArchivePath="iphonesimulatorGiniBankSDK.xcarchive"
iphonesimulatorBuildDir="build-ginibanksdk-iphonesimulator"

iphoneosArchivePath="iphoneosGiniBankSDK.xcarchive"
iphoneosBuildDir="build-ginibanksdk-iphoneos"


# Function to cleanup simulator and iOS archives
cleanup-artefacts() {
    # check if cleanup is disabled in arguments
    if [[ "$1" == "--no-cleanup" || "$1" == "-n" ]]; then
        echo "warning: running without cleaning up"
    else
        echo "Cleaning up intermediate caches and artefacts..."

        # cleaning archives
        rm -rf $iphonesimulatorArchivePath
        rm -rf $iphoneosArchivePath

        # cleaning build dirs
        rm -rf $iphoneosBuildDir
        rm -rf $iphonesimulatorBuildDir

    fi
}

cleanup-frameworks() {
    # cleaning up xcframeworks
    rm -rf "GiniBankSDK.xcframework"
    rm -rf "GiniBankAPILibrary.xcframework"
    rm -rf "GiniCaptureSDK.xcframework"
}

# Function to copy .swiftmodule
cp-modules() {
    local frName=$1
    local srcPath=$2
    local dstPath=$3

    echo "Copying modules and resources for $frName from $srcPath to $dstPath"
    mkdir -p "$dstPath/$frName.framework/Modules"
    cp -a "$srcPath/$frName.swiftmodule" "$dstPath/$frName.framework/Modules/$frName.swiftmodule"
}

# Function to archive a Swift Package
archive() {
    local srcPath=$1
    local platform=$2
    local sdk=$3
    local derivedDataPath=$4
    local outputPath=$5

    echo "Archiving for $platform ($sdk)"
    xcodebuild archive -workspace "$srcPath" \
        -scheme GiniBankSDK \
        -configuration Release \
        -destination "generic/platform=$platform" \
        -archivePath "$outputPath" \
        -derivedDataPath "$derivedDataPath" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGNING_REQUIRED=NO

    # Copy modules
    local resultFrameworksPath="$outputPath/Products/usr/local/lib"
    local modulesPath="$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/BuildProductsPath/Release-$sdk"

    cp-modules "GiniBankSDK" "$modulesPath" "$resultFrameworksPath"
    cp-modules "GiniCaptureSDK" "$modulesPath" "$resultFrameworksPath"
    cp-modules "GiniBankAPILibrary" "$modulesPath" "$resultFrameworksPath"

    # Copy bundle resources
    local bankBundlePath="$modulesPath/../../IntermediateBuildFilesPath/UninstalledProducts/$sdk/GiniBankSDK_GiniBankSDK.bundle"
    if [ -d "$bankBundlePath" ]; then
        cp -a "$bankBundlePath" "$resultFrameworksPath/GiniBankSDK.framework/GiniBankSDK_GiniBankSDK.bundle"
    else
        echo "GiniBank resource bundle not found: $bankBundlePath"
    fi

    local captureBundlePath="$modulesPath/../../IntermediateBuildFilesPath/UninstalledProducts/$sdk/GiniCaptureSDK_GiniCaptureSDK.bundle"
    if [ -d "$captureBundlePath" ]; then
        cp -a "$captureBundlePath" "$resultFrameworksPath/GiniCaptureSDK.framework/GiniCaptureSDK_GiniCaptureSDK.bundle"
    else
        echo "GiniCapture resource bundle not found: $captureBundlePath"
    fi
}

# XCFramework Creation Function
make-xcframework() {
    local frName=$1
    local srcPath=$2
    local srcPathSim=$3

    local frameworkPath="$srcPath/Products/usr/local/lib/$frName.framework"
    local frameworkPathSim="$srcPathSim/Products/usr/local/lib/$frName.framework"

      # Debugging: Display constructed framework paths
    echo "Framework Path (iPhone): $frameworkPath"
    echo "Framework Path (Simulator): $frameworkPathSim"

    # Validate paths
    if [[ ! -d "$frameworkPath" ]]; then
        echo "Error: Framework path does not exist: $frameworkPath"
        return 1
    fi
    if [[ ! -d "$frameworkPathSim" ]]; then
        echo "Error: Framework path does not exist: $frameworkPathSim"
        return 1
    fi

    # Create the XCFramework
    echo "Creating XCFramework for $frName"
    xcodebuild -create-xcframework \
        -framework "$frameworkPath" \
        -framework "$frameworkPathSim" \
        -output "$frName.xcframework"
}

# Pre-cleanup
cleanup-artefacts
cleanup-frameworks

# telling swift packages in the environment that they need to produce dynamic libraries
export GINI_FORCE_DYNAMIC_LIBRARY=1

# Build and Archive for iOS and iOS Simulator
archive "BankSDK/GiniBankSDK" \
    "iOS" \
    "iphoneos" \
    $iphoneosBuildDir \
    $iphoneosArchivePath

archive "BankSDK/GiniBankSDK" \
    "iOS Simulator" \
    "iphonesimulator" \
    $iphonesimulatorBuildDir \
    $iphonesimulatorArchivePath

# Create XCFrameworks
make-xcframework "GiniBankAPILibrary" \
    "$iphoneosArchivePath" \
    "$iphonesimulatorArchivePath"

make-xcframework "GiniCaptureSDK" \
    "$iphoneosArchivePath" \
    "$iphonesimulatorArchivePath"

make-xcframework "GiniBankSDK" \
    "$iphoneosArchivePath" \
    "$iphonesimulatorArchivePath"
    
# swift package checks for "1" so making it empty is enough to clean it
export GINI_FORCE_DYNAMIC_LIBRARY=""

# Post-cleanup
# cleanup-artefacts