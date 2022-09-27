//
//  AnalysisStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

public enum AnalysisStrings: LocalizableStringResource {
    
    case analysisErrorMessage, documentCreationErrorMessage, cancelledMessage, loadingText, pdfPages,
    suggestion1Text, suggestion2Text, suggestion3Text, suggestion4Text, suggestion5Text, suggestionHeader,
    defaultPdfDokumentTitle
    
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
        case .loadingText:
            return ("loadingText", "Text appearing at the center of the analysis screen " +
            "indicating that the document is being analysed")
        case .pdfPages:
            return ("pdfpages",
                    "Text appearing at the top of the analysis screen indicating pdf number of pages")
        case .suggestion1Text:
            return ("suggestion.1", "First suggestion text for analysis screen")
        case .suggestion2Text:
            return ("suggestion.2", "Second suggestion text for analysis screen")
        case .suggestion3Text:
            return ("suggestion.3", "Third suggestion text for analysis screen")
        case .suggestion4Text:
            return ("suggestion.4", "Fourth suggestion text for analysis screen")
        case .suggestion5Text:
            return ("suggestion.5", "Fifth suggestion text for analysis screen")
        case .suggestionHeader:
            return ("suggestion.header", "Fourth suggestion text for analysis screen")
        case .defaultPdfDokumentTitle:
            return ("defaultPdfDokumentTitle", "Default PDF document title")
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
