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
        let titleTextAttrubutes = [NSAttributedString.Key.font: configuration.textStyleFonts[.bodyBold] as Any,
                                   NSAttributedString.Key.foregroundColor: GiniColor(light: .GiniCapture.dark1,
                                                                                     dark: .GiniCapture.light1)
                                                                                                    .uiColor()]
        let navigationBackgroundColor = GiniColor(light: .GiniCapture.light2,
                                                  dark: .GiniCapture.dark2).uiColor()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navigationBackgroundColor
        appearance.titleTextAttributes = titleTextAttrubutes
        appearance.shadowColor = navigationBackgroundColor
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        navigationBar.tintColor = UIColor.GiniCapture.accent1
    }
}
