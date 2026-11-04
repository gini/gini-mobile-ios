//
//  PaymentComponentViewModel.swift
//  GiniInternalPaymentSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import Combine
import GiniHealthAPILibrary

public protocol PaymentComponentViewProtocol: AnyObject {
    func didTapOnMoreInformation(documentId: String?)
    func didTapOnBankPicker(documentId: String?)
    func didTapOnPayInvoice(documentId: String?)
    func didDismissPaymentComponent()
}

/**
 Helping extension for using the PaymentComponentViewProtocol methods without the document ID. This should be kept by the document view model and passed hierarchically from there.

 */
extension PaymentComponentViewProtocol {
    public func didTapOnMoreInformation() {
        didTapOnMoreInformation(documentId: nil)
    }
    public func didTapOnBankPicker() {
        didTapOnBankPicker(documentId: nil)
    }
    public func didTapOnPayInvoice() {
        didTapOnPayInvoice(documentId: nil)
    }
}

public final class PaymentComponentViewModel {
    let primaryButtonConfiguration: ButtonConfiguration
    let secondaryButtonConfiguration: ButtonConfiguration
    let configuration: PaymentComponentsConfiguration
    let strings: PaymentComponentsStrings
    let poweredByGiniViewModel: PoweredByGiniViewModel
    let moreInformationViewModel: MoreInformationViewModel
    var paymentProviderColors: GiniHealthAPILibrary.ProviderColors?
    var bankImageIcon: UIImage?

    private var paymentProviderScheme: String?

    public weak var delegate: PaymentComponentViewProtocol?

    public var documentId: String?

    var minimumButtonsHeight: CGFloat

    var hasBankSelected: Bool

    var paymentComponentConfiguration: PaymentComponentConfiguration?
    var clientConfiguration: ClientConfiguration?

    var shouldShowBrandedView: Bool {
        clientConfiguration?.ingredientBrandType == .paymentComponent || clientConfiguration?.ingredientBrandType == .fullVisible
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

    /**
     Called on main after each emission is applied.
     */
    var onPaymentProvidersUpdated: (() -> Void)?

    /**
     Resolves the saved default provider from the latest emission. Supplied by the controller.
     */
    private let selectedProviderResolver: ((GiniHealthAPILibrary.PaymentProviders) -> GiniHealthAPILibrary.PaymentProvider?)?

    private var cancellables = Set<AnyCancellable>()

    public init(paymentProvider: GiniHealthAPILibrary.PaymentProvider?,
                paymentProvidersPublisher: AnyPublisher<GiniHealthAPILibrary.PaymentProviders, Never>,
                primaryButtonConfiguration: ButtonConfiguration,
                secondaryButtonConfiguration: ButtonConfiguration,
                configuration: PaymentComponentsConfiguration,
                strings: PaymentComponentsStrings,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings,
                moreInformationConfiguration: MoreInformationConfiguration,
                moreInformationStrings: MoreInformationStrings,
                minimumButtonsHeight: CGFloat,
                paymentComponentConfiguration: PaymentComponentConfiguration?,
                clientConfiguration: ClientConfiguration?,
                selectedProviderResolver: ((GiniHealthAPILibrary.PaymentProviders) -> GiniHealthAPILibrary.PaymentProvider?)? = nil) {
        self.configuration = configuration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.secondaryButtonConfiguration = secondaryButtonConfiguration
        self.paymentComponentConfiguration = paymentComponentConfiguration
        self.clientConfiguration = clientConfiguration
        self.selectedProviderResolver = selectedProviderResolver

        self.hasBankSelected = paymentProvider != nil
        self.bankImageIcon = paymentProvider?.iconData.toImage
        self.paymentProviderColors = paymentProvider?.colors
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
        self.bankName = paymentProvider?.name

        self.minimumButtonsHeight = minimumButtonsHeight

        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)
        self.moreInformationViewModel = MoreInformationViewModel(configuration: moreInformationConfiguration, strings: moreInformationStrings)

        paymentProvidersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] providers in
                self?.applyPaymentProviders(providers)
            }
            .store(in: &cancellables)
    }

    /**
     Adopts the resolver's provider so the placeholder swaps for the restored bank.
     */
    private func applyPaymentProviders(_ providers: GiniHealthAPILibrary.PaymentProviders) {
        if let resolved = selectedProviderResolver?(providers) {
            hasBankSelected = true
            bankName = resolved.name
            bankImageIcon = resolved.iconData.toImage
            paymentProviderColors = resolved.colors
            paymentProviderScheme = resolved.appSchemeIOS
        }
        onPaymentProvidersUpdated?()
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
