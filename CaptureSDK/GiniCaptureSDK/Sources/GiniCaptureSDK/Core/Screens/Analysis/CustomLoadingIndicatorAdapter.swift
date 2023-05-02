//
//  CustomLoadingIndicatorAdapter.swift
//  
//
//  Created by David Vizaknai on 12.09.2022.
//

import Foundation
/**
*   Adapter for injecting a custom loading indicator for the analysis viewcontroller.
*/
public protocol CustomLoadingIndicatorAdapter: InjectedViewAdapter {
    /**
     *  Called when the screen is loaded. You should start the loading indicator animation in this method.
     */
    func startAnimation()
    /**
     *  Called when the screen has disappeared. You should stop the loading indicator animation in this method.
     */
    func stopAnimation()
}
