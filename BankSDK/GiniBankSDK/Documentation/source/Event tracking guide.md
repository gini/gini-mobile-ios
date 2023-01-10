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

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types. Some events may supply additional data in a dictionary. Certain events pertaining to transitions between screens are only reported in the Screen API.

| Domain | Event type | Additional info keys | Comment | Introduced in | Screen API | Compoment API |
| --- | --- | --- | --- | --- | :---: | :---: | 
| Onboarding | `start` || Onboarding started | 1.0.0 | ✅ | ✅ |
| Onboarding | `finish` || User completed onboarding | 1.0.0 | ✅ | ✅ |
| Camera Screen | `exit` || User closed the camera screen | 1.0.0| ✅ | ❌ |
| Camera Screen | `help` || User tapped "Help" on the camera screen | 1.0.0 | ✅ | ❌ |
| Camera Screen | `takePicture` || User took a picture | 1.0.0 | ✅ | ✅ |
| Review Screen | `back` || User went back from the review screen | 1.0.0 | ✅ | ❌ |
| Review Screen | `next` || User advanced from the review screen | 1.0.0 | ✅ | ❌ |
| Analysis Screen | `cancel` || User canceled the process during analysis | 1.0.0 | ✅ | ❌ |
| Analysis Screen | `error` | `"message"` | The analysis ended with an error. The error message is supplied under the "message" key. | 1.0.0 | ✅ | ✅ |
| Analysis Screen | `retry` || The user decided to retry after an analysis error. | 1.0.0 | ✅ | ✅ |
