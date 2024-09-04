// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GiniPaymentComponents",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GiniPaymentComponents",
            targets: ["GiniPaymentComponents"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniHealthAPILibrary", url: "https://github.com/gini/health-api-library-ios.git", .exact("4.3.0")),
        .package(name: "GiniUtilites", url: "https://github.com/gini/utilites-ios.git", .exact("1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GiniPaymentComponents",
            dependencies: ["GiniHealthAPILibrary", "GiniUtilites"]),
        .testTarget(
            name: "GiniPaymentComponentsTests",
            dependencies: ["GiniPaymentComponents"]),
    ]
)
