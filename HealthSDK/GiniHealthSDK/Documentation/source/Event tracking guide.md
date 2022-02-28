Event Tracking
=============================

The Gini Health SDK has the ability to track user events. In order to receive the events, implement the `GiniHealthTrackingDelegate` protocol and supply the delegate when initializing `PaymentReviewViewController`. For example:

```swift
let viewController = PaymentReviewViewController.instantiate(with: self.health,
                                                         document: document,
                                                      extractions: extractions,
                                                 trackingDelegate: self)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types.

| Domain | Event type | Additional info keys | Comment |
| --- | --- | --- | --- | 
| Payment Review Screen | `onNextButtonClicked` |`"paymentProvider"`| User tapped "next" button from the payment review screen |
| Payment Review Screen | `onCloseButtonClicked` || User tapped "close" button and closed the payment review screen |
| Payment Review Screen | `onCloseKeyboardButtonClicked` || User tapped "close" button and keyboard will be hidden from the payment review screen |
| Payment Review Screen | `onBankSelectionButtonClicked` |`"paymentProvider"`| User tapped on the bank selection button from the payment review screen |
