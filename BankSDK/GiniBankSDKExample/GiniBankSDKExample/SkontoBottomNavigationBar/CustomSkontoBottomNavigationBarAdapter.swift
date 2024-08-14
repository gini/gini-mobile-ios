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

    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        backButtonCallback = callback
    }
    
    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        helpButtonCallback = callback
    }

    func updateTotalPrice(priceWithCurrencyCode price: String?) {
        view?.updatePrice(with: price)
    }

    func updateSkontoPercentageBadge(with text: String?) {
        view?.updateSkontoPercentageBadge(with: text)
    }

    func updateSkontoPercentageBadgeVisibility(hidden: Bool) {
        view?.updateSkontoPercentageBadgeVisibility(hidden: hidden)
    }

    func updateSkontoSavingsInfo(with text: String?) {
        view?.updateSkontoSavingsInfo(with: text)
    }

    func updateSkontoSavingsInfoVisibility(hidden: Bool) {
        view?.updateSkontoSavingsInfoVisibility(hidden: hidden)
    }

    func injectedView() -> UIView {
        let navigationBar = CustomSkontoBottomNavigationBar(proceedAction: proceedButtonCallback,
                                                            backAction: backButtonCallback,
                                                            helpAction: helpButtonCallback)
        view = navigationBar
        return navigationBar
    }

    func onDeinit() {
        proceedButtonCallback = nil
    }
}
