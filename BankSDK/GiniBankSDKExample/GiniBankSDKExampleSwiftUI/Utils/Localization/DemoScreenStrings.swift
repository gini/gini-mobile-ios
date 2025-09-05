//
//  DemoScreenStrings.swift
//  GiniBankSDKExample
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

enum DemoScreenStrings: Localized {
    case welcomeTitle
    case screenDescription
    case ibanTextFieldPlaceholder
    case photoPaymentButtonTitle
    case alternativeText
    case transactionListButtonTitle
}

extension DemoScreenStrings {
    static var tableName: String? = "DemoScreen"
    
    var localizationKey: String {
        switch self {
            case .welcomeTitle:
                return "welcome.title"
            case .screenDescription:
                return "screen.description"
            case .ibanTextFieldPlaceholder:
                return "iban.textfield.placeholder"
            case .photoPaymentButtonTitle:
                return "photo.payment.button.title"
            case .alternativeText:
                return "alternative.text"
            case .transactionListButtonTitle:
                return "transaction.list.button.title"
        }
    }
}
