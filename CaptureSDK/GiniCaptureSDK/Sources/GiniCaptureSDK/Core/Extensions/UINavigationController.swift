//
//  UINavigationController.swift
//  GiniCapture
//
//  Created by Nadzeya Karaban on 07/11/22.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

extension UINavigationController {
    public func applyStyle(withConfiguration configuration: GiniConfiguration) {
        let titleTextAttrubutes = [NSAttributedString.Key.font:
            configuration.textStyleFonts[.bodyBold] as Any, NSAttributedString.Key.foregroundColor: GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.light1).uiColor()]
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark2).uiColor()
            appearance.titleTextAttributes = titleTextAttrubutes
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            self.navigationBar.barTintColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark2).uiColor()
            self.navigationBar.titleTextAttributes = titleTextAttrubutes
        }
        self.navigationBar.tintColor = UIColor.GiniCapture.accent1
    }
}
