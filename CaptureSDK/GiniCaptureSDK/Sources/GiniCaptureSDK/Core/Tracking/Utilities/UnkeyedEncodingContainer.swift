//
//  UnkeyedEncodingContainer.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

internal extension UnkeyedEncodingContainer {

    /// Encodes a sequence of dictionaries into the container.
    ///
    /// - Parameter sequence: The sequence of dictionaries to encode.
    /// - Throws: An encoding error if the data is invalid.
    mutating func encode(contentsOf sequence: [[String: Any]]) throws {
        for dict in sequence {
            try self.encodeIfPresent(dict)
        }
    }

    /// Encodes a dictionary into the container, if present.
    ///
    /// - Parameter value: The dictionary to encode.
    /// - Throws: An encoding error if the data is invalid.
    mutating func encodeIfPresent(_ value: [String: Any]) throws {
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        for item in value {
            guard let codingKey = JSONCodingKeys(stringValue: item.key) else {
                continue // Skip the item if we cannot create a JSONCodingKey
            }
            if let val = item.value as? Int {
                try container.encodeIfPresent(val, forKey: codingKey)
            } else if let val = item.value as? String {
                try container.encodeIfPresent(val, forKey: codingKey)
            } else if let val = item.value as? Bool {
                try container.encodeIfPresent(val, forKey: codingKey)
            } else if let val = item.value as? [Any] {
                try container.encodeIfPresent(val, forKey: codingKey)
            } else if let val = item.value as? [String: Any] {
                try container.encodeIfPresent(val, forKey: codingKey)
            }
        }
    }
}
