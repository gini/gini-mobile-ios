//
//  UITextField+Utils.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

public extension UITextField {
    var isReallyEmpty: Bool {
        return text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }
    
    func moveSelectedTextRange(from position: UITextPosition, to offset: Int) {
        if let newSelectedRangeFromTo = self.position(from: position, offset: offset),
           let newSelectedRange = self.textRange(from: newSelectedRangeFromTo, to: newSelectedRangeFromTo) {
            self.selectedTextRange = newSelectedRange
        }
    }
}

extension UITextField {
    func configureWith(configuration: TextFieldConfiguration){
        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.borderColor = configuration.borderColor.cgColor
        self.backgroundColor = configuration.backgroundColor
        self.textColor = configuration.textColor
        self.attributedPlaceholder = NSAttributedString(string: "",
                                                        attributes: [NSAttributedString.Key.foregroundColor: configuration.placeholderForegroundColor])
    }
}
