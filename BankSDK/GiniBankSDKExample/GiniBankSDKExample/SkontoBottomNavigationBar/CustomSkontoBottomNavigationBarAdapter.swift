//
//  CustomSkontoBottomNavigationBarAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankSDK

final class CustomSkontoNavigationBarBottomAdapter: SkontoNavigationBarBottomAdapter {

    private var proceedButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?
    private var backButtonCallback: (() -> Void)?
    private var view: CustomSkontoBottomNavigationBar?

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
        let navigationBar = CustomSkontoBottomNavigationBar(proceedAction: proceedButtonCallback,
                                                             helpAction: helpButtonCallback,
                                                             backAction: backButtonCallback)
        view = navigationBar
        return navigationBar
    }

    func onDeinit() {
        proceedButtonCallback = nil
    }
}
