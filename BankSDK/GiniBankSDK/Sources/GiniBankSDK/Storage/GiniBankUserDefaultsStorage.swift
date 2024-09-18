//
//  GiniBankUserDefaultsStorage.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniBankAPILibrary

struct GiniBankUserDefaultsStorage {
    @GiniUserDefault("ginibank.defaults.client.configurations", defaultValue: nil)
    static var clientConfiguration: ClientConfiguration?

    // Bool should be saved as a primitive type directly
    @GiniUserDefault("ginibank.defaults.user.alwaysAttachDocs", defaultValue: nil)
    static var alwaysAttachDocs: Bool?
    // Method to remove the value from UserDefaults
    static func removeAlwaysAttachDocs() {
        GiniBankUserDefaultsStorage.alwaysAttachDocs = nil
    }
}
