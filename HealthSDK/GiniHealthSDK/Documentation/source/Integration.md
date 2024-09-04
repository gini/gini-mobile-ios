Integration
=============================

The Gini Health SDK for iOS provides all the UI and functionality needed to use the Gini Health API in your app to extract payment and health information from invoices. The payment information can be reviewed and then the invoice can be paid using any available payment provider app (e.g., banking app).

The Gini Health API provides an information extraction service for analyzing health invoices. Specifically, it extracts information such as the document sender or the payment relevant information (amount to pay, IBAN, etc.). In addition it also provides a secure channel for sharing payment related information between clients. 

> ⚠️  **Important:**
For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## GiniHealthAPI initialization

> ⚠️  **Important:**
You should have received Gini Health API client credentials from us. Please get in touch with us in case you don't have them.

You can easy initialize `GiniHealthAPI` with the client credentials:

```swift
let apiLib = GiniHealthAPI.Builder(client: client).build()
```

If you want to use a transparent proxy with your own authentication you can specify your own domain and add `AlternativeTokenSource` protocol implementation:

```swift
 let apiLib =  GiniHealthAPI.Builder(customApiDomain: "api.custom.net",
                                 alternativeTokenSource: MyAlternativeTokenSource)
                                 .build()
```
The token your provide will be added as a bearer token to all api.custom.net requests.

> ⚠️  **Important:**

When you implement `AlternativeTokenSource` protocol make sure that you call the completion in one specific thread

```swift
private class MyAlternativeTokenSource: AlternativeTokenSource {
    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        // fetch token from any thread
        // then call the completion in one specific thread
        completion(.success(Token()))
    }
}
```

## Certificate pinning (optional)

If you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration as follows:
```swift
    let yourPublicPinningConfig = [
        "health-api.gini.net": [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
        ],
        "user.gini.net": [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
        ],
    ]
    let apiLib = GiniHealthAPI
        .Builder(client: Client(id: "your-id",
                                secret: "your-secret",
                                domain: "your-domain"),
                 api: .default,
                 pinningConfig: yourPublicPinningConfig)
        .build()
```

## GiniHealth initialization

Now that the `GiniHealthAPI` has been initialized, you can initialize `GiniHealth`:

```swift
 let healthSDK = GiniHealth(with: giniApiLib)
```
## Document upload
 
For the document upload if you plan to do it with `GiniHealth`. First you need get document service and create partial document.

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

We provide 2 ways of doing this.
1. GiniHealth provides a variable for checking if the document is payable or not. You can look for `payment_state` of the document/invoice. The document/invoice is payable if `payment_state` is `Payable` 

2. GiniHealth provides a method for checking if the document is payable or not.

```swift
healthSDK.checkIfDocumentIsPayable(docId: String,
                                   completion: @escaping (Result<Bool, GiniHealthError>) -> Void)
```

The method returns success and `true` value if `payment_state` was extracted.

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

## Integrate the Payment component

We provide a custom payment component view to help users pay the invoice/document.
Please follow the steps below for the payment component integration.

### 1. Create an instance of the `PaymentComponentsController`.

```swift
let paymentComponentsController = PaymentComponentsController(giniHealth: health)
```

### 2. Load the payment providers

You will load the list of the payment providers by calling the `loadPaymentProviders` function from the `PaymentComponentsController` and conform to the `PaymentComponentsControllerProtocol`.

```swift
paymentComponentsController.delegate = self // where self is your viewController
paymentComponentsController.loadPaymentProviders()
```

* `PaymentComponentsControllerProtocol` provides information when the `PaymentComponentsController` is loading.
You can show/hide an `UIActivityIndicator` based on that.

* `PaymentComponentsControllerProtocol` provides completion handlers when `PaymentComponentsController` fetched successfully payment providers or when it failed with an error.

>  **Note:**
It should be sufficient to call paymentComponentsController.loadPaymentProviderApps() only once when your app starts.

> - We effectively handle situations where there are no payment providers available.
> - Based on the payment provider's colors, the `UIView` will automatically change its color.

### 3. Show the Payment Component view

In this step you will show a payment component view and conform to the `PaymentComponentViewProtocol`.

Depending on the value of `isPayable`, incorporate the corresponding payment component view into your cells using this function:

```swift
public func paymentView(documentId: String) -> UIView
```

