//
//  SettingsViewController.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 07.06.23.
//

import UIKit
import GiniBankSDK
import GiniCaptureSDK
import AVFoundation

protocol SettingsViewControllerDelegate: AnyObject {
	func didTapCloseButton()
}

final class SettingsViewController: UIViewController {

	@IBOutlet private weak var navigationBarItem: UINavigationItem!
	@IBOutlet private weak var navigationBar: UINavigationBar!
	@IBOutlet private weak var tableView: UITableView!
	
	var contentData = [CellType]()
	let giniConfiguration: GiniBankConfiguration
	var settingsButtonStates: SettingsButtonStates
	var documentValidationsState: DocumentValidationsState
	
	weak var delegate: SettingsViewControllerDelegate?
	
	// MARK: - Initializers
	
	init(giniConfiguration: GiniBankConfiguration,
		 settingsButtonStates: SettingsButtonStates,
		 documentValidationsState: DocumentValidationsState) {
		self.giniConfiguration = giniConfiguration
		self.settingsButtonStates = settingsButtonStates
		self.documentValidationsState = documentValidationsState
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		configureNavigationBar()
		configureTableView()
    }

	private func configureNavigationBar() {
		navigationBar.isTranslucent = false
		navigationBar.tintColor = ColorPalette.raspberryPunch
		let closeButton = UIBarButtonItem(title: "Close",
										  style: .plain,
										  target: nil,
										  action: #selector(didSelectCloseButton))
		closeButton.target = self
		navigationBarItem.leftBarButtonItem = closeButton
	}

	private func configureTableView() {
		tableView.dataSource = self
		
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.showsVerticalScrollIndicator = false
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 65
		
		if #available(iOS 15.0, *) {
			tableView.sectionHeaderTopPadding = 0
		}
		
		tableView.register(SwitchOptionTableViewCell.self)
		tableView.register(SegmentedOptionTableViewCell.self)
		tableView.register(InfoTableViewCell.self)

		var contentData = [CellType]()
		
		contentData.append(.info(message: "Please relaunch the app to use the default GiniConfiguration values."))
		contentData.append(.switchOption(data: .init(type: .openWith,
													 isSwitchOn: giniConfiguration.openWithEnabled)))
		contentData.append(.switchOption(data: .init(type: .qrCodeScanning,
													 isSwitchOn: giniConfiguration.qrCodeScanningEnabled)))
		contentData.append(.switchOption(data: .init(type: .qrCodeScanningOnly,
													 isSwitchOn: giniConfiguration.onlyQRCodeScanningEnabled)))
		contentData.append(.switchOption(data: .init(type: .multipage,
													 isSwitchOn: giniConfiguration.multipageEnabled)))
		if flashToggleSettingEnabled {
			contentData.append(.switchOption(data: .init(type: .flashToggle,
														 isSwitchOn: giniConfiguration.flashToggleEnabled)))
			contentData.append(.switchOption(data: .init(type: .flashOnByDefault,
														 isSwitchOn: giniConfiguration.flashOnByDefault)))
		}
		
		var selectedFileImportTypeSegmentIndex = 0
		switch giniConfiguration.fileImportSupportedTypes {
		case .none:
			selectedFileImportTypeSegmentIndex = 0
		case .pdf:
			selectedFileImportTypeSegmentIndex = 1
		case .pdf_and_images:
			selectedFileImportTypeSegmentIndex = 2
		}
        contentData.append(.segmentedOption(data: .init(optionType: .fileImport, selectedIndex: selectedFileImportTypeSegmentIndex)))
		
		contentData.append(.switchOption(data: .init(type: .bottomNavigationBar,
													 isSwitchOn: giniConfiguration.bottomNavigationBarEnabled)))
		
		contentData.append(.switchOption(data: .init(type: .helpNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.helpNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .cameraNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.cameraNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .reviewNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.reviewNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .imagePickerNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.imagePickerNavigationBarBottomAdapter != nil)))

		contentData.append(.switchOption(data: .init(type: .onboardingShowAtLaunch,
													 isSwitchOn: giniConfiguration.onboardingShowAtLaunch)))
		contentData.append(.switchOption(data: .init(type: .onboardingShowAtFirstLaunch,
													 isSwitchOn: giniConfiguration.onboardingShowAtFirstLaunch)))
		contentData.append(.switchOption(data: .init(type: .customOnboardingPages,
													 isSwitchOn: giniConfiguration.customOnboardingPages != nil)))

		contentData.append(.switchOption(data: .init(type: .onboardingAlignCornersIllustrationAdapter,
													 isSwitchOn: giniConfiguration.onboardingAlignCornersIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingLightingIllustrationAdapter,
													 isSwitchOn: giniConfiguration.onboardingLightingIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingQRCodeIllustrationAdapter,
													 isSwitchOn: giniConfiguration.onboardingQRCodeIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingMultiPageIllustrationAdapter,
													 isSwitchOn: giniConfiguration.onboardingMultiPageIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .onboardingNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.onboardingNavigationBarBottomAdapter != nil)))
		
		contentData.append(.switchOption(data: .init(type: .onButtonLoadingIndicator,
													 isSwitchOn: giniConfiguration.onButtonLoadingIndicator != nil)))
		contentData.append(.switchOption(data: .init(type: .customLoadingIndicator,
													 isSwitchOn: giniConfiguration.customLoadingIndicator != nil)))

		contentData.append(.switchOption(data: .init(type: .shouldShowSupportedFormatsScreen,
													 isSwitchOn: giniConfiguration.shouldShowSupportedFormatsScreen)))
		contentData.append(.switchOption(data: .init(type: .customMenuItems,
													 isSwitchOn: !giniConfiguration.customMenuItems.isEmpty)))

		contentData.append(.switchOption(data: .init(type: .customNavigationController,
													 isSwitchOn: giniConfiguration.customNavigationController != nil)))
		if UIDevice.current.isIpad {
			contentData.append(.switchOption(data: .init(type: .shouldShowDragAndDropTutorial,
														 isSwitchOn: giniConfiguration.shouldShowDragAndDropTutorial)))
		}
		
		contentData.append(.switchOption(data: .init(type: .returnAssistantEnabled,
													 isSwitchOn: giniConfiguration.returnAssistantEnabled)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingIllustrationAdapter,
													 isSwitchOn: giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceHelpNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.digitalInvoiceHelpNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceOnboardingNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.digitalInvoiceOnboardingNavigationBarBottomAdapter != nil)))
		contentData.append(.switchOption(data: .init(type: .digitalInvoiceNavigationBarBottomAdapter,
													 isSwitchOn: giniConfiguration.digitalInvoiceNavigationBarBottomAdapter != nil)))

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

