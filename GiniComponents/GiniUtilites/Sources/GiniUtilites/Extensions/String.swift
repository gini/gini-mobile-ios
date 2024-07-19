//
//  String.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public extension String {
    func toColor() -> UIColor? {
        return UIColor(hex: "#\(self)FF")
    }

    func canOpenURLString() -> Bool {
        if let url = URL(string: self) , UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
}
