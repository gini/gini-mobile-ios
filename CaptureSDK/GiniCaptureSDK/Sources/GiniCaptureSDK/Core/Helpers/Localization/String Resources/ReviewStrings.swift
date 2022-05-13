//
//  ReviewStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum ReviewStrings: LocalizableStringResource {
    
    case bottomText, documentImageTitle, rotateButton, topText, unknownErrorMessage
    
    var tableName: String {
        return "review"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .bottomText:
            return ("bottom", "Text at the bottom of the review screen encouraging the " +
                "user to check sharpness by double-tapping the image")
        case .documentImageTitle:
            return ("documentImageTitle",
                    "Title for document image in review screen will be used exclusively for accessibility label")
        case .rotateButton:
            return ("rotateButton",
                    "Title for rotate button in review screen will be used exclusively for accessibility label")
        case .topText:
            return ("top", "Text at the top of the review screen asking the user if " +
                    "the full document is sharp and in the correct orientation")
        case .unknownErrorMessage:
            return ("unknownError", "This message is shown when Photo library permission is denied")
        }
    }
    
    var isCustomizable: Bool {
        return true
    }
    
    var fallbackTableEntry: String {
        switch self {
        default:
            return ""
        }
    }
    
}
