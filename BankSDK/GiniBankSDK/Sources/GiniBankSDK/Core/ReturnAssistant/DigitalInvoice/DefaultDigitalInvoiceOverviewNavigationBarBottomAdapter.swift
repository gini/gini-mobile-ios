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

    func injectedView() -> UIView {
        let navigationBar = DigitalInvoiceBottomNavigationBar()
        navigationBar.payButton.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        navigationBar.helpButton.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
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
