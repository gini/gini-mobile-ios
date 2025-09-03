//
//  Localized.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 13.09.23.
//

import Foundation

protocol Localized {
    var localized: String { get }
    var localizationKey: String { get }
    
    static var tableName: String? { get }
}

extension Localized {
    var localized: String {
        return NSLocalizedString(localizationKey, tableName: Self.tableName, comment: "")
    }
}
