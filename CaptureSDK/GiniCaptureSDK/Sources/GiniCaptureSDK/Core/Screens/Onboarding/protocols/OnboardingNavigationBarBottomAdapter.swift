//
//  OnboardingNavigationBarBottomAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 27/10/2022.
//

import Foundation
import UIKit

public enum OnboardingNavigationBarBottomButton: Int {
    case skip
    case next
    case getStarted
}

/**
Protocol for injecting a custom bottom navigation bar on the onboarding screen.

- note: Bottom navigation only.
*/
public protocol OnboardingNavigationBarBottomAdapter: InjectedViewAdapter {

    /**
     *  Called when the displayed buttons have to change. Show only the buttons that are in the list.
     *
     * - Parameter navigationButtons:          The list of buttons that have to be shown
     * - Parameter navigationBar:              The navigationbar that holds the buttons
     */
    func showButtons(
        navigationButtons: [OnboardingNavigationBarBottomButton],
        navigationBar: UIView)
    /**
     *  Set the callback for the next button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in next button action method
     */
    func setNextButtonClickedActionCallback(_ callback: @escaping () -> Void)
    /**
     *  Set the callback for the skip button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in skip button action method
     */
    func setSkipButtonClickedActionCallback(_ callback: @escaping () -> Void)
    /**
     *  Set the callback for the get started button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in get started button action method
     */
    func setGetStartedButtonClickedActionCallback(_ callback: @escaping  () -> Void)
}
