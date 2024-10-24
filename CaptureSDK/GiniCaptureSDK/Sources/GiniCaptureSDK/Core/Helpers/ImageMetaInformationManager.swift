//
//  ImageMetaInformationManager.swift
//  GiniCapture
//
//  Created by Peter Pult on 27/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation
import MobileCoreServices
import GiniBankAPILibrary

typealias MetaInformation = NSDictionary

/// The JPEG compression level that will be used if nothing else
/// is specified in imageData(withCompression:)
let JPEGDefaultCompression: CGFloat = 0.4

@objc public enum DocumentImportMethod: Int, RawRepresentable {
    case openWith
    case picker

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        if rawValue == "openWith" {
            self = .openWith
        } else {
            self = .picker
        }
    }

    public var rawValue: String {
        switch self {
        case .openWith:
            return "openwith"
        case .picker:
            return "picker"
        }
    }
}

public enum DocumentSource: Equatable {
    case camera
    case external
    case appName(name: String?)

    var value: String {
        switch self {
        case .camera:
            return "camera"
        case .external:
            return "external"
        case .appName(let packageName):
            guard let packageName = packageName else {
                return "external"
            }
            if let appName = packageName.split(separator: ".").last {
                return String(describing: appName)
            }
            return packageName
        }
    }

    public static func == (lhs: DocumentSource, rhs: DocumentSource) -> Bool {
        return lhs.value == rhs.value
    }
}

final class ImageMetaInformationManager {

    fileprivate let cfRequiredExifKeys = [
        kCGImagePropertyExifLensMake,
        kCGImagePropertyExifLensModel,
        kCGImagePropertyExifISOSpeed,
        kCGImagePropertyExifISOSpeedRatings,
        kCGImagePropertyExifExposureTime,
        kCGImagePropertyExifApertureValue,
        kCGImagePropertyExifFlash,
        kCGImagePropertyExifCompressedBitsPerPixel,
        kCGImagePropertyExifUserComment
    ]

    fileprivate let cfRequiredTiffKeys = [
        kCGImagePropertyTIFFOrientation,
        kCGImagePropertyTIFFMake,
        kCGImagePropertyTIFFModel,
        kCGImagePropertyTIFFSoftware
    ]

    // user comment fields
    let userCommentRotation = "RotDeltaDeg"
    let userCommentContentId = "ContentId"
    let userCommentDeviceOrientation = "DeviceOrientation"

    var imageData: Data?
    var metaInformation: MetaInformation?

    // Due to future image rotations on ReviewViewController, it is necessary to preserve the device orientation
    // when the picture is taken.
    fileprivate var deviceOrientationOnCapture: String?
    fileprivate var imageSource: DocumentSource
    fileprivate var imageImportMethod: DocumentImportMethod?

    init(imageData data: Data,
         deviceOrientation: UIInterfaceOrientation? = nil,
         imageSource: DocumentSource,
         imageImportMethod: DocumentImportMethod? = nil) {
        self.imageData = data
        self.imageSource = imageSource
        self.imageImportMethod = imageImportMethod
        metaInformation = metaInformation(fromImageData: data)

        // If the image has the DeviceOrientation, it should not be added again
        // because current device orientation could be different.
        // deviceOrientation must be always nil except when the picture has just been taken.
        deviceOrientationOnCapture = value(forUserCommentField: userCommentDeviceOrientation)

        if let deviceOrientation = deviceOrientation, deviceOrientationOnCapture == nil {
            deviceOrientationOnCapture = deviceOrientation.isLandscape ? "landscape" : "portrait"
        }

        filterMetaInformation()
    }

    // Returns the current image but with all meta information added
    func imageByAddingMetadata(to processedImageData: Data? = nil,
                               withCompression compression: CGFloat = JPEGDefaultCompression) -> Data? {
        guard let image = processedImageData ?? imageData,
            let information = metaInformation, (image.isJPEG || image.isTIFF) else { return nil }

        let targetData = NSMutableData()
        let destination = CGImageDestinationCreateWithData(targetData, kUTTypeJPEG, 1, nil)
        let source = CGImageSourceCreateWithData(image as CFData, nil)
        information.setValue(compression, forKey: kCGImageDestinationLossyCompressionQuality as String)

        if let destination = destination, let source = source {
            CGImageDestinationAddImageFromSource(destination, source, 0, information as CFDictionary)
            CGImageDestinationFinalize(destination)

            return targetData as Data
        }

        return nil
    }

    func rotate(degrees: Int, imageOrientation: UIImage.Orientation) {
        update(imageOrientation: imageOrientation)
        let information = metaInformation as? NSMutableDictionary
        information?.set(metaInformation: userComment(rotationDegrees: degrees) as AnyObject?,
                         forKey: kCGImagePropertyExifUserComment as String)
    }

