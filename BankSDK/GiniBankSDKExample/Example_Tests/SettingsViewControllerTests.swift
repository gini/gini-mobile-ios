//
//  SettingsViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 11/16/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDKExample
@testable import GiniCaptureSDK

final class SettingsViewControllerTests: XCTestCase {
    let settingsViewController = (UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController)!
    
    override func setUp() {
        super.setUp()
        settingsViewController.giniConfiguration = GiniConfiguration()
        _ = settingsViewController.view

    }
    
    func testSegmentedControlNone() {
        settingsViewController.fileImportControl.selectedSegmentIndex = 0
        settingsViewController.fileImportControl.sendActions(for: .valueChanged)
        XCTAssertEqual(settingsViewController.giniConfiguration.fileImportSupportedTypes, .none,
                       "none types should be supported in the gini configuration")
    }
    
    func testSegmentedControlPDF() {
        settingsViewController.fileImportControl.selectedSegmentIndex = 1
        settingsViewController.fileImportControl.sendActions(for: .valueChanged)
        XCTAssertEqual(settingsViewController.giniConfiguration.fileImportSupportedTypes, .pdf,
                       "pdf type should be supported in the gini configuration")
    }
    
    func testSegmentedControlPDFAndImages() {
        settingsViewController.fileImportControl.selectedSegmentIndex = 2
        settingsViewController.fileImportControl.sendActions(for: .valueChanged)
        XCTAssertEqual(settingsViewController.giniConfiguration.fileImportSupportedTypes, .pdf_and_images,
                       "pdf and image types should be supported in the gini configuration")
    }
    
    func testOpenWithSwitchOn() {
        settingsViewController.openWithSwitch.isOn = true
        settingsViewController.openWithSwitch.sendActions(for: .valueChanged)
        
        XCTAssertTrue(settingsViewController.giniConfiguration.openWithEnabled,
                      "open with feature should be enabled in the gini configuration")
    }
    
    func testOpenWithSwitchOff() {
        settingsViewController.openWithSwitch.isOn = false
        settingsViewController.openWithSwitch.sendActions(for: .valueChanged)

        XCTAssertFalse(settingsViewController.giniConfiguration.openWithEnabled,
                       "open with feature should not be enabled in the gini configuration")
    }
    
    func testQrCodeScanningSwitchOn() {
        settingsViewController.qrCodeScanningSwitch.isOn = true
        settingsViewController.qrCodeScanningSwitch.sendActions(for: .valueChanged)
        
        XCTAssertTrue(settingsViewController.giniConfiguration.qrCodeScanningEnabled,
                      "qr code scanning should be enabled in the gini configuration")
    }
    
    func testQrCodeScanningSwitchOff() {
        settingsViewController.qrCodeScanningSwitch.isOn = false
        settingsViewController.qrCodeScanningSwitch.sendActions(for: .valueChanged)
        
        XCTAssertFalse(settingsViewController.giniConfiguration.qrCodeScanningEnabled,
                       "qr code scanning should not be enabled in the gini configuration")
    }
    
    func testMultipageSwitchOn() {
        settingsViewController.multipageSwitch.isOn = true
        settingsViewController.multipageSwitch.sendActions(for: .valueChanged)
        
        XCTAssertTrue(settingsViewController.giniConfiguration.multipageEnabled,
                      "multipage should be enabled in the gini configuration")
    }
    
    func testMultipageSwitchOff() {
        settingsViewController.multipageSwitch.isOn = false
        settingsViewController.multipageSwitch.sendActions(for: .valueChanged)
        
        XCTAssertFalse(settingsViewController.giniConfiguration.multipageEnabled,
                       "multipage should not be enabled in the gini configuration")
    }
}
