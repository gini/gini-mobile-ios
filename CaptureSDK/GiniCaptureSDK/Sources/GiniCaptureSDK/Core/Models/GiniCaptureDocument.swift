//
//  GiniCaptureDocument.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import UIKit

/**
 * Document processed by the _GiniCapture_ library.
 */

@objc public protocol GiniCaptureDocument: AnyObject {
    var type: GiniCaptureDocumentType { get }
    var uploadMetadata: Document.UploadMetadata? { get }
    var data: Data { get }
    var id: String { get }
    var previewImage: UIImage? { get }
    var isReviewable: Bool { get }
    var isImported: Bool { get }
}

// MARK: GiniCaptureDocumentType

@objc public enum GiniCaptureDocumentType: Int {
    case pdf = 0
    case image = 1
    case qrcode = 2
}

// MARK: GiniCaptureDocumentBuilder

/**
 The `GiniCaptureDocumentBuilder` provides a way to build a `GiniCaptureDocument` from a `Data` object and
 a `DocumentSource`. Additionally the `DocumentImportMethod` can bet set after builder iniatilization.
 This is an example of how a `GiniCaptureDocument` should be built when it has been imported
 with the _Open with_ feature.
 
 ```swift
 let documentBuilder = GiniCaptureDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
 documentBuilder.importMethod = .openWith
 let document = documentBuilder.build()
 do {
 try document?.validate()
 ...
 } catch {
 ...
 }
 ```
 */
public class GiniCaptureDocumentBuilder: NSObject {

    var documentSource: DocumentSource
    public var deviceOrientation: UIInterfaceOrientation?
    public var importMethod: DocumentImportMethod = .picker

    /**
     Initializes a `GiniCaptureDocumentBuilder` with the document source.
     This method is only accesible in Swift projects.
     
     - Parameter documentSource: document source (external, camera or appName)
     
     */
    public init(documentSource: DocumentSource) {
        self.documentSource = documentSource
    }

    /**
     Builds a `GiniCaptureDocument`
     
     - Returns: A `GiniCaptureDocument` if `data` has a valid type or `nil` if it hasn't.
     
     */
    public func build(with data: Data, fileName: String?) -> GiniCaptureDocument? {
        if data.isPDF {
            return GiniPDFDocument(data: data, fileName: fileName, uploadMetadata: generateUploadMetadata())
        } else if data.isImage {
            return GiniImageDocument(data: data,
                                     imageSource: documentSource,
                                     imageImportMethod: importMethod,
                                     deviceOrientation: deviceOrientation,
                                     uploadMetadata: generateUploadMetadata())
        }
        return nil
    }

    /**
     Builds a `GiniCaptureDocument` from an incoming file url. The completion handler
     delivers the document or `nil` if it couldn't be read.
     
     */
    public func build(with openURL: URL, completion: @escaping (GiniCaptureDocument?) -> Void) {
        let inputDocument = InputDocument(fileURL: openURL)

        inputDocument.open { (success) in

            guard let data = inputDocument.data, success else {
                completion(nil)
                return
            }

            completion(self.build(with: data, fileName: openURL.lastPathComponent))
        }
    }

    public func generateUploadMetadata() -> Document.UploadMetadata {
        var deviceOrientation = ""
        if let isLandscape = self.deviceOrientation?.isLandscape {
            deviceOrientation = isLandscape ? "landscape" : "portrait"
        }
        return Document.UploadMetadata(
            giniCaptureVersion: GiniCaptureSDKVersion,
            deviceOrientation: deviceOrientation,
            source: documentSource.value,
            importMethod: importMethod.rawValue,
            entryPoint: entryFieldString(GiniConfiguration.shared.entryPoint),
            osVersion: UIDevice.current.systemVersion
        )
    }

    fileprivate func entryFieldString(_ entryPoint: GiniConfiguration.GiniEntryPoint) -> String {
        switch entryPoint {
        case .button:
            return "button"
        case .field:
            return "field"
        }
    }
}

private extension GiniCaptureDocumentBuilder {
    enum DocumentError: Error {
        case unrecognizedContent
    }

    final class InputDocument: UIDocument {
        public var data: Data?

        override func load(fromContents contents: Any, ofType typeName: String?) throws {

            guard let data = contents as? Data else {
                throw DocumentError.unrecognizedContent
            }

            self.data = data
        }

        override func writeContents(_ contents: Any,
                                    to url: URL,
                                    for saveOperation: UIDocument.SaveOperation,
                                    originalContentsURL: URL?) throws {
            if (contents as? Data) == nil, (contents as? FileWrapper) == nil {
                throw DocumentError.unrecognizedContent
            }
            try super.writeContents(contents, to: url, for: saveOperation, originalContentsURL: originalContentsURL)
        }
    }
}
