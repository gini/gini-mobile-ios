//
//  JSONCodingKeys.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// A structure conforming to the `CodingKey` protocol, used for encoding JSON keys.
internal struct JSONCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    /// Initializes a `JSONCodingKeys` instance with a string value.
    ///
    /// - Parameter stringValue: The string value of the key.
    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    /// Initializes a `JSONCodingKeys` instance with an integer value.
    ///
    /// - Parameter intValue: The integer value of the key.
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
