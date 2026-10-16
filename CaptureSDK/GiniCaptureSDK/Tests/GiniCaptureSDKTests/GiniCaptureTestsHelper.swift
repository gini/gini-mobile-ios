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
    
    class func giniTestBundle() -> Bundle {
        return Bundle.module
    }
    
    class func fileData(named name: String, fileExtension: String) -> Data? {
        let fileURLPath: String? = Bundle.module
                .path(forResource: name, ofType: fileExtension)
        return try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    }
    
    class func loadImage(named name: String, fileExtension: String = "jpg") -> UIImage {
        return UIImage(named: name,
                       in: giniTestBundle(),
                       compatibleWith: nil) ?? loadImageFromResources(named: name, fileExtension: fileExtension)!
    }
    
    fileprivate class func loadImageFromResources(named name: String, fileExtension: String = "jpg") -> UIImage? {
        guard let fileURLPath = giniTestBundle()
            .path(forResource: name, ofType: fileExtension) else { return nil }
        return UIImage(contentsOfFile: fileURLPath)
    }
    
    class func loadPDFDocument(named name: String) -> GiniPDFDocument {
        let data = fileData(named: name, fileExtension: "pdf")!
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return (builder.build(with: data, fileName: "\(name).pdf") as? GiniPDFDocument)!
    }
    
    class func loadImageDocument(named name: String, fileExtension: String = "jpg") -> GiniImageDocument {
        let data = fileData(named: name, fileExtension: fileExtension)!
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return (builder.build(with: data, fileName: "\(name).pdf") as? GiniImageDocument)!
    }
    
    class private func loadPage(named name: String,
                                fileExtension: String) -> GiniCapturePage {

        let data = fileData(named: name, fileExtension: fileExtension)!
        let builder = GiniCaptureDocumentBuilder(documentSource: .external)
        return GiniCapturePage(document: builder.build(with: data, fileName: "\(name).pdf")!)
    }
    
    class func loadImagePage(named name: String, fileExtension: String = "jpg") -> GiniCapturePage {
        return self.loadPage(named: name, fileExtension: fileExtension)
    }
    
    class func loadPDFPage(named name: String) -> GiniCapturePage {
        return self.loadPage(named: name, fileExtension: "pdf")
    }
    
    fileprivate class func urlFromFile(named name: String, fileExtension: String) -> URL? {
        let fileURLPath: String? = giniTestBundle()
                .path(forResource: name, ofType: fileExtension)
        return URL(fileURLWithPath: fileURLPath!)
    }

    class func loadTextFromFile(named name: String, fileExtension: String = "txt") -> String {
        let path = giniTestBundle().path(forResource: name, ofType: fileExtension) // file path for file "data.txt"
        let string = (try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)) ?? ""
        return string
    }

    // MARK: - Shared storage-flag mutex

    /**
     Process-wide mutex serialising access to the global
     `GiniCaptureUserDefaultsStorage` flag keys the tests mutate. Swift Testing
     runs suites in parallel by default and XCTest classes run alongside, so a
     reader can otherwise observe a stale value from a concurrent writer and
     fail intermittently.
     */
    private static let userDefaultsFlagLock = NSLock()

    /**
     Takes the shared lock, seeds `weroQRCodeScanningEnabled` to `flag`, runs
     `body`, restores the previous value, releases the lock. Previous-value
     restoration and lock release both run on `defer` so they survive `body`
     throwing. Rethrows let the test body use `try` on helpers that surface
     diagnostics via `#require`.

     - Parameters:
       - flag: The value to seed; `nil` emulates "backend never responded".
       - body: The test body executed with the flag seeded under the lock.
     */
    class func withWeroFlag(_ flag: Bool?, _ body: () throws -> Void) rethrows {
        userDefaultsFlagLock.lock()
        defer { userDefaultsFlagLock.unlock() }
        let previous = GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled
        GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = flag
        defer { GiniCaptureUserDefaultsStorage.weroQRCodeScanningEnabled = previous }
        try body()
    }

    /**
     Grants exclusive access to the shared storage-flag mutex for the
     lifetime of an XCTest `setUp`/`tearDown` pair. Call `acquireFlagLock()`
     in `setUp` after reading the current value and `releaseFlagLock()` in
     `tearDown` after restoring it.
     */
    class func acquireFlagLock() {
        userDefaultsFlagLock.lock()
    }

    class func releaseFlagLock() {
        userDefaultsFlagLock.unlock()
    }
}
