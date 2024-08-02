//
//  DefaultSkontoNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class DefaultSkontoNavigationBarBottomAdapter: SkontoNavigationBarBottomAdapter {

    private var proceedButtonCallback: (() -> Void)?
    // MARK: Temporary remove help action
//    private var helpButtonCallback: (() -> Void)?
    private var backButtonCallback: (() -> Void)?
    private var view: DefaultSkontoBottomNavigationBar?

    func setProceedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        proceedButtonCallback = callback
    }

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        // empty for now
    }

    func updateTotalPrice(priceWithCurrencyCode price: String?) {
        view?.updatePrice(with: price)
    }

    func updateSkontoPercentageBadge(with text: String?) {
        view?.updateDiscountValue(with: text)
    }

    func updateSkontoPercentageBadgeVisibility(hidden: Bool) {
        view?.updateDiscountBadge(hidden: hidden)
    }

    func updateSkontoSavingsInfo(with text: String?) {
        view?.updateInvoiceSkontoSavings(with: text)
    }

    func updateSkontoSavingsInfoVisibility(hidden: Bool) {
        view?.displayInvoiceSkontoSavingsBadge(hidden: hidden)
    }

    func injectedView() -> UIView {
        let navigationBar = DefaultSkontoBottomNavigationBar(proceedAction: proceedButtonCallback,
                                                             backAction: backButtonCallback)
        view = navigationBar
        return navigationBar
    }

    func onDeinit() {
        proceedButtonCallback = nil
    }
}
