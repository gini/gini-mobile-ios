//
//  PaymentReviewViewController+PaymentReviewViewModelDelegate.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

extension PaymentReviewViewController: PaymentReviewViewModelDelegate {
    func presentInstallAppBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
    }

    func createPaymentRequestAndOpenBankApp() {
        self.presentedViewController?.dismiss(animated: true)
        if paymentInfoContainerView.inputFieldsHaveNoErrors() {
            createPaymentRequest()
        }
    }

    func presentShareInvoiceBottomSheet(bottomSheet: BottomSheetViewController) {
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
    }

    func obtainPDFFromPaymentRequest(paymentRequestId: String) {
        model.delegate?.obtainPDFURLFromPaymentRequest(viewController: self,
                                                       paymentRequestId: paymentRequestId)
    }

    func presentBankSelectionBottomSheet(bottomSheet: BottomSheetViewController) {
        print("GINI LOG: Content of \(self.presentingViewController) navigation controller \(self.presentingViewController?.navigationController?.viewControllers) \n")
        print("GINI LOG: Content of \(self) navigation controller \(self.navigationController?.viewControllers) \n")
        print("GINI LOG: Content of bottomSheet navigation controller \(bottomSheet.navigationController?.viewControllers) \n")
        
        print("GINI LOG: top most view controller before presenting banks \(self.presentingViewController?.topMostViewController()) \n")
        print("GINI LOG: top most view controller before presenting banks \(self.topMostViewController()) \n")
        print("GINI LOG: top view controller \(self.navigationController?.topViewController) to present banks sheet \n")
        print("GINI LOG: view controller \(self) to present banks sheet \n")
        
        bottomSheet.minHeight = Constants.inputContainerHeight
        presentBottomSheet(viewController: bottomSheet)
        
        print("GINI LOG: top most view controller after presenting banks \(self.presentingViewController?.topMostViewController()) \n")
        print("GINI LOG: top most view controller after presenting banks \(self.topMostViewController()) \n")
        print("GINI LOG: view controller presenting review after present banks \(self.presentingViewController) \n")
        print("GINI LOG: view controller that review is presenting \(self.presentedViewController) \n")
        print("GINI LOG: view controller presenting review after present banks \(self.presentingViewController?.navigationController?.topViewController) \n")
    }
}

extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }
        
        if let tabBarController = self as? UITabBarController {
            if let selectedTab = tabBarController.selectedViewController {
                if let navigation = selectedTab as? UINavigationController {
                    return navigation.visibleViewController?.topMostViewController() ?? selectedTab
                }
                
                return selectedTab.topMostViewController()
            }
            
            return tabBarController
        }
        
        if let presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        return self
    }
}
