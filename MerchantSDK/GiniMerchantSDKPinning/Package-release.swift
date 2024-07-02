// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GiniMerchantSDKPinning",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GiniMerchantSDKPinning",
            targets: ["GiniMerchantSDKPinning"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniHealthAPILibraryPinning", url: "https://github.com/gini/health-api-library-pinning-ios.git", .exact("4.1.0")),
        .package(name: "GiniMerchantSDK", url: "https://github.com/gini/merchant-sdk-ios.git", .exact("0.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GiniMerchantSDKPinning"),
        .testTarget(
            name: "GiniMerchantSDKPinningTests",
            dependencies: ["GiniMerchantSDKPinning"]),
    ]
)
