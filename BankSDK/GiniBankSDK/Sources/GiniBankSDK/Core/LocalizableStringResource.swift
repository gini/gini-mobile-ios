//
//  Localization.swift
//  GiniPayBank
//
//  Created by Gini GmbH on 7/31/18.
//

import Foundation
import UIKit
import GiniCapture

extension LocalizableStringResource {

    var localizedGiniPayFormat: String {
        let keyPrefix = "ginipaybank.\(tableName)"
        let key = "\(keyPrefix).\(tableEntry.value)"
        let fallbackKey = "\(keyPrefix).\(fallbackTableEntry)"

        return NSLocalizedStringPreferredGiniPayFormat(key,
                                                fallbackKey: fallbackKey,
                                                comment: tableEntry.description,
                                                isCustomizable: isCustomizable)
    }
}
