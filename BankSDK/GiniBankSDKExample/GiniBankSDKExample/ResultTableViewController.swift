//
//  ResultTableViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 19.02.21.
//

import UIKit
import GiniBankAPILibrary
import GiniCaptureSDK
/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
final class ResultTableViewController: UITableViewController, UITextFieldDelegate {
    /**
     The result collection from the analysis process.
     */
    var result: [Extraction] = [] {
        didSet {
			for extraction in editableSpecificExtractions {
				if (result.first(where: { $0.name == extraction.key }) == nil) {
					result.append(Extraction(box: nil, candidates: nil, entity: extraction.value, value: "", name: extraction.key))
				}
			}
			
            result.sort(by: { $0.name! < $1.name! })
        }
    }
    
    var lineItems: [[Extraction]]? = nil
	var enabledRows: [Int] = []
	private let rowHeight: CGFloat = 65
	
	// {extraction name} : {entity name}
	let editableSpecificExtractions = ["paymentRecipient" : "companyname", "paymentReference" : "reference", "paymentPurpose" : "text", "iban" : "iban", "bic" : "bic", "amountToPay" : "amount"]
}

extension ResultTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "kCustomResultCell", for: indexPath) as? ResultTableViewCell else {
			return UITableViewCell()
		}
		
		cell.detailTextField.text = result[indexPath.row].value
		cell.detailTextField.placeholder = result[indexPath.row].name
		cell.detailTextField.tag = indexPath.row
		cell.titleLabel.text = result[indexPath.row].name
		if (editableSpecificExtractions.keys.contains(result[indexPath.row].name ?? "")) {
			cell.detailTextField.isEnabled = true
			cell.detailTextField.textColor = GiniColor(light: UIColor.black, dark: Colors.Gini.veryLightGray).uiColor()
			cell.detailTextField.returnKeyType = indexPath.row == result.count - 1 ? .done : .next
			
			if (!enabledRows.contains(indexPath.row)) {
				enabledRows.append(indexPath.row)
			}
		} else {
			cell.detailTextField.isEnabled = false
			cell.detailTextField.textColor = GiniColor(light: Colors.Gini.grey, dark: Colors.Gini.grey).uiColor()
		}
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return rowHeight
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let text = textField.text as NSString? {
			result[textField.tag].value = text.replacingCharacters(in: range, with: string)
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if (textField.returnKeyType == .done) {
			textField.resignFirstResponder()
			return true
		}
		
		guard let rowIndex = enabledRows.firstIndex(of: textField.tag), enabledRows.count > rowIndex + 1, let visibleCell = tableView.cellForRow(at: IndexPath(row: enabledRows[rowIndex + 1], section: 0)) as? ResultTableViewCell else {
			return true
		}
		
		visibleCell.detailTextField.becomeFirstResponder()
		return true
	}
}
