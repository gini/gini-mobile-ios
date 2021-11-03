//
//  CameraButtonsViewControllerTests.swift
//  GiniCapture-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 2/19/19.
//

import XCTest
@testable import GiniCaptureSDK

//swiftlint:disable type_body_length
final class CameraButtonsViewControllerTests: XCTestCase {
    
    var cameraButtonsViewController: CameraButtonsViewController!
    var giniConfiguration: GiniConfiguration!
    var screenAPICoordinator: GiniScreenAPICoordinator!
    let visionDelegateMock = GiniCaptureDelegateMock()
    let delegateMock = CameraButtonViewControllerDelegateMock()
    lazy var imageData: Data = {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let imageData = image.jpegData(compressionQuality: 0.9)!
        return imageData
    }()
    
    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration.shared
        giniConfiguration.multipageEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration)
        cameraButtonsViewController.delegate = delegateMock
    }
    
//TODO: Fix the test capture button is not initialized yet

//    func testCaptureButtonDelegateAction() {
//        cameraButtonsViewController.captureButton.simulateEvent(.touchUpInside)
//        
//        XCTAssertEqual(delegateMock.selectedButton, .capture, "capture button should trigger the delegate method")
//    }
    
    func testImagesStackButtonDelegateAction() {
        cameraButtonsViewController.capturedImagesStackView.didTapImageStackButton?()
        
        XCTAssertEqual(delegateMock.selectedButton, .imagesStack,
                       "images stack button should trigger the delegate method")
    }
    
    func testImportButtonDelegateAction() {
        cameraButtonsViewController.fileImportButtonView.didTapButton?()
        
        XCTAssertEqual(delegateMock.selectedButton, .fileImport,
                       "file import button should trigger the delegate method")
    }
    
//TODO: Fix the test flash button is not initialized yet (lazy and nil)

//    func testFlashToggleButtonDelegateAction() {
//        cameraButtonsViewController.flashToggleButton.sendActions(for: .touchUpInside)
//        
//        XCTAssertEqual(delegateMock.selectedButton, .flashToggle(false),
//                       "flash toggle button should trigger the delegate method and pass false")
//    }
    
