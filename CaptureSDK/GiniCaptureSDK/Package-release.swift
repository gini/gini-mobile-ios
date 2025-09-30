// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GiniCaptureSDK",
    defaultLocalization: "de",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GiniCaptureSDK",
            targets: ["GiniCaptureSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "GiniBankAPILibrary", url: "https://github.com/gini/bank-api-library-ios.git", .exact("3.8.0")),
        .package(name: "GiniUtilites", url: "https://github.com/gini/utilites-ios.git", .exact("2.0.4")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .target(
            name: "GiniCaptureSDK",
            dependencies: ["GiniBankAPILibrary"
                          ]),
        .testTarget(
            name: "GiniCaptureSDKTests",
            dependencies: ["GiniCaptureSDK"],
            resources: [.process("Resources")])
    ]
)
