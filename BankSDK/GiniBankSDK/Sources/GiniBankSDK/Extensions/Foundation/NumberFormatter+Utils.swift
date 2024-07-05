//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

extension NumberFormatter {
    static var decimalGerman: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }
}
