
## Using Swift Package Manager instead of Cocoapods

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniBankSDK` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swif
dependencies: [
    .package(url: "https://github.com/gini/bank-sdk-ios.git", .exact("1.0.0"))
]
```
**Note: Availible from iOS 12**
In case that you want to use the certificate pinning in the library, add `GiniBankSDKPinning`:
```swif
dependencies: [
    .package(url: "https://github.com/gini/bank-sdk-pinning-ios.git", .exact("1.0.0"))
]
```

Migrate from Gini Pay Bank SDK to Gini Bank SDK
=======================================================

## Gini Capture SDK

The [Gini Capture SDK](https://github.com/gini/capture-sdk-ios) provides components for capturing, reviewing and analyzing photos of invoices and remittance slips. 

## Gini Bank API Library

The [Gini Bank API Library](https://github.com/gini/bank-api-library-ios) (`GiniBankAPI`) provides ways to interact with the Gini Bank API and therefore, adds the possiblity to scan documents and extract information from them and support the payment functionality.
The Gini Bank API Library will be used instead of the Gini Pay Api Library.

## Configuration

For customization the Gini Bank SDK uses `GiniBankConfiguration` class instead of `GiniPayBankConfiguration`. All settings from the `GiniPayBankConfiguration` are available in `GiniBankConfiguration`.

## Screen API

#### UI with Networking (Recommended)

In place of using `GiniPayBank`:
```swift
let viewController = GiniPayBank.viewController(withClient: client,
                                               configuration: giniPayBankConfiguration,
                                               resultsDelegate: giniCaptureResultsDelegate)

present(viewController, animated: true, completion: nil)
```

Please use the snippet with `GiniBank` method below:
```swift
let viewController = GiniBank.viewController(withClient: client,
                                               configuration: giniBankConfiguration,
                                               resultsDelegate: giniCaptureResultsDelegate)

present(viewController, animated: true, completion: nil)
```
#### Certificate pinning

If you're using _Certificate pinning_ and have the following lines in your code base:
```swift
let viewController = GiniPayBank.viewController(withClient: client,
                                               configuration: giniPayBankConfiguration,
                                               resultsDelegate: giniCaptureResultsDelegate,
                                               publicKeyPinningConfig: yourPublicPinningConfig,
                                               documentMetadata: documentMetadata,
                                               api: .default)

present(viewController, animated: true, completion:nil)
```

It should now become:
```swift
let viewController = GiniBank.viewController(withClient: client,
                                               configuration: giniBankConfiguration,
                                               resultsDelegate: giniCaptureResultsDelegate,
                                               publicKeyPinningConfig: yourPublicPinningConfig,
                                               documentMetadata: documentMetadata,
                                               api: .default)

present(viewController, animated: true, completion:nil)
```

#### Only UI

Now to handle all the analysis processes you should use the new [Gini Bank API Library](https://github.com/gini/bank-api-library-ios) or your own implementation of the new [Gini Bank API](https://pay-api.gini.net/documentation/#gini-pay-api-documentation-v1-0) and just get the `UIViewController` as follows:
```swift
let viewController = GiniBank.viewController(withDelegate: self,
                                               withConfiguration: giniBankConfiguration)

present(viewController, animated: true, completion: nil)
```

## Component API

The Component API provides a custom `UIViewController` for each screen. For example :

```swift
let giniBankConfiguration = GiniPayBankConfiguration()
.
.
.
let cameraScreen = CameraViewController(giniConfiguration: giniPayBankConfiguration.captureConfiguration())
GiniCapture.setConfiguration(giniPayBankConfiguration.captureConfiguration())
```

Now alternately of using `GiniPayBankConfiguration` in the Gini Bank SDK was introduced `GiniBankConfiguration`.
The configuration for `GiniCapture` should be set explicitly as it's shown below:
```swift
let giniBankConfiguration = GiniBankConfiguration()
.
.
.
let cameraScreen = CameraViewController(giniConfiguration: giniBankConfiguration.captureConfiguration())
GiniCapture.setConfiguration(giniBankConfiguration.captureConfiguration())
```
