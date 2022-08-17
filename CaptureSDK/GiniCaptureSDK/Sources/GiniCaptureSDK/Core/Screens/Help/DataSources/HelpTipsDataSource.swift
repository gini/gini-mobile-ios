//
//  HelpTipsDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

public struct HelpTipsItem {
    let header: String
    let details: String
    let iconName: String
}

final public class HelpTipsDataSource: HelpBaseDataSource<HelpTipsItem, HelpTipCell> {
    // swiftlint:disable function_body_length
    override init(configuration: GiniConfiguration) {
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

    public override func configureCell(cell: HelpTipCell, indexPath: IndexPath) {
        let item = items[indexPath.row]
        cell.headerLabel.text = item.header
        cell.headerLabel.font = giniConfiguration.textStyleFonts[.bodyBold]
        cell.headerLabel.adjustsFontForContentSizeCategory = true
        cell.headerLabel.textColor = UIColorPreferred(named: "labelColor")
        cell.backgroundColor = UIColorPreferred(named: "systemWhite")
        cell.descriptionLabel.text = item.details
        cell.descriptionLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        cell.descriptionLabel.adjustsFontForContentSizeCategory = true
        cell.descriptionLabel.textColor = UIColorPreferred(named: "subheadline")
        cell.iconImageView.image = UIImageNamedPreferred(named: item.iconName)
        cell.separatorView.backgroundColor = UIColorPreferred(named: "separator")
        cell.selectionStyle = .none
        configureCellAccessibility(cell: cell, item: item)
        if indexPath.row == items.count - 1 {
            cell.separatorView.alpha = 0
        } else {
            cell.separatorView.alpha = 1
        }
    }
}
