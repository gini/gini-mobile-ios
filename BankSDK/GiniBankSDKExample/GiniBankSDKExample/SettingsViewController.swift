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
	func settings(settingViewController: SettingsViewController,
				  didChangeConfiguration configuration: GiniBankConfiguration)
}

final class SettingsViewController: UIViewController {

	@IBOutlet private weak var navigationBarItem: UINavigationItem!
	@IBOutlet private weak var navigationBar: UINavigationBar!
	@IBOutlet private weak var tableView: UITableView!
	
	var contentData = [CellType]()
	let giniConfiguration: GiniBankConfiguration
	
	weak var delegate: SettingsViewControllerDelegate?
	
	// MARK: - Initializers
	
	init(giniConfiguration: GiniBankConfiguration) {
		self.giniConfiguration = giniConfiguration
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

		let closeButton = UIBarButtonItem(image: UIImageNamedPreferred(named: "close"),
										  style: .plain,
										  target: nil,
										  action: #selector(didSelectCloseButton))
		closeButton.target = self
		navigationBarItem.leftBarButtonItem = closeButton
		
		let applyButton = UIBarButtonItem(title: "Apply",
										  style: .plain,
										  target: nil,
										  action: nil)
		applyButton.target = self
		applyButton.action = #selector(didSelectApply)
		navigationBarItem.rightBarButtonItems = [applyButton]
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

		var contentData = [CellType]()
		
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
		
		var selectedSegmentIndex = 0
		switch giniConfiguration.fileImportSupportedTypes {
		case .none:
			selectedSegmentIndex = 0
		case .pdf:
			selectedSegmentIndex = 1
		case .pdf_and_images:
			selectedSegmentIndex = 2
		}
		contentData.append(.fileImportType(data: .init(selectedIndex: selectedSegmentIndex)))
		
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
		
		contentData.append(.switchOption(data: .init(type: .shouldShowSupportedFormatsScreen,
													 isSwitchOn: giniConfiguration.shouldShowSupportedFormatsScreen)))
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



		contentData.append(.switchOption(data: .init(type: .enableReturnReasons,
													 isSwitchOn: giniConfiguration.enableReturnReasons)))
		// Add debug or development options at the end in the list
		
		contentData.append(.switchOption(data: .init(type: .giniErrorLoggerIsOn,
													 isSwitchOn: giniConfiguration.giniErrorLoggerIsOn)))
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
		switch data.type {
		case .openWith:
			giniConfiguration.openWithEnabled = data.isSwitchOn
		case .qrCodeScanning:
			giniConfiguration.qrCodeScanningEnabled = data.isSwitchOn
		case .qrCodeScanningOnly:
			giniConfiguration.onlyQRCodeScanningEnabled = data.isSwitchOn
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
			giniConfiguration.helpNavigationBarBottomAdapter = customAdapter
		case .cameraNavigationBarBottomAdapter:
			let customAdapter = CustomCameraBottomNavigationBarAdapter()
			giniConfiguration.cameraNavigationBarBottomAdapter = customAdapter
		case .reviewNavigationBarBottomAdapter:
			let customAdapter = CustomReviewScreenBottomNavigationBarAdapter()
			giniConfiguration.reviewNavigationBarBottomAdapter = customAdapter
		case .imagePickerNavigationBarBottomAdapter:
			let customAdapter = CustomBottomNavigationBarAdapter()
			giniConfiguration.imagePickerNavigationBarBottomAdapter = customAdapter
		case .onboardingShowAtLaunch:
			giniConfiguration.onboardingShowAtLaunch = data.isSwitchOn
			let onboardingShowedUserDefault = UserDefaults.standard.bool(forKey: "ginicapture.defaults.onboardingShowed")
			if !data.isSwitchOn && onboardingShowedUserDefault {
				UserDefaults.standard.removeObject(forKey: "ginicapture.defaults.onboardingShowed")
			}
		case .onboardingShowAtFirstLaunch:
			giniConfiguration.onboardingShowAtFirstLaunch = data.isSwitchOn
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
			giniConfiguration.customMenuItems = [customMenuItem]
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
		case .debugModeOn:
			giniConfiguration.debugModeOn = data.isSwitchOn
		case .digitalInvoiceOnboardingIllustrationAdapter:
			let customAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation",
																	backgroundColor: UIColor.blue)
			giniConfiguration.digitalInvoiceOnboardingIllustrationAdapter = customAdapter
		case .digitalInvoiceHelpNavigationBarBottomAdapter:
			let customAdapter = CustomBottomNavigationBarAdapter()
			giniConfiguration.digitalInvoiceHelpNavigationBarBottomAdapter = customAdapter
		case .digitalInvoiceOnboardingNavigationBarBottomAdapter:
			let customAdapter = CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter()
			giniConfiguration.digitalInvoiceOnboardingNavigationBarBottomAdapter = customAdapter
		case .digitalInvoiceNavigationBarBottomAdapter:
			let customAdapter = CustomDigitalInvoiceBottomNavigationBarAdapter()
			giniConfiguration.digitalInvoiceNavigationBarBottomAdapter = customAdapter
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
		
		let segmentItemTitles = optionModel.items.map { return $0.title }
		let model = SegmentedOptionCellModel(title: optionModel.title,
											 items: segmentItemTitles,
											 selectedIndex: optionModel.selectedIndex)
		cell.set(data: model)
		cell.delegate = self
		return cell
	}
	// MARK: - Actions
	
	@objc func didSelectCloseButton() {
		dismiss(animated: true)
	}

	@objc func didSelectApply() {
		delegate?.settings(settingViewController: self,
						   didChangeConfiguration: giniConfiguration)
		dismiss(animated: true)
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
		case .switchOption(let data):
			return cell(for: data, at: row)
		case .fileImportType(let data):
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
		guard case .fileImportType(var data) = option else { return }
		data.selectedIndex = cell.selectedSegmentIndex
		switch data.selectedIndex {
		case 0:
			giniConfiguration.fileImportSupportedTypes = .none
		case 1:
			giniConfiguration.fileImportSupportedTypes = .pdf
		case 2:
			giniConfiguration.fileImportSupportedTypes = .pdf_and_images
		default: return
		}
	}
}
