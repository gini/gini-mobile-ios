//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

extension Date {
    func formattedDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}
