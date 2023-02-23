//
//  DigitalInvoiceHelpNavigationBarBottomAdapter.swift
//  
//
//  Created by David Vizaknai on 17.02.2023.
//

import Foundation
import GiniCaptureSDK

/**
Protocol for injecting a custom bottom navigation bar on the no result screens.

- note: Bottom navigation only.
*/
public protocol DigitalInvoiceHelpNavigationBarBottomAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
