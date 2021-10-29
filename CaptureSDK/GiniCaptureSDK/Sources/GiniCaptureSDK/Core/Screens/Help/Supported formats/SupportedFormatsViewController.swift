//
//  SupportedTypesViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

typealias SupportedFormatCollectionSection = (title: String,
    items: [String],
    itemsImage: UIImage?,
    itemsImageBackgroundColor: UIColor)

final class SupportedFormatsViewController: UITableViewController {
    
    let supportedFormatsCellIdentifier = "SupportedFormatsCellIdentifier"
    let rowHeight: CGFloat = 70
    let sectionHeight: CGFloat = 70
    fileprivate let giniConfiguration: GiniConfiguration
    lazy var sections: [SupportedFormatCollectionSection] = {
        var sections: [SupportedFormatCollectionSection] =  [
            (.localized(resource: HelpStrings.supportedFormatsSection1Title),
             [.localized(resource: HelpStrings.supportedFormatsSection1Item1Text)],
             UIImage(named: "supportedFormatsIcon",
                     in: Bundle(for: GiniCapture.self),
                     compatibleWith: nil),
             GiniConfiguration.shared.supportedFormatsIconColor),
            (.localized(resource: HelpStrings.supportedFormatsSection2Title),
             [.localized(resource: HelpStrings.supportedFormatsSection2Item1Text),
              .localized(resource: HelpStrings.supportedFormatsSection2Item2Text)],
             UIImage(named: "nonSupportedFormatsIcon", in: Bundle(for: GiniCapture.self), compatibleWith: nil),
             GiniConfiguration.shared.nonSupportedFormatsIconColor)
        ]
        
        if GiniConfiguration.shared.fileImportSupportedTypes != .none {
            if GiniConfiguration.shared.fileImportSupportedTypes == .pdf_and_images {
                sections[0].items.append(.localized(resource: HelpStrings.supportedFormatsSection1Item2Text))
            }
            sections[0].items.append(.localized(resource: HelpStrings.supportedFormatsSection1Item3Text))
        }
        if GiniConfiguration.shared.qrCodeScanningEnabled {
            sections[0].items.append(.localized(resource: HelpStrings.supportedFormatsSection1Item4Text))
        }
        return sections
    }()
    
    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .localized(resource: HelpStrings.supportedFormatsTitle)
        tableView.register(SupportedFormatsTableViewCell.self, forCellReuseIdentifier: supportedFormatsCellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = sectionHeight
        tableView.allowsSelection = false
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = Colors.Gini.dynamicPearl
        } else {
            tableView.backgroundColor = Colors.Gini.pearl
        }
        
        tableView.alwaysBounceVertical = false
        
        // On iOS is .automatic by default and it the transition to this view controller looks weird.
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        let cell = (tableView.dequeueReusableCell(withIdentifier: supportedFormatsCellIdentifier,
                                                 for: indexPath) as? SupportedFormatsTableViewCell)!
        cell.textLabel?.text = item
        cell.textLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.imageView?.image = section.itemsImage
        cell.imageBackgroundView.backgroundColor = section.itemsImageBackgroundColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = nil
        }
    }

}
