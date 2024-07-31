//
//  MoreInformationViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

protocol MoreInformationViewProtocol: AnyObject {
    func didTapOnMoreInformation()
}

final class MoreInformationViewModel {
    
    weak var delegate: MoreInformationViewProtocol?
    // More information part
    let moreInformationAccentColor: UIColor = GiniColor.standard2.uiColor()
    let moreInformationLabelTextColor: UIColor = GiniColor.standard4.uiColor()
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.more.information.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIcon: UIImage = GiniMerchantImage.info.preferredUIImage()
    
    init() {
        moreInformationLabelLinkFont = GiniMerchantConfiguration.shared.font(for: .captions2)
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
}
