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
@testable import GiniBankSDK
@testable import GiniCaptureSDK

final class SettingsViewControllerTests: XCTestCase {
	private lazy var configuration: GiniBankConfiguration = {
		let configuration = GiniBankConfiguration()
		configuration.fileImportSupportedTypes = .pdf_and_images
		configuration.openWithEnabled = true
		configuration.qrCodeScanningEnabled = true
		configuration.onlyQRCodeScanningEnabled = false
		configuration.multipageEnabled = true
		configuration.flashToggleEnabled = true
		configuration.flashOnByDefault = true
		configuration.bottomNavigationBarEnabled = false
		configuration.onboardingShowAtLaunch = true
		configuration.onboardingShowAtFirstLaunch = true
		configuration.onboardingAlignCornersIllustrationAdapter = nil
		configuration.onboardingLightingIllustrationAdapter = nil
		configuration.onboardingQRCodeIllustrationAdapter = nil
		configuration.onboardingMultiPageIllustrationAdapter = nil
		configuration.onboardingNavigationBarBottomAdapter = nil
		configuration.customOnboardingPages = nil
		configuration.onButtonLoadingIndicator = nil
		configuration.customLoadingIndicator = nil
		configuration.shouldShowSupportedFormatsScreen = true
		configuration.customMenuItems = []
		configuration.customNavigationController = nil
		configuration.shouldShowDragAndDropTutorial = true
		configuration.digitalInvoiceOnboardingIllustrationAdapter = nil
		configuration.digitalInvoiceHelpNavigationBarBottomAdapter = nil
		configuration.digitalInvoiceHelpNavigationBarBottomAdapter = nil
		configuration.digitalInvoiceNavigationBarBottomAdapter = nil
		configuration.returnAssistantEnabled = true
		configuration.enableReturnReasons = true
		configuration.giniErrorLoggerIsOn = true
		configuration.debugModeOn = true
		return configuration
	}()
	
	private var settingsViewController: SettingsViewController?
	private var contentData = [SettingsViewController.CellType]()
	
