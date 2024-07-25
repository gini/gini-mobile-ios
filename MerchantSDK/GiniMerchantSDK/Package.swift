// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GiniMerchantSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GiniMerchantSDK",
            targets: ["GiniMerchantSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniHealthAPILibrary", path: "../../HealthAPILibrary/GiniHealthAPILibrary"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(
            name: "GiniMerchantSDK",
            dependencies: ["GiniHealthAPILibrary"]),
        .testTarget(
            name: "GiniMerchantSDKTests",
            dependencies: ["GiniMerchantSDK"],
            resources: [
                .process("Resources")
            ]),
    ]
)
