Integration
=============================

The Gini Health SDK for iOS provides all the UI and functionality needed to use the Gini Pay API in your app to extract payment and health information from invoices. The payment information can be reviewed and then the invoice can be paid using any available payment provider app (e.g., banking app).

The Gini Pay API provides an information extraction service for analyzing health invoices. Specifically, it extracts information such as the document sender or the payment relevant information (amount to pay, IBAN, etc.). In addition it also provides a secure channel for sharing payment related information between clients. 

**Note** For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## Upload the document

Document upload can be done in two ways:

using `GiniApiLib`
using `GiniCapture`


## GiniApiLib initialization

You should have received Gini Pay API client credentials from us. Please get in touch with us in case you don't have them.

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

## GiniHealth initialization

Now that the `GiniApiLib` has been initialized, you can initialize `GiniHealth`

```swift
 let healthSDK = GiniHealth(with: giniApiLib)
```
and upload your document if you plan to do it with `GiniHealth`. First you need get document service and create partial document.

```swift
let documentService: DefaultDocumentService = healthSDK.documentService()
documentService.createDocument(fileName:"ginipay-partial",
                               docType: nil,
                               type: .partial(documentData),
                               metadata: nil)
```
The method above returns the completion block with partial `Document` in success case.

After receiving the partial document in completion you can get actual composite document:

```swift
let partialDocs = [PartialDocumentInfo(document: createdDocument.links.document)]
 self.healthSDK.documentService
            .createDocument(fileName: "ginipay-composite",
                            docType: nil,
                            type: .composite(CompositeDocumentInfo(partialDocuments: partialDocs)),
                            metadata: nil)

```

##  Check preconditions

There are three methods in GiniHealth:

* `healthSDK.isAnyBankingAppInstalled(appSchemes: [String])` without a networking call, returns true when at least the one of the listed among `LSApplicationQueriesSchemes` in your `Info.plist` is installed on the device and can support Gini Pay functionality,
* `healthSDK.checkIfAnyPaymentProviderAvailiable()` with a networking call, returns a list of availible payment provider or informs that there are no supported banking apps installed,
* `healthSDK.checkIfDocumentIsPayable(docId: String)` returns true if Iban was extracted.

## Fetching data for payment review screen

If the preconditions checks are succeeded you can fetch the document and extractions for Payment Review screen:

```swift
healthSDK.fetchDataForReview(documentId: documentId,
                              completion: @escaping (Result<DataForReview, GiniHealthError>) -> Void)
```
The method above returns the completion block with the struct `DataForReview`, which includes document and extractions.

## Payment review screen initialization

```swift
let vc = PaymentReviewViewController.instantiate(with giniHealth: healthSDK,
                                                 data: dataForReview)
```
The screen can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

To also use the `GiniHealthConfiguration`:

```swift
let giniConfiguration = GiniHealthConfiguration()
config.loadingIndicatorColor = .black
.
.
.
healthSDK.setConfiguration(config)
```
## Gini Pay Deep Link For Your App

In order for banking apps to be able to return the user to your app after the payment has been resolved you need register a scheme for your app to respond to a deep link scheme known by the Gini Pay API.

You should already have a scheme and host from us. Please contact us in case you don't have them.

The following is an example for the deep link gini-health://payment-requester:
<br>
<center><img src="img/Integration guide/SchemeExample.png" width="600"/></center>
</br>
## Testing

An example banking app is available in the [Gini Pay Bank SDK's](https://github.com/gini/gini-pay-bank-sdk-ios) repository.

In order to test using our example banking app you need to use development client credentials. This will make sure
the Gini Health SDK uses a test payment provider which will open our example banking app. To inject your API credentials into the Bank example app you need to fill in your credentials in `Example/Bank/Credentials.plist`.

#### End to end testing

The app scheme in our banking example app: `ginipay-bank://`. Please, specify this scheme `LSApplicationQueriesSchemes` in your app in `Info.plist` file.

After you've set the client credentials in the example banking app and installed it on your device you can run your app
and verify that `healthtSDK.isAnyBankingAppInstalled(appSchemes: [String])` returns true and check other preconditions.

After following the integration steps above you'll arrive at the payment review screen.

Check that the extractions and the document preview are shown and then press the `Pay` button:

<br>
<center><img src="img/Customization guide/PaymentReview.PNG" height="500"/></center>
</br>

You should be redirected to the example banking app where the final extractions are shown:

<br>
<center><img src="img/Integration guide/ReviewScreenBeforeResolvingPayment.PNG" height="500"/></center>
</br>

After you press the `Pay` button the Gini Pay Bank SDK resolves the payment and allows you to return to your app:

<br>
<center><img src="img/Integration guide/ReviewScreenAfterResolvingPayment.PNG" height="500"/></center>
</br>

For handling incoming url in your app after redirecting back from the banking app you need to implement to handle the incoming url:
The following is an example for the url `gini-health://payment-requester`:

```swift
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == "payment-requester" {
            // hadle incoming url from the banking app
        }
        return true
    }
```

With these steps completed you have verified that your app, the Gini Pay API, the Gini Health SDK and the Gini Pay
Bank SDK work together correctly.

#### Testing in production

The steps are the same but instead of the development client credentials you will need to use production client
credentials. This will make sure the Gini Healthh SDK receives real payment providers which open real banking apps.

You will also need to install a banking app which uses the Gini Pay Bank SDK. Please contact us in case you don't know
which banking app(s) to install.

Lastly make sure that for production you register the scheme we provided you for deep linking and you are not using 
`gini-health://payment-requester`.
