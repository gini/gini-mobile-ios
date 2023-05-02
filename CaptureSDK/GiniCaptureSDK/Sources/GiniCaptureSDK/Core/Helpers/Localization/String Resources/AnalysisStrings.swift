//
//  AnalysisStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

public enum AnalysisStrings: LocalizableStringResource {

    case analysisErrorMessage, documentCreationErrorMessage, cancelledMessage

    public var tableName: String {
        return "analysis"
    }

    public var tableEntry: LocalizationEntry {
        switch self {
        case .analysisErrorMessage:
            return ("error.analysis", "This message is shown when there is an error analyzing the document")
        case .documentCreationErrorMessage:
            return ("error.documentCreation", "This message is shown when there is an error creating the document")
        case .cancelledMessage:
            return ("error.cancelled", "This message is shown when the analysis was cancelled")
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
