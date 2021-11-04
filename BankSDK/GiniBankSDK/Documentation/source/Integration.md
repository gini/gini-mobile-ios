Integration
=============================

Gini Pay provides an information extraction system for analyzing business invoices and transfers them to the iOS banking app, where the payment process will be completed.

The Gini Pay Bank SDK for iOS provides functionality to upload the multipage documents with mobile phones, accurate line item extraction enables the user to to pay the invoice with prefferable payment provider. 

Payment functionality
=======================

**Note** For supporting your banking app as a payment provider you need to register Gini Pay URL scheme in you  in your `Info.plist` file. Gini Pay URL schemes for specification will be provided by Gini.

<br>
<center><img src="img/definingCustomUrl.png" height="200"/></center>
</br>

#### GiniApiLib initialization

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
 let apiLib =  GiniApiLib.Builder(customApiDomain: "api.custom.net",
                                 alternativeTokenSource: MyAlternativeTokenSource)
                                 .build()
```
The token your provide will be added as a bearer token to all api.custom.net requests.

Optionally if you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information)
```swift
    let giniApiLib = GiniApiLib
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .default,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```
> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting.

##  GiniPayBank initialization

Now that the `GiniApiLib` has been initialized, you can initialize `GiniPayBank`

```swift
 let bankSDK = GiniPayBank(with: giniApiLib)
```
and receive the payment requestID in `AppDelegate`. For handling incoming URL, please use the code snippet below.

```swift
func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        receivePaymentRequestId(url: url) { result in
            switch result {
            case let .success(requestId):
                self.paymentRequestId = requestId
            case .failure:
                break
            }
        }
        return true
    }
```
##  Fetching payment information

After receiving the payment request id you can get fetch the payment information:

```swift

bankSDK.receivePaymentRequest(paymentRequestId: appDelegate.paymentRequestId)

```
The method above returns the completion block with the struct `PaymentRequest`, which includes recipient, iban, amount and purpose fields.

##  Resolving payment request

```swift

bankSDK.resolvePaymentRequest(paymentRequesId: appDelegate.paymentRequestId,
                                 paymentInfo: paymentInfo)

```
The method above returns the completion block with the struct `ResolvedPaymentRequest`, which includes `requesterUri` for redirecting back to the payment requester's app.

##  Redirecting back to the payment requester app

If the payment request was successfully resolved you can allow the user redirect back to the payment requester app:

```swift
bankSDK.returnBackToBusinessAppHandler(resolvedPaymentRequest: resolvedPayment)
```
## Gini Pay Scheme For Your App

In order for your banking app to be available as a payment provider and support the Gini Pay Connect functionality, you need to register a URL scheme for your app known by the Gini Pay API.

You should already have a scheme and host from us. Please contact us in case you don't have them.

The following is an example for the scheme ginipay-bank://
<br>
<center><img src="img/Integration guide/BankSchemeExample.png" height="200"/></center>
</br>

## Testing

An example business app is available in the [Gini Pay Business SDK's](https://github.com/gini/gini-pay-business-sdk-ios) repository.

In order to test using our example business app, you need to use development client credentials. This will make sure that the Gini Pay Business SDK uses a payment provider which will open your development banking app.

To inject your Gini Pay API credentials into the business example app you need to fill in your credentials in `Example/Example Swift/Credentials.plist`.

You also need to replace the `ginipay-bank` URL scheme in the example business app's `LSApplicationQueriesSchemes` in the `Info.plist` with the Gini Pay URL scheme we provided for your banking app.

#### End to end testing

After you've set the client credentials in the example business app and installed it on your device you can start the payment flow with a document import or by taking a photo.

After following the integration steps above your banking app will be launched and you'll be able to fetch the payment request, show the payment information and resolve the payment after the transaction has been confirmed. At this point, you may redirect back to the business app.

With these steps completed you have verified that your app, the Gini Pay API, the Gini Pay Business SDK and the Gini Pay
Bank SDK work together correctly.

#### Testing in production

The steps are the same but instead of the development client credentials, you will need to use production client credentials. This will make sure the Gini Pay Business SDK receives real payment providers including the one which opens your production banking app.

For testing the flow using the example business app you will need to add your banking app's production Gini Pay URL scheme to `LSApplicationQueriesSchemes` in the example business app's `Info.plist`. Also please make sure that production client credentials are used before installing it.

You can also test with a real business app. Please contact us in case you don't know which business app(s) to install for starting the payment flow.

Photo payment functionality
============================

The Gini Pay Bank SDK provides two integration options. A [Screen API](#screen-api) that is easy to implement and a more complex, but also more flexible [Component API](#component-api). Both APIs can access the complete functionality of the SDK.

**Note**: Irrespective of the option you choose if you want to support **iOS 10** you need to specify the `NSCameraUsageDescription` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when using the `Camera` framework.
Also if you're using the [Gini Pay Api Library](https://github.com/gini/gini-pay-api-lib-ios) you need to add support for "Keychain Sharing" in your entitlements by adding a `keychain-access-groups` value to your entitlements file. For more information see the [Integration Guide](https://developer.gini.net/gini-pay-api-lib-ios/docs/getting-started.html) of the Gini Pay Api Library.

## Screen API

The Screen API provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.
The Screen API, in turn, offers two different ways of implementation:

#### UI with Networking (Recommended)
Using this method you don't need to care about handling the analysis process with the [Gini Pay Api Library]](https://github.com/gini/gini-pay-api-lib-ios), you only need to provide your API credentials and a delegate to get the analysis results.

```swift
let viewController = GiniPayBank.viewController(withClient: client,
                                               configuration: giniPayBankConfiguration,
                                               resultsDelegate: giniCaptureResultsDelegate)

