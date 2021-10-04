//
//  UITextField+Utils.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 18.04.21.
//

import Foundation
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
