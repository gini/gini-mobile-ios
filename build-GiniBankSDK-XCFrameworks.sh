#!/bin/bash

# Constants
iphonesimulator_archive_path="iphonesimulatorGiniBankSDK.xcarchive"
iphonesimulator_build_dir="build-ginibanksdk-iphonesimulator"

iphoneos_archive_path="iphoneosGiniBankSDK.xcarchive"
iphoneos_build_dir="build-ginibanksdk-iphoneos"


frameworks=("GiniBankAPILibrary" "GiniUtilites" "GiniCaptureSDK" "GiniBankSDK")

# Function to cleanup simulator and iOS archives
cleanup-artefacts() {
    if [[ "$1" == "--no-cleanup" || "$1" == "-n" ]]; then
        echo "warning: running without cleaning up"
    else
        echo "Cleaning up intermediate caches and artefacts..."
        rm -rf $iphonesimulator_archive_path $iphoneos_archive_path
        rm -rf $iphoneos_build_dir $iphonesimulator_build_dir
    fi
}

cleanup-frameworks() {
    # cleaning up xcframeworks
    rm -rf *.xcframework
}

# Function to copy .swiftmodule
cp-modules() {
    local fr_name=$1
    local src_path=$2
    local dst_path=$3

    echo "Copying modules for $fr_name from $src_path to $dst_path"
    mkdir -p "$dst_path/$fr_name.framework/Modules"
    cp -a "$src_path/$fr_name.swiftmodule" "$dst_path/$fr_name.framework/Modules/$fr_name.swiftmodule"
}

# Function to copy specific resource bundles

copy-resources() {
    local scheme_name=$1
    local dst_path=$2
    local bundle_path=$4

    echo "Copying resources for $scheme_name from DerivedDataPath to $dst_path"

    # Create the destination directory if it doesn't exist
    mkdir -p "$dst_path/$scheme_name.framework"

    # Construct paths for source and destination
    local src_bundle_path="$bundle_path/${scheme_name}_${scheme_name}.bundle"
    local dst_bundle_path="$dst_path/$scheme_name.framework/${scheme_name}_${scheme_name}.bundle"

    # Copy the resource bundle
    if [[ -d "$src_bundle_path" ]]; then
        echo "Copying resource bundle from $src_bundle_path to $dst_bundle_path"
        cp -r "$src_bundle_path" "$dst_bundle_path"
    else
        echo "Error: Resource bundle not found at $src_bundle_path"
    fi
}

archive() {
    local src_path=$1
    local platform=$2
    local sdk=$3
    local derived_data_path=$4
    local output_path=$5

    echo "Archiving for $platform ($sdk)"
    xcodebuild archive -workspace "$src_path" \
        -scheme GiniBankSDK \
        -configuration Release \
        -destination "generic/platform=$platform" \
        -archivePath "$output_path" \
        -derivedDataPath "$derived_data_path" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_ALLOWED=YES \
        CODE_SIGNING_REQUIRED=NO


    # Copy modules
    local result_frameworks_path="$output_path/Products/usr/local/lib"
    local modules_path="$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/BuildProductsPath/Release-$sdk"

    for framework in "${frameworks[@]}"; do
        cp-modules "$framework" "$modules_path" "$result_frameworks_path"
    done
    
    for framework in "${frameworks[@]}"; do
        # Call copy-resources to handle resource bundles
        copy-resources "$framework" "$output_path/Products/usr/local/lib" "$modules_path"
    done
}


# XCFramework Creation Function
make-xcframework() {
    local fr_name=$1
    local src_path=$2
    local src_path_sim=$3

    local framework_path="$src_path/Products/usr/local/lib/$fr_name.framework"
    local framework_path_sim="$src_path_sim/Products/usr/local/lib/$fr_name.framework"

     # Debugging: Display constructed framework paths
    echo "Framework Path (iPhone): $framework_path"
    echo "Framework Path (Simulator): $framework_path_sim"

    # Create the XCFramework
    echo "Creating XCFramework for $fr_name"
    xcodebuild -create-xcframework \
        -framework "$framework_path" \
        -framework "$framework_path_sim" \
        -output "$fr_name.xcframework"
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
    $iphoneos_build_dir \
    $iphoneos_archive_path

archive "BankSDK/GiniBankSDK" \
    "iOS Simulator" \
    "iphonesimulator" \
    $iphonesimulator_build_dir \
    $iphonesimulator_archive_path

for framework in "${frameworks[@]}"; do
    make-xcframework "$framework" "$iphoneos_archive_path" "$iphonesimulator_archive_path"
done
    
# swift package checks for "1" so making it empty is enough to clean it
export GINI_FORCE_DYNAMIC_LIBRARY=""

# Post-cleanup
cleanup-artefacts