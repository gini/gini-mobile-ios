//
//  Data.swift
//  GiniHealthAPI
//
//  Created by Enrique del Pozo Gómez on 3/21/19.
//

import Foundation

extension Data {
    private static let mimeTypeSignatures: [UInt8: String] = [
        0xFF: "image/jpeg",
        0x89: "image/png",
        0x47: "image/gif",
        0x49: "image/tiff",
        0x4D: "image/tiff",
        0x25: "application/pdf",
        0xD0: "application/vnd",
        0x46: "text/plain"
    ]
    
    var contentType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
    
    var mimeType: String {
        return String(contentType.split(separator: "/").first!)
    }
    
    var mimeSubType: String {
        return String(contentType.split(separator: "/").last!)
    }
    
    init?(url: URL?) {
        if let url = url {
            do {
                self = try .init(contentsOf: url)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
