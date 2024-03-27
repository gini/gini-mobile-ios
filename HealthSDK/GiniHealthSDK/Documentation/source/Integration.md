Integration
=============================

The Gini Health SDK for iOS provides all the UI and functionality needed to use the Gini Health API in your app to extract payment and health information from invoices. The payment information can be reviewed and then the invoice can be paid using any available payment provider app (e.g., banking app).

The Gini Health API provides an information extraction service for analyzing health invoices. Specifically, it extracts information such as the document sender or the payment relevant information (amount to pay, IBAN, etc.). In addition it also provides a secure channel for sharing payment related information between clients. 

**Note** For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## GiniHealthAPI initialization

You should have received Gini Health API client credentials from us. Please get in touch with us in case you don't have them.

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
 let apiLib =  GiniHealthAPI.Builder(customApiDomain: "api.custom.net",
                                 alternativeTokenSource: MyAlternativeTokenSource)
                                 .build()
```
The token your provide will be added as a bearer token to all api.custom.net requests.

## Certificate pinning (optional)

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
## Upload the document
 
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

## Check which documents/invoices are payable

There is a method in GiniHealth:

* `healthSDK.checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void)` returns success and `true` value if Iban was extracted.

> - We recommend using a `DispatchGroup` for these requests, waiting till all of them are ready, and then, reloading the list.

```swift
for giniDocument in dataDocuments {
   dispatchGroup.enter()
   self.paymentComponentsController.checkIfDocumentIsPayable(docId: createdDocument.id, completion: { [weak self] result in
       switch result {
       // ...
       }
       self?.dispatchGroup.leave()
   })
}
dispatchGroup.notify(queue: .main) {
    // Reload List
}
```

## Integrate the Payment component view

We provide a custom payment component view to help users pay the invoice/document.
Please follow the steps below for the payment component integration.

### 1. Create an instance of the `PaymentComponentsController` class with a `GiniHealth` as parameter.

```swift
let paymentComponentsController = PaymentComponentsController(giniHealth: health)
```

### 2. Load the payment providers by calling the `loadPaymentProviders` function from the `PaymentComponentsController` and listen to the `PaymentComponentsControllerProtocol`.

```swift
paymentComponentsController.delegate = self // where self is your viewController
paymentComponentsController.loadPaymentProviders()
```
* `PaymentComponentsControllerProtocol` provides information when the `PaymentComponentsController` is loading.
You can show/hide an `UIActivityIndicator` based on that.
* `PaymentComponentsControllerProtocol` provides completion handlers when `PaymentComponentsController` fetched successfully payment providers or when it failed with an error.

**Note:**
It should be sufficient to call paymentComponentsController.loadPaymentProviderApps() only once when your app starts.

> - We effectively handle situations where there are no payment providers available.
> - Based on the payment provider's colors, the `UIView` will automatically change its color.

### 3. Show the Payment Component view and listen to the `PaymentComponentViewProtocol`.

Depending on the value of `isPayable`, incorporate the corresponding payment component view into your cells using this function:

```swift
public func paymentView(documentId: String) -> UIView
```

> - We suggest placing this `UIView` within a vertical `UIStackView`. Additionally, in the `prepareForReuse()` function of each cell, remove the payment component view if it exists.
> - Furthermore, employing automatic dimension height in the `UITableView` containing the cells is recommended.

* `PaymentComponentViewProtocol` is the view protocol and provides events handlers when the user tapped on various areas on the payment component view (more information icon, bank/payment provider picker, the pay invoice button and etc.).

> - Make sure you properly link these delegates to get notified.

## Payment review screen

If the preconditions checks are succeeded you can fetch the document and extractions for Payment Review screen:

```swift
healthSDK.fetchDataForReview(documentId: documentId,
                              completion: @escaping (Result<DataForReview, GiniHealthError>) -> Void)
```
The method above returns the completion block with the struct `DataForReview`, which includes document and extractions.

### Payment review screen initialization

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