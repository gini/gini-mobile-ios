//
//  Style.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import SwiftUI
import UIKit

public enum Style {
    enum TabBarColor {
        static let activeColor = UIColor(red: 0.267, green: 0.278, blue: 0.341, alpha: 1)
        static let inactiveColor = UIColor(red: 0.584, green: 0.6, blue: 0.678, alpha: 1)
    }

    enum AppointmentView {
        static let consultationBackgroundColor = Color(red: 0.714, green: 0.783, blue: 0.887)
        static let consultationTextColor = Color(red: 0, green: 0.322, blue: 0.804)
        static let treatmentBackgroundColor = Color(red: 0.744, green: 0.867, blue: 0.779)
        static let treatmentTextColor = Color(red: 0.149, green: 0.561, blue: 0.286)
    }

    enum ServiceView {
        static let backgroundColor = Color(red: 0.906, green: 0.946, blue: 0.94)
    }

    enum NewInvoice {
        static let backgroundColor = Color(red: 0.859, green: 0.89, blue: 0.945)
        static let grayBackgroundColor = Color(red: 0.898, green: 0.898, blue: 0.898)
        static let accentBlue = Color(red: 0, green: 0.248, blue: 0.887)

    }
}

extension Style {
    enum FontStyle: String {
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "Semibold"
        case bold = "Bold"
    }
    static func appFont(style: FontStyle = .regular, _ size: CGFloat = 16) -> Font {
        return Font.custom("SFProDisplay-\(style.rawValue)", size: size)
    }
}