		contentData.append(.switchOption(data: .init(type: .enableReturnReasons,
													 isSwitchOn: giniConfiguration.enableReturnReasons)))
		
		contentData.append(.switchOption(data: .init(type: .customDocumentValidations,
													 isSwitchOn: documentValidationsState.isSwitchOn)))
		
		// Add debug or development options at the end in the list
		
		contentData.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
													 isSwitchOn: giniConfiguration.giniErrorLoggerIsOn)))
		contentData.append(.switchOption(data: .init(type: .customGiniErrorLogger,
													 isSwitchOn: giniConfiguration.customGiniErrorLoggerDelegate != nil)))
		
		contentData.append(.switchOption(data: .init(type: .debugModeOn,
													 isSwitchOn: giniConfiguration.debugModeOn)))
        var selectedEntryPointSegmentIndex = 0
        switch giniConfiguration.entryPoint {
        case .button:
            selectedEntryPointSegmentIndex = 0
        case .field:
            selectedEntryPointSegmentIndex = 1
        }
        contentData.append(.segmentedOption(data: .init(optionType: .entryPoint, selectedIndex: selectedEntryPointSegmentIndex)))

		
		self.contentData = contentData
	}
	
	private var flashToggleSettingEnabled: Bool = {
		#if targetEnvironment(simulator)
			return true
		#else
			return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)?.hasFlash ?? false
		#endif
	}()
	
	private func handleOnToggle(in cell: SwitchOptionTableViewCell) {
		let option = contentData[cell.tag]
		guard case .switchOption(var data) = option else { return }
		data.isSwitchOn = cell.isSwitchOn
		contentData[cell.tag] = .switchOption(data:(SwitchOptionModel(type: data.type, isSwitchOn: data.isSwitchOn)))
		switch data.type {
		case .openWith:
			giniConfiguration.openWithEnabled = data.isSwitchOn
		case .qrCodeScanning:
			giniConfiguration.qrCodeScanningEnabled = data.isSwitchOn
			giniConfiguration.flashToggleEnabled = data.isSwitchOn
			if !data.isSwitchOn && giniConfiguration.flashOnByDefault {
				// if `qrCodeScanningEnabled` is disabled and `onlyQRCodeScanningEnabled` is enabled,
				// make `onlyQRCodeScanningEnabled` disabled
				// onlyQRCodeScanningEnabled cell is right after
				guard let cell = getSwitchOptionCell(at: cell.tag + 1) as? SwitchOptionTableViewCell else { return }
				cell.isSwitchOn = data.isSwitchOn
				giniConfiguration.onlyQRCodeScanningEnabled = data.isSwitchOn
			}
		case .qrCodeScanningOnly:
			giniConfiguration.onlyQRCodeScanningEnabled = data.isSwitchOn
			if data.isSwitchOn && !giniConfiguration.flashToggleEnabled {
				// if `onlyQRCodeScanningEnabled` is enabled and `qrCodeScanningEnabled` is disabled, make `qrCodeScanningEnabled` enabled
				// qrCodeScanningEnabled cell is right above this
				guard let cell = getSwitchOptionCell(at: cell.tag - 1) as? SwitchOptionTableViewCell else { return }
				cell.isSwitchOn = data.isSwitchOn
				giniConfiguration.qrCodeScanningEnabled = data.isSwitchOn
			}
		case .multipage:
			giniConfiguration.multipageEnabled = data.isSwitchOn
		case .flashToggle:
			giniConfiguration.flashToggleEnabled = data.isSwitchOn
			if !data.isSwitchOn && giniConfiguration.flashOnByDefault {
				// if `flashToggle` is disabled and `flashOnByDefault` is enabled, make `flashOnByDefault` disabled
				// flashOnByDefault cell is right after
				guard let cell = getSwitchOptionCell(at: cell.tag + 1) as? SwitchOptionTableViewCell else { return }
				cell.isSwitchOn = data.isSwitchOn
				giniConfiguration.flashOnByDefault = data.isSwitchOn
			}
		case .flashOnByDefault:
			giniConfiguration.flashOnByDefault = data.isSwitchOn
			if data.isSwitchOn && !giniConfiguration.flashToggleEnabled {
				// if `flashOnByDefault` is enabled and `flashToggle` is disabled, make `flashToggle` enabled
				// flashToggle cell is right above this
				guard let cell = getSwitchOptionCell(at: cell.tag - 1) as? SwitchOptionTableViewCell else { return }
				cell.isSwitchOn = data.isSwitchOn
				giniConfiguration.flashToggleEnabled = data.isSwitchOn
			}
		case .bottomNavigationBar:
			giniConfiguration.bottomNavigationBarEnabled = data.isSwitchOn
		case .helpNavigationBarBottomAdapter:
			let customAdapter = CustomBottomNavigationBarAdapter()
			giniConfiguration.helpNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .cameraNavigationBarBottomAdapter:
			let customAdapter = CustomCameraBottomNavigationBarAdapter()
			giniConfiguration.cameraNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .reviewNavigationBarBottomAdapter:
			let customAdapter = CustomReviewScreenBottomNavigationBarAdapter()
			giniConfiguration.reviewNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .imagePickerNavigationBarBottomAdapter:
			let customAdapter = CustomBottomNavigationBarAdapter()
			giniConfiguration.imagePickerNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .onboardingShowAtLaunch:
			giniConfiguration.onboardingShowAtLaunch = data.isSwitchOn
		case .onboardingShowAtFirstLaunch:
			giniConfiguration.onboardingShowAtFirstLaunch = data.isSwitchOn
			let onboardingShowedUserDefault = UserDefaults.standard.bool(forKey: "ginicapture.defaults.onboardingShowed")
			if !data.isSwitchOn && onboardingShowedUserDefault {
				UserDefaults.standard.removeObject(forKey: "ginicapture.defaults.onboardingShowed")
			}
		case .customOnboardingPages:
			let customPage = OnboardingPage(imageName: "captureSuggestion1",
											title: "Page 1",
											description: "Description for page 1")
			let customOnboardingPages = data.isSwitchOn ? [customPage] : nil
			giniConfiguration.customOnboardingPages = customOnboardingPages
		case .onboardingAlignCornersIllustrationAdapter:
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "page1Animation",
																	backgroundColor: .red)
			giniConfiguration.onboardingAlignCornersIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
		case .onboardingLightingIllustrationAdapter:
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "cameraAnimation",
																	backgroundColor: .yellow)
			giniConfiguration.onboardingLightingIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
		case .onboardingQRCodeIllustrationAdapter:
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
																	backgroundColor: .blue)
			giniConfiguration.onboardingQRCodeIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
		case .onboardingMultiPageIllustrationAdapter:
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "uploadAnimation",
																	backgroundColor: .green)
			giniConfiguration.onboardingMultiPageIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
		case .onboardingNavigationBarBottomAdapter:
			let customAdapter = CustomOnboardingBottomNavigationBarAdapter()
			giniConfiguration.onboardingNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .onButtonLoadingIndicator:
			giniConfiguration.onButtonLoadingIndicator = data.isSwitchOn ? OnButtonLoading() : nil
		case .customLoadingIndicator:
			giniConfiguration.customLoadingIndicator = data.isSwitchOn ? CustomLoadingIndicator() : nil
		case .shouldShowSupportedFormatsScreen:
			giniConfiguration.shouldShowSupportedFormatsScreen = data.isSwitchOn
		case .customMenuItems:
			let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())
			giniConfiguration.customMenuItems = data.isSwitchOn ? [customMenuItem] : []
		case .customNavigationController:
			let navigationViewController = UINavigationController()
			navigationViewController.navigationBar.backgroundColor = GiniColor(light: .purple, dark: .lightGray).uiColor()
			giniConfiguration.customNavigationController = data.isSwitchOn ? navigationViewController : nil
		case .shouldShowDragAndDropTutorial:
			giniConfiguration.shouldShowDragAndDropTutorial = data.isSwitchOn
		case .returnAssistantEnabled:
			giniConfiguration.returnAssistantEnabled = data.isSwitchOn
		case .enableReturnReasons:
			giniConfiguration.enableReturnReasons = data.isSwitchOn
		case .giniErrorLoggerIsOn:
			giniConfiguration.giniErrorLoggerIsOn = data.isSwitchOn
		case .customGiniErrorLogger:
			if data.isSwitchOn && giniConfiguration.giniErrorLoggerIsOn {
				giniConfiguration.customGiniErrorLoggerDelegate = self
			} else {
				giniConfiguration.customGiniErrorLoggerDelegate = nil
			}
			
		case .debugModeOn:
			giniConfiguration.debugModeOn = data.isSwitchOn
		case .digitalInvoiceOnboardingIllustrationAdapter:
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
																	backgroundColor: UIColor.blue)
			giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter = data.isSwitchOn ? customAdapter : nil
		case .digitalInvoiceHelpNavigationBarBottomAdapter:
			let customAdapter = CustomBottomNavigationBarAdapter()
			giniConfiguration.digitalInvoiceHelpNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .digitalInvoiceOnboardingNavigationBarBottomAdapter:
			let customAdapter = CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter()
			giniConfiguration.digitalInvoiceOnboardingNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .digitalInvoiceNavigationBarBottomAdapter:
			let customAdapter = CustomDigitalInvoiceBottomNavigationBarAdapter()
			giniConfiguration.digitalInvoiceNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
		case .primaryButtonConfiguration:
			guard data.isSwitchOn else {
				giniConfiguration.primaryButtonConfiguration = settingsButtonStates.primaryButtonState.configuration
				return
			}
			settingsButtonStates.primaryButtonState.isSwitchOn = data.isSwitchOn
			
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			giniConfiguration.primaryButtonConfiguration = buttonConfiguration
		case .secondaryButtonConfiguration:
			guard data.isSwitchOn else {
				giniConfiguration.secondaryButtonConfiguration = settingsButtonStates.secondaryButtonState.configuration
				return
			}
			settingsButtonStates.secondaryButtonState.isSwitchOn = data.isSwitchOn
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .cyan,
														  borderColor: .blue,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			giniConfiguration.secondaryButtonConfiguration = buttonConfiguration
		case .transparentButtonConfiguration:
			guard data.isSwitchOn else {
				giniConfiguration.transparentButtonConfiguration = settingsButtonStates.transparentButtonState.configuration
				return
			}
			settingsButtonStates.transparentButtonState.isSwitchOn = data.isSwitchOn
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .green,
														  borderColor: .yellow,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			giniConfiguration.transparentButtonConfiguration = buttonConfiguration
		case .cameraControlButtonConfiguration:
			guard data.isSwitchOn else {
				giniConfiguration.cameraControlButtonConfiguration = settingsButtonStates.cameraControlButtonState.configuration
				return
			}
			settingsButtonStates.cameraControlButtonState.isSwitchOn = data.isSwitchOn
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .magenta,
														  borderColor: .lightGray,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			giniConfiguration.cameraControlButtonConfiguration = buttonConfiguration
		case .addPageButtonConfiguration:
			guard data.isSwitchOn else {
				giniConfiguration.addPageButtonConfiguration = settingsButtonStates.addPageButtonState.configuration
				return
			}
			settingsButtonStates.addPageButtonState.isSwitchOn = data.isSwitchOn
			let buttonConfiguration = ButtonConfiguration(backgroundColor: .white,
														  borderColor: .red,
														  titleColor: .green,
														  shadowColor: .clear,
														  cornerRadius: 22,
														  borderWidth: 4,
														  shadowRadius: 0,
														  withBlurEffect: false)
			giniConfiguration.addPageButtonConfiguration = buttonConfiguration
		case .customDocumentValidations:
			guard data.isSwitchOn else {
				giniConfiguration.customDocumentValidations = documentValidationsState.validations
				return
			}
			documentValidationsState.isSwitchOn = data.isSwitchOn
			giniConfiguration.customDocumentValidations = { document in
				// As an example of custom document validation, we add a more strict check for file size
				let maxFileSize = 0.5 * 1024 * 1024
				if document.data.count > Int(maxFileSize) {
					let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als \(maxFileSize)MB")
					return CustomDocumentValidationResult.failure(withError: error)
				}
				return CustomDocumentValidationResult.success()
			}
		}
	}
	
	private func getSwitchOptionCell(at row: Int) -> UITableViewCell? {
		let indexPath = IndexPath(row: row, section: 0)
		 return tableView.cellForRow(at: indexPath)
	}
	
	private func cell(for optionModel: SwitchOptionModel, at row: Int) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell() as SwitchOptionTableViewCell
		cell.tag = row
		let model = SwitchOptionModelCell(title: optionModel.type.title,
										  active: optionModel.isSwitchOn,
										  message: optionModel.type.message)
		cell.set(data: model)
		cell.delegate = self
		return cell
	}

	private func cell(for optionModel: SegmentedOptionModel, at row: Int) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell() as SegmentedOptionTableViewCell
		cell.tag = row
		
		let model = SegmentedOptionCellModel(title: optionModel.title,
                                             items: optionModel.items,
											 selectedIndex: optionModel.selectedIndex)
		cell.set(data: model)
		cell.delegate = self
		return cell
	}
	
	private func cell(for message: String) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell() as InfoTableViewCell
		cell.set(message: message)
		return cell
	}
	
	// MARK: - Actions
	
	@objc func didSelectCloseButton() {
		delegate?.didTapCloseButton()
	}
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contentData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		switch contentData[row] {
		case .info(let message):
			return cell(for: message)
		case .switchOption(let data):
			return cell(for: data, at: row)
		case .segmentedOption(let data):
			return cell(for: data, at: row)
		}
	}
}

