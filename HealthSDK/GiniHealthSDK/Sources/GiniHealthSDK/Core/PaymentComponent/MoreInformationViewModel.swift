//
//  MoreInformationViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

protocol MoreInformationViewProtocol: AnyObject {
    func didTapOnMoreInformation()
}

final class MoreInformationViewModel {
    
    weak var delegate: MoreInformationViewProtocol?
    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    let moreInformationLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                                        darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    let moreInformationActionablePartText = GiniLocalized.string("ginihealth.paymentcomponent.moreInformation.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    init() {
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        self.moreInformationLabelLinkFont = GiniHealthConfiguration.shared.textStyleFonts[.caption2] ?? defaultBoldFont
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
}
