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
    itemsImage: UIImage?)

class HelpFormatsDataSource: NSObject {
    let giniConfiguration: GiniConfiguration

    lazy var sections: [HelpFormatsCollectionSection] = {
        var sections: [HelpFormatsCollectionSection] =  [
            (NSLocalizedStringPreferredFormat(
                "ginicapture.help.supportedFormats.section.1.title",
                comment: "supported format for section 1 title"),
             [
                NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.item.1",
                    comment: "supported format for section 1 item 1")],
             UIImageNamedPreferred(named: "supportedFormatsIcon")),
            (NSLocalizedStringPreferredFormat(
                "ginicapture.help.supportedFormats.section.2.title",
                comment: "supported format for section 2 title"),
             [
                NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.2.item.1",
                    comment: "supported format for section 2 item 1")],
             UIImageNamedPreferred(named: "nonSupportedFormatsIcon"))
        ]

        if giniConfiguration.fileImportSupportedTypes != .none {
            if giniConfiguration.fileImportSupportedTypes == .pdf_and_images {
                sections[0].items.append(
                    NSLocalizedStringPreferredFormat(
                        "ginicapture.help.supportedFormats.section.1.item.2",
                        comment: "supported format for section 1 itemm 2"))
            }
            sections[0].items.append(
                NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.item.3",
                    comment: "supported format for section 1 item 3"))
        }

        if giniConfiguration.qrCodeScanningEnabled {
            sections[0].items.append(
                NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.item.4",
                    comment: "supported format for section 1 item 4"))
        }
        sections[0].items.append(
            NSLocalizedStringPreferredFormat(
                "ginicapture.help.supportedFormats.section.1.item.5",
                comment: "supported format for section 1 item 5"))
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
        cell.descriptionLabel.textColor = UIColorPreferred(named: "labelColor")
        cell.descriptionLabel.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.iconImageView.image = section.itemsImage
        cell.iconImageView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColorPreferred(named: "systemWhite")
        cell.separatorView.backgroundColor = UIColorPreferred(named: "separator")
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
        return sections[section].title.uppercased()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .clear
            headerView.backgroundView?.backgroundColor = .clear
            headerView.textLabel?.textColor = UIColorPreferred(named: "subHeadline")
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
