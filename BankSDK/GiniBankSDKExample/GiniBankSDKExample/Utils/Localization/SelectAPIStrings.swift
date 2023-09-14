//
//  SelectAPIStrings.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 13.09.23.
//

import Foundation

enum SelectAPIStrings: Localized {
    case welcomeTitle
    case screenDescription
    case ibanTextFieldPlaceholder
    case photoPaymentButtonTitle
    case alternativeText
}

extension SelectAPIStrings {
    static var tableName: String? = "SelectAPI"
    
    var localizationKey: String {
        switch self {
            case .welcomeTitle:
                return "WELCOME_TITLE"
            case .screenDescription:
                return "SCREEN_DESCRIPTION"
            case .ibanTextFieldPlaceholder:
                return "IBAN_TEXTFIELD_PLACEHOLDER"
            case .photoPaymentButtonTitle:
                return "PHOTO_PAYMENT_BUTTON_TITLE"
            case .alternativeText:
                return "ALTERNATIVE_TEXT"
        }
    }
}
