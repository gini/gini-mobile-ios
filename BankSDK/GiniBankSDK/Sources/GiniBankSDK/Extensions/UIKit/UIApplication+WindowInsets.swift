//
//  UIApplication+WindowInsets.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

extension UIApplication {
    var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero
    }
}

