//
//  TransactionSummaryTableViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary
import GiniCaptureSDK
import GiniBankSDK

protocol TransactionSummaryTableViewControllerDelegate: AnyObject {
    func didTapCloseAndSendTransferSummary()
    func didTapToScanAgain()
}

/**
 Presents a list of extraction results in a table view.
 In the SEPA flow, fields listed in `editableFields` are rendered as editable text fields.
 In the cross-border flow all fields are read-only and labels use the `displayNameMapping`.
 */
final class TransactionSummaryTableViewController: UITableViewController, CodeLoadableView {

    // MARK: - Public

    var result: [Extraction] = [] {
        didSet {
            result.sort { ($0.name ?? "") < ($1.name ?? "") }
        }
    }
    var editableFields: [String: String] = [:]
    var isCrossBorderPayment: Bool = false

    weak var delegate: TransactionSummaryTableViewControllerDelegate?

    // MARK: - Private

    private let displayNameMapping: [String: String] = [
        "bankName": "Recipient Bank Name",
        "bankAccountNumber": "Account Number",
        "amountToPay": "Amount",
        "iban": "IBAN",
        "currency": "Currency",
        "bankAddress": "Recipient's Bank Address",
        "countryRegionCode": "Country/Region",
        "abaRoutingNumber": "ABA Routing Number",
        "bic": "SWIFT/BIC Code",
        "paymentRecipient": "Payment Recipient",
        "paymentRecipientAddress": "Payment Recipient Address"
    ]

    private let transactionDocsDataCoordinator = GiniBankConfiguration.shared.transactionDocsDataCoordinator
    private var numberOfSections = 1
    private var enabledRows: [Int] = []

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentTransactionDocs = transactionDocsDataCoordinator.transactionDocs
        numberOfSections = (!isCrossBorderPayment && !currentTransactionDocs.isEmpty) ? 2 : 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 75
        tableView.backgroundColor = GiniColor(light: .systemGray5, dark: .systemGray5).uiColor()
        tableView.separatorStyle = .none
        tableView.register(ExtractionResultCell.self)
        tableView.register(AttachmentsTableViewCell.self)
        setupNavigationButtons()
        setupTableFooterButton()
    }

    // MARK: - Setup

    private func setupTableFooterButton() {
        let footerView = UIView()
        footerView.backgroundColor = .clear

        let button = GiniButton(type: .custom)
        button.backgroundColor = GiniColor(light: giniCaptureColor("Accent01"),
                                           dark: giniCaptureColor("Accent01")).uiColor()
        button.setTitle("Test a new document", for: .normal)
        button.setTitleColor(GiniColor(light: giniCaptureColor("Light01"),
                                       dark: giniCaptureColor("Light01")).uiColor(), for: .normal)
        button.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true

        footerView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -10),
            button.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])

        footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70)
        tableView.tableFooterView = footerView
    }

    private func setupNavigationButtons() {
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(tapCloseSreenAPIAndSendTransferSummary)
        )
    }

    // MARK: - Actions

    @objc private func footerButtonTapped() {
        delegate?.didTapToScanAgain()
    }

    @objc func tapCloseSreenAPIAndSendTransferSummary() {
        delegate?.didTapCloseAndSendTransferSummary()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? result.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell() as AttachmentsTableViewCell
            cell.configure(delegate: self)
            return cell
        }

        let cell = tableView.dequeueReusableCell() as ExtractionResultCell
        let extraction = result[indexPath.row]
        let name = extraction.name ?? ""

        let title = isCrossBorderPayment ? (displayNameMapping[name] ?? name) : name
        let isEditable = !isCrossBorderPayment && editableFields.keys.contains(name)

        if isEditable && !enabledRows.contains(indexPath.row) {
            enabledRows.append(indexPath.row)
        }

        let returnKeyType: UIReturnKeyType = (indexPath.row == result.count - 1) ? .done : .next
        cell.configure(title: title,
                       value: extraction.value,
                       isEditable: isEditable,
                       returnKeyType: isEditable ? returnKeyType : .done)
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
            result[textField.tag].value = text.replacingCharacters(in: range, with: string)
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
        let currentTransactionDocs = transactionDocsDataCoordinator.transactionDocs
        numberOfSections = currentTransactionDocs.isEmpty ? 1 : 2
        tableView.reloadData()
    }
}
