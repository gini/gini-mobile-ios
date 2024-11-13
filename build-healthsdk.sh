#!/bin/bash

cp-modules()
{
	local frName=$1
	local srcPath=$2
	local dstPath=$3
	mkdir "$dstPath/$frName.framework/Modules"
	cp -a "$srcPath/$frName.swiftmodule" "$dstPath/$frName.framework/Modules/$frName.swiftmodule"
}

archive() 
{
	local srcPath=$1
	local platform=$2
	local sdk=$3
	local derivedDataPath=$4
	local outputPath=$5

	local resultFrameworksPath="$outputPath/Products/usr/local/lib"
	local modulesPath="$derivedDataPath/Build/Intermediates.noindex/ArchiveIntermediates/GiniHealthSDK/BuildProductsPath/Release-$sdk"

	# archive
	xcodebuild archive -workspace $srcPath \
	-scheme GiniHealthSDK \
	-configuration Release \
	-destination "generic/platform=$platform" \
	-archivePath $outputPath \
	-derivedDataPath $derivedDataPath \
	SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    OTHER_SWIFT_FLAGS=-no-verify-emitted-module-interface # for some reason it generates .swiftinterface that seems broken to the validator, so we're disabling that validator here

	# copy .swiftmodule's manually, due to archives seeming to only have runtime artefacts
	cp-modules "GiniHealthSDK" $modulesPath $resultFrameworksPath
	cp-modules "GiniHealthAPILibrary" $modulesPath $resultFrameworksPath
	cp-modules "GiniInternalPaymentSDK" $modulesPath $resultFrameworksPath
	cp-modules "GiniUtilites" $modulesPath $resultFrameworksPath

	# copy bundle resources
	cp -a "$modulesPath/../../IntermediateBuildFilesPath/UninstalledProducts/$sdk/GiniHealthSDK_GiniHealthSDK.bundle" "$resultFrameworksPath/GiniHealthSDK.framework/GiniHealthSDK_GiniHealthSDK.bundle"
}

make-xcframework()
{
	local frName=$1
	local srcPath=$2
	local srcPathSim=$3

	local frameworkPath="$srcPath/Products/usr/local/lib/$frName.framework"
	local frameworkPathSim="$srcPathSim/Products/usr/local/lib/$frName.framework"

	xcodebuild -create-xcframework \
	-framework $frameworkPath \
	-framework $frameworkPathSim \
	-output "$frName.xcframework"
}

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

make-xcframework "GiniHealthSDK" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
make-xcframework "GiniHealthAPILibrary" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
make-xcframework "GiniInternalPaymentSDK" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"
make-xcframework "GiniUtilites" "iphoneosHealth.xcarchive" "iphonesimulatorHealth.xcarchive"

# xcodebuild archive -workspace HealthSDK/GiniHealthSDK \
# -scheme GiniHealthSDK \
# -configuration Release \
# -destination 'generic/platform=iOS' \
# -archivePath "iphoneosHealth.xcarchive" \
# -derivedDataPath "health-build" \
# SKIP_INSTALL=NO

# xcodebuild archive -workspace HealthSDK/GiniHealthSDK \
# -scheme GiniHealthSDK \
# -configuration Release \
# -destination 'generic/platform=iOS Simulator' \
# -archivePath "iphonesimulatorHealth.xcarchive" \
# -derivedDataPath "health-build" \
# SKIP_INSTALL=NO