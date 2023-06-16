//
//  SettingsViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 11/16/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
import AVFoundation
@testable import GiniBankSDKExample
@testable import GiniCaptureSDK

final class SettingsViewControllerTests: XCTestCase {
	private lazy var configuration: GiniConfiguration = {
		let configuration = GiniConfiguration()
		configuration.fileImportSupportedTypes = .pdf_and_images
		configuration.openWithEnabled = true
		configuration.qrCodeScanningEnabled = true
		configuration.multipageEnabled = true
		configuration.flashToggleEnabled = true
		configuration.flashOnByDefault = true
		return configuration
	}()
	
	private var settingsViewController: SettingsViewController?
	private var sectionData = [SettingsViewController.SectionType]()

	override func setUp() {
		super.setUp()
		settingsViewController = SettingsViewController(giniConfiguration: configuration)
		
		sectionData.append(.switchOption(data: .init(type: .openWith,
													 isActive: configuration.openWithEnabled)))
		sectionData.append(.switchOption(data: .init(type: .qrCodeScanning,
													 isActive: configuration.qrCodeScanningEnabled)))
		sectionData.append(.switchOption(data: .init(type: .qrCodeScanningOnly,
													 isActive: configuration.onlyQRCodeScanningEnabled)))
		sectionData.append(.switchOption(data: .init(type: .multipage,
													 isActive: configuration.multipageEnabled)))
		if flashToggleSettingEnabled {
			sectionData.append(.switchOption(data: .init(type: .flashToggle,
														 isActive: configuration.flashToggleEnabled)))
			sectionData.append(.switchOption(data: .init(type: .flashOnByDefault,
														 isActive: configuration.flashToggleEnabled)))
		}
		sectionData.append(.switchOption(data: .init(type: .bottomNavigationBar,
													 isActive: configuration.bottomNavigationBarEnabled)))
		var selectedSegmentIndex = 0
		switch configuration.fileImportSupportedTypes {
		case .none:
			selectedSegmentIndex = 0
		case .pdf:
			selectedSegmentIndex = 1
		case .pdf_and_images:
			selectedSegmentIndex = 2
		}
		sectionData.append(.fileImportType(data: SegmentedOptionModel(selectedIndex: selectedSegmentIndex)))
	}

