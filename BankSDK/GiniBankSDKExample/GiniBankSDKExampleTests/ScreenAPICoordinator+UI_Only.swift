//
//  ScreenAPICoordinator+UI_Only.swift
//  GiniBankSDKExampleTests
//
//  Created by Nadya Karaban on 28.03.22.
//

import XCTest
@testable import GiniBankSDKExample
@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK

class ScreenAPICoordinator___UI_Only: XCTestCase {
        
    let client = Client(id: "",
                            secret: "",
                            domain: "")
    var screenAPICoordinator = ScreenAPIUIOnlyCoordinator()
    
    lazy var configuration: GiniBankConfiguration = {
        let configuration = GiniBankConfiguration()
        configuration.fileImportSupportedTypes = .pdf_and_images
        configuration.openWithEnabled = true
        configuration.qrCodeScanningEnabled = true
        configuration.multipageEnabled = true
        configuration.flashToggleEnabled = true
        configuration.navigationBarItemTintColor = .white
       return configuration
    }()

    func testInitialization() {
        _ = GiniBank.viewController(withDelegate: screenAPICoordinator, withConfiguration: configuration)
        let bankConfiguration = GiniBankConfiguration.shared
        let captureConfiguration = GiniBankConfiguration.shared.captureConfiguration()
        
        XCTAssertEqual(bankConfiguration.fileImportSupportedTypes, captureConfiguration.fileImportSupportedTypes)
        XCTAssertEqual(bankConfiguration.qrCodeScanningEnabled, captureConfiguration.qrCodeScanningEnabled)
        XCTAssertEqual(bankConfiguration.multipageEnabled, captureConfiguration.multipageEnabled)
        XCTAssertEqual(bankConfiguration.openWithEnabled, captureConfiguration.openWithEnabled)
        XCTAssertEqual(bankConfiguration.flashToggleEnabled, captureConfiguration.flashToggleEnabled)
        XCTAssertEqual(bankConfiguration.navigationBarItemTintColor, captureConfiguration.navigationBarItemTintColor)
    }
    
    class ScreenAPIUIOnlyCoordinator: GiniCaptureDelegate {
        func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
        }
        
        func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
        }
        
        func didCancelCapturing() {
        }
        
        func didCancelReview(for document: GiniCaptureDocument) {
        }
        
        func didCancelAnalysis() {
        }
    }
}
