//
//  GiniHealthTrackingDelegate.swift
//  
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
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
    /// User tapped "To the banking app"  button and ready to be redirected to the banking app
    case onToTheBankButtonClicked
    /// User tapped "close" button and keyboard will be hidden
    case onCloseKeyboardButtonClicked
}

/**
Tracking delegate relating to the payment review screen.
*/
public protocol PaymentReviewScreenTrackingDelegate: AnyObject {
    
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>)
}
