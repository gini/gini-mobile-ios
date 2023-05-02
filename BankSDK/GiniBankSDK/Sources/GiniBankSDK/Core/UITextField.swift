//
//  UITextField.swift
//  GiniBank
//
//  Created by Maciej Trybilo on 18.12.19.
//

import UIKit

public extension UITextField {
    func moveSelectedTextRange(from position: UITextPosition, to offset: Int) {
        if let newSelectedRangeFromTo = self.position(from: position, offset: offset),
           let newSelectedRange = self.textRange(from: newSelectedRangeFromTo, to: newSelectedRangeFromTo) {
            self.selectedTextRange = newSelectedRange
        }
    }
}
