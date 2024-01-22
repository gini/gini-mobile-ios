//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import UIKit

final class PaymentComponentViewModel {
    
    var giniConfiguration: GiniHealthConfiguration
    
    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear, darkModeColor: .black))
    
    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark2).uiColor()
    let moreInformationLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.label", comment: "")
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.underlined.part", comment: "")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Select bank label
    let selectBankLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let selectBankLabelFont: UIFont
    let selectBankAccentColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark1).uiColor()
    
    // Select bank picker
    let selectBankPickerViewBackgroundColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark6).uiColor()
    let selectBankPickerViewBorderColor: UIColor = GiniColor(sameColor: UIColor.GiniColors.dark5).uiColor()
    
    init(giniConfiguration: GiniHealthConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.moreInformationLabelFont = giniConfiguration.customFont.with(weight: .regular, size: 13, style: .caption1)
        self.moreInformationLabelLinkFont = giniConfiguration.customFont.with(weight: .bold, size: 14, style: .linkBold)
        self.selectBankLabelFont = giniConfiguration.customFont.with(weight: .medium, size: 14, style: .subtitle2)
    }
    
    func tapOnMoreInformation() {
        // MARK: - TODO
        print("tap on More informations")
    }
}
