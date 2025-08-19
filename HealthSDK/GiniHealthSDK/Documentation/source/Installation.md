Installation
=============================

Gini Health SDK can either be installed by using Swift Package Manager or by manually dragging the required files to your project.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniHealthSDK` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/gini/health-sdk-ios.git", .exact("5.6.1"))
]
```
