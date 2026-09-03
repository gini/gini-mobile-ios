//
//  GiniCaptureErrorLogger.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 24.08.21.
//

import Foundation

public class GiniCaptureErrorLogger: GiniCaptureErrorLoggerDelegate {
    var isGiniLoggingOn = true
    var customErrorLogger: GiniCaptureErrorLoggerDelegate?
    var giniErrorLogger: GiniCaptureErrorLoggerDelegate?
    public func handleErrorLog(error: ErrorLog) {
        if isGiniLoggingOn {
            giniErrorLogger?.handleErrorLog(error: error)
        }
        if let customErrorLogger = customErrorLogger {
            customErrorLogger.handleErrorLog(error: error)
        }
    }
}
