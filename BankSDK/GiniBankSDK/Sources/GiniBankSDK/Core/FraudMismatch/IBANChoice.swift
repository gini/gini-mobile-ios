//
//  IBANChoice.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation

/** The user's pick on the IBAN selection sheet. */
internal enum IBANChoice: Hashable {
    case qr(iban: String)
    case printed(iban: String)

    /** The raw IBAN value for whichever case is selected. */
    var iban: String {
        switch self {
        case .qr(let iban), .printed(let iban):
            return iban
        }
    }
}
