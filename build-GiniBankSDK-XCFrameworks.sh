#!/bin/bash

# Constants
iphonesimulatorArchivePath="iphonesimulatorGiniBankSDK.xcarchive"
iphonesimulatorBuildDir="build-ginibanksdk-iphonesimulator"

iphoneosArchivePath="iphoneosGiniBankSDK.xcarchive"
iphoneosBuildDir="build-ginibanksdk-iphoneos"


frameworks=("GiniBankAPILibrary" "GiniUtilites" "GiniCaptureSDK" "GiniBankSDK")

# Function to cleanup simulator and iOS archives
cleanup-artefacts() {
    if [[ "$1" == "--no-cleanup" || "$1" == "-n" ]]; then
        echo "warning: running without cleaning up"
    else
        echo "Cleaning up intermediate caches and artefacts..."
        rm -rf $iphonesimulatorArchivePath $iphoneosArchivePath
        rm -rf $iphoneosBuildDir $iphonesimulatorBuildDir
    fi
}

cleanup-frameworks() {
    # cleaning up xcframeworks
    rm -rf *.xcframework
}

# Function to copy .swiftmodule
cp-modules() {
    local frName=$1
    local srcPath=$2
    local dstPath=$3

    echo "Copying modules for $frName from $srcPath to $dstPath"
    mkdir -p "$dstPath/$frName.framework/Modules"
    cp -a "$srcPath/$frName.swiftmodule" "$dstPath/$frName.framework/Modules/$frName.swiftmodule"
}

# Function to copy specific resource bundles

copy-resources() {
    local schemeName=$1
    local derivedDataPath=$2
    local dstPath=$3
    local bundlePath=$4

    echo "Copying resources for $schemeName from DerivedDataPath to $dstPath"

    # Create the destination directory if it doesn't exist
    mkdir -p "$dstPath/$schemeName.framework"

    # Construct paths for source and destination
    local srcBundlePath="$bundlePath/${schemeName}_${schemeName}.bundle"
    local dstBundlePath="$dstPath/$schemeName.framework/${schemeName}_${schemeName}.bundle"

    # Copy the resource bundle
    if [ -d "$srcBundlePath" ]; then
        echo "Copying resource bundle from $srcBundlePath to $dstBundlePath"
        cp -r "$srcBundlePath" "$dstBundlePath"
    else
        echo "Error: Resource bundle not found at $srcBundlePath"
    fi
}

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

    for framework in "${frameworks[@]}"; do
        cp-modules "$framework" "$modulesPath" "$resultFrameworksPath"
    done
    
    for framework in "${frameworks[@]}"; do
        # Call copy-resources to handle resource bundles
        copy-resources "$framework" "$derivedDataPath" "$outputPath/Products/usr/local/lib" "$modulesPath"
    done
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

for framework in "${frameworks[@]}"; do
    make-xcframework "$framework" "$iphoneosArchivePath" "$iphonesimulatorArchivePath"
done
    
# swift package checks for "1" so making it empty is enough to clean it
export GINI_FORCE_DYNAMIC_LIBRARY=""

# Post-cleanup
cleanup-artefacts