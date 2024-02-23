//
//  PaymentProvidersBottomViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

public protocol PaymentProvidersBottomViewProtocol: AnyObject {
    func didSelectPaymentProvider(paymentProvider: PaymentProvider)
    func didTapOnClose()
}

struct PaymentProviderAdditionalInfo {
    var isSelected: Bool
    var isInstalled: Bool
    let paymentProvider: PaymentProvider
}

final class PaymentProvidersBottomViewModel {
    
    weak var viewDelegate: PaymentProvidersBottomViewProtocol?

    var paymentProviders: [PaymentProviderAdditionalInfo] = []
    var selectedPaymentProvider: PaymentProvider? = nil
    
    let maximumViewHeight: CGFloat = UIScreen.main.bounds.height - Constants.topPaddingView
    let rowHeight: CGFloat = Constants.cellSizeHeight
    var bottomViewHeight: CGFloat = 0
    var heightTableView: CGFloat = 0

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.light7,
                                                    darkModeColor: UIColor.GiniHealthColors.dark7).uiColor().withAlphaComponent(0.3)

    let selectBankTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let selectBankLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    var selectBankLabelFont: UIFont

    let closeTitleIcon: UIImage = UIImageNamedPreferred(named: "ic_close") ?? UIImage()
    let closeIconAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()

    let descriptionText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentproviderslist.description", comment: "")
    let descriptionLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                        darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    var descriptionLabelFont: UIFont

    init(paymentProviders: PaymentProviders, selectedPaymentProvider: PaymentProvider) {
        self.selectedPaymentProvider = selectedPaymentProvider
        
        let defaultRegularFont: UIFont = GiniHealthConfiguration.shared.customFont.regular
        let defaultBoldFont: UIFont = GiniHealthConfiguration.shared.customFont.regular

        self.selectBankLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.descriptionLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption1] ?? defaultRegularFont
        
        self.paymentProviders = paymentProviders
            .filter({ $0.appStoreUrlIOS != nil || isPaymentProviderInstalled(paymentProvider: $0) })
            .map({ PaymentProviderAdditionalInfo(isSelected: $0.id == selectedPaymentProvider.id,
                                                 isInstalled: isPaymentProviderInstalled(paymentProvider: $0),
                                                 paymentProvider: $0)})
        
        self.calculateHeights()
    }
    
    func updatePaymentProvidersInstalledState() {
        for index in 0 ..< paymentProviders.count {
            paymentProviders[index].isInstalled = isPaymentProviderInstalled(paymentProvider: paymentProviders[index].paymentProvider)
        }
    }
    
    private func calculateHeights() {
        let totalTableViewHeight = CGFloat(paymentProviders.count) * Constants.cellSizeHeight
        let totalBottomViewHeight = Constants.blankBottomViewHeight + totalTableViewHeight
        if totalBottomViewHeight > maximumViewHeight {
            self.heightTableView = maximumViewHeight - Constants.blankBottomViewHeight
            self.bottomViewHeight = maximumViewHeight
        } else {
            self.heightTableView = totalTableViewHeight
            self.bottomViewHeight = totalTableViewHeight + Constants.blankBottomViewHeight
        }
    }

    func paymentProvidersViewModel(paymentProvider: PaymentProviderAdditionalInfo) -> PaymentProviderBottomTableViewCellModel {
        PaymentProviderBottomTableViewCellModel(paymentProvider: paymentProvider)
    }
    
    func didTapOnClose() {
        viewDelegate?.didTapOnClose()
    }
    
    private func isPaymentProviderInstalled(paymentProvider: PaymentProvider) -> Bool {
        if let url = URL(string: paymentProvider.appSchemeIOS) {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
}

extension PaymentProvidersBottomViewModel {
    enum Constants {
        static let blankBottomViewHeight: CGFloat = 200.0
        static let cellSizeHeight: CGFloat = 64.0
        static let topPaddingView: CGFloat = 100.0
    }
}
