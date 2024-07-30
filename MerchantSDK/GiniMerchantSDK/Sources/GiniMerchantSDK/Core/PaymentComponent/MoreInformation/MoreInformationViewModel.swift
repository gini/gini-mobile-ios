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
    let strings: MoreInformationStrings

    weak var delegate: MoreInformationViewProtocol?

    init(configuration: MoreInformationConfiguration, strings: MoreInformationStrings) {
        self.configuration = configuration
        self.strings = strings
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
}
