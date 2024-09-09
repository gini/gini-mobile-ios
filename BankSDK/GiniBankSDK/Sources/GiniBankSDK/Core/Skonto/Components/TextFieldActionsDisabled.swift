//
//  TextFieldActionsDisabled.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TextFieldActionsDisabled: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
