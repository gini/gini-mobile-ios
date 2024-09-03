//
//  Attachment.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct Attachment {
    public let fileName: String
    public let type: AttachmentType
    
    public init(fileName: String, type: AttachmentType) {
        self.fileName = fileName
        self.type = type
    }
}
