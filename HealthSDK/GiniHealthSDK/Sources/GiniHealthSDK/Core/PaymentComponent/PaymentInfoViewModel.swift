//
//  PaymentInfoViewModel q.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol PaymentInfoViewProtocol: AnyObject {
    func didTapOnCloseOnInfoView()
}

final class PaymentInfoViewModel {
    
    weak var viewDelegate: PaymentInfoViewProtocol?
    var paymentProviders: PaymentProviders
    
    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    
    let titleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.title.label", 
                                                             comment: "Payment Info title label text")
    let titleFont: UIFont
    let titleTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                            darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    let closeTitleIcon: UIImage = UIImageNamedPreferred(named: "ic_close") ?? UIImage()
    let closeIconAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                  darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    
    let payBillsTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.payBills.title.label", 
                                                                     comment: "Payment Info pay bills title label text")
    let payBillsTitleFont: UIFont
    let payBillsTitleTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                    darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    let payBillsDescriptionText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentinfo.payBills.description.label", 
                                                                           comment: "Payment Info pay bills description text")
    let payBillsDescriptionFont: UIFont
    let payBillsDescriptionTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark1,
                                                          darkModeColor: UIColor.GiniHealthColors.light1).uiColor()
    
    init(paymentProviders: PaymentProviders) {
        self.paymentProviders = paymentProviders
        
        let giniHealthConfiguration = GiniHealthConfiguration.shared
        
        let defaultRegularFont: UIFont = giniHealthConfiguration.customFont.regular
        let defaultBoldFont: UIFont = giniHealthConfiguration.customFont.bold
        
        titleFont = giniHealthConfiguration.textStyleFonts[.headline3] ?? defaultBoldFont
        payBillsTitleFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        payBillsDescriptionFont = giniHealthConfiguration.textStyleFonts[.body2] ?? defaultRegularFont
    }
    
    func didTapOnClose() {
        viewDelegate?.didTapOnCloseOnInfoView()
    }
}
