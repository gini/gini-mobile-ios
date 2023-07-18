Getting started
=============================

## Requirements

- The minimum iOS version supported 12+.

In addition to the minimum iOS version we also have hardware requirements to ensure the best possible analysis
results:

- Back-facing camera with auto-focus and flash (iPhone).
- 8MP+ camera resolution. You can find the specification [here](https://developer.apple.com/library/archive/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/Cameras/Cameras.html)

## Installation

Gini Bank SDK can either be installed by using Swift Package Manager or by manually dragging the required XCFrameworks to your project.

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniBankSDK` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/gini/bank-sdk-ios.git", .exact("3.1.2"))
]
```
**Note: Available from iOS 12**
In case that you want to use the certificate pinning in the library, add `GiniBankSDKPinning`:
```swift
dependencies: [
    .package(url: "https://github.com/gini/bank-sdk-pinning-ios.git", .exact("3.1.2"))
]
```

## XCFrameworks

If you prefer not to use a dependency management tool, you can integrate the Gini Bank SDK into your project manually.
To do so add the following frameworks into your project: 
- `GiniBankAPILibrary.xcframework`
- `GiniCaptureSDK.xcframework`
- `GiniBankSDK.xcframework`.

In case that you want to use the certificate pinning you need to add the following frameworks:
 - `GiniBankAPILibrary.xcframework`
 - `GiniBankAPILibraryPinning.xcframework`
 - `GiniCaptureSDK.xcframework`
 - `GiniCaptureSDKPinning.xcframework`
 - `GiniBankSDK.xcframework`
 - `GiniBankSDKPinning.xcframework`
 - `TrustKit.xcframework`

 The latest version of the frameworks is available on [github](https://github.com/gini/gini-mobile-ios/releases/).
