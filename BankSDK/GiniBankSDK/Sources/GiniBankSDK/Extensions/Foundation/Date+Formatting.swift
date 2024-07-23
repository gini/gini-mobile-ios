//
//  Date+Formatting.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension Date {
    var currentShortString: String {
        return DateFormatter.currentShort.string(from: self)
    }

    var yearMonthDayString: String {
        return DateFormatter.yearMonthDay.string(from: self)
    }
}
