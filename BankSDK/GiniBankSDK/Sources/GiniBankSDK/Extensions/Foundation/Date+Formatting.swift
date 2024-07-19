//
//  Date+Formatting.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension Date {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: self)
    }

    var backendFormatString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
