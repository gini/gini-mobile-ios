//
//  InjectedViewAdapter.swift
//  
//
//  Created by Nadya Karaban on 20.05.22.
//

import Foundation
import UIKit

/**
 *  Adapter for injectable views. It allows clients to inject their own views into our layouts.
 */
public protocol InjectedViewAdapter {
/**
 *  Called when the custom view is required. It will be injected into the SDK's layout.
 */
    func injectedView() -> UIView
/**
 *  Called when the view is destroyed/deinitialized.
 */
    func onDeinit()
}
