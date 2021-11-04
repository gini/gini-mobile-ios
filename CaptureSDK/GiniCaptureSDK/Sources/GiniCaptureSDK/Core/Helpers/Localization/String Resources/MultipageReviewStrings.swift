//
//  MultipageReviewStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum MultipageReviewStrings: LocalizableStringResource {
    
    case addButtonLabel, dragAndDropTipMessage, reorderContainerTooltipMessage, retakeActionButton, retryActionButton,
    titleMessage
    
    var tableName: String {
        return "multipagereview"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .addButtonLabel:
            return ("addButtonLabel", "label shown below add button")
        case .dragAndDropTipMessage:
            return ("dragAndDropTip", "drag and drop tip shown below pages collection")
        case .reorderContainerTooltipMessage:
            return ("reorderContainerTooltipMessage", "reorder button tooltip message")
        case .retakeActionButton:
            return ("error.retakeAction", "button title for retake action")
        case .retryActionButton:
            return ("error.retryAction", "button title for retry action")
        case .titleMessage:
            return ("title", "title with the page indicator")
        }
    }
    
    var isCustomizable: Bool {
        switch self {
        case .retakeActionButton, .retryActionButton, .reorderContainerTooltipMessage, .dragAndDropTipMessage:
            return true
        case .addButtonLabel, .titleMessage:
            return false
        }
    }
    
    var fallbackTableEntry: String {
        switch self {
        default:
            return ""
        }
    }
    
}
