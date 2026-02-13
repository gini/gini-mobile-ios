// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "GiniMerchantSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GiniMerchantSDK",
            type: ProcessInfo.processInfo.environment["GINI_FORCE_DYNAMIC_LIBRARY"] == "1" ? .dynamic : nil,
            targets: ["GiniMerchantSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniHealthAPILibrary", path: "../../HealthAPILibrary/GiniHealthAPILibrary"),
        .package(name: "GiniInternalPaymentSDK", path: "../../GiniComponents/GiniInternalPaymentSDK"),
        .package(name: "GiniUtilites", path: "../../GiniComponents/GiniUtilites")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(
            name: "GiniMerchantSDK",
            dependencies: ["GiniHealthAPILibrary", "GiniInternalPaymentSDK", "GiniUtilites"]),
        .testTarget(
            name: "GiniMerchantSDKTests",
            dependencies: ["GiniMerchantSDK"],
            resources: [
                .process("Resources")
            ]),
    ]
)
