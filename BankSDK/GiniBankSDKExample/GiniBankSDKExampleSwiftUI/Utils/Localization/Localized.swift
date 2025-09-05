//
//  Localized.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 13.09.23.
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
