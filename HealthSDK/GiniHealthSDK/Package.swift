// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GiniHealthSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GiniHealthSDK",
            targets: ["GiniHealthSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniHealthAPILibrary", path: "../../HealthAPILibrary/GiniHealthAPILibrary"),
        .package(name: "GiniPaymentComponents", path: "../../GiniComponents/GiniPaymentComponents"),
        .package(name: "GiniUtilites", path: "../../GiniComponents/GiniUtilites")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .target(
            name: "GiniHealthSDK",
            dependencies: ["GiniHealthAPILibrary", "GiniPaymentComponents", "GiniUtilites"]),
        .testTarget(
            name: "GiniHealthSDKTests",
            dependencies: ["GiniHealthSDK"],
            resources: [
                .process("Resources")
            ]),
    ]
)
