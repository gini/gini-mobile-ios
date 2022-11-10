//
//  CameraBottomNavigationBarAdapter.swift
//  
//
//  Created by Krzysztof Kryniecki on 26/09/2022.
//

import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the camera screen.

- note: Bottom navigation only.
*/
public protocol CameraBottomNavigationBarAdapter: InjectedViewAdapter {
    /**
     *  Called when the displayed buttons have to change. Show only the buttons that are in the list.
     *
     * - Parameter navigationBar:              The navigation bar that holds buttons
     * - Parameter navigationButtons:          The list of buttons that have to be shown
     */
    func showButtons(
        navigationBar: UIView,
        navigationButtons: [CameraNavigationBarBottomButton])
    /**
     *  Set the callback for the help button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in help button action method
     */
    func setHelpButtonClickedActionCallback(_ callback: @escaping () -> Void)
    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
