//
//  TextFieldConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
public struct TextFieldConfiguration {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let textColor: UIColor
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let placeholderForegroundColor: UIColor


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
                cornerRadius: CGFloat,
                borderWidth: CGFloat,
                placeholderForegroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.placeholderForegroundColor = placeholderForegroundColor
    }
}
