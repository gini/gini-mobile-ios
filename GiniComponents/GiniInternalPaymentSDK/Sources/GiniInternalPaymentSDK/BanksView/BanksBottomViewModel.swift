//
//  BanksBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

/**
    BanksSelectionProtocol provides trigger events for the actions happening in the BankSelection view
 */
public protocol BanksSelectionProtocol: AnyObject {
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
    public weak var viewDelegate: BanksSelectionProtocol?
    public var documentId: String?

    var paymentProviders: [PaymentProviderAdditionalInfo] = []
    private var selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?
    var maximumViewHeight: CGFloat = 0

    let rowHeight: CGFloat = Constants.cellSizeHeight
    var bottomViewHeight: CGFloat = 0
    var heightTableView: CGFloat = 0

    private var urlOpener: URLOpener
    
    var clientConfiguration: ClientConfiguration?
    var shouldShowBrandedView: Bool {
        clientConfiguration?.ingredientBrandType == .paymentComponent || clientConfiguration?.ingredientBrandType == .fullVisible
    }

    public init(paymentProviders: PaymentProviders,
                selectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider?,
                configuration: BankSelectionConfiguration,
                strings: BanksBottomStrings,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                moreInformationConfiguration: MoreInformationConfiguration,
                moreInformationStrings: MoreInformationStrings,
                urlOpener: URLOpener = URLOpener(UIApplication.shared),
                clientConfiguration: ClientConfiguration?) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.urlOpener = urlOpener
        self.configuration = configuration
        self.strings = strings
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.moreInformationViewModel = MoreInformationViewModel(configuration: moreInformationConfiguration, strings: moreInformationStrings)
        self.clientConfiguration = clientConfiguration

        self.paymentProviders = paymentProviders
            .map({ PaymentProviderAdditionalInfo(isSelected: $0.id == selectedPaymentProvider?.id,
                                                 isInstalled: isPaymentProviderInstalled(paymentProvider: $0),
                                                 paymentProvider: $0)})
            .filter { $0.paymentProvider.gpcSupportedPlatforms.contains(.ios) || $0.paymentProvider.openWithSupportedPlatforms.contains(.ios) }
            .sorted {
                // First, sort by isInstalled
                if $0.isInstalled != $1.isInstalled {
                    return $0.isInstalled && !$1.isInstalled
                }
                // Then sort by paymentProvider.index if both have the same isInstalled value
                return ($0.paymentProvider.index ?? 0) < ($1.paymentProvider.index ?? 0)
            }
        self.calculateHeights()
    }

    func calculateHeights() {
        let totalTableViewHeight = CGFloat(paymentProviders.count) * Constants.cellSizeHeight
        let totalBottomViewHeight = Constants.blankBottomViewHeight + totalTableViewHeight
        let deviceOrientation = UIDevice.current.orientation
        var topPaddingView: CGFloat = 0
        if deviceOrientation == .portrait {
            topPaddingView = Constants.topPaddingViewPortrait
        } else if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
            topPaddingView = Constants.topPaddingViewLandscape
        }
        maximumViewHeight = UIScreen.main.bounds.height - topPaddingView
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
        static let topPaddingViewPortrait: CGFloat = 100.0
        static let topPaddingViewLandscape: CGFloat = 10.0
    }
}
