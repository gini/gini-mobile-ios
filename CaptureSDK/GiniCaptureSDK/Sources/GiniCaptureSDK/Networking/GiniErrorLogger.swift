//
//  GiniCaptureErrorLogger+GiniCaptureErrorLoggerDelegate.swift
//  GiniCapture
//
//  Created by Alpár Szotyori on 27.07.21.
//

import Foundation
import GiniBankAPILibrary
import GiniUtilites

class GiniErrorLogger: GiniCaptureErrorLoggerDelegate {
    
    private let documentService: DocumentServiceProtocol
    
    init(documentService: DocumentServiceProtocol) {
        self.documentService = documentService
    }
    
    public func handleErrorLog(error: ErrorLog) {
        Log(message: "Sending error log to Gini: \(error)", event: "📝")
        documentService.log(errorEvent: ErrorEvent.from(error))
    }
}
