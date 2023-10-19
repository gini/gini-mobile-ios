//
//  UIActivityIndicatorView.swift
//
//
//  Created by Valentina Iancu on 19.10.23.
//

import UIKit

extension UIActivityIndicatorView {
    func applyLargeStyle() {
        if #available(iOS 13.0, *) {
            self.style = .large
        } else {
            self.style = .whiteLarge
        }
    }
}
