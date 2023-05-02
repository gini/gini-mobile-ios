//
//  OnButtonLoadingIndicatorAdapter.swift
//  
//
//  Created by David Vizaknai on 19.10.2022.
//

import Foundation
import UIKit
/**
*   Adapter for injecting a custom loading indicator on top of buttons.
*/
public protocol OnButtonLoadingIndicatorAdapter: InjectedViewAdapter {
    /**
     *  Called when the ther is loading in the background. You should start the loading indicator animation in this method.
     */
    func startAnimation()
    /**
     *  Called when the loading is finished. You should stop the loading indicator animation in this method.
     */
    func stopAnimation()
}
