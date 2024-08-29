//
//  MockPaymentComponents.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
@testable import GiniMerchantSDK
@testable import GiniHealthAPILibrary

class MockPaymentComponents: PaymentComponentsProtocol {

    var isLoading: Bool = false
    var selectedPaymentProvider: GiniMerchantSDK.PaymentProvider?
    
    private var giniMerchant: GiniMerchant
    private var paymentProviders: GiniMerchantSDK.PaymentProviders = []
    private var installedPaymentProviders: GiniMerchantSDK.PaymentProviders = []
    private let giniMerchantConfiguration = GiniMerchantConfiguration.shared
    
    init(giniMerchant: GiniMerchant) {
        self.giniMerchant = giniMerchant
    }
    
    func loadPaymentProviders() {
        isLoading = false
        guard let paymentProviderResponse: PaymentProviderResponse = load(fromFile: "provider") else {
            return
        }
        if let iconData = Data(url: URL(string: paymentProviderResponse.iconLocation)) {
            let openWithPlatforms = paymentProviderResponse.openWithSupportedPlatforms.compactMap { GiniMerchantSDK.PlatformSupported(rawValue: $0.rawValue) }
            let gpcSupportedPlatforms = paymentProviderResponse.gpcSupportedPlatforms.compactMap { GiniMerchantSDK.PlatformSupported(rawValue: $0.rawValue) }
            let colors = GiniMerchantSDK.ProviderColors(background: paymentProviderResponse.colors.background,
                                                        text: paymentProviderResponse.colors.text)
            
            let provider = GiniMerchantSDK.PaymentProvider(id: paymentProviderResponse.id,
                                                           name: paymentProviderResponse.name,
                                                           appSchemeIOS: paymentProviderResponse.appSchemeIOS,
                                                           minAppVersion: nil,
                                                           colors: colors,
                                                           iconData: iconData,
                                                           appStoreUrlIOS: paymentProviderResponse.appStoreUrlIOS,
                                                           universalLinkIOS: paymentProviderResponse.universalLinkIOS,
                                                           index: paymentProviderResponse.index,
                                                           gpcSupportedPlatforms: gpcSupportedPlatforms,
                                                           openWithSupportedPlatforms: openWithPlatforms)
            
            selectedPaymentProvider = provider
        }
    }
    
    func checkIfDocumentIsPayable(docId: String, completion: @escaping (Result<Bool, GiniMerchantError>) -> Void) {
        switch docId {
        case MockSessionManager.payableDocumentID:
            completion(.success(true))
        case MockSessionManager.notPayableDocumentID:
            completion(.success(false))
        case MockSessionManager.missingDocumentID:
            completion(.failure(.apiError(GiniError.decorator(.noResponse))))
        default:
            fatalError("Document id not handled in tests")
        }
    }
    
    func paymentView(documentId: String?) -> UIView {
        let viewModel = PaymentComponentViewModel(paymentProvider: selectedPaymentProvider, giniMerchantConfiguration: giniMerchantConfiguration)
        viewModel.documentId = documentId
        let view = PaymentComponentView()
        view.viewModel = viewModel
        return view
    }
    
    func bankSelectionBottomSheet() -> UIViewController {
        let paymentProvidersBottomViewModel = BanksBottomViewModel(paymentProviders: paymentProviders,
                                                                   selectedPaymentProvider: selectedPaymentProvider)
        let paymentProvidersBottomView = BanksBottomView(viewModel: paymentProvidersBottomViewModel)
        return paymentProvidersBottomView
    }
    
    func loadPaymentReviewScreenFor(documentID: String?, paymentInfo: GiniMerchantSDK.PaymentInfo?, trackingDelegate: (any GiniMerchantSDK.GiniMerchantTrackingDelegate)?, completion: @escaping (UIViewController?, GiniMerchantSDK.GiniMerchantError?) -> Void) {
        switch documentID {
        case MockSessionManager.payableDocumentID:
            completion(PaymentReviewViewController(), nil)
        case MockSessionManager.missingDocumentID:
            completion(nil, .apiError(GiniError.decorator(.noResponse)))
        default:
            fatalError("Document id not handled in tests")
        }
    }
    
    func paymentInfoViewController() -> UIViewController {
        let paymentInfoViewController = PaymentInfoViewController()
        let paymentInfoViewModel = PaymentInfoViewModel(paymentProviders: paymentProviders)
        paymentInfoViewController.viewModel = paymentInfoViewModel
        return paymentInfoViewController
    }

    func paymentViewBottomSheet(documentID: String?) -> UIViewController {
        let paymentComponentBottomView = PaymentComponentBottomView(paymentView: paymentView(documentId: documentID))
        return paymentComponentBottomView
    }
}
