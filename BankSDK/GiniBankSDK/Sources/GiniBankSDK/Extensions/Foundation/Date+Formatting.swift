//
//  Date+Formatting.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension Date {
    var shortString: String {
        return DateFormatter.short.string(from: self)
    }

    var backendString: String {
        return DateFormatter.backend.string(from: self)
    }
}
