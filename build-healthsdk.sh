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

frameworks=("GiniHealthAPILibrary" "GiniUtilites" "GiniInternalPaymentSDK" "GiniHealthSDK")

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
    rm -rf *.xcframework
}

# Function to copy .swiftmodule files manually
cp-modules() {
    local frName=$1
    local srcPath=$2
    local dstPath=$3

    echo "Copying modules for $frName from $srcPath to $dstPath"
    mkdir -p "$dstPath/$frName.framework/Modules"
    cp -a "$srcPath/$frName.swiftmodule" "$dstPath/$frName.framework/Modules/$frName.swiftmodule" 2>/dev/null || true
}

# Function to copy resource bundles
copy-resources() {
    local schemeName=$1
    local dstPath=$2
    local derivedDataPath=$4

    echo "Copying resources for $schemeName from DerivedDataPath to $dstPath"

    local frameworkDir="$dstPath/$schemeName.framework"
    mkdir -p "$frameworkDir"

    # Look for Assets.car in various locations
    local assetCarPath=""
    local possibleCarPaths=(
        "$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/IntermediateBuildFilesPath/${schemeName}.build/Release-iphoneos/${schemeName}.build/assetcatalog_output/thinned/Assets.car"
        "$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/IntermediateBuildFilesPath/${schemeName}.build/Release-iphoneos/${schemeName}_${schemeName}.build/assetcatalog_output/thinned/Assets.car"
        "$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/BuildProductsPath/Release-iphoneos/${schemeName}.framework/Assets.car"
    )

    for path in "${possibleCarPaths[@]}"; do
        if [[ -f "$path" ]]; then
            assetCarPath="$path"
            echo "Found Assets.car at: $path"
            break
        fi
    done

    # If not found, search recursively
    if [[ -z "$assetCarPath" ]]; then
        assetCarPath=$(find "$derivedDataPath" -name "Assets.car" -type f | grep -v ".xcarchive" | head -1)
        if [[ -n "$assetCarPath" ]]; then
            echo "Found Assets.car at: $assetCarPath"
        fi
    fi

    # Copy Assets.car if found
    if [[ -n "$assetCarPath" ]]; then
        cp "$assetCarPath" "$frameworkDir/"
        echo "Copied Assets.car to $frameworkDir/"
    fi

    # Look for bundle
    local bundlePath=""
    local possibleBundlePaths=(
        "$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/${schemeName}_${schemeName}.bundle"
        "$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/BuildProductsPath/Release-iphoneos/${schemeName}_${schemeName}.bundle"
    )

    for path in "${possibleBundlePaths[@]}"; do
        if [[ -d "$path" ]]; then
            bundlePath="$path"
            echo "Found bundle at: $path"
            break
        fi
    done

    # If not found, search recursively
    if [[ -z "$bundlePath" ]]; then
        bundlePath=$(find "$derivedDataPath" -name "*${schemeName}*.bundle" -type d | grep -v ".xcarchive" | head -1)
        if [[ -n "$bundlePath" ]]; then
            echo "Found bundle at: $bundlePath"
        fi
    fi

    # Copy bundle if found
    if [[ -n "$bundlePath" ]]; then
        cp -r "$bundlePath" "$frameworkDir/"
        echo "Copied bundle to $frameworkDir/"
    fi
}

# Function to completely strip code signatures from framework
strip-code-signatures() {
    local frameworkPath=$1

    echo "Stripping code signatures from $(basename "$frameworkPath")..."

    # Remove signature from framework binary
    codesign --remove-signature "$frameworkPath" 2>/dev/null || true

    # Remove signatures from all files inside framework
    find "$frameworkPath" -type f -exec codesign --remove-signature {} \; 2>/dev/null || true

    # Remove all extended attributes (which can contain signatures)
    find "$frameworkPath" -type f -exec xattr -c {} \; 2>/dev/null || true

    echo "Code signatures stripped from $(basename "$frameworkPath")"

    return 0
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
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO

    for framework in "${frameworks[@]}"; do
        cp-modules "$framework" "$modulesPath" "$resultFrameworksPath"
    done

    for framework in "${frameworks[@]}"; do
        copy-resources "$framework" "$resultFrameworksPath" "" "$derivedDataPath"
    done

    # Strip code signatures after copying resources
    for framework in "${frameworks[@]}"; do
        local frameworkPath="$resultFrameworksPath/$framework.framework"
        if [[ -d "$frameworkPath" ]]; then
            strip-code-signatures "$frameworkPath"
        fi
    done
}

# Function to create an XCFramework
make-xcframework() {
    local frName=$1
    local srcPath=$2
    local srcPathSim=$3

    local frameworkPath="$srcPath/Products/usr/local/lib/$frName.framework"
    local frameworkPathSim="$srcPathSim/Products/usr/local/lib/$frName.framework"

    echo "Framework Path (iPhone): $frameworkPath"
    echo "Framework Path (Simulator): $frameworkPathSim"

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

for framework in "${frameworks[@]}"; do
    make-xcframework "$framework" "$iphoneosArchivePath" "$iphonesimulatorArchivePath"
done

# swift package checks for "1" so making it empty is enough to clean it
export GINI_FORCE_DYNAMIC_LIBRARY=""

# Post-cleanup
cleanup-artefacts
