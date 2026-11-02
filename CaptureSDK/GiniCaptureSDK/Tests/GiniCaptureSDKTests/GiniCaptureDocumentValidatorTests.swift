//
//  GiniCaptureDocumentValidatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
import PDFKit
import Testing
import UIKit
@testable import GiniCaptureSDK
final class GiniCaptureDocumentValidatorTests: XCTestCase {

    let giniConfiguration = GiniConfiguration()

    func testExcedeedMaxFileSize() {
        let higherThan10MBData = generateFakeData(megaBytes: 12)

        let pdfDocument = GiniPDFDocument(data: higherThan10MBData, fileName: nil)

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size lower than 10MB should be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }

    func testNotExcedeedMaxFileSize() {
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)

        let pdfDocument = GiniPDFDocument(data: lowerThanOrEqualTo10MBData, fileName: nil)

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size greater than 10MB should not be valid") { error in
                                XCTAssert(error as? DocumentValidationError != .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }

    func testImageValidation() {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let imageDocument = GiniImageDocument(data: image.jpegData(compressionQuality: 0.2)!, imageSource: .camera)

        XCTAssertNoThrow(try GiniCaptureDocumentValidator.validate(imageDocument,
                                                                  withConfig: giniConfiguration),
                         "Valid images should validate without throwing an exception")
    }

    func testEmptyFileValidation() {
        let pdfDocument = GiniPDFDocument(data: Data(count: 0), fileName: nil)

        XCTAssertThrowsError(try GiniCaptureDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Empty files should not be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .fileFormatNotValid,
                                          "should indicate that the file format is invalid")
        }
    }

    func testProtectedPdfFileSize() {
        let pdfData = generateSamplePDF()
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                                   in: .userDomainMask,
                                                                   appropriateFor: nil,
                                                                   create:false
        ) else {
            XCTFail("Could not access document directory")
            return
        }

        let encryptedFileURL = documentDirectory.appendingPathComponent("encrypted_pdf_file")
        if let pdfDocument = PDFDocument(data: pdfData) {
            // write with password protection
            pdfDocument.write(
                to: encryptedFileURL,
                withOptions: [
                    PDFDocumentWriteOption.userPasswordOption : "pwd",
                    PDFDocumentWriteOption.ownerPasswordOption : "pwd"
                ])
            // get encrypted pdf
            guard let encryptedPDFDoc = PDFDocument(url: encryptedFileURL) else {
                return
            }

            XCTAssert(encryptedPDFDoc.isEncrypted == true)
            XCTAssert(encryptedPDFDoc.isLocked == true)

            if let data = try? Data(contentsOf: encryptedFileURL) {
                let pdfDocument = GiniPDFDocument(data: data, fileName: nil)
                XCTAssertThrowsError(
                    try GiniCaptureDocumentValidator.validate(
                        pdfDocument,
                        withConfig: giniConfiguration
                    ),
                    "Password protected files should not be valid") { error in
                        XCTAssert(
                            error as? DocumentValidationError == .pdfPasswordProtected,
                            "should indicate that the file  is protected")
                    }
            }
        }
    }

    fileprivate func generateFakeData(megaBytes lengthInMB: Int) -> Data {
        let length = lengthInMB * 1000000
        return Data(count: length)
    }

    fileprivate func generateSamplePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Test Builder",
            kCGPDFContextAuthor: "Gini"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
        context.beginPage()
        let attributes = [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
        ]
        let text = "I'm a PDF!"
        text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        }

        return data
    }

}

// MARK: - Swift Testing coverage for format & page-count guards

@Suite("GiniCaptureDocumentValidator format & page-count guards")
struct GiniCaptureDocumentValidatorSwiftTests {

    private let giniConfiguration = GiniConfiguration()

