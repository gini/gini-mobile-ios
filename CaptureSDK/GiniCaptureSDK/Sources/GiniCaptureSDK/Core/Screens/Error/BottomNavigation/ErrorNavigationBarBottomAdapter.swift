//
//  ErrorNavigationBarBottomAdapter.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public protocol ErrorNavigationBarBottomAdapter: InjectedViewAdapter {
    func setBackButtonClickedActionCallback(_ callback: @escaping () -> Void)
}
