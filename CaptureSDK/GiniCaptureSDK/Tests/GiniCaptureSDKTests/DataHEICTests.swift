//
//  DataHEICTests.swift
//  GiniCaptureSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Foundation
import CoreGraphics
import ImageIO
import MobileCoreServices
@testable import GiniCaptureSDK

/**
 HEIC (ISO/IEC 23008-12) detection + transcode regression coverage.
 Accepted HEIF brands: `heic`, `heix`, `heif`, `mif1`, `msf1`.

 The iOS Simulator does not ship a HEIC encoder, so tests here never call
 `CGImageDestinationCreateWithData` with a HEIC UTI — that call hangs the
 Swift Testing cooperative pool and starves every other suite. Real HEIC
 coverage is driven off the `iphone-heic-photo.heic` fixture instead.
 */
@Suite("Data extension — HEIC detection")
struct DataHEICTests {

    /**
     Builds a minimal HEIF `ftyp` box: `size · "ftyp" · brand · padding`.

     - Parameter brand: 4-byte HEIF brand identifier (e.g. `"heic"` bytes).
     - Returns: 16-byte signature suitable for magic-byte detection tests.
     */
    private static func heicSignatureBytes(brand: [UInt8]) -> [UInt8] {
        let boxSize: [UInt8] = [0x00, 0x00, 0x00, 0x20]
        let ftypBox: [UInt8] = [0x66, 0x74, 0x79, 0x70]
        let padding: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        return boxSize + ftypBox + brand + padding
    }

    private static let heicBrand: [UInt8] = [0x68, 0x65, 0x69, 0x63]  // "heic"
    private static let heixBrand: [UInt8] = [0x68, 0x65, 0x69, 0x78]  // "heix"
    private static let heifBrand: [UInt8] = [0x68, 0x65, 0x69, 0x66]  // "heif"
    private static let mif1Brand: [UInt8] = [0x6D, 0x69, 0x66, 0x31]  // "mif1"
    private static let msf1Brand: [UInt8] = [0x6D, 0x73, 0x66, 0x31]  // "msf1"

    @Test("`Data.isImage` returns true for HEIC bytes",
          arguments: [heicBrand, heixBrand, heifBrand, mif1Brand, msf1Brand])
    func dataIsImageIsTrueForHEIC(brand: [UInt8]) {
        let data = Data(Self.heicSignatureBytes(brand: brand))
        #expect(data.isImage, "isImage must recognise HEIC")
    }

    @Test("`Data.isImage` still returns false for a plain octet-stream blob")
    func dataIsImageIsFalseForNonImage() {
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        #expect(!data.isImage)
    }

    @Test("`Data.isImage` still returns true for JPEG bytes (existing behaviour)")
    func dataIsImageIsTrueForJPEG() {
        let data = Data([0xFF, 0xD8, 0xFF, 0xE0])
        #expect(data.isImage)
    }

    @Test("`GiniCaptureDocumentBuilder.build(with:fileName:)` builds an image document from HEIC data")
    func buildImageDocumentFromHEICData() throws {
        let data = Data(Self.heicSignatureBytes(brand: Self.heicBrand))
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        let document = builder.build(with: data, fileName: "test.heic")

        let imageDocument = try #require(document as? GiniImageDocument)
        #expect(imageDocument.type == .image)
    }

    // MARK: - `jpegDataPreservingMetadata` — direct helper coverage

    @Test("`jpegDataPreservingMetadata` returns nil for non-image bytes")
    func jpegDataPreservingMetadataReturnsNilForNonImage() {
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        #expect(data.jpegDataPreservingMetadata() == nil)
    }

    @Test("`jpegDataPreservingMetadata` is idempotent on JPEG input (helper is not HEIC-only)")
    func jpegDataPreservingMetadataAcceptsJPEG() throws {
        let jpegBytes = try #require(Self.makeRealJPEGData())
        try #require(jpegBytes.isJPEG)

        let roundTripped = try #require(jpegBytes.jpegDataPreservingMetadata())
        #expect(roundTripped.isJPEG)
    }

    // MARK: - Real-file import (Files-app "Open with" path)

    /**
     End-to-end against a real iPhone HEIC via the data-based builder overload
     — mirrors the customer's Files-app "Open with" flow.
     Fixture: `iphone-heic-photo.heic` in `Tests/Resources/`.

     The URL overload wraps `UIDocument.open`, which requires a hosted
     application run loop and hangs in the SPM test process. Load the
     fixture bytes directly and drive the data overload — that's the code
     path the URL variant delegates to once `UIDocument` returns.
     */
    @Test("`GiniCaptureDocumentBuilder.build(with data:)` imports a real iPhone HEIC and produces JPEG bytes")
    func buildFromRealHEICFile() throws {
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "iphone-heic-photo", withExtension: "heic")
        )
        let fileBytes = try Data(contentsOf: fixtureURL)
        try #require(fileBytes.isHEIC)

        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "com.gini.tests"))
        builder.importMethod = .openWith

        let document = builder.build(with: fileBytes, fileName: fixtureURL.lastPathComponent)

        let imageDocument = try #require(document as? GiniImageDocument)
        #expect(imageDocument.type == .image)
        #expect(imageDocument.data.isJPEG)
        #expect(!imageDocument.data.isHEIC)
        #expect(imageDocument.isFromOtherApp)
    }

    /**
     Encodes a 1×1 pixel as JPEG via `CGImageDestination`.

     - Returns: JPEG bytes on success, or `nil` when the JPEG encoder is
       unavailable on the current platform.
     */
    private static func makeRealJPEGData() -> Data? {
        guard let cgImage = makeCGImage(rgba: [0, 255, 0, 255]) else { return nil }

        let target = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(target, kUTTypeJPEG, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return target as Data
    }

    /**
     Builds a 1×1 `CGImage` (premultiplied-last RGBA) from raw pixel bytes.

     - Parameter rgba: Exactly 4 bytes: red, green, blue, alpha.
     - Returns: A 1×1 `CGImage`, or `nil` when construction fails.
     */
    private static func makeCGImage(rgba: [UInt8]) -> CGImage? {
        var rgba = rgba
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider(data: Data(bytes: &rgba, count: rgba.count) as CFData) else {
            return nil
        }
        return CGImage(width: 1,
                       height: 1,
                       bitsPerComponent: 8,
                       bitsPerPixel: 32,
                       bytesPerRow: 4,
                       space: colorSpace,
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)
    }
}
