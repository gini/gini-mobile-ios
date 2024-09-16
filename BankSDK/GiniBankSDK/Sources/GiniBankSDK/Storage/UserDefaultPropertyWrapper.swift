//
//  UserDefaultPropertyWrapper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            // Handle primitive types directly
            if T.self == Bool.self {
                return (UserDefaults.standard.bool(forKey: key) as? T) ?? defaultValue
            } else if T.self == Int.self {
                return (UserDefaults.standard.integer(forKey: key) as? T) ?? defaultValue
            } else if T.self == Double.self {
                return (UserDefaults.standard.double(forKey: key) as? T) ?? defaultValue
            } else if T.self == String.self {
                return (UserDefaults.standard.string(forKey: key) as? T) ?? defaultValue
            }

            // Handle Codable types with JSON encoding/decoding
            if let data = UserDefaults.standard.data(forKey: key),
               let decodedValue = try? JSONDecoder().decode(T.self, from: data) {
                return decodedValue
            }
            return defaultValue
        }
        set {
            // Handle primitive types directly
            if let boolValue = newValue as? Bool {
                UserDefaults.standard.set(boolValue, forKey: key)
            } else if let intValue = newValue as? Int {
                UserDefaults.standard.set(intValue, forKey: key)
            } else if let doubleValue = newValue as? Double {
                UserDefaults.standard.set(doubleValue, forKey: key)
            } else if let stringValue = newValue as? String {
                UserDefaults.standard.set(stringValue, forKey: key)
            } else {
                // Handle Codable types with JSON encoding
                if let encodedValue = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(encodedValue, forKey: key)
                } else {
                    UserDefaults.standard.set(newValue, forKey: key)
                }
            }
        }
    }
}
