Installation
=============================

Gini Health SDK can either be installed by using Swift Package Manager or by manually dragging the required files to your project.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniHealthSDK` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/gini/health-sdk-ios.git", .exact("4.3.0"))
]
```

In case that you want to use [the certificate pinning](https://www.ssl.com/blogs/what-is-certificate-pinning/#:~:text=Certificate%20pinning%20is%20a%20security,(Transport%20Layer%20Security)%20protocols.) in the library, add `GiniHealthAPILibraryPinning`:
```swift
dependencies: [
    .package(url: "https://github.com/gini/health-sdk-pinning-ios.git", .exact("4.3.0"))
]
```
