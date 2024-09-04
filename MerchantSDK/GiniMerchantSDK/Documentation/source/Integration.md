Integration
=============================

The Gini Merchant SDK for iOS provides all the UI and functionality needed to use the Gini API in your app to create payment. The payment information can be reviewed and then the invoice can be paid using any available payment provider app (e.g., banking app).

> ⚠️  **Important:**
For supporting each payment provider you need to specify `LSApplicationQueriesSchemes` in your `Info.plist` file. App schemes for specification will be provided by Gini.


## GiniMerchant initialization

> ⚠️  **Important:**
You should have received Gini API client credentials from us. Please get in touch with us in case you don't have them.

You can easy initialize `GiniMerchant` with the client credentials:

```swift
private lazy var merchant = GiniMerchant(id: clientID, secret: clientPassword, domain: clientDomain)
```

## Certificate pinning (optional)

If you want to use _Certificate pinning_, provide metadata for the upload process, you can pass both your public key pinning configuration for more information)
```swift
    private lazy var mechant = GiniMerchant(id: clientID, secret: clientPassword, domain: clientDomain, pinningConfig: ["PinnedDomains" : ["PublicKeyHashes"]])
```


## Integrate the Payment component

We provide a custom payment component view to help users pay.
Please follow the steps below for the payment component integration.

### 1. Create an instance of the `PaymentComponentsController`.

```swift
let paymentComponentsController = PaymentComponentsController(giniMerchant: merchant)
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

### 3. Show the PaymentComponentBottomView

In this step you will show the `PaymentComponentBottomView` in a bottom sheet.
This function provides the UIViewController and you cand present it anywhere.

```swift
public func paymentViewBottomSheet(documentId: String?) -> UIViewController 
```

```
let paymentViewBottomSheet = paymentComponentsController.paymentViewBottomSheet(documentId: nil)
paymentViewBottomSheet.modalPresentationStyle = .overFullScreen
present(paymentViewBottomSheet, animated: false)
```

> **Note:** 
> - We strongly recommend to present `PaymentComponentBottomView` modally with a `.overFullScreen` presentation style.
> - Based on the payment provider's colors, the `UIView` will automatically change its color.

* `PaymentComponentViewProtocol` is the view protocol and provides events handlers when the user tapped on various areas on the payment component view (more information icon, bank/payment provider picker, the pay invoice button and etc.).

> - Make sure you properly link `PaymentComponentsControllerProtocol` and `PaymentComponentViewProtocol` delegates to get notified.

## Show PaymentInfoViewController

The `PaymentInfoViewController` displays information and an FAQ section about the payment feature.
It requires a `PaymentComponentsController` instance (see `Integrate the Payment component` step 1).

> **Note:** 
> - The `PaymentInfoViewController` can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigation around the provided views.
> - Please make sure to dismiss presentedViewController (usually `PaymentComponentBottomView`) before you push the PaymentInfoViewController.

> ⚠️  **Important:**
> - The `PaymentInfoViewController` presentation should happen in `func didTapOnMoreInformation(documentId: String?)` inside
`PaymentComponentViewProtocol` implementation.(`Integrate the Payment component` step 3).

```swift
func didTapOnMoreInformation(documentId: String?) {
    let paymentInfoViewController = paymentComponentsController.paymentInfoViewController()
    if let presentedViewController = self.presentedViewController {
        presentedViewController.dismiss(animated: true) {
            self.navigationController?.pushViewController(paymentInfoViewController, animated: true)
        }
    } else {
        self.navigationController?.pushViewController(paymentInfoViewController, animated: true)
    }
}
 ```

## Show BankSelectionBottomSheet

The `BankSelectionBottomSheet` displays a list of available banks for the user to choose from.
If a banking app is not installed we will provide an `InstallAppBottomView` view on the `PaymentReviewScreen` and you will be able to install that missing app from AppStore.
The `BankSelectionBottomSheet` presentation requires a `PaymentComponentsController` instance from the `Integrate the Payment component` step 1.

> **Note:** 
> - We strongly recommend to present `BankSelectionBottomSheet` modally with a `.overFullScreen` presentation style.

> ⚠️  **Important:**
> - The `BankSelectionBottomSheet` presentation should happen in `func didTapOnBankPicker(documentId: String?)` inside
`PaymentComponentViewProtocol` implementation (see `Integrate the Payment component` step 3).
> - Please make sure to dismiss presentedViewController (usually `PaymentComponentBottomView`) before you push the BankSelectionBottomSheet.

```swift
func didTapOnBankPicker(documentId: String?) {
    let bankSelectionBottomSheet = paymentComponentsController.bankSelectionBottomSheet()
    bankSelectionBottomSheet.modalPresentationStyle = .overFullScreen
    if let presentedViewController = self.presentedViewController {
        presentedViewController.dismiss(animated: true) {
            self.present(bankSelectionBottomSheet, animated: animated)
        }
    } else {
        self.present(bankSelectionBottomSheet, animated: animated)
    }
}
 ```

## Show PaymentReviewViewController Bottom Sheet

The `PaymentReviewViewController` displays payment's details. It also lets users pay the invoice with the bank they selected in the `BankSelectionBottomSheet`. In here you will be able to revise the amount field of the payment and proceed with the payment.

The `PaymentReviewViewController` presentation requires a `PaymentComponentsController` instance from the `Integrate the Payment component` step 1 and `documentId`.

> **Note:** 
> - The `PaymentReviewViewController` can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigation around the provided views.
> - Please make sure to dismiss presentedViewController (usually `PaymentComponentBottomView`) before you push the PaymentReviewViewController.

> ⚠️  **Important:**
> - The `PaymentReviewViewController` presentation should happen in `func didTapOnPayInvoice(documentId: String?)` inside
`PaymentComponentViewProtocol` implementation (see `Integrate the Payment component` step 3).

```swift
    func didTapOnPayInvoice(documentId: String?) {
        guard let documentId else { return }
                    paymentComponentsController.loadPaymentReviewScreenFor(documentId: documentId, paymentInfo: obtainPaymentInfo(), trackingDelegate: self) { [weak self] viewController, error in
        if let error {
            self?.errors.append(error.localizedDescription)
            self?.showErrorsIfAny()
        } else if let viewController {
            viewController.modalTransitionStyle = .coverVertical
            viewController.modalPresentationStyle = .overCurrentContext
            if let presentedViewController = self?.presentedViewController {
                presentedViewController.dismiss(animated: true) {
                    self?.present(viewController, animated: animated)
                }
            } else {
            self?.present(viewController, animated: animated)
            }
        }
    }
}
```