    /// Renders an in-memory PDF with the requested number of blank pages.
    private func renderPDF(pageCount: Int) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { context in
            for _ in 0..<pageCount {
                context.beginPage()
            }
        }
    }

    /// Builds a minimal WebP-signature payload. The SDK's `Data.mimeType` sniffer maps the
    /// first byte `0x52` (`R`, RIFF magic) to `image/webp`, whose UTI conforms to
    /// `kUTTypeImage` — so `isImage` returns true and the validator advances past the first
    /// guard. `isJPEG`/`isPNG`/`isGIF`/`isTIFF` all return false, which trips the second
    /// (format-specific) guard.
    private func makeWebPSignatureData() -> Data {
        var bytes: [UInt8] = []

        /// RIFF container header — file size field left as a placeholder (0), which is fine
        /// for the mimeType/UTI sniff we exercise here.
        bytes.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
        bytes.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // placeholder size
        bytes.append(contentsOf: [0x57, 0x45, 0x42, 0x50]) // "WEBP"
        bytes.append(contentsOf: [0x56, 0x50, 0x38, 0x20]) // "VP8 " chunk id
        bytes.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // placeholder chunk size

        return Data(bytes)
    }

    @Test("PDF with 11 pages throws .pdfPageLengthExceeded")
    func testPdfExceedingMaxPagesFails() throws {
        let pdfData = renderPDF(pageCount: 11)
        let document = GiniPDFDocument(data: pdfData, fileName: nil)

        #expect(throws: DocumentValidationError.pdfPageLengthExceeded) {
            try GiniCaptureDocumentValidator.validate(document,
                                                     withConfig: giniConfiguration)
        }
    }

    @Test("PDF wrapper around JPEG bytes throws .fileFormatNotValid")
    func testNonPdfDataInPdfWrapperFails() throws {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let jpegData = try #require(image.jpegData(compressionQuality: 0.2))
        let document = GiniPDFDocument(data: jpegData, fileName: nil)

        #expect(throws: DocumentValidationError.fileFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(document,
                                                     withConfig: giniConfiguration)
        }
    }

    @Test("Image wrapper around WebP-signature bytes throws .imageFormatNotValid")
    func testUnsupportedImageFormatFails() throws {
        let webpData = makeWebPSignatureData()
        let document = GiniImageDocument(data: webpData, imageSource: .external)

        /// Sanity check: the payload must satisfy the generic image guard first,
        /// so the validator reaches the second (format-specific) branch.
        #expect(webpData.isImage)
        #expect(!webpData.isJPEG)
        #expect(!webpData.isPNG)
        #expect(!webpData.isGIF)
        #expect(!webpData.isTIFF)

        #expect(throws: DocumentValidationError.imageFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(document,
                                                     withConfig: giniConfiguration)
        }
    }
}

// MARK: - Wero gate on unknown QR payloads

/**
 Pins the `.none` branch of `GiniCaptureDocumentValidator.validate(qrCode:)`.
 When the Wero flag is off (or unset), an unknown QR payload throws
 `qrCodeFormatNotValid` so the camera surfaces the "unsupported QR code"
 alert and no upload fires. When the flag is on, the same payload passes
 validation so the networking layer can upload it for backend classification.
 Payloads with a recognised `qrCodeFormat` never reach the gate.

 Shares the cross-suite flag lock on `GiniCaptureTestsHelper` with `GiniQRCodeDocumentTests`
 so the two can't race on the global `weroQRCodeScanningEnabled` key.
 */
@Suite("GiniCaptureDocumentValidator — Wero gate on unknown QR payloads", .serialized)
struct GiniCaptureDocumentValidatorWeroGateTests {

    private let configuration = GiniConfiguration()

    /// An EPC QR missing the IBAN field — `qrCodeFormat` resolves to `nil`,
    /// so the validator reaches the Wero gate.
    private let unknownPayload = "BCD\r\n001\r\n2\r\nSCT\r\nGENODES1NUE\r\nAUTOHAUS MARTIN WURST GMBH"

    /// A valid EPC06912 payload — `qrCodeFormat == .epc06912`, so validation
    /// takes the strict-IBAN path and never consults the Wero flag.
    private let validEpcPayload = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\nEUR12.00\n\nRef\n"

    @Test("Flag off: unknown payload throws qrCodeFormatNotValid")
    func unknownPayloadThrowsWhenFlagOff() {
        GiniCaptureTestsHelper.withWeroFlag(false) {
            let document = GiniQRCodeDocument(scannedString: unknownPayload)
            #expect(throws: DocumentValidationError.qrCodeFormatNotValid) {
                try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
            }
        }
    }

    @Test("Flag unset: unknown payload throws qrCodeFormatNotValid (fail-closed)")
    func unknownPayloadThrowsWhenFlagUnset() {
        GiniCaptureTestsHelper.withWeroFlag(nil) {
            let document = GiniQRCodeDocument(scannedString: unknownPayload)
            #expect(throws: DocumentValidationError.qrCodeFormatNotValid) {
                try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
            }
        }
    }

    @Test("Flag on: unknown payload passes validation")
    func unknownPayloadPassesWhenFlagOn() {
        GiniCaptureTestsHelper.withWeroFlag(true) {
            let document = GiniQRCodeDocument(scannedString: unknownPayload)
            #expect(document.qrCodeFormat == nil,
                    "Precondition: unknown payload must resolve to a nil qrCodeFormat so the Wero gate is reached")
            #expect(throws: Never.self) {
                try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
            }
        }
    }

    @Test("Flag on: recognised EPC payload still takes its format-specific path")
    func recognisedPayloadIgnoresFlag() {
        GiniCaptureTestsHelper.withWeroFlag(true) {
            let document = GiniQRCodeDocument(scannedString: validEpcPayload)
            #expect(document.qrCodeFormat != nil,
                    "Precondition: a valid EPC payload must resolve to a non-nil qrCodeFormat")
            #expect(throws: Never.self) {
                try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
            }
        }
    }

    @Test("Flag off: recognised EPC payload still takes its format-specific path")
    func recognisedPayloadIgnoresDisabledFlag() {
        GiniCaptureTestsHelper.withWeroFlag(false) {
            let document = GiniQRCodeDocument(scannedString: validEpcPayload)
            #expect(document.qrCodeFormat != nil,
                    "Precondition: a valid EPC payload must resolve to a non-nil qrCodeFormat")
            #expect(throws: Never.self) {
                try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
            }
        }
    }
}

