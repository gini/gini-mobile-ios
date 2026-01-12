//
//  GiniCaptureDocumentValidator.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//

import Foundation
import CoreGraphics
import GiniUtilites

public final class GiniCaptureDocumentValidator {

    public static var maxPagesCount: Int {
        return 10
    }

    // MARK: File validation
    /**
     Validates a document. The validation process is done in the _global_ `DispatchQueue`.
     Also it is possible to add custom validations in the `GiniConfiguration.customDocumentValidations`
     closure.
     
     - Throws: `DocumentValidationError.exceededMaxFileSize` is thrown if the document is not valid.
     
     */
    public class func validate(_ document: GiniCaptureDocument,
                               withConfig giniConfiguration: GiniConfiguration) throws {
        try validateSize(for: document.data)
        try validateType(for: document)

        let customValidationResult = giniConfiguration.customDocumentValidations(document)
        if let error = customValidationResult.error, !customValidationResult.isSuccess {
            throw error
        }
    }
}

// MARK: - Fileprivate

fileprivate extension GiniCaptureDocumentValidator {

    static var maxFileSize: Int { // Bytes
        return 10 * 1024 * 1024
    }

    class func validateSize(for data: Data) throws {
        if data.count > maxFileSize {
            throw DocumentValidationError.exceededMaxFileSize
        }

        if data.count == 0 {
            throw DocumentValidationError.fileFormatNotValid
        }

        return
    }

    class func validateType(for document: GiniCaptureDocument) throws {
        switch document {
        case let qr as GiniQRCodeDocument:
            try validate(qrCode: qr)

        case let pdf as GiniPDFDocument:
            try validate(pdfDocument: pdf)

        case let image as GiniImageDocument:
            try validate(imageDocument: image)

        default:
            break
        }
    }

    private class func validate(pdfDocument: GiniPDFDocument) throws {
        guard pdfDocument.data.isPDF else {
            throw DocumentValidationError.fileFormatNotValid
        }

        try ensurePDFUnlocked(pdfDocument)
        try ensurePageCountValid(pdfDocument)
    }

    private class func ensurePDFUnlocked(_ pdfDocument: GiniPDFDocument) throws {
        guard let provider = CGDataProvider(data: pdfDocument.data as CFData),
              let cgPDF = CGPDFDocument(provider)
        else {
            return
        }

        if !cgPDF.isUnlocked {
            throw DocumentValidationError.pdfPasswordProtected
        }
    }

    private class func ensurePageCountValid(_ pdfDocument: GiniPDFDocument) throws {
        guard (1...maxPagesCount).contains(pdfDocument.numberPages) else {
            throw DocumentValidationError.pdfPageLengthExceeded
        }
    }

    private class func validate(imageDocument: GiniImageDocument) throws {
        guard imageDocument.data.isImage else {
            throw DocumentValidationError.fileFormatNotValid
        }

        guard imageDocument.data.isJPEG ||
                imageDocument.data.isPNG ||
                imageDocument.data.isGIF ||
                imageDocument.data.isTIFF else {
            throw DocumentValidationError.imageFormatNotValid
        }
    }

    class func validate(qrCode document: GiniQRCodeDocument) throws {
        switch document.qrCodeFormat {
        case .some(.bezahl), .some(.epc06912):
            if document.qrCodeFormat == nil ||
                document.extractedParameters.isEmpty ||
                document.extractedParameters["iban"] == nil ||
                !IBANValidator().isValid(iban: document.extractedParameters["iban"] ?? "") {
                throw DocumentValidationError.qrCodeFormatNotValid
            }
        case .some(.eps4mobile):
            if document.extractedParameters[QRCodesExtractor.epsCodeUrlKey] == nil {
                throw DocumentValidationError.qrCodeFormatNotValid
            }
        case .some(.giniQRCode):
            if document.extractedParameters[QRCodesExtractor.giniCodeUrlKey] == nil {
                throw DocumentValidationError.qrCodeFormatNotValid
            }
        case .none:
            throw DocumentValidationError.qrCodeFormatNotValid
        }
    }
}
