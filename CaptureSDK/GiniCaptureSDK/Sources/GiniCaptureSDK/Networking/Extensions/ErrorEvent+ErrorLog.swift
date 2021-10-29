//
//  ErrorEvent+ErrorLog.swift
//  GiniCapture
//
//  Created by Alpár Szotyori on 18.09.21.
//

import Foundation
import GiniBankAPILibrary

extension ErrorEvent {
    
    static func from(_ errorLog: ErrorLog) -> ErrorEvent {
        var description = errorLog.description
        
        switch errorLog.error {
        case let error as GiniError:
            var details: [String] = [error.message]
            if let response = error.response {
                let headers = response.allHeaderFields
                    .map { (key, value) in "\(key): \(value)" }
                    .joined(separator: "\n")
                details.append("Status code: \(response.statusCode)\nHeaders:\n\(headers)")
            }
            if let data = error.data,
               let dataString = String(data: data, encoding: .utf8) {
                details.append("Body:\n\(dataString)")
            }
            description = "\(description); Exception: \(type(of: error)): \(details.joined(separator: "\n"))"
        case let error as GiniCaptureError:
            description = "\(description); Exception: \(type(of: error)): \(error.message)"
        default:
            description = "\(description); Exception: \(String(describing: errorLog.error))"
        }
        
        return ErrorEvent(deviceModel: errorLog.deviceModel,
                          osName: errorLog.osName,
                          osVersion: errorLog.osVersion,
                          captureSdkVersion: errorLog.captureVersion,
                          apiLibVersion: errorLog.apiLibVersion,
                          description: description,
                          documentId: nil,
                          originalRequestId: nil)
    }
}
