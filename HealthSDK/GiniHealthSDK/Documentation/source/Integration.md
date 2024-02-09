Integration
=============================

The Gini Health SDK for iOS provides all the UI and functionality needed to use the Gini Health API in your app to extract payment and health information from invoices. The payment information can be reviewed and then the invoice can be paid using any available payment provider app (e.g., banking app).

The Gini Health API provides an information extraction service for analyzing health invoices. Specifically, it extracts information such as the document sender or the payment relevant information (amount to pay, IBAN, etc.). In addition it also provides a secure channel for sharing payment related information between clients. 

**Note** For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## Upload the document

Document upload can be done in two ways:

using `GiniHealthAPILibrary`
using `GiniCapture`


## GiniHealthAPI initialization

You should have received Gini Health API client credentials from us. Please get in touch with us in case you don't have them.

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
 let apiLib =  GiniHealthAPI.Builder(customApiDomain: "api.custom.net",
                                 alternativeTokenSource: MyAlternativeTokenSource)
                                 .build()
```
The token your provide will be added as a bearer token to all api.custom.net requests.

## Certificate pinning

If you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information)
```swift
    let giniApiLib = GiniHealthAPI
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

Now that the `GiniHealthAPI` has been initialized, you can initialize `GiniHealth`

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
* `healthSDK.checkIfAnyPaymentProviderAvailable()` with a networking call, returns a list of availible payment provider or informs that there are no supported banking apps installed,
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

## Payment component view initialization
We provide a custom payment component view meant to help user to pay the invoice/document.
Payment component looks like this: 
<br>
<center><img src="img/Customization guide/PaymentComponentView.PNG" height="400"/></center>
</br>

##### Steps to integrate payment component view:

##### 1. You need to instantiate a `PaymentComponentsController` class with a `GiniHealth` as parameter.
```swift
let paymentComponentsController = PaymentComponentsController(giniHealth: health)
```

##### 2. You need to pass this `paymentComponentsController` to the invoices/documents controller. 
There you should have a list of invoices/documents that conform to this structure: `GiniDocument`. 
```swift
public protocol GiniDocument {
    /// The document's unique identifier.
    var documentID: String { get set }
    /// The document's amount to pay.
    var amountToPay: String? { get set }
    /// The document's payment due date.
    var paymentDueDate: String? { get set }
    /// The document's recipient name.
    var recipient: String? { get set }
    /// Boolean value that indicates if the document is payable. This is obtained by calling the checkIfDocumentIsPayable method.
    var isPayable: Bool { get set }
    /// Store payment provider for each document/invoice. Payment provider is obtained by PaymentComponentsController and it's only stored here if the payment provider is installed
    var paymentProvider: PaymentProvider? { get set }
}
```

##### 3. For each invoice/document, you need to call the `checkIfDocumentIsPayable` function from the `paymentComponentsController` and store the value for each invoice in the `isPayable` field.
> - We recommend using a `DispatchGroup` for these requests and wait till all of them are ready. Then, reload the list.
```swift
public func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
```

##### 4. Also, after `paymentComponentsController` is instantiated, he will load in the background the list of payment providers available on your device. You should store for each invoice/document, in the `paymentProvider` variable, the first payment provider from the list. 
You can obtain that by calling: 
```swift
public func obtainFirstPaymentProvider() -> PaymentProvider?
```
> - You might have payment providers, or you may not. We also handle the missing payment provider state.
> - Based on the payment provider's colors, the `UIView` will automatically change it's color.

##### 5. Based on the `isPayable` value, you should add to your cells the payment component view that is obtained through this function:
```swift
public func getPaymentView(paymentProvider: PaymentProvider?) -> UIView
```
> - We recommend adding this `UIView` to a Vertical `UIStackView` and in every cell's `prepareForReuse()` function, remove the payment component view if it's present.
> - We also recommend using an automatic dimension height in the `UITableView` that is holding the cells

##### 6. `PaymentComponentsController` has 2 delegates that you can listen to: `PaymentComponentsControllerProtocol` and the `PaymentComponentViewProtocol`

* `PaymentComponentsControllerProtocol` provides informations when the `PaymentComponentsController` is loading. You can show/hide an `UIActivityIndicator` based on that.
* `PaymentComponentsControllerProtocol` provides completion handlers when `PaymentComponentsController` fetched successfully payment providers or when it failed with an error.

* `PaymentComponentViewProtocol` is the view protocol and provides events when the user tapped on various areas on the payment component view. Such as: More information label or more information icon, bank/payment provider picker or when it tapped on the pay invoice button.

> - Make sure you link this delegates in a proper way in order to get notified.

<br>
<center><img src="img/Customization guide/PaymentComponentScreen.PNG" height="500"/></center>
</br>
