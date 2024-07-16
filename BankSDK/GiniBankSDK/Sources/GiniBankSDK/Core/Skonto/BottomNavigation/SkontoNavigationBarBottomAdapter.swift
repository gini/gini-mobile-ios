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
     * - Parameter callback: An  action callback, which should be retained and called in proceed button action method
     */
    func setProceedButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping  () -> Void)

    /**
     *  Set the total price on the bottom navigation bar. Called when the total price changes
     *
     * - Parameter price: A string which contains the currency and the price
     */
    func updateTotalPrice(priceWithCurrencyCode price: String?)

    // TODO: To specify what we exactly need to expose
    /**
     *  Set the discount value on the bottom navigation bar. Called when Skonto applies
     *
     * - Parameter discount: A string which contains the value of discount
     */
    func updateDiscountValue(with discount: String?)

    /**
     *  Set the discount badge state. Called when Skonto applies
     *
     * - Parameter enabled: A bool value to reflect the state of the badge
     */
    func updateDiscountBadge(enabled: Bool)
}
