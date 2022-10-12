//
//  MultipageReviewStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum MultipageReviewStrings: LocalizableStringResource {
    
    case retakeActionButton, retryActionButton,
    titleMessage
    
    var tableName: String {
        return "multipagereview"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .retakeActionButton:
            return ("error.retakeAction", "button title for retake action")
        case .retryActionButton:
            return ("error.retryAction", "button title for retry action")
        case .titleMessage:
            return ("title", "title with the page indicator")
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
