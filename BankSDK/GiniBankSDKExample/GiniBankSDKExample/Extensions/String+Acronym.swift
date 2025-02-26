//
//  String+Acronym.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


extension String {
    func acronym() -> String {
        // Split the string into words based on spaces
        let words = self.split(separator: " ")
        // Take the first two words (if available)
        let firstTwoLetters = words.prefix(2)
            .compactMap { $0.first } // Get first letter of each word
            .map { String($0).uppercased() } // Convert to uppercase
            .joined()

        return firstTwoLetters
    }
}
