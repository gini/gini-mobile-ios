//
//  GiniLocalization.swift
//  GiniUtilies
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 A utility for handling localized strings in the application.
 */

public enum GiniLocalization: String, CaseIterable {
    case en = "en"
    case de = "de"
}

/**
 An enumeration representing the visibility type of an ingredient brand.
 Use this enum to indicate how the ingredient brand is displayed.
 */
public enum IngredientBrandTypeEnum: String, Codable, CaseIterable {
    case fullVisible = "FULL_VISIBLE"
    case paymentComponent = "PAYMENT_COMPONENT"
    case invisible = "INVISIBLE"
}

/**
 An enumeration representing the tone of communication.

 Use this enum to specify whether the communication style should be formal or informal.
 */
public enum CommunicationToneEnum: String, Codable, CaseIterable {
    case formal = "FORMAL"
    case informal = "INFORMAL"

    func localizable() -> String {
        switch self {
            case .formal:
                "de"
            case .informal:
                "de_informal"
        }
    }

    static let defaultCommunicationTone = CommunicationToneEnum.formal.localizable()
}

/**
 A utility for retrieving localized strings from the client's bundle or SDK bundle.
 */
public enum GiniLocalized {

    /**
     Retrieves a localized string for the given key. According localization GiniHealthConfiguration localization field and with check for client app locallizaton

     - Parameters:
     - key: The key to search for in the strings file.
     - fallbackKey: The fallback key to use if the primary key is not found.
     - comment: The corresponding comment for the key.

     - Returns: The localized string for the given key.
     */
    public static func string(_ key: String, fallbackKey: String? = nil, comment: String, locale: String?, bundle: Bundle, communicationTone: CommunicationToneEnum? = .none) -> String {
        var locale = locale ?? getLanguageCode() ?? GiniLocalization.en.rawValue
        if locale == GiniLocalization.de.rawValue {
            locale = communicationTone?.localizable() ?? CommunicationToneEnum.defaultCommunicationTone
        }
        let clientAppBundle = Bundle.main

        if let clientString = overridedString(key, locale: locale, comment: comment, bundle: clientAppBundle) {
            return clientString
        } else if let fallbackKey = fallbackKey,
                    let fallbackClientString = overridedString(fallbackKey, locale: locale, comment: comment, bundle: clientAppBundle) {
            return fallbackClientString
        } else if let sdkString = overridedString(key, locale: locale, comment: comment, bundle: bundle) {
            return sdkString
        }
        return localizationString(fallbackKey ?? "", locale: locale, comment: comment, bundle: bundle)
    }

    /**
     Checks if the localized string exists in the localized strings.

     - Parameters:
     - key: The key to search for in the strings file.
     - locale: The locale for the localized string.
     - bundle: The bundle to search for the localized string.

     - Returns: The localized string if it exists, otherwise nil.
     */
    private static func overridedString(_ key: String, locale: String?, comment: String, bundle: Bundle) -> String? {
        let value = localizationString(key, locale: locale, comment: comment, bundle: bundle)
        return value.lowercased() == key.lowercased() ? nil : value
    }

    /**
     Retrieves the localized string based on the key and locale in specifyed bundle.

     - Parameters:
     - key: The key to search for in the strings file.
     - locale: The locale for the localized string.
     - bundle: The bundle to search for the localized string.

     - Returns: The localized string for the given key.
     */
    private static func localizationString(_ key: String, locale: String?, comment: String, bundle: Bundle) -> String {
        let localizedBundle = localizedBundle(parentBundle: bundle, localeKey: locale)
        return NSLocalizedString(key, tableName: nil, bundle: localizedBundle ?? bundle, value: "", comment: comment)
    }

    /**
     Retrieves the localized bundle based on the locale key.

     - Parameters:
     - parentBundle: The parent bundle to search for the localized bundle.
     - localeKey: The key representing the locale for the localized bundle.

     - Returns: The localized bundle if found, otherwise nil.
     */
    private static func localizedBundle(parentBundle: Bundle, localeKey: String?) -> Bundle? {
        guard let localeKey = localeKey,
              let path = parentBundle.path(forResource: localeKey, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }

    /**
        Retrieve the default language code of the system
     */
    private static func getLanguageCode() -> String? {
        let locale = Locale.current
        if let languageCode = locale.languageCode {
            return languageCode
        }
        return nil
    }
}
