//
//  SettingsViewController.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 07.06.23.
//

import UIKit
import GiniCaptureSDK
import AVFoundation

protocol SettingsViewControllerDelegate: AnyObject {
	func settings(settingViewController: SettingsViewController,
				  didChangeConfiguration captureConfiguration: GiniConfiguration)
}

class SettingsViewController: UIViewController {

	@IBOutlet private weak var navigationBarItem: UINavigationItem!
	@IBOutlet private weak var navigationBar: UINavigationBar!
	@IBOutlet private weak var tableView: UITableView!
	
	var sectionData = [SectionType]()
	let giniConfiguration: GiniConfiguration
	
	weak var delegate: SettingsViewControllerDelegate?
	
	// MARK: - Initializers
	
	init(giniConfiguration: GiniConfiguration) {
		self.giniConfiguration = giniConfiguration
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setupTableView()
		setContent()
		styleNavigationBar()
		addNavigationBarItems()
    }

	private func styleNavigationBar() {
		navigationBar.isTranslucent = false
		navigationBar.tintColor = ColorPalette.raspberryPunch
	}
	
	private func addNavigationBarItems() {
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

	private func setupTableView() {
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
	}
	
	private func setContent() {
		var sectionData = [SectionType]()
		
		sectionData.append(.switchOption(data: SwitchOptionModel(type: .openWith,
																 isActive: giniConfiguration.openWithEnabled)))
		sectionData.append(.switchOption(data: SwitchOptionModel(type: .qrCodeScanning,
																 isActive: giniConfiguration.qrCodeScanningEnabled)))
		sectionData.append(.switchOption(data: SwitchOptionModel(type: .qrCodeScanningOnly,
																 isActive: giniConfiguration.onlyQRCodeScanningEnabled)))
		sectionData.append(.switchOption(data: SwitchOptionModel(type: .multipage,
																 isActive: giniConfiguration.multipageEnabled)))
		if flashToggleSettingEnabled {
			sectionData.append(.switchOption(data: SwitchOptionModel(type: .flashToggle,
																	 isActive: giniConfiguration.flashToggleEnabled)))
		}
		sectionData.append(.switchOption(data: SwitchOptionModel(type: .bottomNaviagtionBar,
																 isActive: giniConfiguration.bottomNavigationBarEnabled)))
		var selectedSegmentIndex = 0
		switch giniConfiguration.fileImportSupportedTypes {
		case .none:
			selectedSegmentIndex = 0
		case .pdf:
			selectedSegmentIndex = 1
		case .pdf_and_images:
			selectedSegmentIndex = 2
		}
		sectionData.append(.fileImportType(data: SegmentedOptionModel(selectedIndex: selectedSegmentIndex)))

		self.sectionData = sectionData
	}
	
	private var flashToggleSettingEnabled: Bool = {
		#if targetEnvironment(simulator)
			return true
		#else
			return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)?.hasFlash ?? false
		#endif
	}()
	
	private func handleOnToggle(in cell: SwitchOptionTableViewCell) {
		let option = sectionData[cell.tag]
		guard case .switchOption(var data) = option else { return }
		data.isActive = cell.isActive
		switch data.type {
		case .openWith:
			giniConfiguration.openWithEnabled = data.isActive
		case .qrCodeScanning:
			giniConfiguration.qrCodeScanningEnabled = data.isActive
		case .qrCodeScanningOnly:
			giniConfiguration.onlyQRCodeScanningEnabled = data.isActive
		case .multipage:
			giniConfiguration.multipageEnabled = data.isActive
		case .flashToggle:
			giniConfiguration.flashToggleEnabled = data.isActive
		case .bottomNaviagtionBar:
			giniConfiguration.bottomNavigationBarEnabled = data.isActive
		}
	}
	
	private func cell(for optionModel: SwitchOptionModel, at row: Int) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell() as SwitchOptionTableViewCell
		cell.tag = row
		let model = SwitchOptionModelCell(title: optionModel.type.title, active: optionModel.isActive)
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
		return sectionData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		switch sectionData[row] {
		case .switchOption(let data):
			return cell(for: data, at: row)
		case .fileImportType(let data):
			let cell = tableView.dequeueReusableCell() as SegmentedOptionTableViewCell
			cell.tag = row
		
			let segmentItemTitles = data.items.map { return $0.title }
			let model = SegmentedOptionCellModel(title: data.title,
												 items: segmentItemTitles,
												 selectedIndex: data.selectedIndex)
			cell.set(data: model)
			cell.delegate = self
			return cell
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
		let option = sectionData[cell.tag]
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
