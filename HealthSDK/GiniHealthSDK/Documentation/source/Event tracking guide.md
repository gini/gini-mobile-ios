Event Tracking
=============================

The Gini Health SDK has the ability to track user events. In order to receive the events, implement the `GiniHealthTrackingDelegate` protocol and supply the delegate when initializing `PaymentReviewViewController`. For example:

```swift
let viewController = paymentComponentsController.loadPaymentReviewScreenFor(documentID: documentId,
                                                                            trackingDelegate: self)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types.

| Domain | Event type | Additional info keys | Comment |
| --- | --- | --- | --- | 
| Payment Review Screen | `onToTheBankButtonClicked` |`"paymentProvider"`| User tapped "To the banking app" button from the payment review screen |
| Payment Review Screen | `onCloseButtonClicked` || User tapped "close" button and closed the payment review screen |
| Payment Review Screen | `onCloseKeyboardButtonClicked` || User tapped "close" button and keyboard will be hidden from the payment review screen |
