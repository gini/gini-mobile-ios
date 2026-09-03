//
//  DigitalInvoiceOnboardingNavigationBarBottomAdapter.swift
//  
//
//  Created by David Vizaknai on 10.02.2023.
//

import GiniCaptureSDK
import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the onboarding screen for digital invoices.

- note: Bottom navigation only.
*/
public protocol DigitalInvoiceOnboardingNavigationBarBottomAdapter: InjectedViewAdapter {
    /**
     *  Set the callback for the get started button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in get started button action method
     */
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping  () -> Void)
}
