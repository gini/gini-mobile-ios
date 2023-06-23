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
		configuration.returnAssistantEnabled = true
		configuration.enableReturnReasons = true
		configuration.giniErrorLoggerIsOn = true
		configuration.debugModeOn = true
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
		
		sectionData.append(.switchOption(data: .init(type: .onboardingShowAtLaunch,
													 isActive: configuration.onboardingShowAtLaunch)))
		
		sectionData.append(.switchOption(data: .init(type: .onboardingShowAtFirstLaunch,
													 isActive: configuration.onboardingShowAtFirstLaunch)))
		sectionData.append(.switchOption(data: .init(type: .onboardingAlignCornersIllustrationAdapter,
													 isActive: configuration.onboardingAlignCornersIllustrationAdapter != nil)))
		sectionData.append(.switchOption(data: .init(type: .onboardingLightingIllustrationAdapter,
													 isActive: configuration.onboardingLightingIllustrationAdapter != nil)))
		sectionData.append(.switchOption(data: .init(type: .onboardingQRCodeIllustrationAdapter,
													 isActive: configuration.onboardingQRCodeIllustrationAdapter != nil)))
		sectionData.append(.switchOption(data: .init(type: .onboardingMultiPageIllustrationAdapter,
													 isActive: configuration.onboardingMultiPageIllustrationAdapter != nil)))
		sectionData.append(.switchOption(data: .init(type: .onboardingNavigationBarBottomAdapter,
													 isActive: configuration.onboardingNavigationBarBottomAdapter != nil)))
		sectionData.append(.switchOption(data: .init(type: .customOnboardingPages,
													 isActive: configuration.customOnboardingPages != nil)))

		sectionData.append(.switchOption(data: .init(type: .onButtonLoadingIndicator,
													 isActive: configuration.onButtonLoadingIndicator != nil)))
		sectionData.append(.switchOption(data: .init(type: .customLoadingIndicator,
													 isActive: configuration.customLoadingIndicator != nil)))
		
		sectionData.append(.switchOption(data: .init(type: .shouldShowSupportedFormatsScreen,
													 isActive: configuration.shouldShowSupportedFormatsScreen)))
		sectionData.append(.switchOption(data: .init(type: .customMenuItems,
													 isActive: !configuration.customMenuItems.isEmpty)))
		
		sectionData.append(.switchOption(data: .init(type: .customNavigationController,
													 isActive: configuration.customNavigationController != nil)))
		
		sectionData.append(.switchOption(data: .init(type: .shouldShowDragAndDropTutorial,
													 isActive: configuration.shouldShowDragAndDropTutorial)))
		
		sectionData.append(.switchOption(data: .init(type: .returnAssistantEnabled,
													 isActive: configuration.returnAssistantEnabled)))
		
		sectionData.append(.switchOption(data: .init(type: .enableReturnReasons,
													 isActive: configuration.enableReturnReasons)))
		
		sectionData.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
													 isActive: configuration.giniErrorLoggerIsOn)))
		sectionData.append(.switchOption(data: .init(type: .debugModeOn,
													 isActive: configuration.debugModeOn)))
		
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
		return sectionData.firstIndex { section in
			guard case .switchOption(let data) = section, data.type == type else {
				return false
			}
			return true
		}
	}
	
	private func getFileImportOptionIndex() -> Int? {
		return sectionData.firstIndex { section in
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
			
		if case .switchOption(var data) = sectionData[index] {
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
		guard let index = getSwitchOptionIndex(for: .openWith) else {
			XCTFail("`openWith` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	//MARK: - QRCodeScanning
	
	func testQrCodeScanningSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .qrCodeScanning) else {
			XCTFail("`qrCodeScanning` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
		guard let index = getSwitchOptionIndex(for: .qrCodeScanning) else {
			XCTFail("`qrCodeScanning` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	// MARK: - QrCodeScanningOnly
	
	func testQrCodeScanningOnlySwitchOn() {
		guard let index = getSwitchOptionIndex(for: .qrCodeScanningOnly) else {
			XCTFail("`qrCodeScanningOnly` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
		guard let index = getSwitchOptionIndex(for: .qrCodeScanningOnly) else {
			XCTFail("`qrCodeScanningOnly` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	// MARK: - Multipage
	
	func testMultipageSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .multipage) else {
			XCTFail("`multipage` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
		guard let index = getSwitchOptionIndex(for: .multipage) else {
			XCTFail("`multipage` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	// MARK: - FlashToggle
	
	func testFlashToggleSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .flashToggle) else {
			XCTFail("`flashToggle` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
		guard let index = getSwitchOptionIndex(for: .flashToggle) else {
			XCTFail("`flashToggle` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	// MARK: - FlashOnByDefault
	
	func testFlashOnByDefaultSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .flashOnByDefault) else {
			XCTFail("`flashOnByDefault` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
		guard let index = getSwitchOptionIndex(for: .flashOnByDefault) else {
			XCTFail("`flashOnByDefault` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	// MARK: - Bottom Naviagtion Bar
	
	func testBottomNaviagtionBarSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .bottomNavigationBar) else {
			XCTFail("`bottomNavigationBar` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	func testBottomNaviagtionBarSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .bottomNavigationBar) else {
			XCTFail("`bottomNavigationBar` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
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
	
	// MARK: - File Import options
	
	func testSegmentedControlNone() {
		guard let index = getFileImportOptionIndex()else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
		guard case .fileImportType(var data) = sectionData[index] else { return }
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
		guard case .fileImportType(var data) = sectionData[index] else { return }
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
		guard case .fileImportType(var data) = sectionData[index] else { return }
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingShowAtLaunch else {
				XCTFail("Expected type `onboardingShowAtLaunch`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.onboardingShowAtLaunch = data.isActive
			
			XCTAssertFalse(configuration.onboardingShowAtLaunch,
						   "onboardingShowAtLaunch should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingShowAtLaunchOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingShowAtLaunch) else {
			XCTFail("`onboardingShowAtLaunch` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingShowAtLaunch else {
				XCTFail("Expected type `onboardingShowAtLaunch`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.onboardingShowAtLaunch = data.isActive
			
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingNavigationBarBottomAdapter else {
				XCTFail("Expected type `onboardingNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingNavigationBarBottomAdapter else {
				XCTFail("Expected type `onboardingNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingMultiPageIllustrationAdapter else {
				XCTFail("Expected type `onboardingMultiPageIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingMultiPageIllustrationAdapter else {
				XCTFail("Expected type `onboardingMultiPageIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingQRCodeIllustrationAdapter else {
				XCTFail("Expected type `onboardingQRCodeIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingQRCodeIllustrationAdapter else {
				XCTFail("Expected type `onboardingQRCodeIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingLightingIllustrationAdapter else {
				XCTFail("Expected type `onboardingLightingIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingLightingIllustrationAdapter else {
				XCTFail("Expected type `onboardingLightingIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingAlignCornersIllustrationAdapter else {
				XCTFail("Expected type `onboardingAlignCornersIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingAlignCornersIllustrationAdapter else {
				XCTFail("Expected type `onboardingAlignCornersIllustrationAdapter`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingShowAtFirstLaunch else {
				XCTFail("Expected type `onboardingShowAtFirstLaunch`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.onboardingShowAtFirstLaunch = data.isActive
			
			XCTAssertFalse(configuration.onboardingShowAtFirstLaunch,
						   "onboardingShowAtFirstLaunch should not be enabled in the gini configuration")
		}
	}
	
	func testOnboardingShowAtFirstLaunchOn() {
		guard let index = getSwitchOptionIndex(for: .onboardingShowAtFirstLaunch) else {
			XCTFail("`onboardingShowAtFirstLaunch` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onboardingShowAtFirstLaunch else {
				XCTFail("Expected type `onboardingShowAtFirstLaunch`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.onboardingShowAtFirstLaunch = data.isActive
			
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customOnboardingPages else {
				XCTFail("Expected type `customOnboardingPages`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customOnboardingPages else {
				XCTFail("Expected type `customOnboardingPages`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onButtonLoadingIndicator else {
				XCTFail("Expected type `onButtonLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .onButtonLoadingIndicator else {
				XCTFail("Expected type `onButtonLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customLoadingIndicator else {
				XCTFail("Expected type `customLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customLoadingIndicator else {
				XCTFail("Expected type `customLoadingIndicator`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .shouldShowSupportedFormatsScreen else {
				XCTFail("Expected type `shouldShowSupportedFormatsScreen`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.shouldShowSupportedFormatsScreen = data.isActive
			
			XCTAssertTrue(configuration.shouldShowSupportedFormatsScreen,
						  "shouldShowSupportedFormatsScreen should be enabled in the gini configuration")
		}
	}
	
	func testSupportedFormatsScreenSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .shouldShowSupportedFormatsScreen) else {
			XCTFail("`shouldShowSupportedFormatsScreen` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .shouldShowSupportedFormatsScreen else {
				XCTFail("Expected type `shouldShowSupportedFormatsScreen`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.shouldShowSupportedFormatsScreen = data.isActive
			
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customMenuItems else {
				XCTFail("Expected type `customMenuItems`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customMenuItems else {
				XCTFail("Expected type `customMenuItems`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customNavigationController else {
				XCTFail("Expected type `customNavigationController`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .customNavigationController else {
				XCTFail("Expected type `customNavigationController`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .shouldShowDragAndDropTutorial else {
				XCTFail("Expected type `shouldShowDragAndDropTutorial`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.shouldShowDragAndDropTutorial = data.isActive
			
			XCTAssertTrue(configuration.shouldShowDragAndDropTutorial,
						  "shouldShowDragAndDropTutorial should be enabled in the gini configuration")
		}
	}
	
	func testDragAndDropSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .shouldShowDragAndDropTutorial) else {
			XCTFail("`shouldShowDragAndDropTutorial` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .shouldShowDragAndDropTutorial else {
				XCTFail("Expected type `shouldShowDragAndDropTutorial`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.shouldShowDragAndDropTutorial = data.isActive
			
			XCTAssertFalse(configuration.shouldShowDragAndDropTutorial,
						   "shouldShowDragAndDropTutorial should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - ReturnAssistant
	
	func testReturnAssistantSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .returnAssistantEnabled) else {
			XCTFail("`returnAssistantEnabled` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .returnAssistantEnabled else {
				XCTFail("Expected type `returnAssistantEnabled`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.returnAssistantEnabled = data.isActive
			
			XCTAssertTrue(configuration.returnAssistantEnabled,
						  "returnAssistantEnabled should be enabled in the gini configuration")
		}
	}
	
	func testReturnAssistantSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .returnAssistantEnabled) else {
			XCTFail("`returnAssistantEnabled` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .returnAssistantEnabled else {
				XCTFail("Expected type `returnAssistantEnabled`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.returnAssistantEnabled = data.isActive
			
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .enableReturnReasons else {
				XCTFail("Expected type `enableReturnReasons`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.enableReturnReasons = data.isActive
			
			XCTAssertTrue(configuration.enableReturnReasons,
						  "enableReturnReasons should be enabled in the gini configuration")
		}
	}
	
	func testReturnReasonsDigitalInvoiceDialogSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .enableReturnReasons) else {
			XCTFail("`enableReturnReasons` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .enableReturnReasons else {
				XCTFail("Expected type `enableReturnReasons`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.enableReturnReasons = data.isActive
			
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .giniErrorLoggerIsOn else {
				XCTFail("Expected type `giniErrorLoggerIsOn`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.giniErrorLoggerIsOn = data.isActive
			
			XCTAssertTrue(configuration.giniErrorLoggerIsOn,
						  "giniErrorLoggerIsOn should be enabled in the gini configuration")
		}
	}
	
	func testGiniErrorLoggerSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .giniErrorLoggerIsOn) else {
			XCTFail("`giniErrorLoggerIsOn` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .giniErrorLoggerIsOn else {
				XCTFail("Expected type `giniErrorLoggerIsOn`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.giniErrorLoggerIsOn = data.isActive
			
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
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .debugModeOn else {
				XCTFail("Expected type `debugModeOn`, found a different one: \(data.type)")
				return
			}
			data.isActive = true
			configuration.debugModeOn = data.isActive
			
			XCTAssertTrue(configuration.debugModeOn,
						  "debugModeOn should be enabled in the gini configuration")
		}
	}
	
	func testDebugModeSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .debugModeOn) else {
			XCTFail("`debugModeOn` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = sectionData[index] {
			guard data.type == .debugModeOn else {
				XCTFail("Expected type `debugModeOn`, found a different one: \(data.type)")
				return
			}
			data.isActive = false
			configuration.debugModeOn = data.isActive
			
			XCTAssertFalse(configuration.debugModeOn,
						   "debugModeOn should not be enabled in the gini configuration")
		}
	}

}
