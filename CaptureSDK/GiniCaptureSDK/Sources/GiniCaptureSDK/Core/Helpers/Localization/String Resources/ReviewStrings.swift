//
//  ReviewStrings.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

enum ReviewStrings: LocalizableStringResource {
    case screenTitle
    case tipTitle
    case processButtonTitle
    case addPagesButtonTitle
    case addPagesAccessibility
    case photoLibraryAccessDenied
    case photoLibraryAccessDeniedCancelButton
    case photoLibraryAccessDeniedGrantAccessButton

    var tableName: String {
        switch self {
        case .screenTitle, .tipTitle, .processButtonTitle, .addPagesButtonTitle, .addPagesAccessibility:
            return "multipagereview"
        case .photoLibraryAccessDenied, .photoLibraryAccessDeniedCancelButton, .photoLibraryAccessDeniedGrantAccessButton:
            return "saveinvoice"
        }
    }

    var tableEntry: LocalizationEntry {
        switch self {
        case .screenTitle:
            return ("title",
                    "Screen title")
        case .tipTitle:
            return ("description",
                    "Tip on review screen")
        case .processButtonTitle:
            return ("mainButtonTitle",
                    "Process button title")
        case .addPagesButtonTitle:
            return ("secondaryButtonTitle",
                    "Add pages button title")
        case .addPagesAccessibility:
            return ("secondaryButton.accessibility",
                    "Add pages")
        case .photoLibraryAccessDenied:
            return ("photoLibraryAccessDenied",
                    "Message shown when photo library access is denied")
        case .photoLibraryAccessDeniedCancelButton:
            return ("photoLibraryAccessDenied.errorPopup.cancelButton",
                    "Cancel button title in photo library access denied alert")
        case .photoLibraryAccessDeniedGrantAccessButton:
            return ("photoLibraryAccessDenied.errorPopup.grantAccessButton",
                    "Grant access button title in photo library access denied alert")
        }
    }

    var isCustomizable: Bool {
        return true
    }

    var fallbackTableEntry: String {
        switch self {
        case .screenTitle:
            return "title"
        case .tipTitle:
            return "description"
        case .processButtonTitle:
            return "mainButtonTitle"
        case .addPagesButtonTitle:
            return "secondaryButtonTitle"
        case .addPagesAccessibility:
            return "secondaryButton.accessibility"
        case .photoLibraryAccessDenied:
            return "photoLibraryAccessDenied"
        case .photoLibraryAccessDeniedCancelButton:
            return "photoLibraryAccessDenied.errorPopup.cancelButton"
        case .photoLibraryAccessDeniedGrantAccessButton:
            return "photoLibraryAccessDenied.errorPopup.grantAccessButton"
        }
    }

    var localized: String {
        return localizedFormat
    }
}
