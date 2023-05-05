Integration
=============================

The Gini Capture SDK provides two integration options. A [Screen API](#screen-api) that is easy to implement and a more complex, but also more flexible [Component API](#component-api). Both APIs can access the complete functionality of the SDK.

**Note**: You need to specify the `NSCameraUsageDescription` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when using the `Camera` framework. Also if you're using the [Gini Bank API Library](https://github.com/gini/bank-api-library-ios) you need to add support for "Keychain Sharing" in your entitlements by adding a `keychain-access-groups` value to your entitlements file. For more information see the [Integration Guide](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/getting-started.html) of the Gini Bank API Library.

## Screen API

The Screen API provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.
The Screen API, in turn, offers two different ways of implementation:

### UI with Default Networking (Recommended)
Using this method you don't need to care about handling the analysis process with the [Gini Bank API Library](https://github.com/gini/bank-api-library-ios), you only need to provide your API credentials and a delegate to get the analysis results.

```swift
let viewController = GiniCapture.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: resultsDelegate)

present(viewController, animated: true, completion:nil)
```

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
    let viewController = GiniCapture.viewController(withClient: client,
                                                    configuration: configuration,
                                                    resultsDelegate: resultsDelegate,
                                                    api: .custom(domain: "api.custom.net",
                                                                tokenSource: MyAlternativeTokenSource))
```
The token you provide will be added as a bearer token to all `api.custom.net` requests.

You can also specify a custom path segment, if your proxy url requires it:

```swift
    let viewController = GiniCapture.viewController(withClient: client,
                                                    configuration: configuration,
                                                    resultsDelegate: resultsDelegate,
                                                    api: .custom(domain: "api.custom.net",
                                                                path: "/custom/path",
                                                                tokenSource: MyAlternativeTokenSource))
```

#### Certificate Pinning

Optionally if you want to use _Certificate pinning_ and provide metadata for the upload process, you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information), the metadata information and the _API type_ (the [Gini Pay API](https://pay-api.gini.net/documentation/#gini-pay-api-documentation-v1-0) is used by default) as follows:

```swift
import TrustKit

let yourPublicPinningConfig = [
    kTSKPinnedDomains: [
    "api.gini.net": [
        kTSKPublicKeyHashes: [
        // old *.gini.net public key
        "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
        // new *.gini.net public key, active from around June 2020
        "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
    ]],
    "user.gini.net": [
        kTSKPublicKeyHashes: [
        // old *.gini.net public key
        "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
        // new *.gini.net public key, active from around June 2020
        "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
    ]],
]] as [String: Any]

let viewController = GiniCapture.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: resultsDelegate,
                                               publicKeyPinningConfig: yourPublicPinningConfig,
                                               documentMetadata: documentMetadata,
                                               api: .default)

present(viewController, animated: true, completion:nil)
```
**Note**: Starting from Gini Capture SDK version 1.0.6 certificate pinning requires **iOS 12**.

> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting. You can find out more about it in the [Gini Bank API](https://pay-api.gini.net/documentation) documentation.
> - The multipage is supported only by the `.default` api.

#### Retrieve the Analyzed Document

The `AnalysisResult` returned in `GiniCaptureResultsDelegate.giniCaptureAnalysisDidFinishWith(result:, sendFeedbackBlock:)` 
will return the analyzed Gini Bank API document in its `document` property.

When extractions were retrieved without using the Gini Bank API, then the `AnalysisResult.document` will be `nil`. For example when the
extractions came from an EPS QR Code.

### UI with Custom Networking
You can also provide your own networking by implementing the `GiniCaptureNetworkService` and `GiniCaptureResultsDelegate` protocols. Pass your instances to the UIViewController initialiser of GiniCapture as shown below.

```swift
let viewController = GiniCapture.viewController(importedDocuments: visionDocuments,
                                                configuration: visionConfiguration,
                                                resultsDelegate: resultsDelegate,
                                                documentMetadata: documentMetadata,
                                                trackingDelegate: trackingDelegate,
                                                networkingService: networkingService)


present(viewController, animated: true, completion: nil)
```
You may also use the [Gini Bank API Library](https://github.com/gini/bank-api-library-ios) or implement communication with the Gini Bank API yourself.
## Component API

The Component API provides a custom `UIViewController` for each screen. This allows a maximum of flexibility, as the screens can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

To also use the `GiniConfiguration` with the Component API just use the `GiniCapture.setConfiguration(_:)` as follows:

```swift
let giniConfiguration = GiniConfiguration()
.
.
.
GiniCapture.setConfiguration(giniConfiguration)
```

The components that can be found in the SDK are:
* **Camera**: The actual camera screen to capture the image of the document, to import a PDF or an image or to scan a QR Code (`CameraViewController`).
* **Review**: Offers the opportunity to the user to check the sharpness of the image and eventually to rotate it into reading direction (`ReviewViewController`).
* **Multipage Review**: Allows to check the quality of one or several images and the possibility to rotate and reorder them (`MultipageReviewViewController`).
* **Analysis**: Provides a UI for the analysis process of the document by showing the user capture tips when an image is analyzed or the document information when it is a PDF. In both cases an image preview of the document analyzed will be shown (`AnalysisViewController`).
* **Help**: Helpful tutorials indicating how to use the open with feature, which are the supported file types and how to capture better photos for a good analysis (`HelpMenuViewController`).
* **No results**: Shows some suggestions to capture better photos when there are no results after an analysis (`ImageAnalysisNoResultsViewController`).

## Sending Feedback

Your app should send feedback for the extractions the Gini Bank API delivered. Feedback should be sent only for the extractions the user has seen and accepted (or corrected).

We provide a sample test case [here](https://github.com/gini/gini-mobile-ios/blob/main/CaptureSDK/GiniCaptureSDKExample/Tests/ExtractionFeedbackIntegrationTest.swift) to verify that extraction feedback sending works. 
You may use it along with the example pdf and json files as a starting point to write your own test case.

The sample test case is based on the Bank API documentation's [recommended steps](https://pay-api.gini.net/documentation/#test-example) for testing extraction feedback sending.

For additional information about feedback see the [Gini Bank API documentation](https://pay-api.gini.net/documentation/#send-feedback-and-get-even-better-extractions-next-time).

### Default networking implementation

The example below shows how to correct extractions and send feedback using the default networking implementation:

You should send feedback only for extractions the user has seen and accepted.

```swift
var sendFeedbackBlock: (([String: Extraction]) -> Void)?
var extractions: [String: Extraction] = []

func giniCaptureAnalysisDidFinishWith(result: AnalysisResult,
                           sendFeedbackBlock: @escaping ([String: Extraction]) -> Void){
        
    self.extractions = result.extractions
    self.sendFeedbackBlock = sendFeedbackBlock
    showResultsScreen(results: result.extractions.map { $0.value })
}
.
.
.
// In this example only the amountToPay was wrong and we can reuse the other extractions.
let updatedExtractions = self.extractions
updatedExtractions.map{$0.value}.first(where: {$0.name == "amountToPay"})?.value = "31,25:EUR"
sendFeedbackBlock(updatedExtractions)

```
### Custom networking implementation

If you use your own networking implementation and directly communicate with the Gini Bank API then see [this section](https://pay-api.gini.net/documentation/#submitting-feedback-on-extractions) in its documentation on how to send feedback.

In case you use the [Gini Bank API Library](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/) then see [this section](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/getting-started.html) in its documentation for details.