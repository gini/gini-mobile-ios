//
//  HelpFormatsDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

public struct  HelpFormatsSection {
    let items: [String]
    let iconName: String
}

typealias HelpFormatsCollectionSection = (title: String,
    items: [String],
    itemsImage: UIImage?,
    itemsImageBackgroundColor: UIColor)

class HelpFormatsDataSource: NSObject  {
    let giniConfiguration: GiniConfiguration
    
    lazy var sections: [HelpFormatsCollectionSection] = {
        var sections: [HelpFormatsCollectionSection] =  [
            (.localized(resource: HelpStrings.supportedFormatsSection1Title),
             [.localized(resource: HelpStrings.supportedFormatsSection1Item1Text)],
             UIImageNamedPreferred(named: "supportedFormatsIcon"),
             GiniConfiguration.shared.supportedFormatsIconColor),
            (.localized(resource: HelpStrings.supportedFormatsSection2Title),
             [.localized(resource: HelpStrings.supportedFormatsSection2Item1Text),
              .localized(resource: HelpStrings.supportedFormatsSection2Item2Text)],
             UIImageNamedPreferred(named: "nonSupportedFormatsIcon"),
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
    
    init(
        configuration: GiniConfiguration
    ) {
        giniConfiguration = configuration
    }
    
    private func configureCell(cell: HelpFormatCell, indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
            
        cell.descriptionLabel.text = item
        cell.descriptionLabel.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.iconImageView.image = section.itemsImage
        cell.iconImageView.backgroundColor = UIColor.clear
        if indexPath.row == sections[indexPath.section].items.count - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
    }
}

extension HelpFormatsDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if sections[indexPath.section].items.count == 1 {
          cell.round(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], withRadius: RoundedCorners.cornerRadius)
        } else {
            if indexPath.row == 0 {
                cell.round(corners: [.topLeft, .topRight], withRadius: RoundedCorners.cornerRadius)
            }
            if indexPath.row == sections[indexPath.section].items.count - 1 {
                cell.round(corners: [.bottomLeft, .bottomRight], withRadius: RoundedCorners.cornerRadius)
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: HelpFormatCell.reuseIdentifier,
            for: indexPath) as? HelpFormatCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError()
    }
}

extension HelpFormatsDataSource: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
}
