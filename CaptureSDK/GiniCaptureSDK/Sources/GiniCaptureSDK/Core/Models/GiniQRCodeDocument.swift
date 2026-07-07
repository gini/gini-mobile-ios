//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import GiniBankAPILibrary
import UIKit
import GiniUtilites

/**
 A Gini Capture document made from a QR code.

 The Gini Capture SDK supports the following QR code / payment code formats:
 - Bezahlcode (http://www.bezahlcode.de).
 - Stuzza (AT) and GiroCode (DE) (https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation).
 - EPS E-Payment (https://eservice.stuzza.at/de/eps-ueberweisung-dokumentation/category/5-dokumentation.html).
 - SPC / Swiss QR-bill (https://www.paymentstandards.ch).
 - SPD – Czech/Slovak Payment Descriptor.
 - Pay-by-Square (Slovak compressed QR, base32hex + LZMA).
 - UPNQR – Slovenian Universal Payment Order QR.
 - HUB3 – Croatian payment PDF417 barcode.

 */
@objc final public class GiniQRCodeDocument: NSObject, GiniCaptureDocument {
    public var type: GiniCaptureDocumentType = .qrcode
    public lazy var data: Data = {
        return self.paymentInformation ?? Data(count: 0)
    }()
    public var id: String
    public lazy var previewImage: UIImage? = {
        return UIImage(qrData: self.data)
    }()
    public var isReviewable: Bool = false
    public var isImported: Bool = false
    public var uploadMetadata: Document.UploadMetadata?

    fileprivate lazy var paymentInformation: Data? = {
        var jsonDict: [String: Any] = ["qrcode": self.scannedString]

        // Include paymentdata only if the format is not giniQRCode
        if self.qrCodeFormat != .giniQRCode {
            jsonDict["paymentdata"] = self.extractedParameters
        }

        return try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    }()
    fileprivate let scannedString: String
    public lazy var extractedParameters: [String: String] = QRCodesExtractor
        .extractParameters(from: self.scannedString, withFormat: self.qrCodeFormat)
    public lazy var qrCodeFormat: QRCodesFormat? = {
        if self.scannedString.starts(with: QRCodesFormat.giniQRCode.prefixURL) {
            return .giniQRCode
        } else if self.scannedString.starts(with: QRCodesFormat.bezahl.prefixURL) {
            return .bezahl
        } else if self.scannedString.starts(with: QRCodesFormat.eps4mobile.prefixURL) {
            return .eps4mobile
        } else if self.scannedString.starts(with: QRCodesFormat.spd.prefixURL) {
            return .spd
        } else {
            let lines = self.scannedString.splitlines
            guard !lines.isEmpty else { return nil }
            switch lines[0] {
            case QRCodesFormat.epc06912.prefixURL:
                return Self.epc06912Format(from: lines)
            case QRCodesFormat.spc.prefixURL:
                return Self.spcFormat(from: lines)
            case QRCodesFormat.upnqr.prefixURL:
                return .upnqr
            case QRCodesFormat.hub3.prefixURL:
                return .hub3
            default:
                return PayBySquareDecoder.looksLikePayBySquare(self.scannedString) ? .payBySquare : nil
            }
        }
    }()

    /// EPC069-12 (Stuzza/GiroCode): valid only when line 6 holds a valid IBAN.
    /// Line 2 carries the character-set version (1 or 2); anything else is logged.
    private static func epc06912Format(from lines: [String]) -> QRCodesFormat? {
        if lines.indices.contains(2) && !(lines[2] == "1" || lines[2] == "2") {
            Log(message: "WARNING: Character set \(lines[2]) is unknown. Expected version 1 or 2.",
                event: "EPC QR code")
        }
        guard lines.indices.contains(6), IBANValidator().isValid(iban: lines[6]) else { return nil }
        return .epc06912
    }

    /// SPC / Swiss QR-bill: valid only when line 3 holds a valid IBAN.
    private static func spcFormat(from lines: [String]) -> QRCodesFormat? {
        guard lines.indices.contains(3), IBANValidator().isValid(iban: lines[3]) else { return nil }
        return .spc
    }

    init(scannedString: String, uploadMetadata: Document.UploadMetadata? = nil) {
        // Defensive: strip any embedded null bytes. The camera pipeline (Camera.swift)
        // handles truncation at the bit-stream level before reaching here, but callers
        // using this public initialiser directly may pass strings with \0 characters.
        self.scannedString = scannedString.replacingOccurrences(of: "\0", with: "")
        self.uploadMetadata = uploadMetadata
        self.id = UUID().uuidString
        super.init()
    }
}

// MARK: Equatable

extension GiniQRCodeDocument {
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? GiniQRCodeDocument {
            return self.scannedString == object.scannedString
        }
        return false
    }
}
