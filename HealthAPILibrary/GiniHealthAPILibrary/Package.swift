// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "GiniHealthAPILibrary",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GiniHealthAPILibrary",
            type: ProcessInfo.processInfo.environment["GINI_FORCE_DYNAMIC_LIBRARY"] == "1" ? .dynamic : nil,
            targets: ["GiniHealthAPILibrary"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GiniHealthAPILibrary",
            dependencies: []),
        .testTarget(
            name: "GiniHealthAPILibraryTests",
            dependencies: ["GiniHealthAPILibrary"],
            resources: [
                    .process("Resources")
                ]),
    ]
)
