//
//  GiniBankUserDefaultsStorage.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniBankAPILibrary

struct GiniBankUserDefaultsStorage {
    @UserDefault("ginibank.defaults.client.configurations", defaultValue: nil)
    static var clientConfiguration: ClientConfiguration?

    // Bool should be saved as a primitive type directly
    @UserDefault("ginibank.defaults.user.alwaysAttachDocs", defaultValue: nil)
    static var alwaysAttachDocs: Bool?
}
