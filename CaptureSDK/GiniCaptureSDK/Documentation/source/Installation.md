Installation
=============================

Gini Capture SDK can either be installed by using Swift Package Manager or by manually dragging the required XCFrameworks to your project.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniCaptureSDK` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/gini/capture-sdk-ios.git", .exact("2.0.0-beta07"))
]
```

In case that you want to use the certificate pinning in the library, add `GiniCaptureSDKPinning`:
```swift
dependencies: [
    .package(url: "https://github.com/gini/capture-sdk-pinning-ios.git", .exact("2.0.0-beta07"))
]
```

## XCFrameworks

If you prefer not to use a dependency management tool, you can integrate the Gini Capture SDK into your project manually.
To do so add the following frameworks into your project: 
- `GiniBankAPILibrary.xcframework`
- `GiniCaptureSDK.xcframework`.

In case that you want to use the certificate pinning you need to add the following frameworks:
 - `GiniBankAPILibrary.xcframework`
 - `GiniBankAPILibraryPinning.xcframework`
 - `GiniCaptureSDK.xcframework`
 - `GiniCaptureSDKPinning.xcframework`
 - `TrustKit.xcframework`

 The latest version of the frameworks is availiable on [github](https://github.com/gini/gini-mobile-ios/releases/tag/GiniBankSDK%3B1.11.2).
