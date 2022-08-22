//
//  AnalysisStrings.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

public enum AnalysisStrings: LocalizableStringResource {
    
    case analysisErrorMessage, documentCreationErrorMessage, cancelledMessage, loadingText, loadingTextPDF, pdfPages, screenTitle, suggestion1Title, suggestion2Title, suggestion3Title, suggestion4Title, suggestion5Title, suggestion1Description, suggestion2Description, suggestion3Description, suggestion4Description, suggestion5Description, defaultPdfDokumentTitle
    
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
        case .loadingTextPDF:
            return ("loadingText.pdf", "Text appearing at the center of the analysis screen " +
            "indicating that a PDF document is being analysed, indicating the title of the document")
        case .pdfPages:
            return ("pdfpages",
                    "Text appearing at the top of the analysis screen indicating pdf number of pages")
        case .screenTitle:
            return ("screenTitle",
                    "Text appearing on the top of thje navigation bar as the screen title.")
        case .suggestion1Title:
            return ("suggestion.title.1", "First suggestion title for analysis screen")
        case .suggestion2Title:
            return ("suggestion.title.2", "Second suggestion title for analysis screen")
        case .suggestion3Title:
            return ("suggestion.title.3", "Third suggestion title for analysis screen")
        case .suggestion4Title:
            return ("suggestion.title.4", "Fourth suggestion title for analysis screen")
        case .suggestion5Title:
            return ("suggestion.title.5", "Fifth suggestion title for analysis screen")

        case .suggestion1Description:
            return ("suggestion.description.1", "First suggestion description for analysis screen")
        case .suggestion2Description:
            return ("suggestion.description.2", "Second suggestion description for analysis screen")
        case .suggestion3Description:
            return ("suggestion.description.3", "Third suggestion description for analysis screen")
        case .suggestion4Description:
            return ("suggestion.description.4", "Fourth suggestion description for analysis screen")
        case .suggestion5Description:
            return ("suggestion.description.5", "Fifth suggestion description for analysis screen")

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
