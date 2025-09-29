//
//  Localized.swift
//  GiniBankSDKExample
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

protocol Localized {
    var localizationKey: String { get }
    static var tableName: String? { get }
}

extension Localized {
    var localized: String {
        NSLocalizedString(localizationKey,
                          tableName: Self.tableName,
                          comment: "")
    }
}
