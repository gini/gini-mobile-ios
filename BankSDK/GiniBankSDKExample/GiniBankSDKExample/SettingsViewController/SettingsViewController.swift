//
//  SettingsViewController.swift
//  GiniBankSDKExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary
import GiniBankSDK
import GiniCaptureSDK
import AVFoundation

protocol SettingsViewControllerDelegate: AnyObject {
	func didTapCloseButton()
    func didTapSaveCredentialsButton(clientId: String, clientSecret: String)
    func didSelectAPIEnvironment(apiEnvironment: APIEnvironment)
}

final class SettingsViewController: UIViewController {

	@IBOutlet private weak var navigationBarItem: UINavigationItem!
	@IBOutlet private weak var navigationBar: UINavigationBar!
	@IBOutlet private weak var tableView: UITableView!

    private let client: Client?
    private var apiEnvironment: APIEnvironment

	var contentData = [CellType]()
	let giniConfiguration: GiniBankConfiguration
	var settingsButtonStates: SettingsButtonStates
	var documentValidationsState: DocumentValidationsState
	
	weak var delegate: SettingsViewControllerDelegate?
	
	// MARK: - Initializers
     
    init(apiEnvironment: APIEnvironment,
         client: Client? = nil,
         giniConfiguration: GiniBankConfiguration,
         settingsButtonStates: SettingsButtonStates,
         documentValidationsState: DocumentValidationsState) {
        self.apiEnvironment = apiEnvironment
        self.client = client
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
        setupGestures()
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        tableView.register(CredentialsTableViewCell.self)
        tableView.register(UpdateUserDefaultsCell.self)

		var contentData = [CellType]()
		
		contentData.append(.info(message: "Please relaunch the app to use the default GiniConfiguration values."))
        var selectedAPISegmentIndex = 0
        switch apiEnvironment {
        case .production:
            selectedAPISegmentIndex = 0
        case .stage:
            selectedAPISegmentIndex = 1
        }
        contentData.append(.segmentedOption(data: APIEnvironmentSegmentedOptionModel(selectedIndex: selectedAPISegmentIndex)))
        contentData.append(.credentials(data: .init(clientId: client?.id ?? "", secretId: client?.secret ?? "")))
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
        contentData.append(.switchOption(data: .init(type: .customResourceProvider,
                                                     isSwitchOn: giniConfiguration.customResourceProvider != nil)))
		var selectedFileImportTypeSegmentIndex = 0
		switch giniConfiguration.fileImportSupportedTypes {
		case .none:
			selectedFileImportTypeSegmentIndex = 0
		case .pdf:
			selectedFileImportTypeSegmentIndex = 1
		case .pdf_and_images:
			selectedFileImportTypeSegmentIndex = 2
		}
        contentData.append(.segmentedOption(data: FileImportSegmentedOptionModel(selectedIndex: selectedFileImportTypeSegmentIndex)))
		
		contentData.append(.switchOption(data: .init(type: .bottomNavigationBar,
													 isSwitchOn: giniConfiguration.bottomNavigationBarEnabled)))

        contentData.append(.switchOption(data: .init(type: .skontoNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.skontoNavigationBarBottomAdapter != nil)))
        contentData.append(.switchOption(data: .init(type: .skontoHelpNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.skontoHelpNavigationBarBottomAdapter != nil)))

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
		
        contentData.append(.switchOption(data: .init(type: .transactionDocsEnabled,
                                                     isSwitchOn: giniConfiguration.transactionDocsEnabled)))

        //TODO: need to rethink this because this is related to customer internal option to store and reset Gini setting ???!!!!
        // in Gini is saved in UserDefaults as object and not primitive so for that the approach below is not working, but should
        // customers know how we implemented? in case we switch to our backend this it will not work entirely
        print("DEBUG ----- UserDefaultsStorage.attachmentOption =", UserDefaultsStorage.attachmentOption ?? false)
        contentData.append(.userDefaults(message: "Remove TransactionDocs attachement options from UserDefaults",
                                         buttonActive: UserDefaultsStorage.attachmentOption ?? false))

        contentData.append(.switchOption(data: .init(type: .skontoEnabled,
                                                     isSwitchOn: giniConfiguration.skontoEnabled)))

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
        contentData.append(.switchOption(data: .init(type: .digitalInvoiceSkontoNavigationBarBottomAdapter,
                                                     isSwitchOn: giniConfiguration.digitalInvoiceSkontoNavigationBarBottomAdapter != nil)))

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
        case .customResourceProvider:
            let customProvider = GiniBankCustomResourceProvider()
            giniConfiguration.customResourceProvider = data.isSwitchOn ? customProvider : nil
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
            let customPage1 = OnboardingPage(imageName: "captureSuggestion1",
                                             title: "Page 1",
                                             description: "Description for page 1")
            let customPage2 = OnboardingPage(imageName: "captureSuggestion2",
                                             title: "Page 2",
                                             description: "Description for page 2")
            let customPage3 = OnboardingPage(imageName: "captureSuggestion3",
                                             title: "Page 3",
                                             description: "Description for page 3")
            let customPage4 = OnboardingPage(imageName: "captureSuggestion4",
                                             title: "Page 4",
                                             description: "Description for page 4")
            let customPage5 = OnboardingPage(imageName: "captureSuggestion1",
                                             title: "Page 5",
                                             description: "Description for page 5")
			let customOnboardingPages = data.isSwitchOn ? [customPage1, customPage2, customPage3, customPage4, customPage5] : nil
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
        case .skontoEnabled:
            giniConfiguration.skontoEnabled = data.isSwitchOn
        case .transactionDocsEnabled:
            giniConfiguration.transactionDocsEnabled = data.isSwitchOn
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
        case .digitalInvoiceSkontoNavigationBarBottomAdapter:
            let customAdapter = CustomDigitalInvoiceSkontoBottomNavigationBarAdapter()
            giniConfiguration.digitalInvoiceSkontoNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
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
        case .skontoNavigationBarBottomAdapter:
            let customAdapter = CustomSkontoNavigationBarBottomAdapter()
            giniConfiguration.skontoNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
        case .skontoHelpNavigationBarBottomAdapter:
            let customAdapter = CustomBottomNavigationBarAdapter()
            giniConfiguration.skontoHelpNavigationBarBottomAdapter = data.isSwitchOn ? customAdapter : nil
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

	private func cell(for optionModel: SegmentedOptionModelProtocol, at row: Int) -> UITableViewCell {
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

    private func cell(for model: CredentialsModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as CredentialsTableViewCell
        cell.set(data: model)
        cell.delegate = self
        return cell
    }

    private func userDefaultsCell(for message: String, _ buttoActive: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as UpdateUserDefaultsCell
        cell.set(message: message, buttonActive: buttoActive)
        cell.delegate = self
        return cell
    }

	// MARK: - Actions
	
	@objc func didSelectCloseButton() {
		delegate?.didTapCloseButton()
	}

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        case .credentials(let data):
            return cell(for: data)
        case .userDefaults(let message, let buttoActive):
            return userDefaultsCell(for: message, buttoActive)
		}
	}
}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        
        if data is FileImportSegmentedOptionModel {
            handleFileImportOption(fileImportIndex: data.selectedIndex)
        } else if data is APIEnvironmentSegmentedOptionModel {
            handleApiEnvironmentOption(environmentIndex: data.selectedIndex)
        }
	}

    func handleFileImportOption(fileImportIndex: Int) {
        switch fileImportIndex {
        case 0:
            giniConfiguration.fileImportSupportedTypes = .none
        case 1:
            giniConfiguration.fileImportSupportedTypes = .pdf
        case 2:
            giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        default: return
        }
    }

    func handleApiEnvironmentOption(environmentIndex: Int) {
        switch environmentIndex {
        case 0:
            delegate?.didSelectAPIEnvironment(apiEnvironment: .production)
        case 1:
            delegate?.didSelectAPIEnvironment(apiEnvironment: .stage)
        default:
            return
        }
    }
}

