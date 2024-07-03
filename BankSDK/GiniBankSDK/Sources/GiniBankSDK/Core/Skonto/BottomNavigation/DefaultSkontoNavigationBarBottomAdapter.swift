//
//  DefaultSkontoNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class DefaultSkontoNavigationBarBottomAdapter: SkontoNavigationBarBottomAdapter {

    private var proceedButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?
    private var backButtonCallback: (() -> Void)?
    private var view: DefaultSkontoBottomNavigationBar?

    func setProceedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        proceedButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        helpButtonCallback = callback
    }

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }

    func updateProceedButtonState(enabled: Bool) {
        view?.setProceedButtonState(enabled: enabled)
    }

    func updateTotalPrice(priceWithCurrencySymbol price: String?) {
        view?.updatePrice(with: price)
    }

    func updateDiscountValue(with discount: String?) {
        view?.updateDiscountValue(with: discount)
    }

    func updateDiscountBadge(enabled: Bool) {
        view?.updateDiscountBadge(enabled: enabled)
    }

    func injectedView() -> UIView {
        let navigationBar = DefaultSkontoBottomNavigationBar()
        navigationBar.payButton.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        navigationBar.helpButton.addAction(self, #selector(helpButtonClicked))
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
