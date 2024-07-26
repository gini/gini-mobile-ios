//
//  ButtonConfiguration.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct ButtonConfiguration {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let titleColor: UIColor
    let titleFont: UIFont
    let shadowColor: UIColor
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let shadowRadius: CGFloat

    let withBlurEffect: Bool

    /// Button configuration initalizer
    /// - Parameters:
    ///   - backgroundColor: the button's background color
    ///   - borderColor: the button's border color
    ///   - titleColor: the button's title color
    ///   - shadowColor: the button's color of the shadow
    ///   - cornerRadius: the button's corner radius
    ///   - borderWidth: the button's border width
    ///   - shadowRadius: the button's shadow radius
    ///   - withBlurEffect: adds a blur effect on the button ignoring the background color and making it translucent
    public init(backgroundColor: UIColor,
                borderColor: UIColor,
                titleColor: UIColor,
                titleFont: UIFont,
                shadowColor: UIColor,
                cornerRadius: CGFloat,
                borderWidth: CGFloat,
                shadowRadius: CGFloat,
                withBlurEffect: Bool) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.titleColor = titleColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.withBlurEffect = withBlurEffect
        self.titleFont = titleFont
    }
}
