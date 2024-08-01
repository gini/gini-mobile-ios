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

    var inBerlinTimeZone: Date {
        guard let berlinTimeZone = TimeZone(identifier: "Europe/Berlin") else {
            return Date()
        }
        
        var calendar = Calendar.current
        calendar.timeZone = berlinTimeZone
        
        let berlinDate = calendar.date(byAdding: .second, value: calendar.timeZone.secondsFromGMT(for: self), to: self)
        return berlinDate ?? Date()
    }
}
