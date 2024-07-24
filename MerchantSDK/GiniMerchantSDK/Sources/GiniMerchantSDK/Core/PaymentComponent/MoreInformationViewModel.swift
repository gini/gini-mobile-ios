//
//  MoreInformationViewModel.swift
//  GiniMerchantSDK
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
    let moreInformationAccentColor: UIColor = GiniColor.standard2.uiColor()
    let moreInformationLabelTextColor: UIColor = GiniColor.standard4.uiColor()
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.moreInformation.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIcon: UIImage = GiniMerchantImage.info.preferredUIImage()
    
    init() {
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        self.moreInformationLabelLinkFont = GiniMerchantConfiguration.shared.textStyleFonts[.caption2] ?? defaultBoldFont
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
}
