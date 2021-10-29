//
//  ErrorEvent.swift
//  GiniBankAPI
//
//  Created by Alpár Szotyori on 18.09.21.
//

import Foundation

/// Data model for sending error events.
public struct ErrorEvent: Codable, Equatable {
    let deviceModel: String
    let osName: String
    let osVersion: String
    let captureSdkVersion: String
    let apiLibVersion: String
    let description: String
    let documentId: String?
    let originalRequestId: String?
    
    public init(deviceModel: String,
                osName: String,
                osVersion: String,
                captureSdkVersion: String,
                apiLibVersion: String,
                description: String,
                documentId: String?,
                originalRequestId: String?) {
        self.deviceModel = deviceModel
        self.osName = osName
        self.osVersion = osVersion
        self.captureSdkVersion = captureSdkVersion
        self.apiLibVersion = apiLibVersion
        self.description = description
        self.documentId = documentId
        self.originalRequestId = originalRequestId
    }
}
