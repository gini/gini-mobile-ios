//
//  AlternativeNavigationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation
import Testing
import UIKit
import GiniUtilites
@testable import GiniHealthSDK
@testable import GiniInternalPaymentSDK
@testable import GiniHealthSDKExample

final class AlternativeNavigationTests {
    
    private var giniHelper: GiniSetupHelper
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var giniHealthDelegate: MockGiniHealthDelegate
    private var homeViewController: UIViewController
    private var homeNavigationController: MockNavigationController

    @MainActor
    init() {
        giniHelper = GiniSetupHelper()
        giniHelper.setup()
        homeViewController = UIViewController()
        homeNavigationController = MockNavigationController(rootViewController: homeViewController)
        giniHealthDelegate = MockGiniHealthDelegate()
        giniHelper.giniHealth.delegate = giniHealthDelegate
        
        appDelegate.coordinator.selectAPIViewController.show(homeNavigationController, sender: nil)
        _ = homeNavigationController.view
    }
    
    @MainActor
    @Test func presentPaymentComponent() {
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: nil,
                                               navigationController: homeNavigationController,
                                               trackingDelegate: nil)
        
        #expect(homeNavigationController.paymentComponentBottomView != nil)
    }
    
    @MainActor
    @Test func presentPaymentReviewComponent() {
        giniHelper.giniHealth.paymentComponentsController.selectedPaymentProvider = giniPaymentProvider()
        
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: giniPaymentInfo(),
                                               navigationController: homeNavigationController,
                                               trackingDelegate: nil)
        
        #expect(homeNavigationController.paymentComponentReviewViewController != nil)
    }
    
    @MainActor
    @Test func presentPaymentComponentInANewNavigation() {
        let navigationController = MockNavigationController()
        
        homeViewController.present(navigationController, animated: true)
        
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: nil,
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        #expect(homeNavigationController.paymentComponentBottomView == nil)
        #expect(navigationController.paymentComponentBottomView != nil)
    }
    
    @MainActor
    @Test func presentPaymentReviewComponentInANewNavigation() {
        let navigationController = MockNavigationController()
        
        homeViewController.present(navigationController, animated: true)
        
        giniHelper.giniHealth.paymentComponentsController.selectedPaymentProvider = giniPaymentProvider()
        
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: giniPaymentInfo(),
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        #expect(homeNavigationController.paymentComponentReviewViewController == nil)
        #expect(navigationController.paymentComponentReviewViewController != nil)
    }
    
    @MainActor
    @Test func dismissSDKPaymentComponent() {
        let navigationController = MockNavigationController()
        
        homeViewController.present(navigationController, animated: true)
        _ = navigationController.view
        
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: nil,
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        navigationController.paymentComponentBottomView?.dismiss(animated: true)
        
        #expect(giniHealthDelegate.didDismissHealthSDKCount == 1)
    }
    
    @MainActor
    @Test func dismissSDKPaymentReviewComponent() {
        let navigationController = MockNavigationController()
        
        homeViewController.present(navigationController, animated: true)
        giniHelper.giniHealth.paymentComponentsController.selectedPaymentProvider = giniPaymentProvider()
        
        giniHelper.giniHealth.startPaymentFlow(documentId: nil,
                                               paymentInfo: giniPaymentInfo(),
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        #expect(giniHealthDelegate.didDismissHealthSDKCount == 1)
    }

    private func giniPaymentInfo() -> GiniHealthSDK.PaymentInfo {
        PaymentInfo(recipient: "testRecipient",
                           iban: "DE1234567890123456789",
                           bic: "",
                           amount: "23.45",
                           purpose: "testPurpouse",
                           paymentUniversalLink: "",
                           paymentProviderId: "b09ef70a-490f-11eb-952e-9bc6f4646c57")
    }
    
    private func giniPaymentProvider() -> PaymentProvider {
        PaymentProvider(id: "test_id",
                        name: "test",
                        appSchemeIOS: "",
                        minAppVersion: nil,
                        colors: ProviderColors(background: "",
                                               text: ""),
                        iconData: Data(),
                        appStoreUrlIOS: nil,
                        universalLinkIOS: "",
                        index: nil,
                        gpcSupportedPlatforms: [.ios],
                        openWithSupportedPlatforms: [.ios])
    }
}

private final class MockNavigationController: UINavigationController {
    
    var paymentComponentBottomView: PaymentComponentBottomView? {
        presentedViewControllers.last as? PaymentComponentBottomView
    }
    
    var paymentComponentReviewViewController: PaymentReviewViewController? {
        pushedViewControllers.last as? PaymentReviewViewController
    }
    
    private var presentedViewControllers: [UIViewController] = []
    private var pushedViewControllers: [UIViewController] = []
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: false, completion: completion)
        presentedViewControllers.append(viewControllerToPresent)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
        pushedViewControllers.append(viewController)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: false, completion: completion)
        
        presentedViewControllers.removeLast()
    }
}

private final class MockGiniHealthDelegate: GiniHealthDelegate {
    
    var didCreatePaymentRequestCount = 0
    var shouldHandleErrorInternallyCount = 0
    var didDismissHealthSDKCount = 0
    
    func didCreatePaymentRequest(paymentRequestId: String) {
        didCreatePaymentRequestCount += 1
    }
    
    func shouldHandleErrorInternally(error: GiniHealthSDK.GiniHealthError) -> Bool {
        shouldHandleErrorInternallyCount += 1
        
        return false
    }
    
    func didDismissHealthSDK() {
        didDismissHealthSDKCount += 1
    }
}

