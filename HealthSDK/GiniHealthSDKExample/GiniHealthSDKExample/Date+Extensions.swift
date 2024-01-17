//
//  Date+Extensions.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

extension Date {
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
}
