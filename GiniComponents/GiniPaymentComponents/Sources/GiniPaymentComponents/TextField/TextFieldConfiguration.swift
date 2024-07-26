//
//  TextFieldConfiguration.swift
//  GiniUtilites
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct TextFieldConfiguration {
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let textColor: UIColor
    public let textFont: UIFont
    public let cornerRadius: CGFloat
    public let borderWidth: CGFloat
    public let placeholderForegroundColor: UIColor

    /// Text Field configuration initalizer
    /// - Parameters:
    ///   - backgroundColor: the textField's background color
    ///   - borderColor: the textField's border color
    ///   - textColor: the textField's text color
    ///   - cornerRadius: the textField's corner radius
    ///   - borderWidth: the textField's border width
    ///   - placeholderForegroundColor:the textField's placeholder foreground color

    public init(backgroundColor: UIColor,
                borderColor: UIColor,
                textColor: UIColor,
                textFont: UIFont,
                cornerRadius: CGFloat,
                borderWidth: CGFloat,
                placeholderForegroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
        self.textFont = textFont
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.placeholderForegroundColor = placeholderForegroundColor
    }
}
