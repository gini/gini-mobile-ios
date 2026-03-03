//
//   UserDefaults+CredentialsSet.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let selectedCredentialsSetIndex = "selectedCredentialsSetIndex"
        static let selectedAPIEnvironment = "selectedAPIEnvironment"
    }

    var selectedCredentialsSetIndex: Int {
        get {
            return integer(forKey: Keys.selectedCredentialsSetIndex)
        }
        set {
            set(newValue, forKey: Keys.selectedCredentialsSetIndex)
        }
    }

    var selectedAPIEnvironment: String {
        get {
            return string(forKey: Keys.selectedAPIEnvironment) ?? APIEnvironment.production.rawValue
        }
        set {
            set(newValue, forKey: Keys.selectedAPIEnvironment)
        }
    }
}
