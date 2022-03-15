//
//  GiniCustomButton.swift
//  
//
//  Created by Nadya Karaban on 10.11.21.
//

import UIKit
class GiniCustomButton: UIButton {
    var disabledBackgroundColor: UIColor? = .gray
    var disabledTextColor: UIColor? = .white
    var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    var textColor: UIColor? {
        didSet {
            self.setTitleColor(textColor, for: .normal)
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? defaultBackgroundColor : disabledBackgroundColor
            if !self.isEnabled {
                self.setTitleColor(disabledTextColor, for: .disabled)
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.5 : 1
        }
    }
}
