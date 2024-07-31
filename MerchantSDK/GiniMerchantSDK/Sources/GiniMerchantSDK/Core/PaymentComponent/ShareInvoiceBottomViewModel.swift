//
//  ShareInvoiceBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
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

    let backgroundColor: UIColor = GiniColor.standard7.uiColor()
    let rectangleColor: UIColor = GiniColor.standard5.uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)
    let appRectangleBackgroundColor: UIColor = GiniColor.standard6.uiColor()
    
    // Title label
    var titleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.title",
                                                             comment: "Share Invoice Bottom sheet title")
    let titleLabelAccentColor: UIColor = GiniColor.standard2.uiColor()
    var titleLabelFont: UIFont

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor.standard5.uiColor()

    // Description label
    let descriptionLabelTextColor: UIColor = GiniColor.standard3.uiColor()
    let descriptionAccentColor: UIColor = GiniColor.standard3.uiColor()
    var descriptionLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.description",
                                                                        comment: "Text description for share bottom sheet")
    var descriptionLabelFont: UIFont
    
    // Apps View
    let appsBackgroundColor: UIColor = GiniColor.standard6.uiColor()
    let moreIcon: UIImage = GiniMerchantImage.more.preferredUIImage()
    
    // Tip label
    let tipAccentColor: UIColor = GiniColor.standard2.uiColor()
    let tipLabelTextColor: UIColor = GiniColor.standard4.uiColor()
    var tipLabelText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.tip.description",
                                                        comment: "Text for tip label")
    let tipActionablePartText = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.tip.underlined.part",
                                                                 comment: "Text for tip actionable part from the label")
    var tipLabelFont: UIFont
    var tipLabelLinkFont: UIFont
    let tipIcon: UIImage = GiniMerchantImage.info.preferredUIImage()
    
    // Continue label
    let continueLabelText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.continue.button.text",
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
        self.titleLabelFont = giniMerchantConfiguration.font(for: .subtitle1)
        self.descriptionLabelFont = giniMerchantConfiguration.font(for: .captions1)
        self.tipLabelFont = giniMerchantConfiguration.font(for: .captions1)
        self.tipLabelLinkFont = giniMerchantConfiguration.font(for: .linkBold)
        
        self.generateAppMockedElements()
    }
    
    private func generateAppMockedElements() {
        for _ in 0..<2 {
            self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.app", comment: ""), isMoreButton: false))
        }
        self.appsMocked.append(SingleApp(title: selectedPaymentProvider?.name ?? "", image: bankImageIcon, isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.app", comment: ""), isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.share.invoice.bottom.sheet.more", comment: ""), image: moreIcon, isMoreButton: true))
        
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinueToShareInvoice()
    }
}
