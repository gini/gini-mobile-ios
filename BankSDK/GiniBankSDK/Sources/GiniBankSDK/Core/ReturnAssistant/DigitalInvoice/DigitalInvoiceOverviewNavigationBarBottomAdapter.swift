//
//  DigitalInvoiceOverviewNavigationBarBottomAdapter.swift
//  
//
//  Created by David Vizaknai on 02.03.2023.
//

import GiniCaptureSDK
import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the overview screen for digital invoices.

- note: Bottom navigation only.
*/
public protocol DigitalInvoiceOverviewNavigationBarBottomAdapter: InjectedViewAdapter {
    /**
     *  Set the callback for the proceed button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in proceed button action method
     */
    func setProceedButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Set the callback for the help button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in help button action method
     */
    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Set the total price on the bottom navigation bar. Called when the total price changes
     *
     * - Parameter price: A string which contains the currency and the price
     */
    func updateTotalPrice(with price: String?)

    /**
     *  Set the proceed button state. Called when state of the button should be changed
     *
     * - Parameter enabled: A bool value to reflect the state of the button
     */
    func updateButtonState(enalbed: Bool)

    /**
     *  Lays out the views based on the table view's position in the return assistant overview screen. Use this to align views with the table view
     *
     * - Parameter view: The tableview on the return assistant overview screen
     */
    func setupViewsRelated(to view: UIView)
}
