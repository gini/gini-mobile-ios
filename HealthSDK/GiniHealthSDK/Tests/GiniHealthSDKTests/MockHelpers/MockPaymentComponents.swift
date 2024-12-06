//
//  MockPaymentComponentsController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

class MockPaymentComponents: PaymentComponentsProtocol {

    var isLoading: Bool = false
    var selectedPaymentProvider: GiniHealthSDK.PaymentProvider?
    private var healthSelectedPaymentProvider: GiniHealthAPILibrary.PaymentProvider? {
        selectedPaymentProvider?.toHealthPaymentProvider()
    }

    private var giniHealth: GiniHealth
    private var paymentProviders: GiniHealthSDK.PaymentProviders = []
    private var installedPaymentProviders: GiniHealthSDK.PaymentProviders = []
    private let giniHealthConfiguration = GiniHealthConfiguration.shared
    private let configurationProvider: PaymentComponentsConfigurationProvider
    private let stringsProvider: PaymentComponentsStringsProvider
    var documentId: String?

    init(giniHealth: GiniHealth & PaymentComponentsConfigurationProvider & PaymentComponentsStringsProvider) {
        self.giniHealth = giniHealth
        self.configurationProvider = giniHealth
        self.stringsProvider = giniHealth
    }
    
    func loadPaymentProviders() {
        isLoading = false
        guard let paymentProviderResponse: PaymentProviderResponse = load(fromFile: "provider") else {
            return
        }
        if let iconData = Data(url: URL(string: paymentProviderResponse.iconLocation)) {
            let provider = GiniHealthAPILibrary.PaymentProvider(id: paymentProviderResponse.id, name: paymentProviderResponse.name, appSchemeIOS: paymentProviderResponse.appSchemeIOS, minAppVersion: paymentProviderResponse.minAppVersion, colors: paymentProviderResponse.colors, iconData: iconData, appStoreUrlIOS: paymentProviderResponse.appStoreUrlIOS, universalLinkIOS: paymentProviderResponse.universalLinkIOS, index: paymentProviderResponse.index, gpcSupportedPlatforms: paymentProviderResponse.gpcSupportedPlatforms, openWithSupportedPlatforms: paymentProviderResponse.openWithSupportedPlatforms)
            selectedPaymentProvider = GiniHealthSDK.PaymentProvider(healthPaymentProvider: provider)

        }
    }

    func checkIfDocumentIsPayable(documentId: String, completion: @escaping (Result<Bool, GiniHealthError>) -> Void) {
        switch documentId {
        case MockSessionManager.payableDocumentID:
            completion(.success(true))
        case MockSessionManager.notPayableDocumentID:
            completion(.success(false))
        case MockSessionManager.missingDocumentID:
            completion(.failure(.apiError(.decorator(.noResponse))))
        default:
            fatalError("Document id not handled in tests")
        }
    }

    func checkIfDocumentContainsMultipleInvoices(documentId: String, completion: @escaping (Result<Bool, GiniHealthSDK.GiniHealthError>) -> Void) {
        switch documentId {
        case MockSessionManager.payableDocumentID:
            completion(.success(false))
        case MockSessionManager.notPayableDocumentID:
            completion(.success(true))
        case MockSessionManager.missingDocumentID:
            completion(.failure(.apiError(.decorator(.noResponse))))
        default:
            fatalError("Document id not handled in tests")
        }
    }

    func paymentView() -> UIView {
        let paymentComponentViewModel = PaymentComponentViewModel(
            paymentProvider: healthSelectedPaymentProvider,
            primaryButtonConfiguration: configurationProvider.primaryButtonConfiguration,
            secondaryButtonConfiguration: configurationProvider.secondaryButtonConfiguration,
            configuration: configurationProvider.paymentComponentsConfiguration,
            strings: stringsProvider.paymentComponentsStrings,
            poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
            poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
            moreInformationConfiguration: configurationProvider.moreInformationConfiguration,
            moreInformationStrings: stringsProvider.moreInformationStrings,
            minimumButtonsHeight: configurationProvider.paymentComponentButtonsHeight,
            paymentComponentConfiguration: configurationProvider.paymentComponentConfiguration
        )
        paymentComponentViewModel.documentId = MockSessionManager.payableDocumentID
        let view = PaymentComponentView(viewModel: paymentComponentViewModel)
        return view
    }
    
    func bankSelectionBottomSheet() -> UIViewController {
        let paymentProvidersBottomViewModel = BanksBottomViewModel(paymentProviders: paymentProviders.map { $0.toHealthPaymentProvider() },
                                                                   selectedPaymentProvider: healthSelectedPaymentProvider,
                                                                   configuration: configurationProvider.bankSelectionConfiguration,
                                                                   strings: stringsProvider.banksBottomStrings,
                                                                   poweredByGiniConfiguration: configurationProvider.poweredByGiniConfiguration,
                                                                   poweredByGiniStrings: stringsProvider.poweredByGiniStrings,
                                                                   moreInformationConfiguration: configurationProvider.moreInformationConfiguration,
                                                                   moreInformationStrings: stringsProvider.moreInformationStrings)
        return BanksBottomView(viewModel: paymentProvidersBottomViewModel, bottomSheetConfiguration: configurationProvider.bottomSheetConfiguration)
    }

    func loadPaymentReviewScreenFor(trackingDelegate: (any GiniHealthSDK.GiniHealthTrackingDelegate)?,
                                    previousPaymentComponentScreenType: GiniInternalPaymentSDK.PaymentComponentScreenType?,
                                    completion: @escaping (UIViewController?, GiniHealthSDK.GiniHealthError?) -> Void) {
        completion(UIViewController(), nil)
    }

    func paymentInfoViewController() -> UIViewController {
        let paymentInfoViewModel = PaymentInfoViewModel(paymentProviders: paymentProviders.map { $0.toHealthPaymentProvider() },
                                                        configuration: giniHealth.paymentInfoConfiguration,
                                                        strings: giniHealth.paymentInfoStrings,
                                                        poweredByGiniConfiguration: giniHealth.poweredByGiniConfiguration,
                                                        poweredByGiniStrings: giniHealth.poweredByGiniStrings)
        let paymentInfoViewController = PaymentInfoViewController(viewModel: paymentInfoViewModel)
        return paymentInfoViewController
    }

    func paymentViewBottomSheet() -> UIViewController {
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(),
                                                                    bottomSheetConfiguration: giniHealth.bottomSheetConfiguration)
        return paymentComponentBottomView
    }

}
