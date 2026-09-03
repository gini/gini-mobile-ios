//
//  ReviewScreenBottomNavigationBarAdapter.swift
//  
//
//  Created by David Vizaknai on 21.10.2022.
//

import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the Review screen.

- note: Bottom navigation only.
*/
public protocol ReviewScreenBottomNavigationBarAdapter: InjectedViewAdapter {
    /**
     *  Set the callback for the 'Process documents' button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in 'Process documents' button action method
     */
    func setMainButtonClickedActionCallback(_ callback: @escaping () -> Void)
    /**
     *  Set the callback for the Add Pages button action.
     *
     * - Parameter callback: An  action callback, which should be retained and called in back button action method
     */
    func setSecondaryButtonClickedActionCallback(_ callback: @escaping () -> Void)

    /**
     *  Set the loading indicator state on the 'Process documents' button when multipage upload is happening.
     *
     * - Parameter isLoading: A boolean to set the loading state of the button
     */
    func set(loadingState isLoading: Bool)
}