	override func setUp() {
		super.setUp()
		settingsViewController = SettingsViewController(giniConfiguration: configuration)
		
		contentData.append(.switchOption(data: .init(type: .openWith,
													 isSwitchOn: configuration.openWithEnabled)))
		contentData.append(.switchOption(data: .init(type: .qrCodeScanning,
													 isSwitchOn: configuration.qrCodeScanningEnabled)))
		contentData.append(.switchOption(data: .init(type: .qrCodeScanningOnly,
													 isSwitchOn: configuration.onlyQRCodeScanningEnabled)))
		contentData.append(.switchOption(data: .init(type: .multipage,
													 isSwitchOn: configuration.multipageEnabled)))
		if flashToggleSettingEnabled {
			contentData.append(.switchOption(data: .init(type: .flashToggle,
														 isSwitchOn: configuration.flashToggleEnabled)))
			contentData.append(.switchOption(data: .init(type: .flashOnByDefault,
														 isSwitchOn: configuration.flashToggleEnabled)))
		}
		contentData.append(.switchOption(data: .init(type: .bottomNavigationBar,
													 isSwitchOn: configuration.bottomNavigationBarEnabled)))
		
		contentData.append(.switchOption(data: .init(type: .onboardingShowAtLaunch,
													 isSwitchOn: configuration.onboardingShowAtLaunch)))
		
		contentData.append(.switchOption(data: .init(type: .onboardingShowAtFirstLaunch,
													 isSwitchOn: configuration.onboardingShowAtFirstLaunch)))
		contentData.append(.switchOption(data: .init(type: .onboardingAlignCornersIllustrationAdapter,
													 isSwitchOn: configuration.onboardingAlignCornersIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingLightingIllustrationAdapter,
													 isSwitchOn: configuration.onboardingLightingIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingQRCodeIllustrationAdapter,
													 isSwitchOn: configuration.onboardingQRCodeIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingMultiPageIllustrationAdapter,
													 isSwitchOn: configuration.onboardingMultiPageIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingNavigationBarBottomAdapter,
													 isSwitchOn: configuration.onboardingNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .customOnboardingPages,
													 isSwitchOn: configuration.customOnboardingPages != nil)))

		contentData.append(.switchOption(data: .init(type: .onButtonLoadingIndicator,
													 isSwitchOn: configuration.onButtonLoadingIndicator != nil)))
		contentData.append(.switchOption(data: .init(type: .customLoadingIndicator,
													 isSwitchOn: configuration.customLoadingIndicator != nil)))
		
		contentData.append(.switchOption(data: .init(type: .shouldShowSupportedFormatsScreen,
													 isSwitchOn: configuration.shouldShowSupportedFormatsScreen)))
		contentData.append(.switchOption(data: .init(type: .customMenuItems,
													 isSwitchOn: !configuration.customMenuItems.isEmpty)))
		
		contentData.append(.switchOption(data: .init(type: .customNavigationController,
													 isSwitchOn: configuration.customNavigationController != nil)))
		
		contentData.append(.switchOption(data: .init(type: .shouldShowDragAndDropTutorial,
													 isSwitchOn: configuration.shouldShowDragAndDropTutorial)))
		
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingIllustrationAdapter,
													 isSwitchOn: configuration.digitalInvoiceOnboardingIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceHelpNavigationBarBottomAdapter,
													 isSwitchOn: configuration.digitalInvoiceHelpNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingNavigationBarBottomAdapter,
													 isSwitchOn: configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceNavigationBarBottomAdapter,
													 isSwitchOn: configuration.digitalInvoiceNavigationBarBottomAdapter != nil)))
		
		contentData.append(.switchOption(data: .init(type: .returnAssistantEnabled,
													 isSwitchOn: configuration.returnAssistantEnabled)))
		
		contentData.append(.switchOption(data: .init(type: .enableReturnReasons,
													 isSwitchOn: configuration.enableReturnReasons)))
		
		contentData.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
													 isSwitchOn: configuration.giniErrorLoggerIsOn)))
		contentData.append(.switchOption(data: .init(type: .debugModeOn,
													 isSwitchOn: configuration.debugModeOn)))
		
		var selectedSegmentIndex = 0
		switch configuration.fileImportSupportedTypes {
		case .none:
			selectedSegmentIndex = 0
		case .pdf:
			selectedSegmentIndex = 1
		case .pdf_and_images:
			selectedSegmentIndex = 2
		}
		contentData.append(.fileImportType(data: SegmentedOptionModel(selectedIndex: selectedSegmentIndex)))
	}
	
	private var flashToggleSettingEnabled: Bool = {
		#if targetEnvironment(simulator)
			return true
		#else
			return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)?.hasFlash ?? false
	#endif
	}()
	
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
	
	private func getSwitchOptionIndex(for type: SwitchOptionModel.OptionType) -> Int? {
		return contentData.firstIndex { section in
			guard case .switchOption(let data) = section, data.type == type else {
				return false
			}
			return true
		}
	}
	
	private func getFileImportOptionIndex() -> Int? {
		return contentData.firstIndex { section in
			guard case .fileImportType = section else {
				return false
			}
			return true
		}
	}
}

// MARK: - Tests

extension SettingsViewControllerTests {
	
	//MARK: - OpenWith
	