// MARK: - Residual uncovered paths

/**
 Fills the file-level branches that the other suites don't reach:
 the custom-validation error propagation, the `.default` branch of
 `validateType` (non-QR/PDF/Image documents), the non-image guard
 inside `validate(imageDocument:)`, the early-return in
 `ensurePDFUnlocked` when `CGPDFDocument` cannot decode a
 PDF-signatured payload, and the EPS/SPD QR branches with both the
 happy and empty-IBAN paths through `validateNonEmptyIBAN`.
 */
@Suite("GiniCaptureDocumentValidator — residual uncovered paths")
struct GiniCaptureDocumentValidatorResidualPathsTests {

    private let configuration = GiniConfiguration()

    @Test("Custom validation failure propagates the custom error")
    func customValidationFailurePropagatesError() throws {
        let config = GiniConfiguration()
        let expectedMessage = "custom-rejection"
        config.customDocumentValidations = { _ in
            .failure(withError: CustomDocumentValidationError(message: expectedMessage))
        }
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let jpegData = try #require(image.jpegData(compressionQuality: 0.2))
        let document = GiniImageDocument(data: jpegData, imageSource: .camera)

        var thrown: Error?
        do {
            try GiniCaptureDocumentValidator.validate(document, withConfig: config)
        } catch {
            thrown = error
        }

        let custom = try #require(thrown as? CustomDocumentValidationError)
        #expect(custom.message == expectedMessage)
    }

    @Test("XML document hits the default branch of validateType without throwing")
    func xmlDocumentPassesTypeValidation() {
        let document = GiniXMLDocument(data: Data("<x/>".utf8), fileName: "sample.xml")
        #expect(throws: Never.self) {
            try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
        }
    }

    @Test("Non-image bytes wrapped in GiniImageDocument throw .fileFormatNotValid")
    func nonImageBytesThrowFileFormatNotValid() {
        /// First byte `0x6E` ('n') is not a known image signature, so
        /// `Data.mimeType` falls through to `application/octet-stream` and
        /// `isImage` returns false — the first guard inside
        /// `validate(imageDocument:)` throws.
        let document = GiniImageDocument(data: Data("not-an-image".utf8), imageSource: .external)
        #expect(throws: DocumentValidationError.fileFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
        }
    }

    @Test("PDF-signatured garbage short-circuits ensurePDFUnlocked and later trips the page-count guard")
    func pdfSignaturedGarbageSkipsUnlockCheck() {
        /// First byte `0x25` ('%') maps to `application/pdf`, so `isPDF`
        /// returns true. `CGPDFDocument` fails on the malformed body, which
        /// triggers the `else { return }` branch in `ensurePDFUnlocked`.
        /// `numberPages` stays at 0, so `ensurePageCountValid` throws
        /// `pdfPageLengthExceeded` next.
        let document = GiniPDFDocument(data: Data("%PDF-not-a-real-pdf".utf8), fileName: nil)
        #expect(throws: DocumentValidationError.pdfPageLengthExceeded) {
            try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
        }
    }

    @Test("EPS 4 Mobile payload passes validateContainsKey")
    func epsPayloadPassesValidation() {
        /// The EPS extractor always sets `epsCodeUrlKey` to the raw payload,
        /// so this exercises the happy path of `validateContainsKey`.
        let document = GiniQRCodeDocument(scannedString: "epspayment://example.com/abc")
        #expect(document.qrCodeFormat == .eps4mobile,
                "Precondition: the payload must resolve to the eps4mobile format")
        #expect(throws: Never.self) {
            try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
        }
    }

    @Test("SPD payload with ACC passes validateNonEmptyIBAN")
    func spdPayloadWithIBANPassesValidation() {
        let payload = "SPD*1.0*ACC:CZ6508000000192000145399*AM:1000*CC:CZK"
        let document = GiniQRCodeDocument(scannedString: payload)
        #expect(document.qrCodeFormat == .spd,
                "Precondition: the payload must resolve to the spd format")
        #expect(document.extractedParameters["iban"] == "CZ6508000000192000145399")
        #expect(throws: Never.self) {
            try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
        }
    }

    @Test("SPD payload without ACC throws .qrCodeFormatNotValid")
    func spdPayloadWithoutIBANThrows() {
        let payload = "SPD*1.0*AM:1000*CC:CZK"
        let document = GiniQRCodeDocument(scannedString: payload)
        #expect(document.qrCodeFormat == .spd)
        #expect(document.extractedParameters["iban"] == nil,
                "Precondition: the payload must omit the iban so the gate fires")
        #expect(throws: DocumentValidationError.qrCodeFormatNotValid) {
            try GiniCaptureDocumentValidator.validate(document, withConfig: configuration)
        }
    }
}
