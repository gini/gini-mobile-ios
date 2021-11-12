//
//  GiniButton.swift
//  Example Swift
//
//  Created by Nadya Karaban on 05.03.21.
//

import Foundation
import UIKit
@IBDesignable
public class GiniButton: UIButton {
    @IBInspectable public var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
