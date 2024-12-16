// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "GiniBankSDKPinning",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GiniBankSDKPinning",
            type: ProcessInfo.processInfo.environment["GINI_FORCE_DYNAMIC_LIBRARY"] == "1" ? .dynamic : nil,
            targets: ["GiniBankSDKPinning"]),
    ],
    dependencies: [
        .package(name: "TrustKit", url: "https://github.com/datatheorem/TrustKit.git", from: "2.0.0"),
        .package(name: "GiniCaptureSDK", path: "../../CaptureSDK/GiniCaptureSDK"),
        .package(name: "GiniCaptureSDKPinning", path: "../../CaptureSDK/GiniCaptureSDKPinning"),
        .package(name: "GiniBankAPILibrary", path: "../../BankAPILibrary/GiniBankAPILibrary"),
        .package(name: "GiniBankAPILibraryPinning", path: "../../BankAPILibrary/GiniBankAPILibraryPinning"),
        .package(name: "GiniBankSDK", path: "../GiniBankSDK")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .target(
            name: "GiniBankSDKPinning",
            dependencies: ["GiniCaptureSDKPinning",
                           "GiniCaptureSDK",
                           "GiniBankAPILibraryPinning",
                           "GiniBankSDK",
                           "TrustKit",
                           "GiniBankAPILibrary"]),
        .testTarget(
            name: "GiniBankSDKPinningTests",
            dependencies: ["GiniBankSDKPinning"])
    ]
)
