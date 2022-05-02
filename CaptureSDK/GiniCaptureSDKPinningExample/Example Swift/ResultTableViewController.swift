//
//  ResultTableViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import GiniBankAPILibrary
import UIKit

/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
final class ResultTableViewController: UITableViewController {
    /**
     The result collection from the analysis process.
     */
    var result: [Extraction] = [] {
        didSet {
            result.sort(by: { $0.name! < $1.name! })
        }
    }
}

extension ResultTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = result[indexPath.row].value
        cell.detailTextLabel?.text = result[indexPath.row].name
        return cell
    }
}
