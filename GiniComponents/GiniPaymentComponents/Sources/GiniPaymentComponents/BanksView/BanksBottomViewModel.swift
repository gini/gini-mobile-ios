//
//  BanksBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

public protocol BanksBottomViewProtocol: AnyObject {
    func didSelectPaymentProvider(paymentProvider: GiniHealthAPILibrary.PaymentProvider)
    func didTapOnMoreInformation()
    func didTapOnClose()
    func didTapOnContinueOnShareBottomSheet()
    func didTapForwardOnInstallBottomSheet()
    func didTapOnPayButton()
}

struct PaymentProviderAdditionalInfo {
    var isSelected: Bool
    var isInstalled: Bool
    let paymentProvider: GiniHealthAPILibrary.PaymentProvider
}

public final class BanksBottomViewModel {
    let configuration: BankSelectionConfiguration
    let strings: BanksBottomStrings
    let poweredByGiniViewModel: PoweredByGiniViewModel
    let moreInformationViewModel: MoreInformationViewModel
    public weak var viewDelegate: BanksBottomViewProtocol?

    var paymentProviders: [PaymentProviderAdditionalInfo] = []
    private var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?

    let maximumViewHeight: CGFloat = UIScreen.main.bounds.height - Constants.topPaddingView
    let rowHeight: CGFloat = Constants.cellSizeHeight
    var bottomViewHeight: CGFloat = 0
    var heightTableView: CGFloat = 0

    private var urlOpener: URLOpener

    public init(paymentProviders: PaymentProviders,
                selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?,
                configuration: BankSelectionConfiguration,
                strings: BanksBottomStrings,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                moreInformationConfiguration: MoreInformationConfiguration,
                moreInformationStrings: MoreInformationStrings,
                urlOpener: URLOpener = URLOpener(UIApplication.shared)) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.urlOpener = urlOpener
        self.configuration = configuration
        self.strings = strings
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.moreInformationViewModel = MoreInformationViewModel(configuration: moreInformationConfiguration, strings: moreInformationStrings)

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
        let bankSelectionTableViewCellModelColors = BankSelectionTableViewCellModelColors(
            backgroundColor: configuration.bankCellBackgroundColor,
            bankNameAccentColor: configuration.bankCellNameAccentColor,
            bankIconBorderColor: configuration.bankCellIconBorderColor,
            selectedBankBorderColor: configuration.bankCellSelectedBorderColor,
            notSelectedBankBorderColor: configuration.bankCellNotSelectedBorderColor
        )
        return BankSelectionTableViewCellModel(
            paymentProvider: paymentProvider,
            bankNameFont: configuration.bankCellNameFont,
            colors: bankSelectionTableViewCellModelColors,
            selectionIndicatorImage: configuration.bankCellSelectionIndicatorImage
        )
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
