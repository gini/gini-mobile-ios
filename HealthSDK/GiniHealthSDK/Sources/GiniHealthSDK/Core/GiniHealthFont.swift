//
//  GiniHealthFont.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 30.03.21.
//

import UIKit
/**
 Provides a way to set all possible font weights used in the GiniHealth SDK.
 
 **Possible weights:**
 
 * regular
 * bold
 * light
 * thin
 
 */
public class GiniFont: NSObject {
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
            assertionFailure("\(weight.rawValue) font weight is not supported")
            return regular
        }
    }
}
