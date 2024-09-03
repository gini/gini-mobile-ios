//
//  PaymentComponentViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary

public protocol PaymentComponentViewProtocol: AnyObject {
    func didTapOnMoreInformation(documentId: String?)
    func didTapOnBankPicker(documentId: String?)
    func didTapOnPayInvoice(documentId: String?)
}

public final class PaymentComponentViewModel {
    let primaryButtonConfiguration: ButtonConfiguration
    let secondaryButtonConfiguration: ButtonConfiguration
    let configuration: PaymentComponentsConfiguration
    let strings: PaymentComponentsStrings
    let poweredByGiniViewModel: PoweredByGiniViewModel
    let moreInformationViewModel: MoreInformationViewModel
    let paymentProviderColors: GiniHealthAPILibrary.ProviderColors?
    let bankImageIcon: UIImage?

    private var paymentProviderScheme: String?

    public weak var delegate: PaymentComponentViewProtocol?
    
    public var documentId: String?

    var minimumButtonsHeight: CGFloat
    
    var hasBankSelected: Bool

    var paymentComponentConfiguration: PaymentComponentConfiguration?

    var shouldShowBrandedView: Bool {
        paymentComponentConfiguration?.isPaymentComponentBranded ?? true
    }

    var showPaymentComponentInOneRow: Bool {
        paymentComponentConfiguration?.showPaymentComponentInOneRow ?? false
    }

    var hideInfoForReturningUser: Bool {
        paymentComponentConfiguration?.hideInfoForReturningUser ?? false
    }

    var bankName: String?

    var selectBankButtonText: String {
        showPaymentComponentInOneRow ? strings.placeholderBankNameText : bankName ?? strings.placeholderBankNameText
    }

    public init(paymentProvider: GiniHealthAPILibrary.PaymentProvider?,
                primaryButtonConfiguration: ButtonConfiguration,
                secondaryButtonConfiguration: ButtonConfiguration,
                configuration: PaymentComponentsConfiguration,
                strings: PaymentComponentsStrings,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                moreInformationConfiguration: MoreInformationConfiguration,
                moreInformationStrings: MoreInformationStrings,
                minimumButtonsHeight: CGFloat,
                paymentComponentConfiguration: PaymentComponentConfiguration?) {
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.secondaryButtonConfiguration = secondaryButtonConfiguration
        self.paymentComponentConfiguration = paymentComponentConfiguration

        self.hasBankSelected = paymentProvider != nil
        self.bankImageIcon = paymentProvider?.iconData.toImage
        self.paymentProviderColors = paymentProvider?.colors
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
        self.bankName = paymentProvider?.name

        self.minimumButtonsHeight = minimumButtonsHeight

        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.moreInformationViewModel = MoreInformationViewModel(configuration: moreInformationConfiguration, strings: moreInformationStrings)
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation(documentId: documentId)
    }
    
    func tapOnBankPicker() {
        delegate?.didTapOnBankPicker(documentId: documentId)
    }
    
    func tapOnPayInvoiceView() {
        savePaymentComponentViewUsageStatus()
        delegate?.didTapOnPayInvoice(documentId: documentId)
    }
    
    // Function to check if Payment was used at least once
    func isPaymentComponentUsed() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.paymentComponentViewUsedKey)
    }
    
    // Function to save the boolean value indicating whether Payment was used
    private func savePaymentComponentViewUsageStatus() {
        UserDefaults.standard.set(true, forKey: Constants.paymentComponentViewUsedKey)
    }
}

extension PaymentComponentViewModel {
    private enum Constants {
        static let paymentComponentViewUsedKey = "kPaymentComponentViewUsed"
    }
}
