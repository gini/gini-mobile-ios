//
//  String+Acronym.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


extension String {
    func acronym() -> String {
        // Split the string into words based on spaces
        let words = self.split(separator: " ")
        // Extract the first character of each word and join them as uppercase
        return words.compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
    }
}
