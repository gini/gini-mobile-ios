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
    
    func isDueSoon(within days: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDate = calendar.startOfDay(for: self)
        
        // Calculate full days until due date
        let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
        
        // Counting today as day 1
        let inclusiveDays = daysUntilDue + 1
        
        return inclusiveDays >= days
    }
    
    func toDisplayString(format: String = "dd.MM.yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    static func date(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: string)
    }
}
