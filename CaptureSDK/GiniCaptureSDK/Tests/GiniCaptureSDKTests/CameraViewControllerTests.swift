//
//  CameraViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
import AVFoundation
@testable import GiniCaptureSDK

final class CameraViewControllerTests: XCTestCase {
    
    var cameraViewController: CameraScreen!
    var giniConfiguration: GiniConfiguration!
    var screenAPICoordinator: GiniScreenAPICoordinator!
    let visionDelegateMock = GiniCaptureDelegateMock()
    lazy var imageData: Data = {
        let image = GiniCaptureTestsHelper.loadImage(named: "invoice")
        let imageData = image.jpegData(compressionQuality: 0.9)!
        return imageData
    }()

    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration.shared
        giniConfiguration.multipageEnabled = true
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        screenAPICoordinator = GiniScreenAPICoordinator(withDelegate: visionDelegateMock,
                                                        giniConfiguration: self.giniConfiguration)
        cameraViewController.delegate = screenAPICoordinator
    }
    
    func testInitialization() {
        XCTAssertNotNil(cameraViewController, "view controller should not be nil")
    }
    
    func testTooltipWhenFileImportDisabled() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .none
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        _ = cameraViewController.view
        
        XCTAssertNil(cameraViewController.fileImportToolTipView,
                     "ToolTipView should not be created when file import is disabled.")
    }
}

