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
 Regression coverage for HEIC image handling. HEIC files (ISO/IEC 23008-12)
 are ISO Base Media containers whose first bytes are the box size, followed
 by "ftyp" and a brand identifier. The five HEIF brands the SDK should
 accept are `heic`, `heix`, `heif`, `mif1`, and `msf1`.
 */
@Suite("Data extension — HEIC detection")
struct DataHEICTests {

    /// Bytes that mimic a valid HEIC file header, brand-parameterized.
    /// Layout: 4-byte box size · "ftyp" · 4-byte brand · 4-byte padding.
    private static func heicSignatureBytes(brand: [UInt8]) -> [UInt8] {
        [0x00, 0x00, 0x00, 0x20,          // box size (0x20 = 32)
         0x66, 0x74, 0x79, 0x70]           // "ftyp"
        + brand
        + [0x00, 0x00, 0x00, 0x00]         // minor version / padding
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
        #expect(data.isImage,
                "isImage must recognise HEIC — first-byte magic table misses `ftyp <brand>` at offset 4")
    }

    @Test("`Data.isImage` still returns false for a plain octet-stream blob")
    func dataIsImageIsFalseForNonImage() {
        // Random bytes that don't match any image signature.
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        #expect(!data.isImage,
                "isImage must not regress: non-image binary blobs stay rejected")
    }

    @Test("`Data.isImage` still returns true for JPEG bytes (existing behaviour)")
    func dataIsImageIsTrueForJPEG() {
        // JPEG magic bytes.
        let data = Data([0xFF, 0xD8, 0xFF, 0xE0])
        #expect(data.isImage)
    }

    @Test("`GiniCaptureDocumentBuilder.build(with:fileName:)` builds an image document from HEIC data")
    func buildImageDocumentFromHEICData() throws {
        let data = Data(Self.heicSignatureBytes(brand: Self.heicBrand))
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        let document = builder.build(with: data, fileName: "test.heic")

        let imageDocument = try #require(document as? GiniImageDocument,
                                          "Builder must produce a GiniImageDocument for HEIC input")
        #expect(imageDocument.type == .image)
    }

    // MARK: - `jpegDataPreservingMetadata` — direct helper coverage

    @Test("`jpegDataPreservingMetadata` returns nil for non-image bytes")
    func jpegDataPreservingMetadataReturnsNilForNonImage() {
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        #expect(data.jpegDataPreservingMetadata() == nil,
                "Helper must refuse non-image input rather than silently emitting empty JPEG bytes")
    }

    @Test("`jpegDataPreservingMetadata` preserves a planted EXIF field across the transcode")
    func jpegDataPreservingMetadataKeepsEXIF() throws {
        let expectedLens = "gini-capture-heic-exif-lens-test"
        let heicData = try #require(
            Self.makeRealHEICData(exifLensModel: expectedLens),
            "Simulator lacks HEIC encoder — skipping EXIF-preservation proof"
        )

        let jpegData = try #require(heicData.jpegDataPreservingMetadata(),
                                     "HEIC → JPEG transcode must produce data for a valid image")

        let source = try #require(CGImageSourceCreateWithData(jpegData as CFData, nil),
                                    "Transcoded JPEG must decode as an image")
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        let exif = try #require(properties[kCGImagePropertyExifDictionary] as? [CFString: Any],
                                  "EXIF dictionary must survive the transcode")
        let lensModel = try #require(exif[kCGImagePropertyExifLensModel] as? String,
                                       "EXIF LensModel must survive the transcode")
        #expect(lensModel == expectedLens)
    }

    @Test("`jpegDataPreservingMetadata` is idempotent on JPEG input (helper is not HEIC-only)")
    func jpegDataPreservingMetadataAcceptsJPEG() throws {
        // A tiny CGImage → JPEG blob. Nothing special about the metadata; the
        // point is that the helper accepts JPEG input and returns valid JPEG.
        let jpegBytes = try #require(Self.makeRealJPEGData(),
                                       "Simulator lacks JPEG encoder — skipping idempotency proof")
        #expect(jpegBytes.isJPEG)

        let roundTripped = try #require(jpegBytes.jpegDataPreservingMetadata(),
                                          "Helper must accept JPEG input and produce JPEG output")
        #expect(roundTripped.isJPEG,
                "Roundtripped output must still be JPEG")
    }

    // MARK: - Backend expects JPEG, not HEIC

    /// End-to-end proof: a real HEIC-encoded `UIImage` reaches `GiniImageDocument`
    /// and its stored `data` is JPEG on the way out — matching what the Gallery
    /// path produces and what the Gini backend accepts.
    ///
    /// A synthetic 16-byte HEIC header (used by the tests above for `isImage`
    /// detection) is not actually a decodable image, so `UIImage(data:)` cannot
    /// re-encode it. This test builds a real HEIC by round-tripping a 1×1 pixel
    /// through `CGImageDestination` with the HEIC UTI.
    @Test("`GiniImageDocument` stores JPEG bytes when initialised from real HEIC data")
    func giniImageDocumentNormalisesRealHEICToJPEG() throws {
        let heicData = try #require(Self.makeRealHEICData(),
                                     "Simulator lacks HEIC encoder — skipping the transcode proof")
        #expect(heicData.isHEIC, "Fixture should encode as HEIC")

        let document = GiniImageDocument(data: heicData,
                                          imageSource: .external,
                                          imageImportMethod: .openWith,
                                          deviceOrientation: nil)

        #expect(document.data.isJPEG,
                "GiniImageDocument.data must be JPEG so the backend accepts it")
        #expect(!document.data.isHEIC,
                "GiniImageDocument.data must not retain the HEIC container")
    }

    /// Real-HEIC round-trip that plants a known TIFF `Software` tag in the
    /// source, transcodes via `GiniImageDocument`, and reads the JPEG's
    /// properties back — proving that embedded metadata survives the
    /// `CGImageDestination`-based transcode instead of being dropped like
    /// `UIImage.jpegData` would drop it.
    @Test("`GiniImageDocument.data` preserves EXIF/TIFF metadata across the HEIC → JPEG transcode")
    func giniImageDocumentPreservesTIFFMetadataAcrossTranscode() throws {
        let expectedSoftwareTag = "gini-capture-heic-metadata-test"
        let heicData = try #require(Self.makeRealHEICData(softwareTag: expectedSoftwareTag),
                                     "Simulator lacks HEIC encoder — skipping the metadata proof")

        let document = GiniImageDocument(data: heicData,
                                          imageSource: .external,
                                          imageImportMethod: .openWith,
                                          deviceOrientation: nil)

        let source = try #require(CGImageSourceCreateWithData(document.data as CFData, nil),
                                    "GiniImageDocument.data must decode as an image")
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            "The transcoded JPEG must expose image properties"
        )
        let tiff = try #require(properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any],
                                  "TIFF dictionary must survive the transcode")
        let software = try #require(tiff[kCGImagePropertyTIFFSoftware] as? String,
                                      "TIFF Software tag must survive the transcode")
        #expect(software == expectedSoftwareTag)
    }

    /// Build a real HEIC-encoded image blob by writing a 1×1 pixel through
    /// `CGImageDestination` with the HEIC UTI. Optionally embeds a TIFF
    /// `Software` tag and/or an EXIF `LensModel` tag so the caller can
    /// verify metadata preservation later. Returns nil on platforms where
    /// the encoder is unavailable — the caller should skip the test.
    private static func makeRealHEICData(softwareTag: String? = nil,
                                          exifLensModel: String? = nil) -> Data? {
        var rgba: [UInt8] = [255, 0, 0, 255]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider(data: Data(bytes: &rgba, count: rgba.count) as CFData),
              let cgImage = CGImage(width: 1,
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
        else {
            return nil
        }

        let target = NSMutableData()
        let heicUTI = "public.heic" as CFString
        guard let destination = CGImageDestinationCreateWithData(target, heicUTI, 1, nil) else {
            return nil
        }

        var properties: [CFString: Any] = [:]
        if let softwareTag {
            properties[kCGImagePropertyTIFFDictionary] = [
                kCGImagePropertyTIFFSoftware: softwareTag
            ] as CFDictionary
        }
        if let exifLensModel {
            properties[kCGImagePropertyExifDictionary] = [
                kCGImagePropertyExifLensModel: exifLensModel
            ] as CFDictionary
        }
        CGImageDestinationAddImage(destination,
                                    cgImage,
                                    properties.isEmpty ? nil : properties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else { return nil }
        return target as Data
    }

    // MARK: - Real-file import (Files-app "Open with" path)

    /// End-to-end proof against a real iPhone-captured HEIC file. This mirrors
    /// the Files-app "Open with" flow the customer reported: the URL-based
    /// `GiniCaptureDocumentBuilder.build(with openURL:completion:)` overload
    /// reads the raw bytes off disk, hands them to the data-based path, and
    /// should produce a `GiniImageDocument` whose stored data is JPEG.
    ///
    /// Fixture: `iphone-heic-photo.heic` (bundled in `Tests/Resources/`),
    /// a native iPhone Camera capture — `ftyp heic` with compatible brands
    /// `mif1`/`MiHB`/`MiHA`/`heix`.
    @Test("`GiniCaptureDocumentBuilder.build(with openURL:)` imports a real iPhone HEIC and produces JPEG bytes")
    func buildFromRealHEICFileURL() async throws {
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "iphone-heic-photo", withExtension: "heic"),
            "iphone-heic-photo.heic fixture must be present in the test bundle Resources"
        )

        // Sanity-check the fixture itself before running the SUT.
        let fileBytes = try Data(contentsOf: fixtureURL)
        #expect(fileBytes.isHEIC, "Fixture must be a HEIF/HEIC container")

        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "com.gini.tests"))
        builder.importMethod = .openWith

        let document = await withCheckedContinuation { continuation in
            builder.build(with: fixtureURL) { document in
                continuation.resume(returning: document)
            }
        }

        let imageDocument = try #require(document as? GiniImageDocument,
                                          "Files-app import must produce a GiniImageDocument")
        #expect(imageDocument.type == .image)
        #expect(imageDocument.data.isJPEG,
                "Backend expects JPEG bytes — HEIC must be transcoded end-to-end")
        #expect(!imageDocument.data.isHEIC,
                "GiniImageDocument.data must not retain the HEIC container")
        #expect(imageDocument.isFromOtherApp,
                "documentSource .appName means the document is imported from another app")
    }

    /// Build a tiny real JPEG-encoded image blob for the idempotency test.
    /// Returns nil on platforms where the encoder is unavailable.
    private static func makeRealJPEGData() -> Data? {
        var rgba: [UInt8] = [0, 255, 0, 255]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider(data: Data(bytes: &rgba, count: rgba.count) as CFData),
              let cgImage = CGImage(width: 1,
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
        else {
            return nil
        }

        let target = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(target, kUTTypeJPEG, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return target as Data
    }
}
