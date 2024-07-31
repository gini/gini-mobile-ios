//
//  NumberFormatter+Utils.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension NumberFormatter {
    private static func makeLocalizedDecimalFormatter(locale: Locale = .current,
                                                      numberStyle: NumberFormatter.Style = .decimal,
                                                      usesGroupingSeparator: Bool = true) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = numberStyle
        formatter.usesGroupingSeparator = usesGroupingSeparator
        return formatter
    }

    static var twoDecimalPriceFormatter: NumberFormatter {
        let formatter = makeLocalizedDecimalFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }

    static var floorRoundingFormatter: NumberFormatter {
        let formatter = makeLocalizedDecimalFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .floor
        return formatter
    }
}
