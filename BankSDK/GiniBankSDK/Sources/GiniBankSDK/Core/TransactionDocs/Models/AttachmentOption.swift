//
//  AttachmentOption.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
enum AttachmentOption {
    case alwaysAttach
    case attachOnce
    case doNotAttach

    var title: String {
        switch self {
        case .alwaysAttach:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.action.attachAlways",
                                                            comment: "Always attach")
        case .attachOnce:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.action.attachOnce",
                                                            comment: "Attach once")
        case .doNotAttach:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.transactionDocs.alert.action.doNotAttach",
                                                            comment: "Do not attach")
        }
    }
}
