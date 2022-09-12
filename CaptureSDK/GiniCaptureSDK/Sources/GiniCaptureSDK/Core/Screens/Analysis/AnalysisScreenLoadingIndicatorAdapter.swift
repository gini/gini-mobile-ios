//
//  AnalysisScreenLoadingIndicatorAdapter.swift
//  
//
//  Created by David Vizaknai on 12.09.2022.
//

import Foundation
/**
*   Adapter for injecting a custom loading indicator for the analysis viewcontroller.
*/
public protocol AnalysisScreenLoadingIndicatorAdapter: InjectedViewAdapter {
    /**
     *  Called when the screen is loaded, can be also called from the AnalysisViewController's showAnimation() method.
     */
    func startAnimation()
    /**
     *  Can be called from the AnalysisViewController's hideAnimation() method.
     */
    func stopAnimation()
}
