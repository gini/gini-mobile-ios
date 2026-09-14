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
 */
@Suite("Data extension — HEIC detection")
struct DataHEICTests {

    /** 4-byte box size · "ftyp" · 4-byte brand · 4-byte padding. */
    private static func heicSignatureBytes(brand: [UInt8]) -> [UInt8] {
        [0x00, 0x00, 0x00, 0x20,
         0x66, 0x74, 0x79, 0x70]
        + brand
        + [0x00, 0x00, 0x00, 0x00]
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

    @Test("`jpegDataPreservingMetadata` preserves a planted EXIF field across the transcode")
    func jpegDataPreservingMetadataKeepsEXIF() throws {
        let expectedLens = "gini-capture-heic-exif-lens-test"
        let heicData = try #require(Self.makeRealHEICData(exifLensModel: expectedLens))
        let jpegData = try #require(heicData.jpegDataPreservingMetadata())

        let source = try #require(CGImageSourceCreateWithData(jpegData as CFData, nil))
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        let exif = try #require(properties[kCGImagePropertyExifDictionary] as? [CFString: Any])
        let lensModel = try #require(exif[kCGImagePropertyExifLensModel] as? String)
        #expect(lensModel == expectedLens)
    }

    @Test("`jpegDataPreservingMetadata` is idempotent on JPEG input (helper is not HEIC-only)")
    func jpegDataPreservingMetadataAcceptsJPEG() throws {
        let jpegBytes = try #require(Self.makeRealJPEGData())
        try #require(jpegBytes.isJPEG)

        let roundTripped = try #require(jpegBytes.jpegDataPreservingMetadata())
        #expect(roundTripped.isJPEG)
    }

    // MARK: - Backend expects JPEG, not HEIC

    /**
     Real HEIC through `GiniImageDocument` — stored `data` must be JPEG.
     Synthetic 16-byte headers aren't decodable, so build via `CGImageDestination`.
     */
    @Test("`GiniImageDocument` stores JPEG bytes when initialised from real HEIC data")
    func giniImageDocumentNormalisesRealHEICToJPEG() throws {
        let heicData = try #require(Self.makeRealHEICData())
        try #require(heicData.isHEIC)

        let document = GiniImageDocument(data: heicData,
                                         imageSource: .external,
                                         imageImportMethod: .openWith,
                                         deviceOrientation: nil)

        #expect(document.data.isJPEG)
        #expect(!document.data.isHEIC)
    }

    /**
     Plants a TIFF `Software` tag in the source and reads it off the
     transcoded JPEG — proves `CGImageDestination` preserves metadata.
     */
    @Test("`GiniImageDocument.data` preserves EXIF/TIFF metadata across the HEIC → JPEG transcode")
    func giniImageDocumentPreservesTIFFMetadataAcrossTranscode() throws {
        let expectedSoftwareTag = "gini-capture-heic-metadata-test"
        let heicData = try #require(Self.makeRealHEICData(softwareTag: expectedSoftwareTag))

        let document = GiniImageDocument(data: heicData,
                                         imageSource: .external,
                                         imageImportMethod: .openWith,
                                         deviceOrientation: nil)

        let source = try #require(CGImageSourceCreateWithData(document.data as CFData, nil))
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        let tiff = try #require(properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any])
        let software = try #require(tiff[kCGImagePropertyTIFFSoftware] as? String)
        #expect(software == expectedSoftwareTag)
    }

    /**
     Encodes a 1×1 pixel as HEIC via `CGImageDestination`, optionally embedding
     a TIFF `Software` and/or EXIF `LensModel` tag. Returns nil when unavailable.
     */
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

    /**
     End-to-end against a real iPhone HEIC via the URL-based builder overload
     — mirrors the customer's Files-app "Open with" flow.
     Fixture: `iphone-heic-photo.heic` in `Tests/Resources/`.
     */
    @Test("`GiniCaptureDocumentBuilder.build(with openURL:)` imports a real iPhone HEIC and produces JPEG bytes")
    func buildFromRealHEICFileURL() async throws {
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "iphone-heic-photo", withExtension: "heic")
        )

        let fileBytes = try Data(contentsOf: fixtureURL)
        try #require(fileBytes.isHEIC)

        let builder = GiniCaptureDocumentBuilder(documentSource: .appName(name: "com.gini.tests"))
        builder.importMethod = .openWith

        let document = await withCheckedContinuation { continuation in
            builder.build(with: fixtureURL) { document in
                continuation.resume(returning: document)
            }
        }

        let imageDocument = try #require(document as? GiniImageDocument)
        #expect(imageDocument.type == .image)
        #expect(imageDocument.data.isJPEG)
        #expect(!imageDocument.data.isHEIC)
        #expect(imageDocument.isFromOtherApp)
    }

    /** Encodes a 1×1 pixel as JPEG via `CGImageDestination`. Nil when unavailable. */
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
