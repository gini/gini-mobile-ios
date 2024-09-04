//
//  DefaultDigitalInvoiceNavigationBarBottomAdapter.swift
//  
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit

final class DefaultDigitalInvoiceNavigationBarBottomAdapter: DigitalInvoiceNavigationBarBottomAdapter {

    private var proceedButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?
    private var view: DigitalInvoiceBottomNavigationBar?

    func setProceedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        proceedButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        helpButtonCallback = callback
    }

    func updateProceedButtonState(enabled: Bool) {
        view?.setProceedButtonState(enabled: enabled)
    }

    func updateTotalPrice(priceWithCurrencySymbol price: String?) {
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
        let navigationBar = DigitalInvoiceBottomNavigationBar(proceedAction: proceedButtonClicked,
                                                              helpAction: helpButtonClicked)
        view = navigationBar
        return navigationBar
    }

    @objc func proceedButtonClicked() {
        proceedButtonCallback?()
    }

    @objc func helpButtonClicked() {
        helpButtonCallback?()
    }

    func onDeinit() {
        proceedButtonCallback = nil
    }
}
