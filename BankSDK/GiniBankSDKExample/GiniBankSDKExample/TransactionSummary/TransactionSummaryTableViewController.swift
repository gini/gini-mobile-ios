//
//  TransactionSummaryTableViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniBankSDK

protocol TransactionSummaryTableViewControllerDelegate: AnyObject {
    func didTapDone()
    func didTapToScanAgain()
}

/**
 Presents a list of extraction results in a table view.
 In the SEPA flow, fields listed in `editableFields` are rendered as editable text fields.
 In the cross-border flow all fields are all editable and labels use the `displayNameMapping`.
 */
final class TransactionSummaryTableViewController: UITableViewController, CodeLoadableView {

    var viewModel: TransactionSummaryViewModel?

    weak var delegate: TransactionSummaryTableViewControllerDelegate?

    // MARK: - Private

    private let transactionDocsDataCoordinator = GiniBankConfiguration.shared.transactionDocsDataCoordinator
    private var numberOfSections = 1
    private var enabledRows: [Int] = []

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNumberOfSections()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationButtons()
        setupTableFooterButton()
    }

    // MARK: - Setup

    private func updateNumberOfSections() {
        let currentTransactionDocs = transactionDocsDataCoordinator.transactionDocs
        let isCrossBorderPayment = viewModel?.isCrossBorderPayment ?? false
        numberOfSections = (!isCrossBorderPayment && !currentTransactionDocs.isEmpty) ? 2 : 1
    }

    private func setupTableView() {
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.backgroundColor = GiniColor(light: .systemGray5, dark: .systemGray5).uiColor()
        tableView.separatorStyle = .none
        tableView.register(ExtractionResultCell.self)
        tableView.register(AttachmentsTableViewCell.self)
    }

    private func setupTableFooterButton() {
        let footerView = UIView()
        footerView.backgroundColor = .clear

        let button = GiniButton(type: .custom)
        button.backgroundColor = GiniColor(light: giniCaptureColor("Accent01"),
                                           dark: giniCaptureColor("Accent01")).uiColor()
        button.setTitle(Strings.footerButtonTitle, for: .normal)
        button.setTitleColor(GiniColor(light: giniCaptureColor("Light01"),
                                       dark: giniCaptureColor("Light01")).uiColor(), for: .normal)
        button.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.clipsToBounds = true

        footerView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: footerView.leadingAnchor,
                                            constant: Constants.buttonHorizontalPadding),
            button.trailingAnchor.constraint(equalTo: footerView.trailingAnchor,
                                             constant: -Constants.buttonHorizontalPadding),
            button.topAnchor.constraint(equalTo: footerView.topAnchor,
                                        constant: Constants.buttonVerticalPadding),
            button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor,
                                           constant: -Constants.buttonVerticalPadding),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])

        footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: Constants.footerHeight)
        tableView.tableFooterView = footerView
    }

    private func setupNavigationButtons() {
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Strings.doneButtonTitle,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(submitTransferAndClose))
    }

    // MARK: - Actions

    @objc private func footerButtonTapped() {
        delegate?.didTapToScanAgain()
    }

    @objc func submitTransferAndClose() {
        delegate?.didTapDone()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? (viewModel?.items.count ?? 0) : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell() as AttachmentsTableViewCell
            cell.configure(delegate: self)
            return cell
        }

        let cell = tableView.dequeueReusableCell() as ExtractionResultCell
        guard let item = viewModel?.items[indexPath.row] else { return cell }

        if item.isEditable && !enabledRows.contains(indexPath.row) {
            enabledRows.append(indexPath.row)
        }

        let returnKeyType: UIReturnKeyType = (indexPath.row == (viewModel?.items.count ?? 0) - 1) ? .done : .next
        cell.configure(title: item.title,
                       value: item.value,
                       isEditable: item.isEditable,
                       returnKeyType: item.isEditable ? returnKeyType : .done)
        cell.valueTextField.tag = indexPath.row
        cell.valueTextField.delegate = self

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension TransactionSummaryTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let newValue = text.replacingCharacters(in: range, with: string)
            viewModel?.updateValue(at: textField.tag, value: newValue)
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
            return true
        }

        guard let rowIndex = enabledRows.firstIndex(of: textField.tag),
              enabledRows.count > rowIndex + 1,
              let nextCell = tableView.cellForRow(
                  at: IndexPath(row: enabledRows[rowIndex + 1], section: 0)
              ) as? ExtractionResultCell else {
            return true
        }

        nextCell.valueTextField.becomeFirstResponder()
        return true
    }
}

// MARK: - TransactionDocsViewDelegate

extension TransactionSummaryTableViewController: TransactionDocsViewDelegate {
    func transactionDocsViewDidUpdateContent(_ attachmentsView: TransactionDocsView) {
        updateNumberOfSections()
        tableView.reloadData()
    }
}

extension TransactionSummaryTableViewController {
    struct Constants {
        static let estimatedRowHeight: CGFloat = 75
        static let buttonCornerRadius: CGFloat = 4
        static let buttonHorizontalPadding: CGFloat = 10
        static let buttonVerticalPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let footerHeight: CGFloat = 70
    }

    struct Strings {
        static let footerButtonTitle = "Test a new document"
        static let doneButtonTitle = "Done"
    }
}
