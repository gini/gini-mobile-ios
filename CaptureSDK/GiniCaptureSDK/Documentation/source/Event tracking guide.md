Event Tracking
=============================

The Gini Capture SDK has the ability to track user events. In order to receive the events, implement the `GiniCaptureTrackingDelegate` protocol and supply the delegate when initializing Gini Capture SDK. For example:

```swift
let viewController = GiniCapture.viewController(withClient: client,
                                               importedDocuments: visionDocuments,
                                               configuration: captureConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata,
                                               trackingDelegate: trackingDelegate)

// Or when not using the default network implementation pod GiniCapture/Networking:
let viewController = GiniCapture.viewController(withDelegate: self,
                                               withConfiguration: captureConfiguration,
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
