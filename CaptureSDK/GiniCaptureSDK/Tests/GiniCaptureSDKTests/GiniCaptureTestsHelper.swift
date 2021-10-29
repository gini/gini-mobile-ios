//
//  GiniCaptureTestsHelper.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 6/5/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
@testable import GiniCaptureSDK
final class GiniCaptureTestsHelper {
    
    class func fileData(named name: String, fileExtension: String) -> Data? {
        return try? Data(contentsOf: urlFromFile(named: name, fileExtension: fileExtension)!)
    }
    
    class func loadImage(named name: String, fileExtension: String = "jpg") -> UIImage {
        return UIImage(named: name,
                       in: Bundle(for: GiniCaptureTestsHelper.self),
                       compatibleWith: nil) ?? loadImageFromResources(named: name, fileExtension: fileExtension)!
    }
    
    fileprivate class func loadImageFromResources(named name: String, fileExtension: String = "jpg") -> UIImage? {
        guard let path = urlFromFile(named: name, fileExtension: fileExtension)?.path else { return nil}
        
        return UIImage(contentsOfFile: path)
    }
    
    class func loadPDFDocument(named name: String) -> GiniPDFDocument {
        let data = fileData(named: name, fileExtension: "pdf")!
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return (builder.build(with: data) as? GiniPDFDocument)!
    }
    
    class func loadImageDocument(named name: String, fileExtension: String = "jpg") -> GiniImageDocument {
        let data = fileData(named: name, fileExtension: fileExtension)!
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return (builder.build(with: data) as? GiniImageDocument)!
    }
    
    class private func loadPage(named name: String,
                                fileExtension: String) -> GiniCapturePage {
        let data = fileData(named: name, fileExtension: fileExtension)!
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return GiniCapturePage(document: builder.build(with: data)!)
    }
    
    class func loadImagePage(named name: String, fileExtension: String = "jpg") -> GiniCapturePage {
        return self.loadPage(named: name, fileExtension: fileExtension)
    }
    
    class func loadPDFPage(named name: String) -> GiniCapturePage {
        return self.loadPage(named: name, fileExtension: "pdf")
    }
    
    fileprivate class func urlFromFile(named name: String, fileExtension: String) -> URL? {
        return Bundle(for: GiniCaptureTestsHelper.self).url(forResource: name, withExtension: fileExtension)
    }
}
