//
//  GiniUserDefaultPropertyWrapper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
/**
 A property wrapper for storing and retrieving `Codable` values in `UserDefaults`.

 This wrapper automatically encodes and decodes the wrapped value using `JSONEncoder` and `JSONDecoder`.

 - note: Internal usage only.
*/

@propertyWrapper
public struct GiniUserDefault<T: Codable> {
    // The key used to store the value in `UserDefaults`.
    private let key: String
    // The default value returned if no value is found for the given key.
    private let defaultValue: T

    /**
     Initializes the property wrapper.

     - Parameters:
     - key: The `UserDefaults` key.
     - defaultValue: A fallback value to return if no data is stored.
     */
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    /**
     The wrapped value that can be accessed or modified.

     - Returns: The decoded value from `UserDefaults` if present and valid, otherwise the default value.
     - Sets: The value is encoded and stored in `UserDefaults`.
     */
    public var wrappedValue: T {
        get {
            // Handle Codable types with JSON encoding/decoding
            if let data = UserDefaults.standard.data(forKey: key),
               let decodedValue = try? JSONDecoder().decode(T.self, from: data) {
                return decodedValue
            }
            return defaultValue
        }
        set {
            // Handle Codable types with JSON encoding
            if let encodedValue = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedValue, forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}
