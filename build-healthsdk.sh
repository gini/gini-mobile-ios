#!/bin/bash

# help message
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	echo "./build-healthsdk.sh usage:"
	echo "	Build XCFrameworks: ./build-healthsdk.sh"
	echo "	Build XCFrameworks, no cleanup: ./build-healthsdk.sh [--no-cleanup|-n]"
	echo "	Print this message: ./build-healthsdk.sh [--help|-h]"
	exit 0
fi

# constants
iphonesimulatorArchivePath="iphonesimulatorHealth.xcarchive"
iphonesimulatorBuildDir="build-health-iphonesimulator"

iphoneosArchivePath="iphoneosHealth.xcarchive"
iphoneosBuildDir="build-health-iphoneos"

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
    rm -rf "GiniHealthSDK.xcframework"
    rm -rf "GiniHealthAPILibrary.xcframework"
    rm -rf "GiniUtilites.xcframework"
    rm -rf "GiniInternalPaymentSDK.xcframework"
}

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

# Pre-cleanup
cleanup-artefacts
cleanup-frameworks

# telling swift packages in the environment that they need to produce dynamic libraries
export GINI_FORCE_DYNAMIC_LIBRARY=1

# Archive for iOS and iOS Simulator
archive "HealthSDK/GiniHealthSDK" \
    "iOS" \
    "iphoneos" \
    $iphoneosBuildDir \
    $iphoneosArchivePath

archive "HealthSDK/GiniHealthSDK" \
    "iOS Simulator" \
    "iphonesimulator" \
    $iphonesimulatorBuildDir \
    $iphonesimulatorArchivePath

make-xcframework "GiniHealthSDK" \
    $iphoneosArchivePath \
    $iphonesimulatorArchivePath

make-xcframework "GiniHealthAPILibrary" \
    $iphoneosArchivePath \
    $iphonesimulatorArchivePath

make-xcframework "GiniInternalPaymentSDK" \
    $iphoneosArchivePath \
    $iphonesimulatorArchivePath

make-xcframework "GiniUtilites" \
    $iphoneosArchivePath \
    $iphonesimulatorArchivePath

# swift package checks for "1" so making it empty is enough to clean it
export GINI_FORCE_DYNAMIC_LIBRARY=""

# Post-cleanup
cleanup-artefacts