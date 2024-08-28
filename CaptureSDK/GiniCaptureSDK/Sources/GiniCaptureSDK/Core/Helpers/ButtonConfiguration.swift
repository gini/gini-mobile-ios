//
//  ButtonConfiguration.swift
//  
//
//  Created by David Vizaknai on 30.11.2022.
//

import UIKit

public struct ButtonConfiguration {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let titleColor: UIColor
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
    }
}

extension BottomLabelButton {
    func configure(with configuration: ButtonConfiguration) {
        self.backgroundColor = configuration.backgroundColor
        self.layer.borderColor = configuration.borderColor.cgColor
        self.layer.shadowColor = configuration.shadowColor.cgColor

        self.actionLabel.textColor = configuration.titleColor

        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.shadowRadius = configuration.shadowRadius
    }
}

public extension UIButton {
    func configure(with configuration: ButtonConfiguration) {
        self.backgroundColor = configuration.backgroundColor
        self.layer.borderColor = configuration.borderColor.cgColor
        self.layer.shadowColor = configuration.shadowColor.cgColor
        self.setTitleColor(configuration.titleColor, for: .normal)
        self.setTitleColor(configuration.titleColor, for: .highlighted)
        self.setTitleColor(configuration.titleColor, for: .selected)

        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.shadowRadius = configuration.shadowRadius

        // When switching from one ButtonConfiguration with a blur effect to another ButtonConfiguration with a blur effect,
        // the previous blur effect should be removed.
        self.removeBlurEffect()
        if configuration.withBlurEffect {
            self.addBlurEffect(cornerRadius: configuration.cornerRadius)
        }
    }
}