// MARK: - SwitchOptionTableViewCellDelegate

extension SettingsViewController: SwitchOptionTableViewCellDelegate {
	func didToggleOption(in cell: SwitchOptionTableViewCell) {
		handleOnToggle(in: cell)
	}
}

// MARK: - SegmentedOptionTableViewCellDelegate

extension SettingsViewController: SegmentedOptionTableViewCellDelegate {
	func didSegmentedControlValueChanged(in cell: SegmentedOptionTableViewCell) {
		let option = contentData[cell.tag]
		guard case .segmentedOption(var data) = option else { return }
        data.selectedIndex = cell.selectedSegmentIndex

        switch data.optionType {
        case .fileImport:
            switch data.selectedIndex {
            case 0:
                giniConfiguration.fileImportSupportedTypes = .none
            case 1:
                giniConfiguration.fileImportSupportedTypes = .pdf
            case 2:
                giniConfiguration.fileImportSupportedTypes = .pdf_and_images
            default: return
        }
            
        case .entryPoint:
            switch data.selectedIndex {
            case 0:
                giniConfiguration.entryPoint = .button
            case 1:
                giniConfiguration.entryPoint = .field
            default:
                return
            }
        }
	}
}

extension SettingsViewController: GiniCaptureErrorLoggerDelegate {
	func handleErrorLog(error: GiniCaptureSDK.ErrorLog) {
		print("💻 custom - log error event called")
	}
}
