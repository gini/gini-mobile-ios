//
//  EncodingHelper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// A shared helper to encode dictionaries into a container.
internal func encodeDictionary<Container: KeyedEncodingContainerProtocol>(
    into container: inout Container,
    value: [String: Any]
) throws where Container.Key == JSONCodingKeys {
    for (key, itemValue) in value {
        guard let codingKey = JSONCodingKeys(stringValue: key) else { continue }

        switch itemValue {
            case let intValue as Int:
                try container.encode(intValue, forKey: codingKey)
            case let stringValue as String:
                try container.encode(stringValue, forKey: codingKey)
            case let boolValue as Bool:
                try container.encode(boolValue, forKey: codingKey)
            case let arrayValue as [Any]:
                var nestedUnkeyedContainer = container.nestedUnkeyedContainer(forKey: codingKey)
                try encodeArray(into: &nestedUnkeyedContainer, value: arrayValue)
            case let dictionaryValue as [String: Any]:
                var nestedContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, 
                                                                forKey: codingKey)
                try encodeDictionary(into: &nestedContainer, value: dictionaryValue)
            default:
                continue // Skip unsupported types
        }
    }
}

/// A shared helper to encode arrays into a container.
internal func encodeArray<Container: UnkeyedEncodingContainer>(
    into container: inout Container,
    value: [Any]
) throws {
    for item in value {
        switch item {
            case let intValue as Int:
                try container.encode(intValue)
            case let stringValue as String:
                try container.encode(stringValue)
            case let boolValue as Bool:
                try container.encode(boolValue)
            case let dictionaryValue as [String: Any]:
                var nestedContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self)
                try encodeDictionary(into: &nestedContainer, value: dictionaryValue)
            case let arrayValue as [Any]:
                var nestedUnkeyedContainer = container.nestedUnkeyedContainer()
                try encodeArray(into: &nestedUnkeyedContainer, value: arrayValue)
            default:
                continue // Skip unsupported types
        }
    }
}
