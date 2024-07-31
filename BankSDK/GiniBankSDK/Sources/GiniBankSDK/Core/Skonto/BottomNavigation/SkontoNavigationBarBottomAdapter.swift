//
//  SkontoNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import UIKit

/**
Protocol for injecting a custom bottom navigation bar on Skonto.

- note: Bottom navigation only.
*/
public protocol SkontoNavigationBarBottomAdapter: InjectedViewAdapter {
    /**
     *  Set the callback for the proceed button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in proceed button action method.
     */
    func setProceedButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in back button action method.
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Set the callback for the help button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in help button action method.
     */
    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Update the total price on the bottom navigation bar.
     *
     * - Parameter price: A string which contains the currency and the price.
     */
    func updateTotalPrice(priceWithCurrencyCode price: String?)

    /**
     *  Update the Skonto percentage badge text on the bottom navigation bar.
     *
     * - Parameter text: A string which contains the value of Skonto percentage(e.g: "3 % Skonto").
     */
    func updateSkontoPercentageBadge(with text: String?)

    /**
     *  Update the Skonto percentage badge visibility.
     *
     * - Parameter enabled: A bool value to reflect the visibility of the Skonto percentage badge.
     */
    func updateSkontoPercentageBadgeVisibility(hidden: Bool)

    /**
     *  Update the Skonto savings information on the bottom navigation bar. This reflects the savings after paying the invoice within the Skonto period.
     *
     * - Parameter text: A string that contains the value of the savings when paying within the Skonto period(e.g: "3,00 EUR sparen").
     */
    func updateSkontoSavingsInfo(with text: String?)

    /**
     *  Update the Skonto savings information visibility.
     *
     * - Parameter hidden: A bool value to reflect the visibility of the savings information.
     */
    func updateSkontoSavingsInfoVisibility(hidden: Bool)
}