	func testOpenWithSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .openWith) else {
			XCTFail("`openWith` option not found in sectionData")
			return
		}
			
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .openWith else {
				XCTFail("Expected type `openWith`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.openWithEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.openWithEnabled,
						   "open with feature should not be enabled in the gini configuration")
		}
	}
	
	func testOpenWithSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .openWith) else {
			XCTFail("`openWith` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .openWith else {
				XCTFail("Expected type `openWith`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.openWithEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.openWithEnabled,
						  "open with feature should be enabled in the gini configuration")
		}
	}
	
	//MARK: - QRCodeScanning
	
	func testQrCodeScanningSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .qrCodeScanning) else {
			XCTFail("`qrCodeScanning` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .qrCodeScanning else {
				XCTFail("Expected type `qrCodeScanning`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.qrCodeScanningEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.qrCodeScanningEnabled,
						  "qr code scanning should be enabled in the gini configuration")
		}
	}
	
	func testQrCodeScanningSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .qrCodeScanning) else {
			XCTFail("`qrCodeScanning` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .qrCodeScanning else {
				XCTFail("Expected type `qrCodeScanning`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.qrCodeScanningEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.qrCodeScanningEnabled,
						   "qr code scanning should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - QrCodeScanningOnly
	
	func testQrCodeScanningOnlySwitchOn() {
		guard let index = getSwitchOptionIndex(for: .qrCodeScanningOnly) else {
			XCTFail("`qrCodeScanningOnly` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .qrCodeScanningOnly else {
				XCTFail("Expected type `qrCodeScanningOnly`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.onlyQRCodeScanningEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.onlyQRCodeScanningEnabled,
						  "qrCodeScanningOnly should be enabled in the gini configuration")
		}
	}
	
	func testQrCodeScanningOnlySwitchOff() {
		guard let index = getSwitchOptionIndex(for: .qrCodeScanningOnly) else {
			XCTFail("`qrCodeScanningOnly` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .qrCodeScanningOnly else {
				XCTFail("Expected type `qrCodeScanningOnly`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onlyQRCodeScanningEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.onlyQRCodeScanningEnabled,
						   "qrCodeScanningOnly should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - Multipage
	
	func testMultipageSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .multipage) else {
			XCTFail("`multipage` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .multipage else {
				XCTFail("Expected type `multipage`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.multipageEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.multipageEnabled,
						  "multipage should be enabled in the gini configuration")
		}
	}
	
	func testMultipageSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .multipage) else {
			XCTFail("`multipage` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .multipage else {
				XCTFail("Expected type `multipage`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.multipageEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.multipageEnabled,
						   "multipage should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - FlashToggle
	
	func testFlashToggleSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .flashToggle) else {
			XCTFail("`flashToggle` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .flashToggle else {
				XCTFail("Expected type `flashToggle`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.flashToggleEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.flashToggleEnabled,
						  "flashToggle should be enabled in the gini configuration")
		}
	}
	
	func testFlashToggleSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .flashToggle) else {
			XCTFail("`flashToggle` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .flashToggle else {
				XCTFail("Expected type `flashToggle`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.flashToggleEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.flashToggleEnabled,
						   "flashToggle should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - FlashOnByDefault
	
	func testFlashOnByDefaultSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .flashOnByDefault) else {
			XCTFail("`flashOnByDefault` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .flashOnByDefault else {
				XCTFail("Expected type `flashOnByDefault`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.flashOnByDefault = data.isSwitchOn
			
			XCTAssertTrue(configuration.flashOnByDefault,
						  "flashOnByDefault should be enabled in the gini configuration")
		}
	}
	
	func testFlashOnByDefaultSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .flashOnByDefault) else {
			XCTFail("`flashOnByDefault` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .flashOnByDefault else {
				XCTFail("Expected type `flashOnByDefault`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.flashOnByDefault = data.isSwitchOn
			
			XCTAssertFalse(configuration.flashOnByDefault,
						   "flashOnByDefault should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - Bottom Naviagtion Bar
	
	func testBottomNaviagtionBarSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .bottomNavigationBar) else {
			XCTFail("`bottomNavigationBar` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .bottomNavigationBar else {
				XCTFail("Expected type `bottomNaviagtionBar`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.bottomNavigationBarEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.bottomNavigationBarEnabled,
						  "bottomNaviagtionBar should be enabled in the gini configuration")
		}
	}
	
	func testBottomNaviagtionBarSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .bottomNavigationBar) else {
			XCTFail("`bottomNavigationBar` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .bottomNavigationBar else {
				XCTFail("Expected type `bottomNavigationBar`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.bottomNavigationBarEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.bottomNavigationBarEnabled,
						   "bottomNavigationBar should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - File Import options
	
	func testSegmentedControlNone() {
		guard let index = getFileImportOptionIndex()else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
		guard case .fileImportType(var data) = contentData[index] else { return }
		data.selectedIndex = 0
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .none,
					   "none types should be supported in the gini configuration")
	}
	
	func testSegmentedControlPDF() {
		guard let index = getFileImportOptionIndex()else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
		guard case .fileImportType(var data) = contentData[index] else { return }
		data.selectedIndex = 1
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .pdf,
					   "pdf type should be supported in the gini configuration")
	}
	
	func testSegmentedControlPDFAndImages() {
		guard let index = getFileImportOptionIndex()else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
		guard case .fileImportType(var data) = contentData[index] else { return }
		data.selectedIndex = 2
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .pdf_and_images,
					   "pdf and image types should be supported in the gini configuration")
	}
	
	// MARK: - OnboardingShowAtLaunch
	
	func testOnboardingShowAtLaunchOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingShowAtLaunch) else {
			XCTFail("`onboardingShowAtLaunch` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingShowAtLaunch else {
				XCTFail("Expected type `onboardingShowAtLaunch`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingShowAtLaunch = data.isSwitchOn
			
			XCTAssertFalse(configuration.onboardingShowAtLaunch,
						   "onboardingShowAtLaunch should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingShowAtLaunchOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingShowAtLaunch) else {
			XCTFail("`onboardingShowAtLaunch` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingShowAtLaunch else {
				XCTFail("Expected type `onboardingShowAtLaunch`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.onboardingShowAtLaunch = data.isSwitchOn
			
			XCTAssertTrue(configuration.onboardingShowAtLaunch,
						  "onboardingShowAtLaunch should be enabled in the gini configuration")
		}
	}

	// MARK: - OnboardingNavigationBarBottomAdapter
	
	func testOnboardingCustomNavigationBottomBarOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingNavigationBarBottomAdapter) else {
			XCTFail("`onboardingNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingNavigationBarBottomAdapter else {
				XCTFail("Expected type `onboardingNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.onboardingNavigationBarBottomAdapter != nil,
						   "onboardingNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingCustomNavigationBottomBarOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingNavigationBarBottomAdapter) else {
			XCTFail("`onboardingNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingNavigationBarBottomAdapter else {
				XCTFail("Expected type `onboardingNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomOnboardingBottomNavigationBarAdapter()
			configuration.onboardingNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.onboardingNavigationBarBottomAdapter != nil,
						  "onboardingNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}

	// MARK: - OnboardingMultiPageIllustrationAdapter
	
	func testOnboardingMultiPageCustomIllustrationOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingMultiPageIllustrationAdapter) else {
			XCTFail("`onboardingMultiPageIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingMultiPageIllustrationAdapter else {
				XCTFail("Expected type `onboardingMultiPageIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingMultiPageIllustrationAdapter = nil
			
			XCTAssertFalse(configuration.onboardingMultiPageIllustrationAdapter != nil,
						   "onboardingMultiPageIllustrationAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingMultiPageCustomIllustrationOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingMultiPageIllustrationAdapter) else {
			XCTFail("`onboardingMultiPageIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingMultiPageIllustrationAdapter else {
				XCTFail("Expected type `onboardingMultiPageIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "uploadAnimation",
																	backgroundColor: .green)
			configuration.onboardingMultiPageIllustrationAdapter = customAdapter
			
			XCTAssertTrue(configuration.onboardingMultiPageIllustrationAdapter != nil,
						  "onboardingMultiPageIllustrationAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - OnboardingQRCodeIllustrationAdapter
	
	func testOnboardingQRCodeCustomIllustrationOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingQRCodeIllustrationAdapter) else {
			XCTFail("`onboardingQRCodeIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingQRCodeIllustrationAdapter else {
				XCTFail("Expected type `onboardingQRCodeIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingQRCodeIllustrationAdapter = nil
			
			XCTAssertFalse(configuration.onboardingQRCodeIllustrationAdapter != nil,
						   "onboardingQRCodeIllustrationAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingQRCodeCustomIllustrationOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingQRCodeIllustrationAdapter) else {
			XCTFail("`onboardingQRCodeIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingQRCodeIllustrationAdapter else {
				XCTFail("Expected type `onboardingQRCodeIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
																	backgroundColor: .blue)
			configuration.onboardingQRCodeIllustrationAdapter = customAdapter
			
			XCTAssertTrue(configuration.onboardingQRCodeIllustrationAdapter != nil,
						  "onboardingQRCodeIllustrationAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - OnboardingLightingIllustrationAdapter
	
	func testOnboardingLightingCustomIllustrationOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingLightingIllustrationAdapter) else {
			XCTFail("`onboardingLightingIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingLightingIllustrationAdapter else {
				XCTFail("Expected type `onboardingLightingIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingLightingIllustrationAdapter = nil
			
			XCTAssertFalse(configuration.onboardingLightingIllustrationAdapter != nil,
						   "onboardingLightingIllustrationAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingLightingCustomIllustrationOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingLightingIllustrationAdapter) else {
			XCTFail("`onboardingLightingIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingLightingIllustrationAdapter else {
				XCTFail("Expected type `onboardingLightingIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "cameraAnimation",
																	backgroundColor: .yellow)
			configuration.onboardingLightingIllustrationAdapter = customAdapter
			
			XCTAssertTrue(configuration.onboardingLightingIllustrationAdapter != nil,
						  "onboardingLightingIllustrationAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - OnboardingAlignCornersIllustrationAdapter
	
	func testOnboardingAlignCornersCustomIllustrationOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingAlignCornersIllustrationAdapter) else {
			XCTFail("`onboardingAlignCornersIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingAlignCornersIllustrationAdapter else {
				XCTFail("Expected type `onboardingAlignCornersIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingAlignCornersIllustrationAdapter = nil
			
			XCTAssertFalse(configuration.onboardingAlignCornersIllustrationAdapter != nil,
						   "onboardingAlignCornersIllustrationAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingAlignCornersCustomIllustrationOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingAlignCornersIllustrationAdapter) else {
			XCTFail("`onboardingAlignCornersIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingAlignCornersIllustrationAdapter else {
				XCTFail("Expected type `onboardingAlignCornersIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "page1Animation",
																	backgroundColor: .red)
			configuration.onboardingAlignCornersIllustrationAdapter = customAdapter
			
			XCTAssertTrue(configuration.onboardingAlignCornersIllustrationAdapter != nil,
						  "onboardingAlignCornersIllustrationAdapter should be enabled in the gini configuration")
		}
	}

	// MARK: - OnboardingShowAtFirstLaunch
	
	func testOnboardingShowAtFirstLaunchOff() {
		guard let index = getSwitchOptionIndex(for: .onboardingShowAtFirstLaunch) else {
			XCTFail("`onboardingShowAtFirstLaunch` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingShowAtFirstLaunch else {
				XCTFail("Expected type `onboardingShowAtFirstLaunch`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onboardingShowAtFirstLaunch = data.isSwitchOn
			
			XCTAssertFalse(configuration.onboardingShowAtFirstLaunch,
						   "onboardingShowAtFirstLaunch should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingShowAtFirstLaunchOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingShowAtFirstLaunch) else {
			XCTFail("`onboardingShowAtFirstLaunch` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onboardingShowAtFirstLaunch else {
				XCTFail("Expected type `onboardingShowAtFirstLaunch`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.onboardingShowAtFirstLaunch = data.isSwitchOn
			
			XCTAssertTrue(configuration.onboardingShowAtFirstLaunch,
						  "onboardingShowAtFirstLaunch should be enabled in the gini configuration")
		}
	}
	
	// MARK: - CustomOnboardingPages
	
	func testCustomOnboardingPagesOff() {
		guard let index = getSwitchOptionIndex(for: .customOnboardingPages) else {
			XCTFail("`customOnboardingPages` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customOnboardingPages else {
				XCTFail("Expected type `customOnboardingPages`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.customOnboardingPages = nil
			
			XCTAssertFalse(configuration.customOnboardingPages != nil,
						   "customOnboardingPages should not be enabled in the gini configuration")
		}
	}
	
	func testCustomOnboardingPagesOn() {
		guard let index = getSwitchOptionIndex(for: .customOnboardingPages) else {
			XCTFail("`customOnboardingPages` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customOnboardingPages else {
				XCTFail("Expected type `customOnboardingPages`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customPage = OnboardingPage(imageName: "captureSuggestion1",
											title: "Page 1",
											description: "Description for page 1")
			configuration.customOnboardingPages = [customPage]
			
			XCTAssertTrue(configuration.customOnboardingPages != nil,
						  "customOnboardingPages should be enabled in the gini configuration")
		}
	}
	
	// MARK: - OnButtonLoadingIndicator
	
	func testOnButtonLoadingIndicatorOff() {
		guard let index = getSwitchOptionIndex(for: .onButtonLoadingIndicator) else {
			XCTFail("`onButtonLoadingIndicator` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onButtonLoadingIndicator else {
				XCTFail("Expected type `onButtonLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.onButtonLoadingIndicator = nil
			
			XCTAssertFalse(configuration.onButtonLoadingIndicator != nil,
						   "onButtonLoadingIndicator should not be enabled in the gini configuration")
		}
	}
	
	func testOnButtonLoadingIndicatorOn() {
		guard let index = getSwitchOptionIndex(for: .onButtonLoadingIndicator) else {
			XCTFail("`onButtonLoadingIndicator` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .onButtonLoadingIndicator else {
				XCTFail("Expected type `onButtonLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.onButtonLoadingIndicator = OnButtonLoading()
			
			XCTAssertTrue(configuration.onButtonLoadingIndicator != nil,
						  "onButtonLoadingIndicator should be enabled in the gini configuration")
		}
	}
	
	// MARK: - CustomLoadingIndicator
	
	func testCustomLoadingIndicatorOff() {
		guard let index = getSwitchOptionIndex(for: .customLoadingIndicator) else {
			XCTFail("`customLoadingIndicator` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customLoadingIndicator else {
				XCTFail("Expected type `customLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.customLoadingIndicator = nil
			
			XCTAssertFalse(configuration.customLoadingIndicator != nil,
						   "customLoadingIndicator should not be enabled in the gini configuration")
		}
	}
	
	func testCustomLoadingIndicatorOn() {
		guard let index = getSwitchOptionIndex(for: .customLoadingIndicator) else {
			XCTFail("`customLoadingIndicator` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customLoadingIndicator else {
				XCTFail("Expected type `customLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.customLoadingIndicator = CustomLoadingIndicator()
			
			XCTAssertTrue(configuration.customLoadingIndicator != nil,
						  "customLoadingIndicator should be enabled in the gini configuration")
		}
	}
	
	// MARK: - SupportedFormatsScreen
	
	func testSupportedFormatsScreenSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .shouldShowSupportedFormatsScreen) else {
			XCTFail("`shouldShowSupportedFormatsScreen` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .shouldShowSupportedFormatsScreen else {
				XCTFail("Expected type `shouldShowSupportedFormatsScreen`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.shouldShowSupportedFormatsScreen = data.isSwitchOn
			
			XCTAssertTrue(configuration.shouldShowSupportedFormatsScreen,
						  "shouldShowSupportedFormatsScreen should be enabled in the gini configuration")
		}
	}
	
	func testSupportedFormatsScreenSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .shouldShowSupportedFormatsScreen) else {
			XCTFail("`shouldShowSupportedFormatsScreen` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .shouldShowSupportedFormatsScreen else {
				XCTFail("Expected type `shouldShowSupportedFormatsScreen`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.shouldShowSupportedFormatsScreen = data.isSwitchOn
			
			XCTAssertFalse(configuration.shouldShowSupportedFormatsScreen,
						   "shouldShowSupportedFormatsScreen should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - CustomHelpMenuItems
	
	func testCustomHelpMenuItemsSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .customMenuItems) else {
			XCTFail("`customMenuItems` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customMenuItems else {
				XCTFail("Expected type `customMenuItems`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())
			configuration.customMenuItems = [customMenuItem]
			
			XCTAssertTrue(configuration.customMenuItems.isEmpty == false,
						  "customMenuItems should be enabled in the gini configuration")
		}
	}
	
	func testCustomHelpMenuItemsSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .customMenuItems) else {
			XCTFail("`customMenuItems` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customMenuItems else {
				XCTFail("Expected type `customMenuItems`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.customMenuItems = []
			
			XCTAssertFalse(configuration.customMenuItems.isEmpty == false,
						   "customMenuItems should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - CustomNavigationController
	
	func testCustomNavigationControllerSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .customNavigationController) else {
			XCTFail("`customNavigationController` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customNavigationController else {
				XCTFail("Expected type `customNavigationController`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let navigationViewController = UINavigationController()
			navigationViewController.navigationBar.backgroundColor = GiniColor(light: .purple, dark: .lightGray).uiColor()
			configuration.customNavigationController = navigationViewController
			
			XCTAssertTrue(configuration.customNavigationController != nil,
						  "customNavigationController should be enabled in the gini configuration")
		}
	}
	
	func testCustomNavigationControllerSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .customNavigationController) else {
			XCTFail("`customNavigationController` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customNavigationController else {
				XCTFail("Expected type `customNavigationController`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.customNavigationController = nil
			
			XCTAssertFalse(configuration.customNavigationController != nil,
						   "customNavigationController should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - DragAndDrop
	
	func testDragAndDropSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .shouldShowDragAndDropTutorial) else {
			XCTFail("`shouldShowDragAndDropTutorial` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .shouldShowDragAndDropTutorial else {
				XCTFail("Expected type `shouldShowDragAndDropTutorial`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.shouldShowDragAndDropTutorial = data.isSwitchOn
			
			XCTAssertTrue(configuration.shouldShowDragAndDropTutorial,
						  "shouldShowDragAndDropTutorial should be enabled in the gini configuration")
		}
	}
	
	func testDragAndDropSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .shouldShowDragAndDropTutorial) else {
			XCTFail("`shouldShowDragAndDropTutorial` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .shouldShowDragAndDropTutorial else {
				XCTFail("Expected type `shouldShowDragAndDropTutorial`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.shouldShowDragAndDropTutorial = data.isSwitchOn
			
			XCTAssertFalse(configuration.shouldShowDragAndDropTutorial,
						   "shouldShowDragAndDropTutorial should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - DigitalInvoiceOnboardingIllustrationAdapter
	
	func testDigitalInvoiceOnboardingCustomIllustrationSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceOnboardingIllustrationAdapter) else {
			XCTFail("`customNavigationController` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceOnboardingIllustrationAdapter else {
				XCTFail("Expected type `digitalInvoiceOnboardingIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
																	backgroundColor: UIColor.blue)
			configuration.digitalInvoiceOnboardingIllustrationAdapter = customAdapter
			
			XCTAssertTrue(configuration.digitalInvoiceOnboardingIllustrationAdapter != nil,
						  "customNavigationController should be enabled in the gini configuration")
		}
	}
	
	func testDigitalInvoiceOnboardingCustomIllustrationSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceOnboardingIllustrationAdapter) else {
			XCTFail("`digitalInvoiceOnboardingIllustrationAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceOnboardingIllustrationAdapter else {
				XCTFail("Expected type `digitalInvoiceOnboardingIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.digitalInvoiceOnboardingIllustrationAdapter = nil
			
			XCTAssertFalse(configuration.digitalInvoiceOnboardingIllustrationAdapter != nil,
						   "digitalInvoiceOnboardingIllustrationAdapter should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - DigitalInvoiceHelpNavigationBarBottomAdapter
	
	func testDigitalInvoiceHelpCustomNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceHelpNavigationBarBottomAdapter) else {
			XCTFail("`digitalInvoiceHelpNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceHelpNavigationBarBottomAdapter else {
				XCTFail("Expected type `digitalInvoiceHelpNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomBottomNavigationBarAdapter()
			configuration.digitalInvoiceHelpNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.digitalInvoiceHelpNavigationBarBottomAdapter != nil,
						  "digitalInvoiceHelpNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	func testDigitalInvoiceHelpCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceHelpNavigationBarBottomAdapter) else {
			XCTFail("`digitalInvoiceHelpNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceHelpNavigationBarBottomAdapter else {
				XCTFail("Expected type `digitalInvoiceHelpNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.digitalInvoiceHelpNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.digitalInvoiceHelpNavigationBarBottomAdapter != nil,
						   "digitalInvoiceHelpNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - DigitalInvoiceOnboardingNavigationBarBottomAdapter
	
	func testDigitalInvoiceOnboardingCustomNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceOnboardingNavigationBarBottomAdapter) else {
			XCTFail("`digitalInvoiceOnboardingNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceOnboardingNavigationBarBottomAdapter else {
				XCTFail("Expected type `digitalInvoiceOnboardingNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter()
			configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter != nil,
						  "digitalInvoiceOnboardingNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	func testDigitalInvoiceOnboardingCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceOnboardingNavigationBarBottomAdapter) else {
			XCTFail("`digitalInvoiceOnboardingNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceOnboardingNavigationBarBottomAdapter else {
				XCTFail("Expected type `digitalInvoiceOnboardingNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter != nil,
						   "digitalInvoiceOnboardingNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - DigitalInvoiceNavigationBarBottomAdapter
	
	func testDigitalInvoiceCustomNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceNavigationBarBottomAdapter) else {
			XCTFail("`digitalInvoiceNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceNavigationBarBottomAdapter else {
				XCTFail("Expected type `digitalInvoiceNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomDigitalInvoiceBottomNavigationBarAdapter()
			configuration.digitalInvoiceNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.digitalInvoiceNavigationBarBottomAdapter != nil,
						  "digitalInvoiceNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	func testDigitalInvoiceCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .digitalInvoiceNavigationBarBottomAdapter) else {
			XCTFail("`digitalInvoiceNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .digitalInvoiceNavigationBarBottomAdapter else {
				XCTFail("Expected type `digitalInvoiceNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.digitalInvoiceNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.digitalInvoiceNavigationBarBottomAdapter != nil,
						   "digitalInvoiceNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - ReturnAssistant
	
	func testReturnAssistantSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .returnAssistantEnabled) else {
			XCTFail("`returnAssistantEnabled` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .returnAssistantEnabled else {
				XCTFail("Expected type `returnAssistantEnabled`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.returnAssistantEnabled = data.isSwitchOn
			
			XCTAssertTrue(configuration.returnAssistantEnabled,
						  "returnAssistantEnabled should be enabled in the gini configuration")
		}
	}
	
	func testReturnAssistantSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .returnAssistantEnabled) else {
			XCTFail("`returnAssistantEnabled` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .returnAssistantEnabled else {
				XCTFail("Expected type `returnAssistantEnabled`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.returnAssistantEnabled = data.isSwitchOn
			
			XCTAssertFalse(configuration.returnAssistantEnabled,
						   "returnAssistantEnabled should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - ReturnReasonsDigitalInvoiceDialog
	
	func testReturnReasonsDigitalInvoiceDialogSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .enableReturnReasons) else {
			XCTFail("`enableReturnReasons` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .enableReturnReasons else {
				XCTFail("Expected type `enableReturnReasons`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.enableReturnReasons = data.isSwitchOn
			
			XCTAssertTrue(configuration.enableReturnReasons,
						  "enableReturnReasons should be enabled in the gini configuration")
		}
	}
	
	func testReturnReasonsDigitalInvoiceDialogSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .enableReturnReasons) else {
			XCTFail("`enableReturnReasons` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .enableReturnReasons else {
				XCTFail("Expected type `enableReturnReasons`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.enableReturnReasons = data.isSwitchOn
			
			XCTAssertFalse(configuration.enableReturnReasons,
						   "enableReturnReasons should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - GiniErrorLogger
	
	func testGiniErrorLoggerSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .giniErrorLoggerIsOn) else {
			XCTFail("`giniErrorLoggerIsOn` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .giniErrorLoggerIsOn else {
				XCTFail("Expected type `giniErrorLoggerIsOn`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.giniErrorLoggerIsOn = data.isSwitchOn
			
			XCTAssertTrue(configuration.giniErrorLoggerIsOn,
						  "giniErrorLoggerIsOn should be enabled in the gini configuration")
		}
	}
	
	func testGiniErrorLoggerSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .giniErrorLoggerIsOn) else {
			XCTFail("`giniErrorLoggerIsOn` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .giniErrorLoggerIsOn else {
				XCTFail("Expected type `giniErrorLoggerIsOn`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.giniErrorLoggerIsOn = data.isSwitchOn
			
			XCTAssertFalse(configuration.giniErrorLoggerIsOn,
						   "giniErrorLoggerIsOn should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - DebugMode
	
	func testDebugModeSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .debugModeOn) else {
			XCTFail("`debugModeOn` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .debugModeOn else {
				XCTFail("Expected type `debugModeOn`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.debugModeOn = data.isSwitchOn
			
			XCTAssertTrue(configuration.debugModeOn,
						  "debugModeOn should be enabled in the gini configuration")
		}
	}
	
	func testDebugModeSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .debugModeOn) else {
			XCTFail("`debugModeOn` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .debugModeOn else {
				XCTFail("Expected type `debugModeOn`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.debugModeOn = data.isSwitchOn
			
			XCTAssertFalse(configuration.debugModeOn,
						   "debugModeOn should not be enabled in the gini configuration")
		}
	}

}
