//
//  BanksBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

public protocol PaymentProvidersBottomViewProtocol: AnyObject {
    func didSelectPaymentProvider(paymentProvider: PaymentProvider)
    func didTapOnClose()
    func didTapOnMoreInformation()
    func didTapOnContinueOnShareBottomSheet()
    func didTapForwardOnInstallBottomSheet()
    func didTapOnPayButton()
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

    let backgroundColor: UIColor = GiniColor.standard7.uiColor()
    let rectangleColor: UIColor = GiniColor.standard5.uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)

    let selectBankTitleText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.select.bank.label", 
                                                                       comment: "Select bank text from the top label on payment providers bottom sheet")
    let selectBankLabelAccentColor: UIColor = GiniColor(lightModeColorName: .dark1, darkModeColorName: .light2).uiColor()
    var selectBankLabelFont: UIFont

    let closeTitleIcon: UIImage = GiniMerchantImage.close.preferredUIImage()
    let closeIconAccentColor: UIColor = GiniColor.standard2.uiColor()

    let descriptionText: String = NSLocalizedStringPreferredFormat("gini.merchant.paymentcomponent.payment.providers.list.description", 
                                                                   comment: "Top description text on payment providers bottom sheet")
    let descriptionLabelAccentColor: UIColor = GiniColor.standard3.uiColor()
    var descriptionLabelFont: UIFont
    
    private var urlOpener: URLOpener

    init(paymentProviders: PaymentProviders, selectedPaymentProvider: PaymentProvider?, urlOpener: URLOpener = URLOpener(UIApplication.shared)) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.urlOpener = urlOpener

        self.selectBankLabelFont = GiniMerchantConfiguration.shared.font(for: .subtitle2)
        self.descriptionLabelFont = GiniMerchantConfiguration.shared.font(for: .captions1)

        self.paymentProviders = paymentProviders
            .map({ PaymentProviderAdditionalInfo(isSelected: $0.id == selectedPaymentProvider?.id,
                                                 isInstalled: isPaymentProviderInstalled(paymentProvider: $0),
                                                 paymentProvider: $0)})
            .filter { $0.paymentProvider.gpcSupportedPlatforms.contains(.ios) || $0.paymentProvider.openWithSupportedPlatforms.contains(.ios) }
            .sorted(by: { ($0.paymentProvider.index ?? 0 < $1.paymentProvider.index ?? 0) })
            .sorted(by: { ($0.isInstalled && !$1.isInstalled) })
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
    
    func didTapOnMoreInformation() {
        viewDelegate?.didTapOnMoreInformation()
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
