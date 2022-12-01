//
//  ButtonConfiguration.swift
//  
//
//  Created by David Vizaknai on 30.11.2022.
//

import UIKit

struct ButtonConfiguration {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let titleColor: UIColor
    let shadowColor: UIColor

    let titleFont: UIFont?

    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let shadowRadius: CGFloat
}

enum ButtonType {
    case primary
    case secondary

    func configuration() -> ButtonConfiguration {
        switch self {
        case .primary:
            return ButtonConfiguration(backgroundColor: .red, // .GiniCapture.accent1,
                                       borderColor: .clear,
                                       titleColor: .GiniCapture.light1,
                                       shadowColor: .clear,
                                       titleFont: GiniConfiguration.shared.textStyleFonts[.bodyBold],
                                       cornerRadius: 16,
                                       borderWidth: 0,
                                       shadowRadius: 0)
        case .secondary:
            return ButtonConfiguration(backgroundColor: .green, // .GiniCapture.dark4,
                                       borderColor: .clear,
                                       titleColor: .GiniCapture.accent1,
                                       shadowColor: .clear,
                                       titleFont: GiniConfiguration.shared.textStyleFonts[.bodyBold],
                                       cornerRadius: 16,
                                       borderWidth: 2,
                                       shadowRadius: 0)

        }
    }
}

extension UIButton {
    func configure(with configuration: ButtonConfiguration) -> UIButton {
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

        return self
    }
}
