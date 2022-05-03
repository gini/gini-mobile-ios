//
//  UITextField+Utils.swift
//  Bank
//
//  Created by Nadya Karaban on 04.05.21.
//

import UIKit
public extension UITextField {
    var isReallyEmpty: Bool {
        return text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }
}
