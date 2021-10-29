//
//  UINavigationController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

extension UINavigationController {
    public func applyStyle(withConfiguration configuration: GiniConfiguration) {
        let titleTextAttrubutes = [NSAttributedString.Key.font: configuration.customFont.isEnabled ?
            configuration.customFont.with(weight: .light, size: 16, style: .title2) :
            configuration.navigationBarTitleFont as Any, NSAttributedString.Key.foregroundColor: configuration.navigationBarTitleColor]
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = configuration.navigationBarTintColor
            appearance.titleTextAttributes = titleTextAttrubutes
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            self.navigationBar.barTintColor = configuration.navigationBarTintColor
            self.navigationBar.titleTextAttributes = titleTextAttrubutes
        }
        self.navigationBar.tintColor = configuration.navigationBarItemTintColor
    }
}
