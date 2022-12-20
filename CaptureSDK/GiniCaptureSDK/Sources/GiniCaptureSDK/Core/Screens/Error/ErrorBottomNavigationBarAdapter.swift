//
//  ErrorBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 29/11/2022.
//

import Foundation

public protocol ErrorBottomNavigationBarAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
