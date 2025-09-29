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
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
final class TransactionSummaryTableViewController: UITableViewController  {
    /**
     The result collection from the analysis process.
     */
    var result: [Extraction] = [] {
        didSet {
            result.sort(by: { $0.name! < $1.name! })
        }
    }
    var editableFields: [String : String] = [:]
    var lineItems: [[Extraction]]? = nil
    var enabledRows: [Int] = []
    let displayNameMapping: [String: String] = [
        "bankName": "Recipient Bank Name",
        "bankAccountNumber": "Account Number",
        "amountToPay": "Amount",
        "iban": "IBAN",
        "currency": "Currency",
        "bankAddress": "Recipient's Bank Address",
        "countryRegionCode":"Country/Region",
        "abaRoutingNumber":"ABA Routing Number",
        "bic":"SWIFT/BIC Code",
        "paymentRecipient":"Payment Recipient",
        "paymentRecipientAddress":"Payment Recipient Address"
    ]

    weak var delegate: TransactionSummaryTableViewControllerDelegate?

    private let transactionDocsDataCoordinator = GiniBankConfiguration.shared.transactionDocsDataCoordinator
    private var numberOfSections = 1

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentTransactionDocs = transactionDocsDataCoordinator.transactionDocs
        numberOfSections = currentTransactionDocs.isEmpty ? 1 : 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 75
        tableView.register(AttachmentsTableViewCell.self)
        setupNavigationButtons()
        setupTableFooterButton()
    }
    
    private func setupTableFooterButton() {
            // Create a container view for the footer
            let footerView = UIView()
            footerView.backgroundColor = .clear

            // Create the button
        let button = GiniButton(type: .custom)
        button.backgroundColor = GiniColor(light: giniCaptureColor("Accent01"),
                                                      dark: giniCaptureColor("Accent01")).uiColor()
        button.setTitle("Test a new document", for: .normal)
        button.setTitleColor(GiniColor(light: giniCaptureColor("Light01"),
                                                   dark: giniCaptureColor("Light01")).uiColor(), for: .normal)
            button.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
        
        button.layer.cornerRadius = 4
        button.clipsToBounds = true

            // Add button to footer view
            footerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -10),
            button.topAnchor.constraint(equalTo: footerView.topAnchor,constant: 10),
            button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -10),
            button.heightAnchor.constraint(equalToConstant: 50) // optional if you want fixed height
        ])

            // Important: set frame height for footerView so it has space
            footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70)

            // Assign to tableFooterView
            tableView.tableFooterView = footerView
        }

        @objc private func footerButtonTapped() {
            print("Footer button tapped!")
            tapToScanAgain()
        }
    

    private func setupNavigationButtons() {
        navigationItem.setHidesBackButton(true, animated: true)
        let title = NSLocalizedStringPreferredFormat("results.sendfeedback.button.title",
                                                     fallbackKey: "Send feedback and close",
                                                     comment: "title for send feedback button",
                                                     isCustomizable: true)
        navigationItem
            .rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(tapCloseSreenAPIAndSendTransferSummary))
    }
    
    
    
    // MARK: - Actions
    @objc func tapCloseSreenAPIAndSendTransferSummary() {
        delegate?.didTapCloseAndSendTransferSummary()
    }
    
    func tapToScanAgain() {
        delegate?.didTapToScanAgain()
    }

    // MARK: - TableViewDataSource and TableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numberOfSections == 1 {
            return result.count
        }
        return section == 0 ? result.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue prototype cell
               let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)

               // Fetch data

               // Access labels and image via tags
               if let titleLabel = cell.viewWithTag(201) as? UILabel {
                   titleLabel.textColor =  GiniColor(light: giniCaptureColor("Accent01"),
                                                                 dark: giniCaptureColor("Accent01")).uiColor()
                   titleLabel.text = displayNameMapping[result[indexPath.row].name ?? ""] ?? result[indexPath.row].name ?? ""
                   
               }

               if let subtitleLabel = cell.viewWithTag(202) as? UILabel {
                   subtitleLabel.text =  result[indexPath.row].value
               }

               if let iconImageView = cell.viewWithTag(203) as? UIImageView {
                   let imageName = result[indexPath.row].name ?? ""
                   iconImageView.image = UIImage(named: imageName) ?? UIImage(named: "unknown")
                   iconImageView.isHidden = true
               }
        
        return cell

//        if indexPath.section == 0 {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "kCustomResultCell",
//                                                           for: indexPath) as? ExtractionResultTableViewCell else {
//                return UITableViewCell()
//            }
//            cell.detailTextField.text = result[indexPath.row].value
//            cell.detailTextField.placeholder = result[indexPath.row].name
//            cell.detailTextField.tag = indexPath.row
//            cell.titleLabel.text = displayNameMapping[result[indexPath.row].name ?? ""] ?? result[indexPath.row].name ?? ""
//            cell.detailTextField.textColor = GiniColor(light: UIColor.black,
//                                                       dark: UIColor.gray).uiColor()
//
//            if editableFields.keys.contains(result[indexPath.row].name ?? "") {
//                cell.detailTextField.isEnabled = true
//                cell.detailTextField.returnKeyType = indexPath.row == result.count - 1 ? .done : .next
//                cell.detailTextField.alpha = 1
//
//                if !enabledRows.contains(indexPath.row) {
//                    enabledRows.append(indexPath.row)
//                }
//            } else {
//                cell.detailTextField.isEnabled = false
//                cell.detailTextField.alpha = 0.5
//            }
//
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell() as AttachmentsTableViewCell
//            cell.configure(delegate: self)
//            return cell
//        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
extension TransactionSummaryTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        
        guard let rowIndex = enabledRows.firstIndex(of: textField.tag), enabledRows.count > rowIndex + 1,
              let visibleCell = tableView.cellForRow(at: IndexPath(row: enabledRows[rowIndex + 1], section: 0)) as? ExtractionResultTableViewCell else {
            return true
        }
        
        visibleCell.detailTextField.becomeFirstResponder()
        return true
    }
}

extension TransactionSummaryTableViewController: TransactionDocsViewDelegate {
    func transactionDocsViewDidUpdateContent(_ attachmentsView: TransactionDocsView) {
        let currentTransactionDocs = transactionDocsDataCoordinator.transactionDocs
        numberOfSections = currentTransactionDocs.isEmpty ? 1 : 2
        tableView.reloadData()
    }
}
