//
//  ImagePickerBottomNavigationBarAdapter.swift.swift
//  
//
//  Created by David Vizaknai on 13.01.2023.
//

import UIKit

/**
Protocol for injecting a custom bottom navigation bar on the image picker screen.

- note: Bottom navigation only.
*/
public protocol ImagePickerBottomNavigationBarAdapter: InjectedViewAdapter {

    /**
     *  Set the callback for the back button action.
     *
     * - Parameter callback:          An  action callback, which should be retained and called in back button action method
     */
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}

