//
//  AlternativeNavigationTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniUtilites
@testable import GiniHealthSDK
@testable import GiniInternalPaymentSDK

struct AlternativeNavigationTests {
    
    private var giniHelper: GiniSetupHelper
    private var giniHealthDelegate: MockGiniHealthDelegate
    private var homeViewController: UIViewController
    private var homeNavigationController: MockNavigationController

    @MainActor
    init() {
        giniHelper = GiniSetupHelper()
        giniHelper.setup()
        giniHealthDelegate = MockGiniHealthDelegate()
        homeViewController = MockVieWController()
        homeNavigationController = MockNavigationController(rootViewController: homeViewController)
        giniHelper.giniHealth.delegate = giniHealthDelegate
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
        navigationController.giniHealthDelegate = giniHealthDelegate
        
        homeViewController.present(navigationController, animated: false)
        
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: nil,
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        navigationController.dismiss(animated: true)
        
        #expect(giniHealthDelegate.didDismissHealthSDKCount == 1)
    }
    
    @MainActor
    @Test func dismissSDKPaymentReviewComponent() {
        let navigationController = MockNavigationController()
        navigationController.giniHealthDelegate = giniHealthDelegate
        
        homeViewController.present(navigationController, animated: false)
        
        giniHelper.giniHealth.paymentComponentsController.selectedPaymentProvider = giniPaymentProvider()
        
        giniHelper.giniHealth.startPaymentFlow(documentId: nil,
                                               paymentInfo: giniPaymentInfo(),
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        navigationController.dismiss(animated: true)
        
        #expect(giniHealthDelegate.didDismissHealthSDKCount == 1)
    }
    
    @MainActor
    @Test func dismissSDKPaymentReviewComponentWithDocument() {
        let navigationController = MockNavigationController()
        navigationController.giniHealthDelegate = giniHealthDelegate
        
        homeViewController.present(navigationController, animated: false)
        
        giniHelper.giniHealth.paymentComponentsController.selectedPaymentProvider = giniPaymentProvider()
        
        giniHelper.giniHealth.startPaymentFlow(documentId: "test",
                                               paymentInfo: giniPaymentInfo(),
                                               navigationController: navigationController,
                                               trackingDelegate: nil)
        
        navigationController.dismiss(animated: true)
        
        #expect(giniHealthDelegate.didDismissHealthSDKCount == 0)
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
        presentedViewControllers.first as? PaymentComponentBottomView
    }
    
    var paymentComponentReviewViewController: PaymentReviewViewController? {
        pushedViewControllers.last as? PaymentReviewViewController
    }
    
    private var presentedViewControllers: [UIViewController] = []
    private var pushedViewControllers: [UIViewController] = []
    
    var giniHealthDelegate: GiniHealthDelegate?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllers.append(viewControllerToPresent)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if !presentedViewControllers.isEmpty {
            presentedViewControllers.removeLast()
            giniHealthDelegate?.didDismissHealthSDK()
        }
    }
}

private final class MockVieWController: UIViewController {
    
    var dismissCount = 0
    var presentCount = 0
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCount += 1
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCount += 1
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

