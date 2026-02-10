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
    cp -a "$src_path/$fr_name.swiftmodule" "$dst_path/$fr_name.framework/Modules/$fr_name.swiftmodule" 2>/dev/null || true
}

# Function to copy specific resource bundles - FIXED VERSION
copy-resources() {
    local scheme_name=$1
    local dst_path=$2
    local derived_data_path=$4

    echo "Copying resources for $scheme_name from DerivedDataPath to $dst_path"

    # Create the destination directory if it doesn't exist
    local framework_dir="$dst_path/$scheme_name.framework"
    mkdir -p "$framework_dir"
    
    # Look for Assets.car in various locations
    local asset_car_path=""
    local possible_car_paths=(
        "$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/IntermediateBuildFilesPath/${scheme_name}.build/Release-iphoneos/${scheme_name}.build/assetcatalog_output/thinned/Assets.car"
        "$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/IntermediateBuildFilesPath/${scheme_name}.build/Release-iphoneos/${scheme_name}_${scheme_name}.build/assetcatalog_output/thinned/Assets.car"
        "$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/BuildProductsPath/Release-iphoneos/${scheme_name}.framework/Assets.car"
    )
    
    for path in "${possible_car_paths[@]}"; do
        if [[ -f "$path" ]]; then
            asset_car_path="$path"
            echo "Found Assets.car at: $path"
            break
        fi
    done
    
    # If not found, search recursively
    if [[ -z "$asset_car_path" ]]; then
        asset_car_path=$(find "$derived_data_path" -name "Assets.car" -type f | grep -v ".xcarchive" | head -1)
        if [[ -n "$asset_car_path" ]]; then
            echo "Found Assets.car at: $asset_car_path"
        fi
    fi
    
    # Copy Assets.car if found
    if [[ -n "$asset_car_path" ]]; then
        cp "$asset_car_path" "$framework_dir/"
        echo "Copied Assets.car to $framework_dir/"
    fi
    
    # Look for bundle
    local bundle_path=""
    local possible_bundle_paths=(
        "$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/${scheme_name}_${scheme_name}.bundle"
        "$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/BuildProductsPath/Release-iphoneos/${scheme_name}_${scheme_name}.bundle"
    )
    
    for path in "${possible_bundle_paths[@]}"; do
        if [[ -d "$path" ]]; then
            bundle_path="$path"
            echo "Found bundle at: $path"
            break
        fi
    done
    
    # If not found, search recursively
    if [[ -z "$bundle_path" ]]; then
        bundle_path=$(find "$derived_data_path" -name "*${scheme_name}*.bundle" -type d | grep -v ".xcarchive" | head -1)
        if [[ -n "$bundle_path" ]]; then
            echo "Found bundle at: $bundle_path"
        fi
    fi
    
    # Copy bundle if found
    if [[ -n "$bundle_path" ]]; then
        cp -r "$bundle_path" "$framework_dir/"
        echo "Copied bundle to $framework_dir/"
    fi
}

# Function to completely strip code signatures from framework
strip-code-signatures() {
    local framework_path=$1
    
    echo "Stripping code signatures from $(basename "$framework_path")..."
    
    # Remove signature from framework binary
    codesign --remove-signature "$framework_path" 2>/dev/null || true
    
    # Remove signatures from all files inside framework
    find "$framework_path" -type f -exec codesign --remove-signature {} \; 2>/dev/null || true
    
    # Remove all extended attributes (which can contain signatures)
    find "$framework_path" -type f -exec xattr -c {} \; 2>/dev/null || true
    
    echo "Code signatures stripped from $(basename "$framework_path")"
}

archive() {
    local src_path=$1
    local platform=$2
    local sdk=$3
    local derived_data_path=$4
    local output_path=$5

    echo "Archiving for $platform ($sdk)"
    
    # DISABLE CODE SIGNING during archive
    xcodebuild archive -workspace "$src_path" \
        -scheme GiniBankSDK \
        -configuration Release \
        -destination "generic/platform=$platform" \
        -archivePath "$output_path" \
        -derivedDataPath "$derived_data_path" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO

    # Copy modules
    local result_frameworks_path="$output_path/Products/usr/local/lib"
    local modules_path="$derived_data_path/Build/Intermediates.noindex/ArchiveIntermediates/GiniBankSDK/BuildProductsPath/Release-$sdk"

    for framework in "${frameworks[@]}"; do
        cp-modules "$framework" "$modules_path" "$result_frameworks_path"
    done
    
    for framework in "${frameworks[@]}"; do
        copy-resources "$framework" "$result_frameworks_path" "" "$derived_data_path"
    done
    
    # Strip code signatures after copying resources
    for framework in "${frameworks[@]}"; do
        local framework_path="$result_frameworks_path/$framework.framework"
        if [[ -d "$framework_path" ]]; then
            strip-code-signatures "$framework_path"
        fi
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
