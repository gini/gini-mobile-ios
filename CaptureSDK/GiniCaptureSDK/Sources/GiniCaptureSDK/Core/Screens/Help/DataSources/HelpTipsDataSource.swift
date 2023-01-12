//
//  HelpTipsDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

struct HelpTipsItem {
    let header: String
    let details: String
    let iconName: String
}

final class HelpTipsDataSource: HelpRoundedCornersDataSource<HelpTipsItem, HelpTipCell> {
    // swiftlint:disable function_body_length
    required init(configuration: GiniConfiguration) {
        super.init(configuration: configuration)
        items.append(contentsOf: [
            HelpTipsItem(
                header: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.1",
                    comment: "Analysis suggestion 1 header"),
                details: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.1.details",
                    comment: "Analysis suggestion 1 details"),
                iconName: "captureSuggestion1"),
            HelpTipsItem(
                header: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.2",
                    comment: "Analysis suggestion 2 header"),
                details: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.2.details",
                    comment: "Analysis suggestion 2 details"),
                iconName: "captureSuggestion2"),
            HelpTipsItem(
                header: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.3",
                    comment: "Analysis suggestion 3 header"),
                details: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.3.details",
                    comment: "Analysis suggestion 3 details"),
                iconName: "captureSuggestion3"),
            HelpTipsItem(
                header: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.4",
                    comment: "Analysis suggestion 4 header"),
                details: NSLocalizedStringPreferredFormat(
                    "ginicapture.analysis.suggestion.4.details",
                    comment: "Analysis suggestion 4 details"),
                iconName: "captureSuggestion4")
        ])

        if giniConfiguration.multipageEnabled {
            items.append(
                HelpTipsItem(
                    header: NSLocalizedStringPreferredFormat(
                        "ginicapture.analysis.suggestion.5",
                        comment: "Analysis suggestion 5 header"),
                    details: NSLocalizedStringPreferredFormat(
                        "ginicapture.analysis.suggestion.5.details",
                        comment: "Analysis suggestion 5 details"),
                    iconName: "captureSuggestion5"))
        }
    }

    private func configureCellAccessibility(
        cell: HelpTipCell,
        item: HelpTipsItem) {
        cell.iconImageView?.accessibilityTraits = .image
        cell.iconImageView?.accessibilityLabel = item.header
    }

    private func configureHeader(
        header: HelpFormatSectionHeader,
        section: Int) {
        header.titleLabel.font = giniConfiguration.textStyleFonts[.caption1]
        header.titleLabel.adjustsFontForContentSizeCategory = true
        header.titleLabel.numberOfLines = 0
            header.titleLabel.textColor =  GiniColor(
                light: UIColor.GiniCapture.dark7,
                dark: UIColor.GiniCapture.dark7).uiColor()
        header.titleLabel.text = NSLocalizedStringPreferredFormat(
            "ginicapture.analysis.section.header",
            comment: "Analysis section header").uppercased()
        header.backgroundView?.backgroundColor = UIColor.clear
    }

    var showHeader = false

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if showHeader, let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HelpFormatSectionHeader.reuseIdentifier
        ) as? HelpFormatSectionHeader {
            configureHeader(header: header, section: section)
            return header
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showHeader {
            return UITableView.automaticDimension
        }
        return 0
    }

    override func configureCell(cell: HelpTipCell, indexPath: IndexPath) {
        let item = items[indexPath.row]
        cell.headerLabel.text = item.header
        cell.headerLabel.font = giniConfiguration.textStyleFonts[.calloutBold]
        cell.headerLabel.adjustsFontForContentSizeCategory = true
        cell.headerLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1).uiColor()
        cell.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.light1,
            dark: UIColor.GiniCapture.dark3).uiColor()
        cell.descriptionLabel.text = item.details
        cell.descriptionLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        cell.descriptionLabel.adjustsFontForContentSizeCategory = true
        cell.descriptionLabel.textColor = GiniColor(
            light: UIColor.GiniCapture.dark7,
            dark: UIColor.GiniCapture.dark7).uiColor()
        cell.iconImageView.image = UIImageNamedPreferred(named: item.iconName)
        cell.separatorView.backgroundColor = GiniColor(
            light: UIColor.GiniCapture.light3,
            dark: UIColor.GiniCapture.dark4).uiColor()
        cell.selectionStyle = .none
        configureCellAccessibility(cell: cell, item: item)
        if indexPath.row == items.count - 1 {
            cell.separatorView.alpha = 0
        } else {
            cell.separatorView.alpha = 1
        }
    }
}
