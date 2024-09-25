Event Tracking
=============================

The Gini Merchant SDK exposes protocols for tracking events. 

# Global events

Implement the `GiniMerchantDelegate` protocol and supply the delegate to the `GiniMerchant` instance:

```swift
let merchantSDK = GiniMerchant(with: giniApiLib)
merchantSDK.delegate = self // where self conforms to the GiniMerchantDelegate protocol
````
## Events

| Event | Additional info | Comment |
| --- | --- | --- | 
| `didCreatePaymentRequest` | `paymentRequestID`| A payment request had been created |
| `shouldHandleErrorInternally` | `error` | An error occurred. Return `false` to prevent the SDK from showing an error message. |


# Screen events

Implement the `GiniMerchantTrackingDelegate` protocol and supply the delegate when initializing `PaymentReviewViewController`. For example:

```swift
let viewController = paymentComponentsController.loadPaymentReviewScreenFor(documentId: documentId, paymentInfo: paymentInfo, trackingDelegate: self)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types.

| Domain | Event type | Additional info keys | Comment |
| --- | --- | --- | --- | 
| Payment Review Screen | `onToTheBankButtonClicked` |`"paymentProvider"`| User tapped "To the banking app" button from the payment review screen |
