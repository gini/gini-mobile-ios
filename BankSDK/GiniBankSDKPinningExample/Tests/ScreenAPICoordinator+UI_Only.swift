//
//  ScreenAPICoordinator+UI_Only.swift
//  GiniBankSDKExampleTests
//
//  Created by Nadya Karaban on 28.03.22.
//

import XCTest
@testable import GiniBankSDKPinningExample
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
    }
    
    func testInitializationWithTrackingDelegate() {
        _ = GiniBank.viewController(withDelegate: screenAPICoordinator, withConfiguration: configuration, importedDocument: nil, trackingDelegate: screenAPICoordinator)
        let bankConfiguration = GiniBankConfiguration.shared
        let captureConfiguration = GiniBankConfiguration.shared.captureConfiguration()
        
        XCTAssertEqual(bankConfiguration.fileImportSupportedTypes, captureConfiguration.fileImportSupportedTypes)
        XCTAssertEqual(bankConfiguration.qrCodeScanningEnabled, captureConfiguration.qrCodeScanningEnabled)
        XCTAssertEqual(bankConfiguration.multipageEnabled, captureConfiguration.multipageEnabled)
        XCTAssertEqual(bankConfiguration.openWithEnabled, captureConfiguration.openWithEnabled)
        XCTAssertEqual(bankConfiguration.flashToggleEnabled, captureConfiguration.flashToggleEnabled)
    }
    
    func testSetConfiguration() {
        GiniBank.setConfiguration(configuration)
        let bankConfiguration = GiniBankConfiguration.shared
        let captureConfiguration = GiniBankConfiguration.shared.captureConfiguration()
        
        XCTAssertEqual(bankConfiguration.fileImportSupportedTypes, captureConfiguration.fileImportSupportedTypes)
        XCTAssertEqual(bankConfiguration.qrCodeScanningEnabled, captureConfiguration.qrCodeScanningEnabled)
        XCTAssertEqual(bankConfiguration.multipageEnabled, captureConfiguration.multipageEnabled)
        XCTAssertEqual(bankConfiguration.openWithEnabled, captureConfiguration.openWithEnabled)
        XCTAssertEqual(bankConfiguration.flashToggleEnabled, captureConfiguration.flashToggleEnabled)
    }
    
    class ScreenAPIUIOnlyCoordinator: GiniCaptureDelegate, GiniCaptureTrackingDelegate {
        
        func didPressEnterManually() {
            // This method will remain empty; no implementation is needed.
        }
        
        func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>) {
            // This method will remain empty; no implementation is needed.
        }
        
        func onCameraScreenEvent(event: Event<CameraScreenEventType>) {
            // This method will remain empty; no implementation is needed.
        }
        
        func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>) {
            // This method will remain empty; no implementation is needed.
        }
        
        func onReviewScreenEvent(event: Event<ReviewScreenEventType>) {
            // This method will remain empty; no implementation is needed.
        }
        
        func didCapture(document: GiniCaptureDocument, networkDelegate: GiniCaptureNetworkDelegate) {
            // This method will remain empty; no implementation is needed.
        }
        
        func didReview(documents: [GiniCaptureDocument], networkDelegate: GiniCaptureNetworkDelegate) {
            // This method will remain empty; no implementation is needed.
        }
        
        func didCancelCapturing() {
            // This method will remain empty; no implementation is needed.
        }
        
        func didCancelReview(for document: GiniCaptureDocument) {
            // This method will remain empty; no implementation is needed.
        }
        
        func didCancelAnalysis() {
            // This method will remain empty; no implementation is needed.
        }
    }
}
