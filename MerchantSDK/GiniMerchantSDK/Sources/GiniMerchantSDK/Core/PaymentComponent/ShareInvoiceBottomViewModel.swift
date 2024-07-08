//
//  ShareInvoiceBottomViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

protocol ShareInvoiceBottomViewProtocol: AnyObject {
    func didTapOnContinueToShareInvoice()
}

struct SingleApp {
    var title: String
    var image: UIImage?
    var isMoreButton: Bool
}

final class ShareInvoiceBottomViewModel {
    
    var giniMerchantConfiguration = GiniMerchantConfiguration.shared
    
    var selectedPaymentProvider: PaymentProvider?
    // Payment provider colors
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: ShareInvoiceBottomViewProtocol?

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark7,
                                             darkModeColor: UIColor.GiniMerchantColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark5,
                                            darkModeColor: UIColor.GiniMerchantColors.light5).uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)
    let appRectangleBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark6,
                                                         darkModeColor: UIColor.GiniMerchantColors.light6).uiColor()
    
    // Title label
    var titleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.title",
                                                             comment: "Share Invoice Bottom sheet title")
    let titleLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark2,
                                                   darkModeColor: UIColor.GiniMerchantColors.light2).uiColor()
    var titleLabelFont: UIFont

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark5,
                                        darkModeColor: UIColor.GiniMerchantColors.light5).uiColor()

    // Description label
    let descriptionLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark3,
                                                       darkModeColor: UIColor.GiniMerchantColors.light3).uiColor()
    let descriptionAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark3,
                                                    darkModeColor: UIColor.GiniMerchantColors.light3).uiColor()
    var descriptionLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.description",
                                                                        comment: "Text description for share bottom sheet")
    var descriptionLabelFont: UIFont
    
    // Apps View
    let appsBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark6,
                                                 darkModeColor: UIColor.GiniMerchantColors.light6).uiColor()
    let moreIcon: UIImage = GiniMerchantImage.more.preferredUIImage()
    
    // Tip label
    let tipAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark2,
                                            darkModeColor: UIColor.GiniMerchantColors.light2).uiColor()
    let tipLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniMerchantColors.dark4,
                                               darkModeColor: UIColor.GiniMerchantColors.light4).uiColor()
    var tipLabelText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.tip.description",
                                                        comment: "Text for tip label")
    let tipActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.tip.underlined.part",
                                                                 comment: "Text for tip actionable part from the label")
    var tipLabelFont: UIFont
    var tipLabelLinkFont: UIFont
    let tipIcon: UIImage = GiniMerchantImage.info.preferredUIImage()
    
    // Continue label
    let continueLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.continue.button.text",
                                                                     comment: "Title label used for the Continue button")

    let bankToReplaceString = "[BANK]"
    
    var appsMocked: [SingleApp] = []

    init(selectedPaymentProvider: PaymentProvider?) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
        self.paymentProviderColors = selectedPaymentProvider?.colors
        
        titleText = titleText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        descriptionLabelText = descriptionLabelText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        tipLabelText = tipLabelText.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
        
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)

        self.titleLabelFont = giniMerchantConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.descriptionLabelFont = giniMerchantConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        self.tipLabelFont = giniMerchantConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        self.tipLabelLinkFont = giniMerchantConfiguration.textStyleFonts[.linkBold] ?? defaultBoldFont
        
        self.generateAppMockedElements()
    }
    
    private func generateAppMockedElements() {
        for _ in 0..<2 {
            self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""), isMoreButton: false))
        }
        self.appsMocked.append(SingleApp(title: selectedPaymentProvider?.name ?? "", image: bankImageIcon, isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""), isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.shareInvoiceBottomSheet.more", comment: ""), image: moreIcon, isMoreButton: true))
        
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinueToShareInvoice()
    }
}
