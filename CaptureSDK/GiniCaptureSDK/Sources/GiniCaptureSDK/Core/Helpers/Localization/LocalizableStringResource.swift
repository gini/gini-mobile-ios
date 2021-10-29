//
//  Localization.swift
//  GiniCapture
//
//  Created by Gini GmbH on 7/31/18.
//

import Foundation
import UIKit

public typealias LocalizationEntry = (value: String, description: String)

public protocol LocalizableStringResource {
    var tableName: String { get }
    var tableEntry: LocalizationEntry { get }
    var fallbackTableEntry: String { get }
    var isCustomizable: Bool { get }
}

extension LocalizableStringResource {

    public var localizedFormat: String {
        let keyPrefix = "ginicapture.\(tableName)"
        let key = "\(keyPrefix).\(tableEntry.value)"
        let fallbackKey = "\(keyPrefix).\(fallbackTableEntry)"

        return NSLocalizedStringPreferredFormat(key,
                                                fallbackKey: fallbackKey,
                                                comment: tableEntry.description,
                                                isCustomizable: isCustomizable)
        
    }
}
