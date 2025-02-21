//
//  Date+ToString.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

extension Date {
    func toFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
