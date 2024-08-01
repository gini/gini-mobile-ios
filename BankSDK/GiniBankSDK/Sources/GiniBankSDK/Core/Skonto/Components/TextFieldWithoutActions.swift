//
//  NoActionTextField.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

class TextFieldWithoutActions: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
