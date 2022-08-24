//
//  HelpFormatsDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 03/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

typealias HelpFormatsCollectionSection = (title: String,
    formats: [String],
    formatsImage: UIImage?)

class HelpFormatsDataSource: HelpRoundedCornersDataSource<HelpFormatsCollectionSection, HelpFormatCell> {

    lazy var itemSections: [HelpFormatsCollectionSection] = {
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
                sections[0].formats.append(
                    NSLocalizedStringPreferredFormat(
                        "ginicapture.help.supportedFormats.section.1.item.2",
                        comment: "supported format for section 1 itemm 2"))
            }
            sections[0].formats.append(
                NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.item.3",
                    comment: "supported format for section 1 item 3"))
        }

        if giniConfiguration.qrCodeScanningEnabled {
            sections[0].formats.append(
                NSLocalizedStringPreferredFormat(
                    "ginicapture.help.supportedFormats.section.1.item.4",
                    comment: "supported format for section 1 item 4"))
        }
        sections[0].formats.append(
            NSLocalizedStringPreferredFormat(
                "ginicapture.help.supportedFormats.section.1.item.5",
                comment: "supported format for section 1 item 5"))
        return sections
    }()

    override var items: [HelpFormatsCollectionSection] {
        get {
            return itemSections
        }
        set {
            itemSections = newValue
        }
    }

    private func configureCellAccessibility(
        cell: HelpFormatCell,
        title: String) {
        cell.iconImageView?.accessibilityTraits = .image
        cell.iconImageView.accessibilityLabel = title
    }

    override func configureCell(cell: HelpFormatCell, indexPath: IndexPath) {
        let section = items[indexPath.section]
        let item = section.formats[indexPath.row]
        cell.descriptionLabel.text = item
        cell.descriptionLabel.font = giniConfiguration.textStyleFonts[.body]
        cell.descriptionLabel.textColor = UIColorPreferred(named: "label")
        cell.descriptionLabel.adjustsFontForContentSizeCategory = true
        cell.iconImageView.image = section.formatsImage
        cell.iconImageView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColorPreferred(named: "systemWhite")
        cell.separatorView.backgroundColor = UIColorPreferred(named: "separator")
        configureCellAccessibility(cell: cell, title: section.title.uppercased())
        if indexPath.row == items[indexPath.section].formats.count - 1 {
            cell.separatorView.isHidden = true
        } else {
            cell.separatorView.isHidden = false
        }
    }

    private func configureHeader(
        header: HelpFormatSectionHeader,
        section: Int) {
        header.titleLabel.font = giniConfiguration.textStyleFonts[.caption1]
        header.titleLabel.adjustsFontForContentSizeCategory = true
        header.titleLabel.numberOfLines = 0
        header.titleLabel.textColor =  UIColorPreferred(named: "subheadline")
        header.titleLabel.text = items[section].title.uppercased()
        header.backgroundView?.backgroundColor = UIColor.clear
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HelpFormatSectionHeader.reuseIdentifier
        ) as? HelpFormatSectionHeader {
            configureHeader(header: header, section: section)
            return header
        }
        fatalError("Section header is missing")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: HelpFormatCell.reuseIdentifier,
            for: indexPath) as? HelpFormatCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        }
        fatalError()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].formats.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}
