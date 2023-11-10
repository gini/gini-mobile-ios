//
//  UIWindow.swift
//
//
//  Copyright © 2023 Gini GmbH. All rights reserved
//

import UIKit

extension UIWindow {
    static var orientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation ?? .portrait
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
