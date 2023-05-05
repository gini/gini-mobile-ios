
## Using Swift Package Manager instead of Cocoapods

The [Swift Package Manager](https://swift.org/package-manager/)  is a tool for managing the distribution of Swift code.
Once you have your Swift package set up, adding `GiniBankSDK` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`

```swif
dependencies: [
    .package(url: "https://github.com/gini/bank-sdk-ios.git", .exact("1.0.0"))
]
```
**Note: Available from iOS 12**
In case that you want to use the certificate pinning in the library, add `GiniBankSDKPinning`:
```swif
dependencies: [
    .package(url: "https://github.com/gini/bank-sdk-pinning-ios.git", .exact("1.0.0"))
]
```

Migrate from Gini Vision Library to Gini Bank SDK
=======================================================

## Gini Capture SDK

The [Gini Capture SDK](https://github.com/gini/gini-capture-sdk-ios) provides components for capturing, reviewing and analyzing photos of invoices and remittance slips. 
The Gini Capture SDK (`GiniCapture`) will be used in place of the Gini Vision Library (`GiniVision`). 
The Gini Capture SDK used by the Gini Pay Bank SDK and therefore will be mentioned in the migration guide in a couple of places.

## Gini Bank API Library

The [Gini Bank Api Library](https://github.com/gini/bank-api-library-ios) (`GiniBankAPI`) provides ways to interact with the Gini Bank API and therefore, adds the possiblity to scan documents and extract information from them and support the payment functionality.
The Gini Bank API Library will be used instead of the Gini iOS SDK.

## Configuration

For customization the Gini Bank SDK uses `GiniBankConfiguration` class - extended version of `GiniConfiguration`. All settings from the `GiniConfiguration` are available in `GiniBankConfiguration`.

## Screen API

#### UI with Networking (Recommended)

In place of using `GiniVision`:
```swift
let viewController = GiniVision.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: resultsDelegate)

present(viewController, animated: true, completion:nil)
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
let viewController = GiniVision.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: resultsDelegate,
                                               publicKeyPinningConfig: yourPublicPinningConfig,
                                               documentMetadata: documentMetadata,
                                               api: .accounting)

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

For using only the UI and the handling the analysis processes either was used [Gini API SDK](https://github.com/gini/gini-ios) or your own implementation of the [Gini API](https://developer.gini.net/gini-api/html/index.html). The `UIViewController` initialization was following:
```swift
let viewController = GiniVision.viewController(withDelegate: self,
                                               withConfiguration: giniConfiguration)

present(viewController, animated: true, completion: nil)
```

Now to handle all the analysis processes you should use the new [Gini Bank API Library](https://github.com/gini/bank-api-library-ios) or your own implementation of the new [Gini Bank API](https://bank-api.gini.net/documentation/#gini-bank-api-documentation-v1-0) and just get the `UIViewController` as follows:
```swift
let viewController = GiniBank.viewController(withDelegate: self,
                                               withConfiguration: giniBankConfiguration)

present(viewController, animated: true, completion: nil)
```

## Component API

The Component API provides a custom `UIViewController` for each screen. For example :

```swift
let giniConfiguration = GiniConfiguration()
.
.
.
let cameraScreen = CameraViewController(giniConfiguration: giniConfiguration)
cameraScreen?.delegate = self
present(cameraScreen, animated: true, completion: nil)
```

Now alternately of using `GiniConfiguration` in the Gini Bank SDK was introduced `GiniBankConfiguration`.
The configuration for `GiniCapture` should be set explicitly as it's shown below:
```swift
let giniBankConfiguration = GiniBankConfiguration()
.
.
.
let cameraScreen = CameraViewController(giniConfiguration: giniBankConfiguration.captureConfiguration())
GiniCapture.setConfiguration(giniBankConfiguration.captureConfiguration())
```

## Open With

In order to define that the file opened is valid (correct size, correct type and number of pages below the threshold on PDFs), it is necessary to validate it before using it. Previously you've could validate the file:
```swift
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        // 1. Build the document
        let documentBuilder = GiniVisionDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        
        documentBuilder.build(with: url) { [weak self] (document) in
            
            guard let self = self else { return }
            
            // 2. Validate the document
            if let document = document {
                do {
                    try GiniVision.validate(document,
                                            withConfig: self.giniConfiguration)
                    // Load the GiniVision with the validated document
                } catch {
                    // Show an error pointing out that the document is invalid
                }
            }
        }

        return true
}
```
Now, using the Gini Bank SDK your code should be similar to:
```swift
func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {            

        // 1. Build the document
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        
        documentBuilder.build(with: url) { [weak self] (document) in
            
            guard let self = self else { return }
            
            // 2. Validate the document
            if let document = document {
                do {
                    try GiniCapture.validate(document,
                                             withConfig: giniBankConfiguration.captureConfiguration())
                    // Load the GiniCapture with the validated document
                } catch {
                    // Show an error pointing out that the document is invalid
                }
            }
        }

        return true
}
```
## Event Tracking

The version 5.2 of Gini Vision Library has introduces the ability to track user events. For receiving the events, you've implemented the `GiniVisionTrackingDelegate` protocol and supplied the delegate when initializing GVL. For example:
```swift
let viewController = GiniVision.viewController(withClient: client,
                                               importedDocuments: visionDocuments,
                                               configuration: visionConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata,
                                               trackingDelegate: trackingDelegate)

// Or when not using the default network implementation pod GiniVision/Networking:
let viewController = GiniVision.viewController(withDelegate: self,
                                               withConfiguration: visionConfiguration,
                                               importedDocument: nil,
                                               trackingDelegate: trackingDelegate)
```

For receiving the events with the Gini Bank SDK, you need to import `GiniCapture` and implement the `GiniCaptureTrackingDelegate` protocol and supply the delegate when initializing `GiniBank` like it's shown below:
```swift
let viewController = GiniBank.viewController(withClient: client,
                                               importedDocuments: captureDocuments,
                                               configuration: giniBankConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata,
                                               trackingDelegate: trackingDelegate)

// Or when not using the default network:
let viewController = GiniBank.viewController(withDelegate: self,
                                               withConfiguration: giniBankConfiguration,
                                               importedDocument: nil,
                                               trackingDelegate: trackingDelegate)
```

## Customization

The Gini Vision Library components were customized either through the `GiniConfiguration`, the `Localizable.strings` file or through the assets.
Тhe Gini Bank SDK components are customizable either through the `GiniBankConfiguration`, the `Localizable.strings` file or through the assets. The main change for Localizable.strings is that instead of the `ginivision` prefix for keys now used `ginicapture`. The names for images in the assets have stayed the same as before.
