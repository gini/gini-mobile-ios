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
	
    private var viewModel: SettingsViewModel!
    
	weak var delegate: SettingsViewControllerDelegate?
	
	// MARK: - Initializers
     
    init(apiEnvironment: APIEnvironment,
         client: Client? = nil,
         giniConfiguration: GiniBankConfiguration,
         settingsButtonStates: SettingsButtonStates,
         documentValidationsState: DocumentValidationsState) {
        self.viewModel = SettingsViewModel(apiEnvironment: apiEnvironment,
                                                   client: client,
                                                   giniConfiguration: giniConfiguration,
                                                   settingsButtonStates: settingsButtonStates,
                                                   documentValidationsState: documentValidationsState)
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
		return viewModel.contentData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		switch viewModel.contentData[row] {
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
        let nextSwitchOptionCell = getSwitchOptionCell(at: cell.tag + 1) as? SwitchOptionTableViewCell
        viewModel.handleOnToggle(in: cell, nextSwitchOptionCell: nextSwitchOptionCell)
	}
}

// MARK: - SegmentedOptionTableViewCellDelegate

extension SettingsViewController: SegmentedOptionTableViewCellDelegate {
	func didSegmentedControlValueChanged(in cell: SegmentedOptionTableViewCell) {
		let option = viewModel.contentData[cell.tag]
		guard case .segmentedOption(var data) = option else { return }
        data.selectedIndex = cell.selectedSegmentIndex
        
        if data is FileImportSegmentedOptionModel {
            viewModel.handleFileImportOption(fileImportIndex: data.selectedIndex)
        } else if data is APIEnvironmentSegmentedOptionModel {
            handleApiEnvironmentOption(environmentIndex: data.selectedIndex)
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

extension SettingsViewController: UpdateUserDefaultsCellDelegate {
    func didTapRemoveButton(in view: UpdateUserDefaultsCell) {
        let alwaysAttachDocsValue = GiniBankConfiguration.shared.transactionDocsDataCoordinator.getAlwaysAttachDocsValue()
        if alwaysAttachDocsValue {
            GiniBankConfiguration.shared.transactionDocsDataCoordinator.setAlwaysAttachDocs(false)
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
