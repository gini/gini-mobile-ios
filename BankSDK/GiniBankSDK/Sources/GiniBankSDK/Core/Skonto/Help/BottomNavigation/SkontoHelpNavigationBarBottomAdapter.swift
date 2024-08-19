//
//  SkontoHelpNavigationBarBottomAdapter.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniCaptureSDK

/**
 Protocol for injecting a custom bottom navigation bar on the Skonto help screen.
*/
public protocol SkontoHelpNavigationBarBottomAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback: An action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
