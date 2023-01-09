Integration
=============================
## Request camera access

**Note**: You need to specify the `NSCameraUsageDescription` key in your `Info.plist` file.
This key is mandatory for all apps since iOS 10 when using the `Camera` framework.

Also if you're using the [Gini Bank API Library](https://github.com/gini/bank-api-library-ios) you need to add support for "Keychain Sharing" in your entitlements by adding a `keychain-access-groups` value to your entitlements file. 
For more information see the [Integration Guide](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/getting-started.html) of the Gini Bank API Library.

## Start SDK

The SDK provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.
Gini Capture SDK offers two different ways of the networking implementation:

### Default Networking (Recommended)

Using this method you don't need to care about handling the analysis process with the [Gini Bank API Library](https://github.com/gini/bank-api-library-ios), you only need to provide your API credentials and a delegate to get the analysis results.

```swift
let viewController = GiniCapture.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: resultsDelegate)

present(viewController, animated: true, completion:nil)
```

#### Certificate Pinning

Optionally if you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information), the metadata information and the _API type_ (the [Gini Pay API](https://pay-api.gini.net/documentation/#gini-pay-api-documentation-v1-0) is used by default) as follows:

```swift
import TrustKit

let yourPublicPinningConfig = [
    kTSKPinnedDomains: [
    "pay-api.gini.net": [
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
> - The document metadata for the upload process is intended to be used for reporting.
> - The multipage is supported only by the `.default` api.

#### Retrieve the Analyzed Document

The `AnalysisResult` returned in `GiniCaptureResultsDelegate.giniCaptureAnalysisDidFinishWith(result:)` 
will return the analyzed Gini Bank API document in its `document` property.

When extractions were retrieved without using the Gini Bank API, then the `AnalysisResult.document` will be `nil`. For example when the extractions came from an EPS QR Code.

### Custom Networking

You can also provide your own networking by implementing the `GiniCaptureNetworkService` and `GiniCaptureResultsDelegate` protocols. Pass your instances to the `UIViewController` initialiser of `GiniCapture` as shown below.

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

## Sending Feedback - TODO

Your app should send feedback for the extractions the Gini Bank API delivered. Feedback should be sent only for the extractions the user has seen and accepted (or corrected).

We provide a sample test case [here](https://github.com/gini/gini-mobile-ios/blob/main/CaptureSDK/GiniCaptureSDKExample/Tests/ExtractionFeedbackIntegrationTest.swift) to verify that extraction feedback sending works. 
You may use it along with the example pdf and json files as a starting point to write your own test case.

The sample test case is based on the Bank API documentation's [recommended steps](https://pay-api.gini.net/documentation/#test-example) for testing extraction feedback sending.

For additional information about feedback see the [Gini Bank API documentation](https://pay-api.gini.net/documentation/#send-feedback-and-get-even-better-extractions-next-time).

### Default networking implementation - TODO

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
### Custom networking implementation - TODO

If you use your own networking implementation and directly communicate with the Gini Bank API then see [this section](https://pay-api.gini.net/documentation/#submitting-feedback-on-extractions) in its documentation on how to send feedback.

In case you use the [Gini Bank API Library](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/) then see [this section](https://developer.gini.net/gini-mobile-ios/GiniBankAPILibrary/getting-started.html) in its documentation for details.

## Capturing documents

To launch the Gini Capture SDK you only need to:

1.  Request camera access via configuring `Info.plist` in your project.

2.  Configure `GiniConfiguration.shared`. The implementation example can be found [here](https://github.com/gini/gini-mobile-ios/blob/new-ui/CaptureSDK/GiniCaptureSDKExample/Example%20Swift/AppCoordinator.swift#L32)

3.  Present the `UIViewController`.

You can find the example [here](https://github.com/gini/gini-mobile-ios/blob/new-ui/CaptureSDK/GiniCaptureSDKExample/Example%20Swift/ScreenAPICoordinator.swift#L44)

4.  Handle the extraction results

For handling the extraction results you need to implement `GiniCaptureResultsDelegate `.
[Here](https://github.com/gini/gini-mobile-ios/blob/new-ui/CaptureSDK/GiniCaptureSDKExample/Example%20Swift/ScreenAPICoordinator.swift#L128) you can find the implementation example.

5.  Cleanup configuration and resources.

The cleanup step includes the previously called `feedback sending` method. You don't need to implement any extra steps, just follow the recommendations below:

 - Please do cleanup always for all necessary fields, including those that were not extracted.

 - Please do cleanup with final data approved by the user (and not initially extracted only).

 - Please do cleanup after TAN verification.

```swift
GiniConfiguration.shared.cleanup(paymentRecipient: "Payment Recipient",
                                        paymentReference: "Payment Reference",
                                        paymentPurpose: "Payment Purpose",
                                        iban: "IBAN",
                                        bic: "BIC",
                                        amountToPay: ExtractionAmount(value: 10.242, currency: .EUR))
```

Check out the [example app](https://github.com/gini/gini-mobile-ios/tree/new-ui/CaptureSDK/GiniCaptureSDKExample/Example%20Swift) to see how an integration could look like.
The following example shows how to launch the Gini Capture SDK and how to handle the extraction results.
