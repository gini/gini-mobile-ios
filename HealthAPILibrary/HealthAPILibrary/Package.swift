// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HealthAPILibrary",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GiniHealthAPILibrary",
            targets: ["GiniHealthAPILibrary"]),
        .library(
            name: "GiniHealthAPILibrary+Pinning",
            targets: ["GiniHealthAPILibrary+Pinning"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "TrustKit", url: "git@github.com:datatheorem/TrustKit.git" , from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GiniHealthAPILibrary",
            dependencies: [],
            path: "Sources/GiniHealthAPILibrary/Documents"),
        .target(
            name: "GiniHealthAPILibrary+Pinning",
            dependencies: ["GiniHealthAPILibrary","TrustKit"],
            path: "Sources/GiniHealthAPILibrary/Pinning"),
        .testTarget(
            name: "HealthAPILibraryTests",
            dependencies: ["GiniHealthAPILibrary"]),
    ]
)
