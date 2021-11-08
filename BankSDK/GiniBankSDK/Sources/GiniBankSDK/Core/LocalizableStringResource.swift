//
//  Localization.swift
// GiniBank
//
//  Created by Gini GmbH on 7/31/18.
//

import Foundation
import UIKit
import GiniCaptureSDK

extension LocalizableStringResource {

    var localizedGiniBankFormat: String {
        let keyPrefix = "ginibank.\(tableName)"
        let key = "\(keyPrefix).\(tableEntry.value)"
        let fallbackKey = "\(keyPrefix).\(fallbackTableEntry)"

        return NSLocalizedStringPreferredGiniBankFormat(key,
                                                fallbackKey: fallbackKey,
                                                comment: tableEntry.description,
                                                isCustomizable: isCustomizable)
    }
}
