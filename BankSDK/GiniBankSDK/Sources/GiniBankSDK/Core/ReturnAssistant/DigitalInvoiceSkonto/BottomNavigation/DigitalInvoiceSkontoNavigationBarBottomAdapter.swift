//
//  DigitalInvoiceSkontoNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniCaptureSDK

/**
Protocol for injecting a custom bottom navigation bar on the Digital Invoice screen with Skonto information.

- note: Bottom navigation only.
*/
public protocol DigitalInvoiceSkontoNavigationBarBottomAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)

    /**
     *  Set the callback for the help button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in help button action method
     */
    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void)
}
