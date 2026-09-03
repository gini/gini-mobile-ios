//
//  HelpBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the help screens.

- note: Bottom navigation only.
*/
public protocol HelpBottomNavigationBarAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
