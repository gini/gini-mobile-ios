//
//  ResultTableViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 19.02.21.
//

import UIKit
import GiniBankAPILibrary
fileprivate enum LabelType: Int {
case textLabel = 100
case detailTextLabel = 101
}
/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
final class ResultTableViewController: UITableViewController {
    
    fileprivate enum LabelType: Int {
    case textLabel = 100
    case detailTextLabel = 101
    }
    
    /**
     The result collection from the analysis process.
     */
    var result: [Extraction] = [] {
        didSet {
            result.sort(by: { $0.name! < $1.name! })
        }
    }
    
    var lineItems: [[Extraction]]? = nil

}

extension ResultTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kCustomResultCell", for: indexPath)
        if let label = cell.viewWithTag(LabelType.textLabel.rawValue) as? UILabel {
            label.text = result[indexPath.row].value
        }
        
        if let label = cell.viewWithTag(LabelType.detailTextLabel.rawValue) as? UILabel {
            label.text = result[indexPath.row].name
        }
        return cell
    }
}
