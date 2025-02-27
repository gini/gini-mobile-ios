// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "GiniUtilites",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GiniUtilites",
            type: ProcessInfo.processInfo.environment["GINI_FORCE_DYNAMIC_LIBRARY"] == "1" ? .dynamic : nil,
            targets: ["GiniUtilites"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GiniUtilites"),
        .testTarget(
            name: "GiniUtilitesTests",
            dependencies: ["GiniUtilites"]),
    ]
)
