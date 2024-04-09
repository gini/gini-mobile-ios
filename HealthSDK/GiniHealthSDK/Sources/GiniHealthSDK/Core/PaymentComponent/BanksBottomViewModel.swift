//
//  BanksBottomViewModel.swift
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

final class BanksBottomViewModel {
    
    weak var viewDelegate: PaymentProvidersBottomViewProtocol?

    var paymentProviders: [PaymentProviderAdditionalInfo] = []
    private var selectedPaymentProvider: PaymentProvider?
    
    let maximumViewHeight: CGFloat = UIScreen.main.bounds.height - Constants.topPaddingView
    let rowHeight: CGFloat = Constants.cellSizeHeight
    var bottomViewHeight: CGFloat = 0
    var heightTableView: CGFloat = 0

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)

    let selectBankTitleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", 
                                                                       comment: "Select bank text from the top label on payment providers bottom sheet")
    let selectBankLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    var selectBankLabelFont: UIFont

    let closeTitleIcon: UIImage = UIImageNamedPreferred(named: "ic_close") ?? UIImage()
    let closeIconAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                  darkModeColor: UIColor.GiniHealthColors.light2).uiColor()

    let descriptionText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentproviderslist.description", 
                                                                   comment: "Top description text on payment providers bottom sheet")
    let descriptionLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                         darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    var descriptionLabelFont: UIFont
    
    private var urlOpener: URLOpener

    init(paymentProviders: PaymentProviders, selectedPaymentProvider: PaymentProvider?, urlOpener: URLOpener = URLOpener(UIApplication.shared)) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.urlOpener = urlOpener
        
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)

        self.selectBankLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.descriptionLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption1] ?? defaultRegularFont
        
        self.paymentProviders = paymentProviders
            .map({ PaymentProviderAdditionalInfo(isSelected: $0.id == selectedPaymentProvider?.id,
                                                 isInstalled: isPaymentProviderInstalled(paymentProvider: $0),
                                                 paymentProvider: $0)})
            .sorted(by: { $0.isInstalled && !$1.isInstalled })
        self.calculateHeights()
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

    func paymentProvidersViewModel(paymentProvider: PaymentProviderAdditionalInfo) -> BankSelectionTableViewCellModel {
        BankSelectionTableViewCellModel(paymentProvider: paymentProvider)
    }
    
    func didTapOnClose() {
        viewDelegate?.didTapOnClose()
    }
    
    private func isPaymentProviderInstalled(paymentProvider: PaymentProvider) -> Bool {
        if let urlAppScheme = URL(string: paymentProvider.appSchemeIOS) {
            return urlOpener.canOpenLink(url: urlAppScheme)
        }
        return false
    }
}

extension BanksBottomViewModel {
    enum Constants {
        static let blankBottomViewHeight: CGFloat = 200.0
        static let cellSizeHeight: CGFloat = 64.0
        static let topPaddingView: CGFloat = 100.0
    }
}