// MARK: - CredentialsTableViewCellDelegate

extension SettingsViewController: CredentialsTableViewCellDelegate {
    func didTapSaveButton(clientId: String, clientSecret: String) {
        dismissKeyboard()
        delegate?.didTapSaveCredentialsButton(clientId: clientId, clientSecret: clientSecret)
    }
}

extension SettingsViewController: GiniCaptureErrorLoggerDelegate {
	func handleErrorLog(error: GiniCaptureSDK.ErrorLog) {
		print("💻 custom - log error event called")
	}
}

extension SettingsViewController: UpdateUserDefaultsCellDelegate {
    func didTapRemoveButton(in view: UpdateUserDefaultsCell) {
        //TODO: need to rethink this because this is related to customer internal option to store and reset Gini setting ???!!!!
        // in Gini is saved in UserDefaults as object and not primitive so for that the approach below is not working, but should
        // customers know how we implemented? in case we switch to our backend this it will not work entirely

        let isAttachmentOptionEnabled = UserDefaultsStorage.attachmentOption ?? false
        if isAttachmentOptionEnabled {
            UserDefaultsStorage.removeAttachmentOption()
            view.updateButtonState(isActive: false)
            // Show confirmation alert
            let alert = UIAlertController(title: "Success",
                                          message: "The preference was successfully removed.",
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            // Present the alert on the provided viewController
            present(alert, animated: true, completion: nil)
        }
    }
}
