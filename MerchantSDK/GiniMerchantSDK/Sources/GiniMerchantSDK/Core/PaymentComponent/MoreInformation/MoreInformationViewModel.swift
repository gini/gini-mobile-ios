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
    let configuration: MoreInformationConfiguration
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.moreInformation.underlined.part",
                                                                             comment: "Text for more information actionable part from the label")
    weak var delegate: MoreInformationViewProtocol?

    init(configuration: MoreInformationConfiguration) {
        self.configuration = configuration
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
}
