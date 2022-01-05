//
//  GiniHealthTrackingDelegate.swift
//  
//
//  Created by Nadya Karaban on 05.01.22.
//

import Foundation

/**
Delegate protocol that Gini Health SDK uses to report user events.
 
The delegate is separated into smaller protocols relating to different screens of the Gini Health SDK.
 
- note: The delegate isn't retained by Gini Health SDK. It should be retained by the client code.
*/
public protocol GiniHealthTrackingDelegate:
    PaymentReviewScreenTrackingDelegate
{}

/**
Event types relating to the payment review screen.
*/
public enum PaymentReviewScreenEventType: String {
    /// User tapped "next"  button and ready to be redirected to the banking app
    case next
    /// User tapped "close" button and closed the screen
    case close
    /// User tapped "close" button and keyboard will be hidden
    case closeKeyboard
    /// User tapped on the bankSelection button
    case bankSelection
}

/**
Tracking delegate relating to the payment review screen.
*/
public protocol PaymentReviewScreenTrackingDelegate: AnyObject {
    
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>)
}
