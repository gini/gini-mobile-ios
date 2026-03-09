//
//  UIStackView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension UIStackView {
    public func removeAllArrangedSubviews() {
        let subviews = self.arrangedSubviews
        for subview in subviews {
            self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}