	private var flashToggleSettingEnabled: Bool = {
		#if targetEnvironment(simulator)
			return true
		#else
			return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)?.hasFlash ?? false
	#endif
	}()
	
	func testOpenWithSwitchOff() {
		if case .switchOption(var data) = sectionData[0] {
			guard data.type == .openWith else {
				XCTFail("Expected type `openWith`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.openWithEnabled = data.isActive
			
			XCTAssertFalse(configuration.openWithEnabled,
						   "open with feature should not be enabled in the gini configuration")
		}
	}
	
	func testOpenWithSwitchOn() {
		if case .switchOption(var data) = sectionData[0] {
			guard data.type == .openWith else {
				XCTFail("Expected type `openWith`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.openWithEnabled = data.isActive
			
			XCTAssertTrue(configuration.openWithEnabled,
						  "open with feature should be enabled in the gini configuration")
		}
	}
	
	func testQrCodeScanningSwitchOn() {
		if case .switchOption(var data) = sectionData[1] {
			guard data.type == .qrCodeScanning else {
				XCTFail("Expected type `qrCodeScanning`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.qrCodeScanningEnabled = data.isActive
			
			XCTAssertTrue(configuration.qrCodeScanningEnabled,
						  "qr code scanning should be enabled in the gini configuration")
		}
	}
	
	func testQrCodeScanningSwitchOff() {
		if case .switchOption(var data) = sectionData[1] {
			guard data.type == .qrCodeScanning else {
				XCTFail("Expected type `qrCodeScanning`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.qrCodeScanningEnabled = data.isActive
			
			XCTAssertFalse(configuration.qrCodeScanningEnabled,
						   "qr code scanning should not be enabled in the gini configuration")
		}
	}
	
	func testQrCodeScanningOnlySwitchOn() {
		if case .switchOption(var data) = sectionData[2] {
			guard data.type == .qrCodeScanningOnly else {
				XCTFail("Expected type `qrCodeScanningOnly`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.onlyQRCodeScanningEnabled = data.isActive
			
			XCTAssertTrue(configuration.onlyQRCodeScanningEnabled,
						  "qrCodeScanningOnly should be enabled in the gini configuration")
		}
	}
	
	func testQrCodeScanningOnlySwitchOff() {
		if case .switchOption(var data) = sectionData[2] {
			guard data.type == .qrCodeScanningOnly else {
				XCTFail("Expected type `qrCodeScanningOnly`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.onlyQRCodeScanningEnabled = data.isActive
			
			XCTAssertFalse(configuration.onlyQRCodeScanningEnabled,
						   "qrCodeScanningOnly should not be enabled in the gini configuration")
		}
	}
	
	func testMultipageSwitchOn() {
		if case .switchOption(var data) = sectionData[3] {
			guard data.type == .multipage else {
				XCTFail("Expected type `multipage`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.multipageEnabled = data.isActive
			
			XCTAssertTrue(configuration.multipageEnabled,
						  "multipage should be enabled in the gini configuration")
		}
	}

	func testMultipageSwitchOff() {
		if case .switchOption(var data) = sectionData[3] {
			guard data.type == .multipage else {
				XCTFail("Expected type `multipage`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.multipageEnabled = data.isActive
			
			XCTAssertFalse(configuration.multipageEnabled,
						   "multipage should not be enabled in the gini configuration")
		}
	}
	
	func testFlashToggleSwitchOn() {
		if case .switchOption(var data) = sectionData[4] {
			guard data.type == .flashToggle else {
				XCTFail("Expected type `flashToggle`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.flashToggleEnabled = data.isActive
			
			XCTAssertTrue(configuration.flashToggleEnabled,
						  "flashToggle should be enabled in the gini configuration")
		}
	}
	
	func testFlashToggleSwitchOff() {
		if case .switchOption(var data) = sectionData[4] {
			guard data.type == .flashToggle else {
				XCTFail("Expected type `flashToggle`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.flashToggleEnabled = data.isActive
			
			XCTAssertFalse(configuration.flashToggleEnabled,
						   "flashToggle should not be enabled in the gini configuration")
		}
	}
	
	
	func testFlashOnByDefaultSwitchOn() {
		if case .switchOption(var data) = sectionData[5] {
			guard data.type == .flashOnByDefault else {
				XCTFail("Expected type `flashOnByDefault`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.flashOnByDefault = data.isActive
			
			XCTAssertTrue(configuration.flashOnByDefault,
						  "flashOnByDefault should be enabled in the gini configuration")
		}
	}
	
	func testFlashOnByDefaultSwitchOff() {
		if case .switchOption(var data) = sectionData[5] {
			guard data.type == .flashOnByDefault else {
				XCTFail("Expected type `flashOnByDefault`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.flashOnByDefault = data.isActive
			
			XCTAssertFalse(configuration.flashOnByDefault,
						   "flashOnByDefault should not be enabled in the gini configuration")
		}
	}
	
	func testbottomNaviagtionBarSwitchOn() {
		if case .switchOption(var data) = sectionData[6] {
			guard data.type == .bottomNavigationBar else {
				XCTFail("Expected type `bottomNaviagtionBar`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.bottomNavigationBarEnabled = data.isActive
			
			XCTAssertTrue(configuration.bottomNavigationBarEnabled,
						  "bottomNaviagtionBar should be enabled in the gini configuration")
		}
	}
	
	func testbottomNaviagtionBarSwitchOff() {
		if case .switchOption(var data) = sectionData[6] {
			guard data.type == .bottomNavigationBar else {
				XCTFail("Expected type `bottomNavigationBar`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.bottomNavigationBarEnabled = data.isActive
			
			XCTAssertFalse(configuration.bottomNavigationBarEnabled,
						   "bottomNavigationBar should not be enabled in the gini configuration")
		}
	}

    func testSegmentedControlNone() {
		guard case .fileImportType(var data) = sectionData[7] else { return }
		data.selectedIndex = 0
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		
        XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .none,
                       "none types should be supported in the gini configuration")
    }

    func testSegmentedControlPDF() {
		guard case .fileImportType(var data) = sectionData[7] else { return }
		data.selectedIndex = 1
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
        XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .pdf,
                       "pdf type should be supported in the gini configuration")
    }
	
	func testSegmentedControlPDFAndImages() {
		guard case .fileImportType(var data) = sectionData[7] else { return }
		data.selectedIndex = 2
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .pdf_and_images,
					   "pdf and image types should be supported in the gini configuration")
	}
	
	private func giniImportFileType(selectedIndex: Int) -> GiniCaptureSDK.GiniConfiguration.GiniCaptureImportFileTypes {
		switch selectedIndex {
		case 0:
			return .none
		case 1:
			return .pdf
		case 2:
			return .pdf_and_images
		default: return .none
		}
	}
}