> - We suggest placing this `UIView` within a vertical `UIStackView`. Additionally, in the `prepareForReuse()` function of each cell, remove the payment component view if it exists.
> - Furthermore, employing automatic dimension height in the `UITableView` containing the cells is recommended.

* `PaymentComponentViewProtocol` is the view protocol and provides events handlers when the user tapped on various areas on the payment component view (more information icon, bank/payment provider picker, the pay invoice button and etc.).

> - Make sure you properly link `PaymentComponentsControllerProtocol` and `PaymentComponentViewProtocol` delegates to get notified.

## Show PaymentInfoViewController

The `PaymentInfoViewController` displays information and an FAQ section about the payment feature.
It requires a `PaymentComponentsController` instance (see `Integrate the Payment component` step 1).

> **Note:** 
> - The `PaymentInfoViewController` can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigation around the provided views.

> ⚠️  **Important:**
> - The `PaymentInfoViewController` presentation should happen in `func didTapOnMoreInformation(documentId: String?)` inside `PaymentComponentViewProtocol` implementation without animation since SDK handles the animation  during the presentation.(`Integrate the Payment component` step 3).

```swift
func didTapOnMoreInformation(documentId: String?) {
    let paymentInfoViewController = paymentComponentsController.paymentInfoViewController()
    self.yourInvoicesListViewController.navigationController?.pushViewController(paymentInfoViewController,
                                                                                 animated: false)
}
 ```

## Show BankSelectionBottomSheet

The `BankSelectionBottomSheet` displays a list of available banks for the user to choose from.
If a banking app is not installed it will also display its AppStore link.
The `BankSelectionBottomSheet` presentation requires a `PaymentComponentsController` instance from the `Integrate the Payment component` step 1.

> **Note:** 
> - We strongly recommend to present `BankSelectionBottomSheet` modally with a `.overFullScreen` presentation style.

> ⚠️  **Important:**
> - The `BankSelectionBottomSheet` presentation should happen in `func didTapOnBankPicker(documentId: String?)` inside
`PaymentComponentViewProtocol` implementation without animation since SDK handles the animation during the presentation (see `Integrate the Payment component` step 3).

```swift
func didTapOnBankPicker(documentId: String?) {
    let bankSelectionBottomSheet = paymentComponentsController.bankSelectionBottomSheet()
    bankSelectionBottomSheet.modalPresentationStyle = .overFullScreen
    self.yourInvoicesListViewController.present(bankSelectionBottomSheet,
                                                animated: false)
    }
 ```

## Show PaymentReviewViewController

The `PaymentReviewViewController` displays an invoice's pages and extractions. It also lets users pay the invoice with the bank they selected in the `BankSelectionBottomSheet`.

The `PaymentReviewViewController` presentation requires a `PaymentComponentsController` instance from the `Integrate the Payment component` step 1 and `documentId`.

> **Note:** 
> - The `PaymentReviewViewController` can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigation around the provided views.

> ⚠️  **Important:**
> - The `PaymentReviewViewController` presentation should happen in `func didTapOnBankPicker(documentId: String?)` inside
`PaymentComponentViewProtocol` implementation without animation since SDK handles the animation during the presentation (see `Integrate the Payment component` step 3).

```swift
    func didTapOnPayInvoice(documentId: String?) {
        guard let documentId else { return }
        paymentComponentsController.loadPaymentReviewScreenFor(documentId: documentId, trackingDelegate: self) { [weak self] viewController, error in
            if let error {
                self?.showErrorsIfAny()
            } else if let viewController {
                viewController.modalTransitionStyle = .coverVertical
                viewController.modalPresentationStyle = .overCurrentContext
                self?.yourInvoicesListViewController.present(viewController, animated: false)
            }
        }
    }
```

> **Note:** 
> - PaymentReviewViewController contains the following configuration options:
> - paymentReviewStatusBarStyle: Sets the status bar style on the payment review screen. Only if `View controller-based status bar appearance` = `YES` in `Info.plist`.
> - showPaymentReviewCloseButton: If set to true, a floating close button will be shown in the top right corner of the screen.
Default value is false.

For enabling `showPaymentReviewCloseButton`:

```swift
let giniConfiguration = GiniHealthConfiguration()
config.showPaymentReviewCloseButton =  true
.
.
.
healthSDK.setConfiguration(config)
```
