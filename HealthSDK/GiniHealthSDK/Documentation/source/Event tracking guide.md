Event Tracking
=============================

The Gini Health SDK exposes protocols for tracking events. 

# Global events

Implement the `GiniHealthDelegate` protocol and supply the delegate to the `GiniHealth` instance:

```swift
let healthSDK = GiniHealth(with: giniApiLib)
healthSDK.delegate = self // where self conforms to the GiniHealthDelegate protocol
````
## Events

| Event | Additional info | Comment |
| --- | --- | --- | 
| `didCreatePaymentRequest` | `paymentRequestID`| A payment request had been created |
| `shouldHandleErrorInternally` | `error` | An error occurred. Return `false` to prevent the SDK from showing an error message. |


# Screen events

Implement the `GiniHealthTrackingDelegate` protocol and supply the delegate when initializing `PaymentReviewViewController`. For example:

```swift
let viewController = paymentComponentsController.loadPaymentReviewScreenFor(documentId: documentId,
                                                                            trackingDelegate: self)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types.

| Domain | Event type | Additional info keys | Comment |
| --- | --- | --- | --- | 
| Payment Review Screen | `onToTheBankButtonClicked` |`"paymentProvider"`| User tapped "To the banking app" button from the payment review screen |
| Payment Review Screen | `onCloseButtonClicked` || User tapped "close" button and closed the payment review screen |
| Payment Review Screen | `onCloseKeyboardButtonClicked` || User tapped "close" button and keyboard will be hidden from the payment review screen |
