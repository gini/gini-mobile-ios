//
//  File.swift
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
            if let value = UserDefaults.standard.object(forKey: key) as? T {
                return value
            }
            if let data = UserDefaults.standard.data(forKey: key),
               let decodedValue = try? JSONDecoder().decode(T.self, from: data) {
                return decodedValue
            }
            return defaultValue
        }
        set {
            if let encodedValue = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedValue, forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}
