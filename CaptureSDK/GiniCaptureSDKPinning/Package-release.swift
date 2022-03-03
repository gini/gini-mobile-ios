// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GiniCaptureSDKPinning",
    defaultLocalization: "en",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GiniCaptureSDKPinning",
            targets: ["GiniCaptureSDKPinning"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniBankAPILibraryPinning", url: "https://github.com/gini/bank-api-library-pinning-ios.git", .exact("1.1.1")),
        .package(name: "GiniCaptureSDK", url: "https://github.com/gini/capture-sdk-ios.git", .exact("1.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .target(
            name: "GiniCaptureSDKPinning",
            dependencies: ["GiniBankAPILibraryPinning", "GiniCaptureSDK"]),
        .testTarget(
            name: "GiniCaptureSDKPinningTests",
            dependencies: ["GiniCaptureSDKPinning"]),
    ]
)
