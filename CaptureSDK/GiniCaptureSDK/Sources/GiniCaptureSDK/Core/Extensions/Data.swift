//
//  Data.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import MobileCoreServices
import ImageIO
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
        0x46: "text/plain",
        0x3C: "application/xml"
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

    var isXML: Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeXML)
        }
        return false
    }

    var isImage: Bool {
        if isHEIC { return true }
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeImage)
        }
        return false
    }

    /**
     Whether `self` looks like a HEIF/HEIC container.

     `Data.mimeType` matches on the first byte only; HEIC files start with the
     ISO Base Media box size (typically `0x00 0x00 0x00 0x20`) which collides
     with `application/octet-stream`. Detect HEIC by looking for the `ftyp`
     box marker at offset 4 and one of the five HEIF brands at offset 8:
     `heic`, `heix`, `heif`, `mif1`, or `msf1`.
     */
    var isHEIC: Bool {
        guard count >= 12 else { return false }

        let ftyp: [UInt8] = [0x66, 0x74, 0x79, 0x70]
        let heifBrands: [[UInt8]] = [
            [0x68, 0x65, 0x69, 0x63], // "heic"
            [0x68, 0x65, 0x69, 0x78], // "heix"
            [0x68, 0x65, 0x69, 0x66], // "heif"
            [0x6D, 0x69, 0x66, 0x31], // "mif1"
            [0x6D, 0x73, 0x66, 0x31]  // "msf1"
        ]

        return withUnsafeBytes { raw -> Bool in
            let bytes = raw.bindMemory(to: UInt8.self)
            for offset in 0..<4 where bytes[4 + offset] != ftyp[offset] {
                return false
            }
            return heifBrands.contains { brand in
                for offset in 0..<4 where bytes[8 + offset] != brand[offset] {
                    return false
                }
                return true
            }
        }
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

    /**
     Transcodes the receiver to JPEG bytes, preserving embedded EXIF, TIFF,
     and GPS properties.

     Uses `CGImageSource` → `CGImageDestination`, so metadata survives —
     unlike `UIImage(data:).jpegData(compressionQuality:)`, which drops it.

     - Parameter compressionQuality: JPEG quality in the range `0.0`…`1.0`.
       Defaults to `1.0` (lossless-ish re-encode).
     - Returns: JPEG bytes on success, or `nil` when the receiver cannot be
       decoded as an image.
     */
    func jpegDataPreservingMetadata(compressionQuality: CGFloat = 1.0) -> Data? {
        guard let source = CGImageSourceCreateWithData(self as CFData, nil) else { return nil }
        let target = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(target, kUTTypeJPEG, 1, nil) else {
            return nil
        }
        /// `kCGImageDestinationLossyCompressionQuality` is a per-image option:
        /// setting it on the destination is silently ignored. Pass it in the
        /// properties dict of `AddImageFromSource`, which merges with — rather
        /// than replaces — the source's EXIF/TIFF/GPS properties.
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        CGImageDestinationAddImageFromSource(destination, source, 0, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return target as Data
    }
}
