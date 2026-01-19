// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "GiniInternalPaymentSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GiniInternalPaymentSDK",
            type: ProcessInfo.processInfo.environment["GINI_FORCE_DYNAMIC_LIBRARY"] == "1" ? .dynamic : nil,
            targets: ["GiniInternalPaymentSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniHealthAPILibrary", path: "../../HealthAPILibrary/GiniHealthAPILibrary"),
        .package(name: "GiniUtilites", path: "../../GiniComponents/GiniUtilites")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GiniInternalPaymentSDK",
            dependencies: ["GiniHealthAPILibrary", "GiniUtilites"]),
        .testTarget(
            name: "GiniInternalPaymentSDKTests",
            dependencies: ["GiniInternalPaymentSDK"]),
    ]
)
