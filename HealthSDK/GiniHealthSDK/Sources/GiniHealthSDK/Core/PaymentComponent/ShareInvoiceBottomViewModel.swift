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
    
    var giniHealthConfiguration = GiniHealthConfiguration.shared
    
    var selectedPaymentProvider: PaymentProvider?
    // Payment provider colors
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: ShareInvoiceBottomViewProtocol?

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)
    let appRectangleBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark6,
                                                         darkModeColor: UIColor.GiniHealthColors.light6).uiColor()
    
    // Title label
    var titleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.title",
                                                             comment: "Share Invoice Bottom sheet title")
    let titleLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                   darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    var titleLabelFont: UIFont

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                        darkModeColor: UIColor.GiniHealthColors.light5).uiColor()

    // Description label
    let descriptionLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                       darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    let descriptionAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                    darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    var descriptionLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.description",
                                                                        comment: "Text description for share bottom sheet")
    var descriptionLabelFont: UIFont
    
    // Apps View
    let appsBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark6,
                                                 darkModeColor: UIColor.GiniHealthColors.light6).uiColor()
    let moreIconName: String = "more_vertical"
    
    // Tip label
    let tipAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                            darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    let tipLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark4,
                                               darkModeColor: UIColor.GiniHealthColors.light4).uiColor()
    var tipLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.tip.description",
                                                        comment: "Text for tip label")
    let tipActionablePartText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.tip.underlined.part",
                                                                 comment: "Text for tip actionable part from the label")
    var tipLabelFont: UIFont
    var tipLabelLinkFont: UIFont
    let tipIconName = "info.circle"
    
    // Continue label
    let continueLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.continue.button.text",
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

        self.titleLabelFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.descriptionLabelFont = giniHealthConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        self.tipLabelFont = giniHealthConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        self.tipLabelLinkFont = giniHealthConfiguration.textStyleFonts[.linkBold] ?? defaultBoldFont
        
        self.generateAppMockedElements()
    }
    
    private func generateAppMockedElements() {
        for _ in 0..<2 {
            self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""), isMoreButton: false))
        }
        self.appsMocked.append(SingleApp(title: selectedPaymentProvider?.name ?? "", image: bankImageIcon, isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.app", comment: ""), isMoreButton: false))
        self.appsMocked.append(SingleApp(title: NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.shareInvoiceBottomSheet.more", comment: ""), image: UIImageNamedPreferred(named: moreIconName), isMoreButton: true))
        
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinueToShareInvoice()
    }
}
