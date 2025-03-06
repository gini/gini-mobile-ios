//
//  UIApplication+WindowInsets.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

extension UIApplication {
    var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
        } else {
            return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
    }
}

