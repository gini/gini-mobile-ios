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
		configuration.flashOnByDefault = false
		configuration.bottomNavigationBarEnabled = false
		configuration.helpNavigationBarBottomAdapter = nil
		configuration.cameraNavigationBarBottomAdapter = nil
		configuration.reviewNavigationBarBottomAdapter = nil
		configuration.imagePickerNavigationBarBottomAdapter = nil
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
		configuration.customGiniErrorLoggerDelegate = self
		configuration.debugModeOn = true
        configuration.customResourceProvider = nil
		return configuration
	}()
	
	private lazy var settingsButtonStates: SettingsButtonStates = {
		let primaryButtonState = SettingsButtonStates.ButtonState(configuration: configuration.primaryButtonConfiguration,
																  isSwitchOn: false)
		let secondaryButtonState = SettingsButtonStates.ButtonState(configuration: configuration.secondaryButtonConfiguration,
																	isSwitchOn: false)
		let transparentButtonState = SettingsButtonStates.ButtonState(configuration: configuration.transparentButtonConfiguration,
																	  isSwitchOn: false)
		let cameraControlButtonState = SettingsButtonStates.ButtonState(configuration: configuration.cameraControlButtonConfiguration,
																		isSwitchOn: false)
		let addPageButtonState = SettingsButtonStates.ButtonState(configuration: configuration.addPageButtonConfiguration,
																  isSwitchOn: false)
		return SettingsButtonStates(primaryButtonState: primaryButtonState,
									secondaryButtonState: secondaryButtonState,
									transparentButtonState: transparentButtonState,
									cameraControlButtonState: cameraControlButtonState,
									addPageButtonState: addPageButtonState)
	}()
	
	private lazy var documentValidationsState: DocumentValidationsState = {
		return DocumentValidationsState(validations: configuration.customDocumentValidations,
										isSwitchOn: false)
	}()
	
	private var settingsViewController: SettingsViewController?
	private var contentData = [SettingsViewController.CellType]()
	
	override func setUp() {
		super.setUp()
        settingsViewController = SettingsViewController(apiEnvironment: .production,
                                                        giniConfiguration: configuration,
														settingsButtonStates: settingsButtonStates,
														documentValidationsState: documentValidationsState)
		
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
        contentData.append(.switchOption(data: .init(type: .skontoNavigationBarBottomAdapter,
                                                     isSwitchOn: configuration.skontoNavigationBarBottomAdapter != nil)))
        contentData.append(.switchOption(data: .init(type: .skontoHelpNavigationBarBottomAdapter,
                                                     isSwitchOn: configuration.skontoHelpNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .helpNavigationBarBottomAdapter,
													 isSwitchOn: configuration.helpNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .cameraNavigationBarBottomAdapter,
													 isSwitchOn: configuration.cameraNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .reviewNavigationBarBottomAdapter,
													 isSwitchOn: configuration.reviewNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .imagePickerNavigationBarBottomAdapter,
													 isSwitchOn: configuration.imagePickerNavigationBarBottomAdapter != nil)))
		
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
        contentData.append(.switchOption(data: .init(type: .digitalInvoiceSkontoNavigationBarBottomAdapter,
                                                     isSwitchOn: configuration.digitalInvoiceSkontoNavigationBarBottomAdapter != nil)))

		contentData.append(.switchOption(data: .init(type: .primaryButtonConfiguration,
													 isSwitchOn: settingsButtonStates.primaryButtonState.isSwitchOn)))
		
		contentData.append(.switchOption(data: .init(type: .secondaryButtonConfiguration,
													 isSwitchOn: settingsButtonStates.secondaryButtonState.isSwitchOn)))
		
		contentData.append(.switchOption(data: .init(type: .transparentButtonConfiguration,
													 isSwitchOn: settingsButtonStates.transparentButtonState.isSwitchOn)))
		
		contentData.append(.switchOption(data: .init(type: .cameraControlButtonConfiguration,
													 isSwitchOn: settingsButtonStates.cameraControlButtonState.isSwitchOn)))
		
		contentData.append(.switchOption(data: .init(type: .addPageButtonConfiguration,
													 isSwitchOn: settingsButtonStates.addPageButtonState.isSwitchOn)))
		contentData.append(.switchOption(data: .init(type: .returnAssistantEnabled,
													 isSwitchOn: configuration.returnAssistantEnabled)))
        contentData.append(.switchOption(data: .init(type: .skontoEnabled,
                                                     isSwitchOn: configuration.skontoEnabled)))
		contentData.append(.switchOption(data: .init(type: .enableReturnReasons,
													 isSwitchOn: configuration.enableReturnReasons)))
		contentData.append(.switchOption(data: .init(type: .customDocumentValidations,
													 isSwitchOn: documentValidationsState.isSwitchOn)))
		contentData.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
													 isSwitchOn: configuration.giniErrorLoggerIsOn)))
		contentData.append(.switchOption(data: .init(type: .customGiniErrorLogger,
													 isSwitchOn: configuration.customGiniErrorLoggerDelegate != nil)))
		contentData.append(.switchOption(data: .init(type: .debugModeOn,
													 isSwitchOn: configuration.debugModeOn)))

        contentData.append(.switchOption(data: .init(type: .customResourceProvider,
                                                     isSwitchOn: configuration.customResourceProvider != nil)))

		var selectedSegmentIndex = 0
		switch configuration.fileImportSupportedTypes {
		case .none:
			selectedSegmentIndex = 0
		case .pdf:
			selectedSegmentIndex = 1
		case .pdf_and_images:
			selectedSegmentIndex = 2
		}
        contentData.append(.segmentedOption(data: FileImportSegmentedOptionModel(selectedIndex: selectedSegmentIndex)))
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
    
    private func giniEntryPoint(selectedIndex: Int) -> GiniCaptureSDK.GiniConfiguration.GiniEntryPoint {
        switch selectedIndex {
        case 0:
            return .button
        case 1:
            return .field
        default:
            return .button
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
			guard case .segmentedOption = section else {
				return false
			}
			return true
		}
	}
    
    private func getEntryPointIndex() -> Int? {
        return contentData.firstIndex { section in
            guard case .segmentedOption = section else {
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
	
	// MARK: - HelpNavigationBarBottomAdapter
	
	func testHelpCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .helpNavigationBarBottomAdapter) else {
			XCTFail("`helpNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .helpNavigationBarBottomAdapter else {
				XCTFail("Expected type `helpNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.helpNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.helpNavigationBarBottomAdapter != nil,
						   "helpNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testHelpCustomNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .helpNavigationBarBottomAdapter) else {
			XCTFail("`helpNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .helpNavigationBarBottomAdapter else {
				XCTFail("Expected type `helpNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomBottomNavigationBarAdapter()
			configuration.helpNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.helpNavigationBarBottomAdapter != nil,
						  "helpNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - CameraNavigationBarBottomAdapter
	
	func testCameraCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .cameraNavigationBarBottomAdapter) else {
			XCTFail("`cameraNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .cameraNavigationBarBottomAdapter else {
				XCTFail("Expected type `cameraNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.cameraNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.cameraNavigationBarBottomAdapter != nil,
						   "cameraNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testCameraCustomNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .cameraNavigationBarBottomAdapter) else {
			XCTFail("`cameraNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .cameraNavigationBarBottomAdapter else {
				XCTFail("Expected type `cameraNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomCameraBottomNavigationBarAdapter()
			configuration.cameraNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.cameraNavigationBarBottomAdapter != nil,
						  "cameraNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - ReviewNavigationBarBottomAdapter
	
	func testReviewCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .reviewNavigationBarBottomAdapter) else {
			XCTFail("`reviewNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .reviewNavigationBarBottomAdapter else {
				XCTFail("Expected type `reviewNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.reviewNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.reviewNavigationBarBottomAdapter != nil,
						   "reviewNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testReviewCustomNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .reviewNavigationBarBottomAdapter) else {
			XCTFail("`reviewNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .reviewNavigationBarBottomAdapter else {
				XCTFail("Expected type `reviewNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomReviewScreenBottomNavigationBarAdapter()
			configuration.reviewNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.reviewNavigationBarBottomAdapter != nil,
						  "reviewNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - imagePickerNavigationBarBottomAdapter
	
	func testImagePickerCustomNavigationBarBottomSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .imagePickerNavigationBarBottomAdapter) else {
			XCTFail("`imagePickerNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .imagePickerNavigationBarBottomAdapter else {
				XCTFail("Expected type `imagePickerNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.imagePickerNavigationBarBottomAdapter = nil
			
			XCTAssertFalse(configuration.imagePickerNavigationBarBottomAdapter != nil,
						   "imagePickerNavigationBarBottomAdapter should not be enabled in the gini configuration")
		}
	}
	
	func testImagePickerNavigationBarBottomSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .imagePickerNavigationBarBottomAdapter) else {
			XCTFail("`imagePickerNavigationBarBottomAdapter` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .imagePickerNavigationBarBottomAdapter else {
				XCTFail("Expected type `imagePickerNavigationBarBottomAdapter`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let customAdapter = CustomBottomNavigationBarAdapter()
			configuration.imagePickerNavigationBarBottomAdapter = customAdapter
			
			XCTAssertTrue(configuration.imagePickerNavigationBarBottomAdapter != nil,
						  "imagePickerNavigationBarBottomAdapter should be enabled in the gini configuration")
		}
	}
	
	// MARK: - File Import options
	
	func testSegmentedControlNone() {
		guard let index = getFileImportOptionIndex() else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
        guard case .segmentedOption(var data) = contentData[index]  else { return }
		data.selectedIndex = 0
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .none,
					   "none types should be supported in the gini configuration")
	}
	
	func testSegmentedControlPDF() {
		guard let index = getFileImportOptionIndex() else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
		guard case .segmentedOption(var data) = contentData[index] else { return }
		data.selectedIndex = 1
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .pdf,
					   "pdf type should be supported in the gini configuration")
	}
	
	func testSegmentedControlPDFAndImages() {
		guard let index = getFileImportOptionIndex() else {
			XCTFail("`fileImportType` option not found in sectionData")
			return
		}
		guard case .segmentedOption(var data) = contentData[index] else { return }
		data.selectedIndex = 2
		configuration.fileImportSupportedTypes = giniImportFileType(selectedIndex: data.selectedIndex)
		XCTAssertEqual(configuration.fileImportSupportedTypes,
					   .pdf_and_images,
					   "pdf and image types should be supported in the gini configuration")
	}

	// MARK: - OnboardingShowAtLaunch
	
	func testOnboardingShowAtLaunchSwitchOff() {
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
	
	func testOnboardingShowAtLaunchSwitchOn() {
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
	
	func testOnboardingCustomNavigationBottomBarSwitchOff() {
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
	
	func testOnboardingCustomNavigationBottomBarSwitchOn() {
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
	
	func testOnboardingMultiPageCustomIllustrationSwitchOff() {
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
	
	func testOnboardingMultiPageCustomIllustrationSwitchOn() {
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
	
	func testOnboardingQRCodeCustomIllustrationSwitchOff() {
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
	
	func testOnboardingQRCodeCustomIllustrationSwitchOn() {
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
	
	func testOnboardingLightingCustomIllustrationSwitchOff() {
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
	
	func testOnboardingLightingCustomIllustrationSwitchOn() {
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
	
	func testOnboardingAlignCornersCustomIllustrationSwitchOff() {
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
	
	func testOnboardingAlignCornersCustomIllustrationSwitchOn() {
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
	
	func testOnboardingShowAtFirstLaunchSwitchOff() {
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
	
	func testOnboardingShowAtFirstLaunchSwitchOn() {
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
	
	func testCustomOnboardingPagesSwitchOff() {
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
	
	func testCustomOnboardingPagesSwitchOn() {
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
	
	func testOnButtonLoadingIndicatorSwitchOff() {
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
	
	func testOnButtonLoadingIndicatorSwitchOn() {
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
	
	func testCustomLoadingIndicatorSwitchOff() {
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
	
	func testCustomLoadingIndicatorSwitchOn() {
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
    
    // MARK: - DigitalInvoiceSkontoNavigationBarBottomAdapter
    
    func testDigitalInvoiceSkontoCustomNavigationBarBottomSwitchOn() {
        guard let index = getSwitchOptionIndex(for: .digitalInvoiceSkontoNavigationBarBottomAdapter) else {
            XCTFail("`digitalInvoiceSkontoNavigationBarBottomAdapter` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .digitalInvoiceSkontoNavigationBarBottomAdapter else {
                XCTFail("Expected type `digitalInvoiceSkontoNavigationBarBottomAdapter`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = true
            let customAdapter = CustomDigitalInvoiceSkontoBottomNavigationBarAdapter()
            configuration.digitalInvoiceSkontoNavigationBarBottomAdapter = customAdapter
            
            XCTAssertTrue(configuration.digitalInvoiceSkontoNavigationBarBottomAdapter != nil,
                          "digitalInvoiceSkontoNavigationBarBottomAdapter should be enabled in the gini configuration")
        }
    }
    
    func testDigitalInvoiceSkontoCustomNavigationBarBottomSwitchOff() {
        guard let index = getSwitchOptionIndex(for: .digitalInvoiceSkontoNavigationBarBottomAdapter) else {
            XCTFail("`digitalInvoiceSkontoNavigationBarBottomAdapter` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .digitalInvoiceSkontoNavigationBarBottomAdapter else {
                XCTFail("Expected type `digitalInvoiceSkontoNavigationBarBottomAdapter`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = false
            configuration.digitalInvoiceSkontoNavigationBarBottomAdapter = nil
            
            XCTAssertFalse(configuration.digitalInvoiceSkontoNavigationBarBottomAdapter != nil,
                           "digitalInvoiceSkontoNavigationBarBottomAdapter should not be enabled in the gini configuration")
        }
    }
    
    // MARK: - SkontoNavigationBarBottomAdapter
    
    func testSkontoNavigationBarBottomSwitchOn() {
        guard let index = getSwitchOptionIndex(for: .skontoNavigationBarBottomAdapter) else {
            XCTFail("`skontoNavigationBarBottomAdapter` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .skontoNavigationBarBottomAdapter else {
                XCTFail("Expected type `skontoNavigationBarBottomAdapter`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = true
            let customAdapter = CustomSkontoNavigationBarBottomAdapter()
            configuration.skontoNavigationBarBottomAdapter = customAdapter
            
            XCTAssertTrue(configuration.skontoNavigationBarBottomAdapter != nil,
                          "skontoNavigationBarBottomAdapter should be enabled in the gini configuration")
        }
    }
    
    func testSkontoNavigationBarBottomSwitchOff() {
        guard let index = getSwitchOptionIndex(for: .skontoNavigationBarBottomAdapter) else {
            XCTFail("`skontoNavigationBarBottomAdapter` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .skontoNavigationBarBottomAdapter else {
                XCTFail("Expected type `skontoNavigationBarBottomAdapter`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = false
            configuration.skontoNavigationBarBottomAdapter = nil
            
            XCTAssertFalse(configuration.skontoNavigationBarBottomAdapter != nil,
                           "skontoNavigationBarBottomAdapter should not be enabled in the gini configuration")
        }
    }
    
    // MARK: - SkontoHelpNavigationBarBottomAdapter
    
    func testSkontoHelpCustomNavigationBarBottomSwitchOff() {
        guard let index = getSwitchOptionIndex(for: .skontoHelpNavigationBarBottomAdapter) else {
            XCTFail("`skontoHelpNavigationBarBottomAdapter` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .skontoHelpNavigationBarBottomAdapter else {
                XCTFail("Expected type `skontoHelpNavigationBarBottomAdapter`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = false
            configuration.skontoHelpNavigationBarBottomAdapter = nil
            
            XCTAssertFalse(configuration.skontoHelpNavigationBarBottomAdapter != nil,
                           "skontoHelpNavigationBarBottomAdapter should not be enabled in the gini configuration")
        }
    }
    
    func testSkontoHelpCustomNavigationBarBottomSwitchOn() {
        guard let index = getSwitchOptionIndex(for: .skontoHelpNavigationBarBottomAdapter) else {
            XCTFail("`skontoHelpNavigationBarBottomAdapter` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .skontoHelpNavigationBarBottomAdapter else {
                XCTFail("Expected type `skontoHelpNavigationBarBottomAdapter`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = true
            let customAdapter = CustomBottomNavigationBarAdapter()
            configuration.skontoHelpNavigationBarBottomAdapter = customAdapter
            
            XCTAssertTrue(configuration.skontoHelpNavigationBarBottomAdapter != nil,
                          "skontoHelpNavigationBarBottomAdapter should be enabled in the gini configuration")
        }
    }
	
	// MARK: - PrimaryButtonConfiguration
	
	func testCustomPrimaryButtonSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .primaryButtonConfiguration) else {
			XCTFail("`primaryButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .primaryButtonConfiguration else {
				XCTFail("Expected type `primaryButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			configuration.primaryButtonConfiguration = buttonConfiguration
			settingsButtonStates.primaryButtonState.isSwitchOn = true
			
			XCTAssertTrue(settingsButtonStates.primaryButtonState.isSwitchOn,
						  "primaryButtonConfiguration should be enabled in the gini configuration")
		}
	}
	
	func testCustomPrimaryButtonSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .primaryButtonConfiguration) else {
			XCTFail("`primaryButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .primaryButtonConfiguration else {
				XCTFail("Expected type `primaryButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.primaryButtonConfiguration = settingsButtonStates.primaryButtonState.configuration
			settingsButtonStates.primaryButtonState.isSwitchOn = false
			
			XCTAssertFalse(settingsButtonStates.primaryButtonState.isSwitchOn,
						   "primaryButtonConfiguration should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - SecondaryButtonConfiguration
	
	func testCustomSecondaryButtonSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .secondaryButtonConfiguration) else {
			XCTFail("`secondaryButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .secondaryButtonConfiguration else {
				XCTFail("Expected type `secondaryButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			configuration.secondaryButtonConfiguration = buttonConfiguration
			settingsButtonStates.secondaryButtonState.isSwitchOn = true
			
			XCTAssertTrue(settingsButtonStates.secondaryButtonState.isSwitchOn,
						  "secondaryButtonConfiguration should be enabled in the gini configuration")
		}
	}
	
	func testCustomSecondaryButtonSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .secondaryButtonConfiguration) else {
			XCTFail("`secondaryButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .secondaryButtonConfiguration else {
				XCTFail("Expected type `secondaryButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.secondaryButtonConfiguration = settingsButtonStates.secondaryButtonState.configuration
			settingsButtonStates.secondaryButtonState.isSwitchOn = false
			
			XCTAssertFalse(settingsButtonStates.secondaryButtonState.isSwitchOn,
						   "secondaryButtonConfiguration should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - TransparentButtonConfiguration
	
	func testCustomTransparentButtonSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .transparentButtonConfiguration) else {
			XCTFail("`transparentButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .transparentButtonConfiguration else {
				XCTFail("Expected type `transparentButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			configuration.transparentButtonConfiguration = buttonConfiguration
			settingsButtonStates.transparentButtonState.isSwitchOn = true
			
			XCTAssertTrue(settingsButtonStates.transparentButtonState.isSwitchOn,
						  "transparentButtonConfiguration should be enabled in the gini configuration")
		}
	}
	
	func testCustomTransparentButtonSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .transparentButtonConfiguration) else {
			XCTFail("`transparentButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .transparentButtonConfiguration else {
				XCTFail("Expected type `transparentButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.transparentButtonConfiguration = settingsButtonStates.transparentButtonState.configuration
			settingsButtonStates.transparentButtonState.isSwitchOn = false
			
			XCTAssertFalse(settingsButtonStates.transparentButtonState.isSwitchOn,
						   "transparentButtonConfiguration should not be enabled in the gini configuration")
		}
	}
	
	
	// MARK: - CameraControlButtonConfiguration
	
	func testCustomCameraButtonSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .cameraControlButtonConfiguration) else {
			XCTFail("`cameraControlButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .cameraControlButtonConfiguration else {
				XCTFail("Expected type `cameraControlButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			configuration.cameraControlButtonConfiguration = buttonConfiguration
			settingsButtonStates.cameraControlButtonState.isSwitchOn = true
			
			XCTAssertTrue(settingsButtonStates.cameraControlButtonState.isSwitchOn,
						  "cameraControlButtonConfiguration should be enabled in the gini configuration")
		}
	}
	
	func testCustomCameraButtonSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .cameraControlButtonConfiguration) else {
			XCTFail("`cameraControlButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .cameraControlButtonConfiguration else {
				XCTFail("Expected type `cameraControlButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.cameraControlButtonConfiguration = settingsButtonStates.cameraControlButtonState.configuration
			settingsButtonStates.cameraControlButtonState.isSwitchOn = false
			
			XCTAssertFalse(settingsButtonStates.cameraControlButtonState.isSwitchOn,
						   "cameraControlButtonConfiguration should not be enabled in the gini configuration")
		}
	}
	
	// MARK: - AddPageButtonConfiguration
	
	func testCustomAddPageButtonSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .addPageButtonConfiguration) else {
			XCTFail("`addPageButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .addPageButtonConfiguration else {
				XCTFail("Expected type `addPageButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			configuration.addPageButtonConfiguration = buttonConfiguration
			settingsButtonStates.addPageButtonState.isSwitchOn = true
			
			XCTAssertTrue(settingsButtonStates.addPageButtonState.isSwitchOn,
						  "addPageButtonConfiguration should be enabled in the gini configuration")
		}
	}
	
	func testCustomAddPageButtonSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .addPageButtonConfiguration) else {
			XCTFail("`addPageButtonConfiguration` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .addPageButtonConfiguration else {
				XCTFail("Expected type `addPageButtonConfiguration`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.addPageButtonConfiguration = settingsButtonStates.addPageButtonState.configuration
			settingsButtonStates.addPageButtonState.isSwitchOn = false
			
			XCTAssertFalse(settingsButtonStates.addPageButtonState.isSwitchOn,
						   "addPageButtonConfiguration should not be enabled in the gini configuration")
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
    
    // MARK: - Skonto
    
    func testSkontoSwitchOn() {
        guard let index = getSwitchOptionIndex(for: .skontoEnabled) else {
            XCTFail("`skontoEnabled` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .skontoEnabled else {
                XCTFail("Expected type `skontoEnabled`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = true
            configuration.skontoEnabled = data.isSwitchOn
            
            XCTAssertTrue(configuration.skontoEnabled,
                          "skontoEnabled should be enabled in the gini configuration")
        }
    }
    
    func testSkontoSwitchOff() {
        guard let index = getSwitchOptionIndex(for: .skontoEnabled) else {
            XCTFail("`skontoEnabled` option not found in sectionData")
            return
        }
        
        if case .switchOption(var data) = contentData[index] {
            guard data.type == .skontoEnabled else {
                XCTFail("Expected type `skontoEnabled`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = false
            configuration.skontoEnabled = data.isSwitchOn
            
            XCTAssertFalse(configuration.skontoEnabled,
                           "skontoEnabled should not be enabled in the gini configuration")
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
	
	// MARK: - CustomDocumentValidations
	
	func testCustomDocumentValidationsSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .customDocumentValidations) else {
			XCTFail("`customDocumentValidations` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customDocumentValidations else {
				XCTFail("Expected type `customDocumentValidations`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true

			configuration.customDocumentValidations = { document in
				// As an example of custom document validation, we add a more strict check for file size
				let maxFileSize = 0.5 * 1024 * 1024
				if document.data.count > Int(maxFileSize) {
					let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als \(maxFileSize)MB")
					return CustomDocumentValidationResult.failure(withError: error)
				}
				return CustomDocumentValidationResult.success()
			}
			documentValidationsState.isSwitchOn = true
			
			XCTAssertTrue(documentValidationsState.isSwitchOn,
						  "customDocumentValidations should be enabled in the gini configuration")
		}
	}
	
	func testCustomDocumentValidationsSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .customDocumentValidations) else {
			XCTFail("`customDocumentValidations` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customDocumentValidations else {
				XCTFail("Expected type `customDocumentValidations`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.customDocumentValidations = documentValidationsState.validations
			documentValidationsState.isSwitchOn = false
			
			XCTAssertFalse(documentValidationsState.isSwitchOn,
						   "customDocumentValidations should not be enabled in the gini configuration")
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
	
	// MARK: - CustomGiniErrorLogger
	
	func testCustomGiniErrorLoggerSwitchOn() {
		guard let index = getSwitchOptionIndex(for: .customGiniErrorLogger) else {
			XCTFail("`customGiniErrorLogger` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customGiniErrorLogger else {
				XCTFail("Expected type `customGiniErrorLogger`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = true
			configuration.customGiniErrorLoggerDelegate = self
			
			XCTAssertTrue(configuration.customGiniErrorLoggerDelegate != nil,
						  "customGiniErrorLogger should be enabled in the gini configuration")
		}
	}
	
	func testCustomGiniErrorLoggerSwitchOff() {
		guard let index = getSwitchOptionIndex(for: .customGiniErrorLogger) else {
			XCTFail("`customGiniErrorLogger` option not found in sectionData")
			return
		}
		
		if case .switchOption(var data) = contentData[index] {
			guard data.type == .customGiniErrorLogger else {
				XCTFail("Expected type `customGiniErrorLogger`, found a different one: \(data.type)")
				return
			}
			data.isSwitchOn = false
			configuration.customGiniErrorLoggerDelegate = nil
			
			XCTAssertFalse(configuration.customGiniErrorLoggerDelegate != nil,
						   "customGiniErrorLogger should not be enabled in the gini configuration")
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

    // MARK: - GiniBankCustomResourceProvider

    func testCustomResourceProvider() {
        guard let index = getSwitchOptionIndex(for: .customResourceProvider) else {
            XCTFail("`customResourceProvider` option not found in sectionData")
            return
        }

        if case .switchOption(var data) = contentData[index] {
            guard data.type == .customResourceProvider else {
                XCTFail("Expected type `customResourceProvider`, found a different one: \(data.type)")
                return
            }
            data.isSwitchOn = true
            let customProvider = GiniBankCustomResourceProvider()
            configuration.customResourceProvider = customProvider

            XCTAssertTrue(configuration.customResourceProvider != nil,
                          "customResourceProvider should be enabled in the gini configuration")
        }
    }

}

extension SettingsViewControllerTests: GiniCaptureErrorLoggerDelegate {
	func handleErrorLog(error: GiniCaptureSDK.ErrorLog) {
		print("💻 custom - log error event called")
	}
}
