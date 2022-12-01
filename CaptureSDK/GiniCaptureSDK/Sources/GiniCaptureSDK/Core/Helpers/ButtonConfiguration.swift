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

    let titleFont: UIFont?

    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let shadowRadius: CGFloat

    let withBlurEffect: Bool

    // TODO: Document this
    public init(backgroundColor: UIColor, borderColor: UIColor, titleColor: UIColor, shadowColor: UIColor, titleFont: UIFont?, cornerRadius: CGFloat, borderWidth: CGFloat, shadowRadius: CGFloat, withBlurEffect: Bool) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.titleColor = titleColor
        self.shadowColor = shadowColor
        self.titleFont = titleFont
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.withBlurEffect = withBlurEffect
    }
}

extension UIButton {
    func configure(with configuration: ButtonConfiguration) {
        self.backgroundColor = configuration.backgroundColor
        self.layer.borderColor = configuration.borderColor.cgColor
        self.layer.shadowColor = configuration.shadowColor.cgColor
        self.setTitleColor(configuration.titleColor, for: .normal)
        self.setTitleColor(configuration.titleColor, for: .highlighted)
        self.setTitleColor(configuration.titleColor, for: .selected)

        self.titleLabel?.font = configuration.titleFont

        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.borderWidth
        self.layer.shadowRadius = configuration.shadowRadius

        if configuration.withBlurEffect {
            self.addBlurEffect(cornerRadius: configuration.cornerRadius)
        }
    }
}
