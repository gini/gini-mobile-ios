//
//  DateFormatter+Utils.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let backend: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        return formatter
    }()
}