    func update(imageOrientation orientation: UIImage.Orientation) {
        var information = metaInformation ?? MetaInformation()
        information = update(getExifOrientationFromUIImageOrientation(orientation), onMetaInformation: information)
        metaInformation = information
    }

    fileprivate func filterMetaInformation() {
        var information = metaInformation ?? MetaInformation()
        information = addDefaultValues(toMetaInformation: information)
        guard let filteredInformation = filterDefaultValues(fromMetaInformation: information) else { return }
        metaInformation = filteredInformation
    }

    fileprivate func update(_ orientation: Int, onMetaInformation information: MetaInformation) -> MetaInformation {
        guard let updatedInformation = information.mutableCopy() as? NSMutableDictionary else { return information }
        // Set both keys in case one is changed in the future all orientations will still be set correctly
        updatedInformation.set(metaInformation: orientation as AnyObject?,
                               forKey: kCGImagePropertyTIFFOrientation as String)
        updatedInformation.set(metaInformation: orientation as AnyObject?,
                               forKey: kCGImagePropertyOrientation as String)
        return updatedInformation
    }

    fileprivate func addDefaultValues(toMetaInformation information: MetaInformation) -> MetaInformation {
        var defaultInformation = information
        defaultInformation = add(requiredValuesWithKeys: cfRequiredExifKeys.strings,
                                 toMetaInformation: defaultInformation)
        defaultInformation = add(requiredValuesWithKeys: cfRequiredTiffKeys.strings,
                                 toMetaInformation: defaultInformation)
        return defaultInformation
    }

    fileprivate func add(requiredValuesWithKeys keys: [String],
                         toMetaInformation information: MetaInformation) -> MetaInformation {
        guard let addedInformation = information.mutableCopy() as? NSMutableDictionary else { return information }
        for key in keys {
            if addedInformation.getMetaInformation(forKey: key) != nil {
                continue
            }
            addedInformation.set(metaInformation: value(forMetaKey: key), forKey: key)
        }
        return addedInformation
    }

    fileprivate func filterDefaultValues(fromMetaInformation information: MetaInformation) -> MetaInformation? {
        guard let filteredInformation = information.mutableCopy() as? NSMutableDictionary else { return nil }
        filteredInformation.filterDefaultMetaInformation()
        return filteredInformation as MetaInformation
    }

    fileprivate func metaInformation(fromImageData data: Data) -> MetaInformation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
            let metaInformation = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as MetaInformation?
            else { return nil }
        return metaInformation
    }

    fileprivate func value(forMetaKey key: String) -> AnyObject? {
        if key == kCGImagePropertyTIFFSoftware as String {
            return UIDevice.current.systemVersion as AnyObject?
        }
        if key == kCGImagePropertyTIFFMake as String {
            return "Apple" as AnyObject? // Hardcoded, but a pretty safe guess
        }
        if key == kCGImagePropertyTIFFModel as String {
            return deviceName() as AnyObject?
        }
        if key == kCGImagePropertyExifUserComment as String {
            return userComment() as AnyObject?
        }

        return nil
    }

    fileprivate func userComment(rotationDegrees: Int? = nil) -> String {
        var rotationNorm = ""
        if let rotationDegrees = rotationDegrees {
            rotationNorm = "\(normalizedDegrees(imageRotation: imageRotationDeltaDegrees() + rotationDegrees))"
        }
        return Document.UploadMetadata.constructComment(
            osVersion: UIDevice.current.systemVersion,
            giniVersion: GiniCapture.versionString,
            contentId: imageUUID(),
            source: imageSource.value,
            entryPoint: GiniConfiguration.shared.entryPoint.stringValue,
            importMethod: imageSource.value != DocumentSource.camera.value
            ? imageImportMethod?.rawValue ?? ""
            : "",
            deviceOrientation: deviceOrientationOnCapture ?? "",
            rotation: rotationNorm
        )
    }

    fileprivate func imageUUID() -> String {
        // if it already has one, reuse it - it shouldn't change
        // if not, generate it
        let existingUUID = uuidFromImage()
        return existingUUID ?? NSUUID().uuidString
    }

    func imageRotationDeltaDegrees() -> Int {
        return rotationDeltaFromImage() ?? 0
    }

    fileprivate func uuidFromImage() -> String? {
        return self.value(forUserCommentField: userCommentContentId)
    }

    fileprivate func rotationDeltaFromImage() -> Int? {
        return Int(self.value(forUserCommentField: userCommentRotation) ?? "0")
    }

    fileprivate func value(forUserCommentField field: String) -> String? {
        let exifDict = metaInformation as? NSMutableDictionary
        let existingUserComment = exifDict?.getMetaInformation(forKey: kCGImagePropertyExifUserComment as String)
        let components = existingUserComment?.components(separatedBy: ",")
        let userCommentComponent = components?.filter({ (component) -> Bool in
            return component.contains(field)
        })
        let equasionComponents = userCommentComponent?.last?.components(separatedBy: "=")
        return equasionComponents?.last
    }

    fileprivate func deviceName() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let code = withUnsafeMutablePointer(to: &systemInfo.machine) { ptr in String(cString: UnsafeRawPointer(ptr)
            .assumingMemoryBound(to: CChar.self))
        }
        return code
    }

    fileprivate func getExifOrientationFromUIImageOrientation(_ orientation: UIImage.Orientation) -> Int {
        let number: Int
        switch orientation {
        case .up:
            number = 1
        case .upMirrored:
            number = 2
        case .down:
            number = 3
        case .downMirrored:
            number = 4
        case .left:
            number = 8
        case .leftMirrored:
            number = 7
        case .right:
            number = 6
        case .rightMirrored:
            number = 5
        @unknown default:
            preconditionFailure("All orientations must be handled")
        }
        return number
    }

    fileprivate func normalizedDegrees(imageRotation: Int) -> Int {
        var normalized = imageRotation % 360
        if imageRotation < 0 {
            normalized += 360
        }
        return normalized
    }

}

