Event Tracking
=============================

The Gini Bank SDK Library has the ability to track user events. In order to receive the events, import `GiniCapture` and implement the `GiniCaptureTrackingDelegate` protocol and supply the delegate when initializing `GiniBank`. For example:

```swift
let viewController = GiniBank.viewController(withClient: client,
                                               importedDocuments: captureDocuments,
                                               configuration: giniBankConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata,
                                               trackingDelegate: trackingDelegate)

// Or when not using the default network:
let viewController = GiniBank.viewController(withDelegate: self,
                                               withConfiguration: giniBankConfiguration,
                                               importedDocument: nil,
                                               trackingDelegate: trackingDelegate)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types. Some events may supply additional data in a dictionary.

| Domain | Event type | Additional info keys | Comment |
| --- | --- | --- | --- | 
| Onboarding | `start` || Onboarding started |
| Onboarding | `finish` || User completed onboarding |
| Camera Screen | `exit` || User closed the camera screen |
| Camera Screen | `help` || User tapped "Help" on the camera screen |
| Camera Screen | `takePicture` || User took a picture |
| Review Screen | `back` || User went back from the review screen |
| Review Screen | `next` || User advanced from the review screen |
| Analysis Screen | `cancel` || User canceled the process during analysis |
| Analysis Screen | `error` | `"message"` | The analysis ended with an error. The error message is supplied under the "message" key. |
| Analysis Screen | `retry` || The user decided to retry after an analysis error. |
