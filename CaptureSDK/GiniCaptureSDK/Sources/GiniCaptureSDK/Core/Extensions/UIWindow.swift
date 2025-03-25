//
//  UIWindow.swift
//
//
//  Copyright © 2023 Gini GmbH. All rights reserved
//

import UIKit

extension UIWindow {
    static var orientation: UIInterfaceOrientation {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation ?? .portrait
    }
}
