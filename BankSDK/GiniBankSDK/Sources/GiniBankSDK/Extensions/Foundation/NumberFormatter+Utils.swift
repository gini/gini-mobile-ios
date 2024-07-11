//
//  NumberFormatter+Utils.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension NumberFormatter {
    static var localizedDecimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }
}
