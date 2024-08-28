//
//  ScreenAPICoordinator.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import GiniCaptureSDK
import GiniMerchantSDK
import GiniPaymentComponents
import UIKit

protocol ScreenAPICoordinatorDelegate: AnyObject {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ())
    func presentOrdersList(orders: [Order]?)
}

final class ScreenAPICoordinator: NSObject, Coordinator {
    
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController
    }
    
    var giniMerchant: GiniMerchant?
    var screenAPIViewController: UINavigationController!

    weak var analysisDelegate: AnalysisDelegate?
    var visionDocuments: [GiniCaptureDocument]?
    var visionConfiguration: GiniConfiguration
    private var captureExtractedResults: [GiniBankAPILibrary.Extraction] = []
    private var hardcodedOrdersController: HardcodedOrdersController
    private var paymentComponentController: PaymentComponentsController
    
    // {extraction name} : {entity name}
    private let editableSpecificExtractions = ["paymentRecipient" : "companyname", "paymentReference" : "reference", "paymentPurpose" : "text", "iban" : "iban", "bic" : "bic", "amountToPay" : "amount"]
    
    init(configuration: GiniConfiguration,
         importedDocuments documents: [GiniCaptureDocument]?,
         hardcodedOrdersController: HardcodedOrdersController,
         paymentComponentController: PaymentComponentsController) {
        visionConfiguration = configuration
        visionDocuments = documents
        self.hardcodedOrdersController = hardcodedOrdersController
        self.paymentComponentController = paymentComponentController
        super.init()
    }
    
    func onPaymentReviewScreenEvent(event: GiniMerchantSDK.TrackingEvent<GiniMerchantSDK.PaymentReviewScreenEventType>) {
    }
}
// MARK: - UINavigationControllerDelegate

extension ScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is PaymentReviewViewController {
            delegate?.screenAPI(coordinator: self, didFinish: ())
        }
        return nil
    }
}
