//
//  MoreInformationViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

public protocol MoreInformationViewProtocol: AnyObject {
    func didTapOnMoreInformation()
}

public final class MoreInformationViewModel {
    let configuration: MoreInformationConfiguration
    let strings: MoreInformationStrings

    public weak var delegate: MoreInformationViewProtocol?

    public init(configuration: MoreInformationConfiguration, strings: MoreInformationStrings) {
        self.configuration = configuration
        self.strings = strings
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
}
