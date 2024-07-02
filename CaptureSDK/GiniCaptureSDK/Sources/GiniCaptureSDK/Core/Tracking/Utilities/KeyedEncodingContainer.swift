//
//  KeyedEncodingContainer.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

internal extension KeyedEncodingContainer {

    /// Encodes a dictionary into the container for the given key, if present.
    ///
    /// - Parameters:
    ///   - value: The dictionary to encode.
    ///   - key: The key to associate with the encoded value.
    /// - Throws: An encoding error if the data is invalid.
    mutating func encodeIfPresent(_ value: [String: Any?]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard let safeValue = value, !safeValue.isEmpty else { return }
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        for item in safeValue {
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

    /// Encodes an array into the container for the given key, if present.
    ///
    /// - Parameters:
    ///   - value: The array to encode.
    ///   - key: The key to associate with the encoded value.
    /// - Throws: An encoding error if the data is invalid.
    mutating func encodeIfPresent(_ value: [Any]?, forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard let safeValue = value else { return }
        if let val = safeValue as? [Int] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = safeValue as? [String] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = safeValue as? [Bool] {
            try self.encodeIfPresent(val, forKey: key)
        } else if let val = value as? [[String: Any]] {
            var container = self.nestedUnkeyedContainer(forKey: key)
            try container.encode(contentsOf: val)
        }
    }
}
