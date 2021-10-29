//
//  GiniCaptureFont.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Provides a way to set all possible font weights used in the GiniCapture SDK.
 
 **Possible weights:**
 
 * regular
 * bold
 * light
 * thin
 
 */

public class GiniCaptureFont: NSObject {
    public var regular: UIFont
    public var bold: UIFont
    public var light: UIFont
    public var thin: UIFont
    public private(set) var isEnabled: Bool
    
    public init(regular: UIFont, bold: UIFont, light: UIFont, thin: UIFont, isEnabled: Bool = true) {
        self.regular = regular
        self.bold = bold
        self.light = light
        self.thin = thin
        self.isEnabled = isEnabled
    }
    
    public func with(weight: UIFont.Weight, size: CGFloat, style: UIFont.TextStyle) -> UIFont {
        if #available(iOS 11.0, *) {
            return UIFontMetrics(forTextStyle: style).scaledFont(for: font(for: weight).withSize(size))
        } else {
            return font(for: weight).withSize(size)
        }
    }
    
    private func font(for weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .regular:
            return regular
        case .bold:
            return bold
        case .light:
            return light
        case .thin:
            return thin
        default:
            preconditionFailure("\(weight.rawValue) font weight is not supported")
        }
    }
}
