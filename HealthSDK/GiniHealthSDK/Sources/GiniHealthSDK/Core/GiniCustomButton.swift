//
//  GiniCustomButton.swift
//  
//
//  Created by Nadya Karaban on 10.11.21.
//

import UIKit
class GiniCustomButton: UIButton {
    var disabledBackgroundColor: UIColor? = .gray
    var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    override public var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? defaultBackgroundColor : disabledBackgroundColor
            self.tintColor = .white
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.5 : 1
        }
    }
}
