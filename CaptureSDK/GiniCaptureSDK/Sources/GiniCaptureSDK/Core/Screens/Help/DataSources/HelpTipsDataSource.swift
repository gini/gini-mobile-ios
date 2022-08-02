//
//  HelpTipsDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 01/08/2022.
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
                header: .localized(resource: AnalysisStrings.suggestion1Text),
                details: .localized(resource: AnalysisStrings.suggestion1Details),
                iconName: "captureSuggestion1"),
            HelpTipsItem(
                header: .localized(resource:AnalysisStrings.suggestion2Text),
                details: .localized(resource: AnalysisStrings.suggestion2Details),
                iconName: "captureSuggestion2"),
            HelpTipsItem(
                header: .localized(resource:AnalysisStrings.suggestion3Text),
                details: .localized(resource: AnalysisStrings.suggestion3Details),
                iconName: "captureSuggestion3"),
            HelpTipsItem(
                header: .localized(resource:AnalysisStrings.suggestion4Text),
                details: .localized(resource: AnalysisStrings.suggestion4Details),
                iconName: "captureSuggestion4")
        ])
    
        if giniConfiguration.multipageEnabled {
            items.append(
                HelpTipsItem(
                    header: .localized(resource: AnalysisStrings.suggestion5Text),
                    details: .localized(resource: AnalysisStrings.suggestion5Details),
                    iconName: "captureSuggestion5"))
        }
    }
    
    public override func configureCell(cell: HelpTipCell, indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        cell.headerLabel.text = item.header
        cell.descriptionLabel.text = item.details
        cell.iconImageView.image = UIImageNamedPreferred(named: item.iconName)
        cell.selectionStyle = .none
    }
}

