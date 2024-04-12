//
//  InstallAppBottomViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

protocol InstallAppBottomViewProtocol: AnyObject {
    func didTapOnContinue()
}

final class InstallAppBottomViewModel {
    
    var giniHealthConfiguration = GiniHealthConfiguration.shared
    
    var selectedPaymentProvider: PaymentProvider?
    // Payment provider colors
    var paymentProviderColors: ProviderColors?
    
    weak var viewDelegate: InstallAppBottomViewProtocol?
    
    let maximumViewHeight: CGFloat = UIScreen.main.bounds.height - Constants.topPaddingView
    var bottomViewHeight: CGFloat = 0

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)

    let titleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.installAppBottom.title",
                                                                       comment: "Install App Bottom sheet title")
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

    // More information part
    let moreInformationLabelTextColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                           darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    let moreInformationAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                        darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    var moreInformationLabelText: String {
        isBankInstalled ? 
        NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.installAppBottom.tip.description",
                                         comment: "Text for tip information label") :
        NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.installAppBottom.notes.description",
                                         comment: "Text for notes information label")
    }

    var moreInformationLabelFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Pay invoice label
    let continueLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.installAppBottom.continue.button.text",
                                                                     comment: "Title label used for the Continue button")
    
    var appStoreImageIconName = "appStoreIcon"
    
    var isBankInstalled: Bool {
        selectedPaymentProvider?.appSchemeIOS.canOpenURLString() ?? false
    }

    init(selectedPaymentProvider: PaymentProvider?) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
        self.paymentProviderColors = selectedPaymentProvider?.colors
        
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)

        self.titleLabelFont = giniHealthConfiguration.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.moreInformationLabelFont = giniHealthConfiguration.textStyleFonts[.caption1] ?? defaultRegularFont
        
        self.calculateHeights()
    }
    
    private func calculateHeights() {
        let totalBottomViewHeight = Constants.blankBottomViewHeight
        if totalBottomViewHeight > maximumViewHeight {
            self.bottomViewHeight = maximumViewHeight
        } else {
            self.bottomViewHeight = Constants.blankBottomViewHeight
        }
    }
    
    func didTapOnContinue() {
        viewDelegate?.didTapOnContinue()
    }
}

extension InstallAppBottomViewModel {
    enum Constants {
        static let blankBottomViewHeight: CGFloat = 320.0
        static let topPaddingView: CGFloat = 100.0
    }
}
