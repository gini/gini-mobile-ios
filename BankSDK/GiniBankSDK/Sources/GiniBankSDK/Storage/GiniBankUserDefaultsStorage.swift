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
}
