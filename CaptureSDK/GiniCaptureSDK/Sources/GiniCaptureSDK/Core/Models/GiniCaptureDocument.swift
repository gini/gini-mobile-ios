//
//  GiniCaptureDocument.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 * Document processed by the _GiniCapture_ library.
 */

@objc public protocol GiniCaptureDocument: AnyObject {
    var type: GiniCaptureDocumentType { get }
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
    public func build(with data: Data) -> GiniCaptureDocument? {
        if data.isPDF {
            return GiniPDFDocument(data: data)
        } else if data.isImage {
            return GiniImageDocument(data: data,
                                     imageSource: documentSource,
                                     imageImportMethod: importMethod,
                                     deviceOrientation: deviceOrientation)
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
            
            completion(self.build(with: data))
        }
    }
}

private extension GiniCaptureDocumentBuilder {
    
    final class InputDocument: UIDocument {
        
        public var data: Data?
        
        enum DocumentError: Error {
            case unrecognizedContent
        }
        
        override public func load(fromContents contents: Any, ofType typeName: String?) throws {
            
            guard let data = contents as? Data else {
                throw DocumentError.unrecognizedContent
            }
            
            self.data = data
        }
    }
}
