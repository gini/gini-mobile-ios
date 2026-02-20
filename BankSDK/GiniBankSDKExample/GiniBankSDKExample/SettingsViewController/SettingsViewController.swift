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

protocol SettingsViewControllerDelegate: AnyObject {
    func didTapCloseButton()
    func didTapSaveCredentialsButton(clientId: String, clientSecret: String)
    func didSelectAPIEnvironment(apiEnvironment: APIEnvironment)
    func didSelectPinningSDK(_ enablePinningSDK: Bool)
}

final class SettingsViewController: UIViewController {
    
    @IBOutlet private weak var navigationBarItem: UINavigationItem!
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var tableView: UITableView!
    
    private var viewModel: SettingsViewModel!
    
	weak var delegate: SettingsViewControllerDelegate?
	
	// MARK: - Initializers
     
    init(apiEnvironment: APIEnvironment,
         enablePinningSDK: Bool,
         client: Client? = nil,
         giniConfiguration: GiniBankConfiguration,
         settingsButtonStates: SettingsButtonStates,
         documentValidationsState: DocumentValidationsState) {
        self.viewModel = SettingsViewModel(apiEnvironment: apiEnvironment,
                                           enablePinningSDK: enablePinningSDK,
                                           client: client,
                                           giniConfiguration: giniConfiguration,
                                           settingsButtonStates: settingsButtonStates,
                                           documentValidationsState: documentValidationsState)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
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
        tableView.delegate = self

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
        tableView.registerHeaderFooter(SettingsHeaderView.self)
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
        return viewModel.contentData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contentData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.contentData[indexPath.section].items[indexPath.row]
        switch item {
        case .info(let message):
            return cell(for: message)
        case .switchOption(let data):
            return cell(for: data, at: indexPath)
        case .segmentedOption(let data):
            return cell(for: data, at: indexPath)
        case .credentials(let data):
            return cell(for: data)
        case .userDefaults(let message, let buttonActive):
            return userDefaultsCell(for: message, buttonActive)
        }
    }

    // Cell configuration methods
    private func cell(for optionModel: SwitchOptionModel, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as SwitchOptionTableViewCell
        cell.indexPath = indexPath
        let model = SwitchOptionModelCell(title: optionModel.type.title,
                                          active: optionModel.isSwitchOn,
                                          message: optionModel.type.message)
        cell.set(data: model)
        cell.delegate = self
        return cell
    }

    private func cell(for optionModel: SegmentedOptionModelProtocol, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as SegmentedOptionTableViewCell
        cell.indexPath = indexPath
        let model = SegmentedOptionCellModel(title: optionModel.title,
                                             items: optionModel.items,
                                             selectedIndex: optionModel.selectedIndex,
                                             description: optionModel.description)
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

    private func userDefaultsCell(for message: String, _ buttonActive: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as UpdateUserDefaultsCell
        cell.set(message: message, buttonActive: buttonActive)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: SettingsHeaderView = tableView.dequeueReusableHeaderFooter()
        let title = viewModel.contentData[section].title
        headerView.configure(with: title)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
}
// MARK: - SwitchOptionTableViewCellDelegate

extension SettingsViewController: SwitchOptionTableViewCellDelegate {
    func didToggleOption(in cell: SwitchOptionTableViewCell) {
        viewModel.handleOnToggle(at: cell.indexPath, isSwitchOn: cell.isSwitchOn)
    }
}

// MARK: - SegmentedOptionTableViewCellDelegate

extension SettingsViewController: SegmentedOptionTableViewCellDelegate {
    func didSegmentedControlValueChanged(in cell: SegmentedOptionTableViewCell) {
        let indexPath = cell.indexPath
        let item = viewModel.contentData[indexPath.section].items[indexPath.row]
        guard case .segmentedOption(let data) = item else { return }
        var newData = data
        newData.selectedIndex = cell.selectedSegmentIndex
        if newData is FileImportSegmentedOptionModel {
            viewModel.handleFileImportOption(fileImportIndex: newData.selectedIndex)
        } else if newData is APIEnvironmentSegmentedOptionModel {
            handleApiEnvironmentOption(environmentIndex: newData.selectedIndex)
        } else if newData is SDKTypeSegmentedOptionModel {
            handleSDKTypeOption(index: newData.selectedIndex)
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

    func handleSDKTypeOption(index: Int) {
        switch index {
        case 0:
            delegate?.didSelectPinningSDK(false)
        case 1:
            delegate?.didSelectPinningSDK(true)
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

// MARK: - SettingsViewModelDelegate

extension SettingsViewController: SettingsViewModelDelegate {
    func contentDataUpdated() {
        self.tableView.reloadData()
    }
}
