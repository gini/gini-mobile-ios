//
//  Data.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import MobileCoreServices
import UIKit

extension Data {
    private static let mimeTypeSignatures: [UInt8: String] = [
        0xFF: "image/jpeg",
        0x89: "image/png",
        0x47: "image/gif",
        0x49: "image/tiff",
        0x4D: "image/tiff",
        0x52: "image/webp",
        0x25: "application/pdf",
        0xD0: "application/vnd",
        0x46: "text/plain"
        ]

    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }

    var utiFromMimeType: Unmanaged<CFString>? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self.mimeType as CFString, nil)
    }

    var isPDF: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypePDF)
        }
        return false
    }

    var isImage: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeImage)
        }
        return false
    }

    var isPNG: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypePNG)
        }
        return false
    }

    var isJPEG: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeJPEG)
        }
        return false
    }

    var isGIF: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeGIF)
        }
        return false
    }

    var isTIFF: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeTIFF)
        }
        return false
    }

}