//    func testFlashToggleButtonReactivateDelegateAction() {
//        cameraButtonsViewController.flashToggleButton.simulateEvent(.touchUpInside)
//        cameraButtonsViewController.flashToggleButton.simulateEvent(.touchUpInside)
//
//        XCTAssertEqual(delegateMock.selectedButton, .flashToggle(true),
//                       "flash toggle button should trigger the delegate method and pass true when tapped twice")
//    }
    
    func testLayoutWhenNoButtonsOnIpad() {
        let giniConfiguration = GiniConfiguration()
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IpadDevice())
        _ = cameraButtonsViewController.view
        
        XCTAssertTrue(cameraButtonsViewController.rightStackView.arrangedSubviews.isEmpty,
                      "right stack view should not contain views")
        XCTAssertTrue(cameraButtonsViewController.rightStackView.arrangedSubviews.isEmpty,
                      "left stack view should not contain views")
    }
    
    func testLayoutWhenOnlyFileImportEnabledOnIpad() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IpadDevice())
        _ = cameraButtonsViewController.view
        cameraButtonsViewController.addFileImportButton()
        
        let innerRightVerticalStackview = cameraButtonsViewController.rightStackView
            .arrangedSubviews.first as? UIStackView
        let innerLeftVerticalStackview = cameraButtonsViewController.leftStackView
            .arrangedSubviews.first as? UIStackView
        
        XCTAssertNil(innerRightVerticalStackview, "right stack view should not contain an inner stack view")
        XCTAssertNotNil(innerLeftVerticalStackview, "left stack view should contain an inner stack view")
        XCTAssertTrue(innerLeftVerticalStackview?.arrangedSubviews
            .contains(cameraButtonsViewController.fileImportButtonView) ?? false,
                      "the inner stck view should contain the file import view")
    }
    
    func testLayoutWhenFileImportAndFlashAreEnabledOnIpad() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.flashToggleEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IpadDevice())
        _ = cameraButtonsViewController.view
        cameraButtonsViewController.addFileImportButton()
        
        let innerRightVerticalStackview = cameraButtonsViewController.rightStackView
            .arrangedSubviews.first as? UIStackView
        let innerLeftVerticalStackview = cameraButtonsViewController.leftStackView
            .arrangedSubviews.first as? UIStackView
        
        XCTAssertNotNil(innerRightVerticalStackview, "right stack view should not contain an inner stack view")
        XCTAssertNotNil(innerLeftVerticalStackview, "left stack view should contain an inner stack view")
        XCTAssertEqual(innerRightVerticalStackview?.arrangedSubviews.count, 1,
                       "the inner stack view should contain only the flash toggle button")
        XCTAssertEqual(innerRightVerticalStackview?.arrangedSubviews[0],
                      cameraButtonsViewController.flashToggleButtonContainerView,
                      "the inner stack view should contain the flash toggle button")
        XCTAssertEqual(innerLeftVerticalStackview?.arrangedSubviews[0],
                       cameraButtonsViewController.fileImportButtonView,
                       "the inner stack view should contain the file import view")
    }
    
    func testLayoutWhenFileImportMultipageAndFlashAreEnabledOnIpad() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.multipageEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IpadDevice())
        _ = cameraButtonsViewController.view
        cameraButtonsViewController.addFileImportButton()
        
        let innerRightVerticalStackview = cameraButtonsViewController.rightStackView
            .arrangedSubviews.first as? UIStackView
        let innerLeftVerticalStackview = cameraButtonsViewController.leftStackView
            .arrangedSubviews.first as? UIStackView
        
        XCTAssertNotNil(innerRightVerticalStackview, "right stack view should not contain an inner stack view")
        XCTAssertNotNil(innerLeftVerticalStackview, "left stack view should contain an inner stack view")
        XCTAssertEqual(innerRightVerticalStackview?.arrangedSubviews[0],
                       cameraButtonsViewController.capturedImagesStackView,
                       "the inner stack view should contain the captured images stack button")
        XCTAssertEqual(innerRightVerticalStackview?.arrangedSubviews[1],
                       cameraButtonsViewController.flashToggleButtonContainerView,
                       "the inner stack view should contain the flash toggle button")
        XCTAssertEqual(innerLeftVerticalStackview?.arrangedSubviews[0],
                       cameraButtonsViewController.fileImportButtonView,
                       "the inner stack view should contain the file import view")
    }
    
    func testLayoutWhenMultipageAndFlashAreEnabledOnIpad() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.multipageEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IpadDevice())
        _ = cameraButtonsViewController.view
        
        let innerRightVerticalStackview = cameraButtonsViewController.rightStackView
            .arrangedSubviews.first as? UIStackView
        let innerLeftVerticalStackview = cameraButtonsViewController.leftStackView
            .arrangedSubviews.first as? UIStackView
        
        XCTAssertNotNil(innerRightVerticalStackview, "right stack view should not contain an inner stack view")
        XCTAssertNil(innerLeftVerticalStackview, "left stack view should not contain an inner stack view")
        XCTAssertEqual(innerRightVerticalStackview?.arrangedSubviews[0],
                       cameraButtonsViewController.capturedImagesStackView,
                       "the inner stack view should contain the captured images stack button")
        XCTAssertEqual(innerRightVerticalStackview?.arrangedSubviews[1],
                       cameraButtonsViewController.flashToggleButtonContainerView,
                       "the inner stack view should contain the flash toggle button")
    }
    
    func testLayoutWhenNoButtonsOnIphone() {
        let giniConfiguration = GiniConfiguration()
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        _ = cameraButtonsViewController.view
        
        XCTAssertTrue(cameraButtonsViewController.rightStackView.arrangedSubviews.isEmpty,
                      "right stack view should not contain views")
        XCTAssertTrue(cameraButtonsViewController.rightStackView.arrangedSubviews.isEmpty,
                      "left stack view should not contain views")
    }
    
    func testLayoutWhenOnlyFileImportEnabledOnIphone() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        _ = cameraButtonsViewController.view
        cameraButtonsViewController.addFileImportButton()
        
        XCTAssertTrue(cameraButtonsViewController.rightStackView.arrangedSubviews.isEmpty,
                      "right stack view should not contain views")
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews.count, 1,
            "the inner stack view should contain only the file import button")
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews[0],
                       cameraButtonsViewController.fileImportButtonView,
                       "the inner stack view should contain the file import button")
    }
    
    func testLayoutWhenFileImportAndFlashAreEnabledOnIphone() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.flashToggleEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        _ = cameraButtonsViewController.view
        cameraButtonsViewController.addFileImportButton()
        
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews.count, 1,
                       "the inner stack view should contain only the file import button")
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews[0],
                       cameraButtonsViewController.fileImportButtonView,
                       "the inner stack view should contain the file import button")
        XCTAssertEqual(cameraButtonsViewController.rightStackView.arrangedSubviews.count, 1,
                       "the inner stack view should contain only the flash button")
        XCTAssertEqual(cameraButtonsViewController.rightStackView.arrangedSubviews[0],
                       cameraButtonsViewController.flashToggleButtonContainerView,
                       "the inner stack view should contain the flash button")
    }
    
    func testLayoutWhenFileImportMultipageAndFlashAreEnabledOnIphone() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.multipageEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        _ = cameraButtonsViewController.view
        cameraButtonsViewController.addFileImportButton()
        
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews.count, 2,
                       "the inner stack view should contain only the file import button")
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews[0],
                       cameraButtonsViewController.fileImportButtonView,
                       "the inner stack view should contain the file import button")
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews[1],
                       cameraButtonsViewController.flashToggleButtonContainerView,
                       "the inner stack view should contain the flash button")
        XCTAssertEqual(cameraButtonsViewController.rightStackView.arrangedSubviews.count, 1,
                       "the inner stack view should contain only the captured images stack button")
        XCTAssertEqual(cameraButtonsViewController.rightStackView.arrangedSubviews[0],
                       cameraButtonsViewController.capturedImagesStackView,
                       "the inner stack view should contain the captured images stack button")
    }
    
    func testLayoutWhenMultipageAndFlashAreEnabledOnIphone() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.multipageEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        _ = cameraButtonsViewController.view
        
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews.count, 1,
                       "the inner stack view should contain only the file import button")
        XCTAssertEqual(cameraButtonsViewController.leftStackView.arrangedSubviews[0],
                       cameraButtonsViewController.flashToggleButtonContainerView,
                       "the inner stack view should contain the flash button")
        XCTAssertEqual(cameraButtonsViewController.rightStackView.arrangedSubviews.count, 1,
                       "the inner stack view should contain only the captured images stack button")
        XCTAssertEqual(cameraButtonsViewController.rightStackView.arrangedSubviews[0],
                       cameraButtonsViewController.capturedImagesStackView,
                       "the inner stack view should contain the captured images stack button")
    }
    
    func testFlashStatusWhenOnByDefault() {
        let giniConfiguration = GiniConfiguration()
        
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        
        XCTAssertTrue(cameraButtonsViewController.flashToggleButton.isSelected,
                      "the flash toggle should be selected when flash in on by default")
        
    }
    
    func testFlashStatusWhenOffByDefault() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.flashOnByDefault = false
        
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  currentDevice: IphoneDevice())
        
        XCTAssertFalse(cameraButtonsViewController.flashToggleButton.isSelected,
                       "the flash toggle should be selected when flash in off by default")
        
    }
    
}