extension NSMutableDictionary {

    fileprivate var cfExifKeys: [CFString] {
        return [
            kCGImagePropertyExifLensMake,
            kCGImagePropertyExifLensModel,
            kCGImagePropertyExifISOSpeed,
            kCGImagePropertyExifISOSpeedRatings,
            kCGImagePropertyExifExposureTime,
            kCGImagePropertyExifApertureValue,
            kCGImagePropertyExifFlash,
            kCGImagePropertyExifCompressedBitsPerPixel,
            kCGImagePropertyExifUserComment
        ]
    }

    fileprivate var cfTiffKeys: [CFString] {
        return [
            kCGImagePropertyTIFFMake,
            kCGImagePropertyTIFFModel,
            kCGImagePropertyTIFFSoftware,
            kCGImagePropertyTIFFOrientation
        ]
    }

    fileprivate var cfTopLevelKeys: [CFString] {
        return [
            kCGImagePropertyExifDictionary,
            kCGImagePropertyTIFFDictionary
        ]
    }

    fileprivate var stringKeys: [String] {
        return allKeys
            .map { $0 as? String }
            .compactMap { $0 }
    }

    func set(metaInformation value: AnyObject?, forKey key: String, inSubdictionary isSubdictionary: Bool = false) {
        // Helper method to set a value in a meta dictionary like TIFF or Exif
        func set(_ value: AnyObject?, forKey key: String, inMetaDictionaryWithKey metaDictionaryKey: String) {
            let metaDictionary = (self[metaDictionaryKey] as? NSMutableDictionary) ?? NSMutableDictionary()
            metaDictionary[key] = value
            self[metaDictionaryKey] = metaDictionary
        }

        // Try to set the key in the current context
        let keys = stringKeys
        if keys.contains(key) {
            setValue(value, forKey: key)
        }

        // Try to set in known context
        if !isSubdictionary {
            if cfExifKeys.strings.contains(key) {
                set(value, forKey: key, inMetaDictionaryWithKey: kCGImagePropertyExifDictionary as String)
            }
            if cfTiffKeys.strings.contains(key) {
                set(value, forKey: key, inMetaDictionaryWithKey: kCGImagePropertyTIFFDictionary as String)
            }
        }

        // Try to set in subdictioanies
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .compactMap { $0 }

        for dictionary in dictionaries {
            dictionary.set(metaInformation: value, forKey: key, inSubdictionary: true)
        }
    }

    func getMetaInformation(forKey key: String) -> AnyObject? {
        let keys = stringKeys
        guard keys.count > 0 else { return nil }
        if keys.contains(key) {
            return self[key] as AnyObject?
        }
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .compactMap { $0 }

        for dictionary in dictionaries {
            if let value = dictionary.getMetaInformation(forKey: key) {
                return value
            }
        }

        return nil
    }

    func filterDefaultMetaInformation() {
        let keys = [ cfExifKeys, cfTiffKeys, cfTopLevelKeys ].flatMap { $0 }.strings
        filterMetaInformation(keys)
    }

    /**
     Set all values to `CFNull` if the corresponding key is not in the filtered keys array.

     - parameter filterKeys: The keys to filter for.
     */
    func filterMetaInformation(_ filterKeys: [String]) {
        let keys = stringKeys
        for key in keys {
            if !filterKeys.contains(key) {
                self[key] = kCFNull
            } else if let dictionary = self[key] as? NSMutableDictionary {
                dictionary.filterDefaultMetaInformation()
            }
        }
    }
}
