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
    
    override init(configuration: GiniConfiguration) {
        super.init(configuration: configuration)
        items.append(contentsOf:[
            HelpTipsItem(
                header: NSLocalizedString("ginicapture.analysis.suggestion.1", bundle: giniCaptureBundle(), comment: ""),
                details:NSLocalizedString("ginicapture.analysis.suggestion.1.details", bundle: giniCaptureBundle(), comment: ""),
                iconName: "captureSuggestion1"),
            HelpTipsItem(
                header: NSLocalizedString("ginicapture.analysis.suggestion.2", bundle: giniCaptureBundle(), comment: ""),
                details: NSLocalizedString("ginicapture.analysis.suggestion.2.details", bundle: giniCaptureBundle(), comment: ""),
                iconName: "captureSuggestion2"),
            HelpTipsItem(
                header: NSLocalizedString("ginicapture.analysis.suggestion.3", bundle: giniCaptureBundle(), comment: ""),
                details: NSLocalizedString("ginicapture.analysis.suggestion.3.details", bundle: giniCaptureBundle(), comment: ""),
                iconName: "captureSuggestion3"),
            HelpTipsItem(
                header: NSLocalizedString("ginicapture.analysis.suggestion.4", bundle: giniCaptureBundle(), comment: ""),
                details: NSLocalizedString("ginicapture.analysis.suggestion.4.details", bundle: giniCaptureBundle(), comment: ""),
                iconName: "captureSuggestion4")
        ])
    
        if giniConfiguration.multipageEnabled {
            items.append(
                HelpTipsItem(
                    header: NSLocalizedString("ginicapture.analysis.suggestion.5", bundle: giniCaptureBundle(), comment: ""),
                    details: NSLocalizedString("ginicapture.analysis.suggestion.5.details", bundle: giniCaptureBundle(), comment: ""),
                    iconName: "captureSuggestion5"))
        }
    }
    
    public override func configureCell(cell: HelpTipCell, indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        cell.headerLabel.text = item.header
        cell.headerLabel.textColor = UIColorPreferred(named: "labelColor")
        cell.backgroundColor = UIColorPreferred(named: "systemWhite")
        cell.descriptionLabel.text = item.details
        cell.descriptionLabel.textColor = UIColorPreferred(named: "subHeadline")
        cell.iconImageView.image = UIImageNamedPreferred(named: item.iconName)
        cell.separatorView.backgroundColor = UIColorPreferred(named: "separator")
        cell.selectionStyle = .none
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

