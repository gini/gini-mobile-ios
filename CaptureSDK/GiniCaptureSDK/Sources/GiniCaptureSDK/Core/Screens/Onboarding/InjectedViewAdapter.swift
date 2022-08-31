//
//  InjectedViewAdapter.swift
//  
//
//  Created by Nadya Karaban on 20.05.22.
//

import Foundation
import UIKit

public protocol InjectedViewAdapter {
    func injectedView() -> UIView
    func onDestroy()
}
