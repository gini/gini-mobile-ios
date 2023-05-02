//
//  ImageAnalysisNoResultsStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

public enum ImageAnalysisNoResultsStrings: LocalizableStringResource {

    case collectionHeaderText, goToCameraButton, titleText, warningText, warningHelpMenuText

    public var tableName: String {
        return "noresults"
    }

    public var tableEntry: LocalizationEntry {
        switch self {
        case .collectionHeaderText:
            return ("collection.header", "no results suggestions collection header title")
        case .goToCameraButton:
            return ("gotocamera", "bottom button title (go to camera button)")
        case .titleText:
            return ("title",
                    "navigation title shown on no results tips, when the screen is shown through the help menu")
        case .warningText:
            return ("warning", "Warning text that indicates that there was any result for this photo analysis")
        case .warningHelpMenuText:
            return ("warningHelpMenu",
                    "warning text shown on no results tips, when the screen is shown through the help menu")
        }
    }

    public var isCustomizable: Bool {
        return true
    }

    public var fallbackTableEntry: String {
        switch self {
        default:
            return ""
        }
    }

}
