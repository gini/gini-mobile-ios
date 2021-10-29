//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import UIKit

//swiftlint:disable line_length
/**
 A Gini Capture document made from a QR code.
 
 The Gini Capture SDK supports the following QR code formats:
 - Bezahlcode (http://www.bezahlcode.de).
 - Stuzza (AT) and GiroCode (DE) (https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation).
 - EPS E-Payment (https://eservice.stuzza.at/de/eps-ueberweisung-dokumentation/category/5-dokumentation.html).
 
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
    
    fileprivate lazy var paymentInformation: Data? = {
        let jsonDict: [String: Any] = ["qrcode": self.scannedString, "paymentdata": self.extractedParameters]
        
        return try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    }()
    fileprivate let scannedString: String
    public lazy var extractedParameters: [String: String] = QRCodesExtractor
        .extractParameters(from: self.scannedString, withFormat: self.qrCodeFormat)
    fileprivate let epc06912LinesCount = 12
    public lazy var qrCodeFormat: QRCodesFormat? = {
        if self.scannedString.starts(with: "bank://") {
            return .bezahl
        } else if self.scannedString.starts(with: "epspayment://") {
            return .eps4mobile
        } else if let lines = Optional(self.scannedString.splitlines),
            lines.count > 9 &&
            (lines[1] == "001" || lines[1] == "002") {
            
            if !(lines[2] == "1" || lines[2] == "2") {
                print("WARNING: Character set \(lines[2]) is unknown. Expected version 1 or 2.")
            }
            
            return .epc06912
        } else {
            return nil
        }
    }()
    
    init(scannedString: String) {
        self.scannedString = scannedString
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