present(viewController, animated: true, completion: nil)
```

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

let viewController = GiniPayBank.viewController(withClient: client,
                                               configuration: giniPayBankConfiguration,
                                               resultsDelegate: giniCaptureResultsDelegate,
                                               publicKeyPinningConfig: yourPublicPinningConfig,
                                               documentMetadata: documentMetadata,
                                               api: .default)

present(viewController, animated: true, completion:nil)
```


> ⚠️  **Important**
> - The document metadata for the upload process is intended to be used for reporting.
> - Starting from Gini Pay Bank SDK 1.0.3 certification pinning requires iOS 12.

#### Only UI

In case that you decide to use only the UI and to handle all the analysis process (either using the [Gini Pay Api Library](https://github.com/gini/gini-pay-api-lib-ios) or with your own implementation of the API), just get the `UIViewController` as follows:

```swift
let viewController = GiniPayBank.viewController(withDelegate: self,
                                               withConfiguration: giniPayBankConfiguration)

present(viewController, animated: true, completion: nil)
```

## Component API

The Component API provides a custom `UIViewController` for each screen. This allows a maximum of flexibility, as the screens can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

For using the `GiniPayBankConfiguration` with the Component API:

```swift
let giniPayBankConfiguration = GiniPayBankConfiguration()
.
.
.
GiniCapture.setConfiguration(giniPayBankConfiguration.captureConfiguration())
```

The components that can be found in the library are:
* **Camera**: The actual camera screen to capture the image of the document, to import a PDF or an image or to scan a QR Code (`CameraViewController`).
* **Review**: Offers the opportunity to the user to check the sharpness of the image and eventually to rotate it into reading direction (`ReviewViewController`).
* **Multipage Review**: Allows to check the quality of one or several images and the possibility to rotate and reorder them (`MultipageReviewViewController`).
* **Analysis**: Provides a UI for the analysis process of the document by showing the user capture tips when an image is analyzed or the document information when it is a PDF. In both cases an image preview of the document analyzed will be shown (`AnalysisViewController`).
* **Help**: Helpful tutorials indicating how to use the open with feature, which are the supported file types and how to capture better photos for a good analysis (`HelpMenuViewController`).
* **No results**: Shows some suggestions to capture better photos when there are no results after an analysis (`ImageAnalysisNoResultsViewController`).

## Sending Feedback

Your app should send feedback for the extractions the Gini Pay API delivered. Feedback should be sent only for the extractions the user has seen and accepted (or corrected).

For additional information about feedback see the [Gini Pay API documentation](https://pay-api.gini.net/documentation/#send-feedback-and-get-even-better-extractions-next-time).

### Default Implementation

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
### Custom Implementation

If you use your own networking implementation and directly communicate with the Gini Pay API then see [this section](https://pay-api.gini.net/documentation/#submitting-feedback-on-extractions) in its documentation on how to send feedback.

In case you use the [Gini Pay API Library](https://developer.gini.net/gini-pay-api-lib-ios/docs/) then see [this section](https://developer.gini.net/gini-pay-api-lib-ios/docs/getting-started.html) in its documentation for details.
