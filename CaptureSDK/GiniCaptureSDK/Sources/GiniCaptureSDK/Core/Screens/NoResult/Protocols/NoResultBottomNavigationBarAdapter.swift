//
//  NoResultBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/10/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the no result screens.

- note: Bottom navigation only.
*/
public protocol NoResultBottomNavigationBarAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
