//
//  PaymentInvoiceRoutingTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

/**
 Swift Testing coverage for the payment-invoice tap routing changes introduced
 in PR #1260 on `PaymentComponentsController+Helpers.swift`.

 Covers `didTapOnPayInvoice(documentId:)` and the routing it does through the
 four private helpers (`shouldShowPaymentReviewScreen`, `handlePaymentReviewFlow`,
 `handleExternalPaymentFlow`, `handleOpenWithPayment`, `handleGPCPayment`), plus
 the three public predicates the external flow branches on (`supportsOpenWith`,
 `supportsGPC`, `canOpenPaymentProviderApp`).

 The private helpers cannot be invoked directly, so they are covered by driving
 `didTapOnPayInvoice(documentId:)` with the state that routes into each branch
 and observing side effects on the spy `UINavigationController` and the delegate.

 The suite is `.serialized` because tests mutate `GiniHealthConfiguration.shared`.
 The class-based suite saves and restores the two toggled flags in `init`/`deinit`
 so tests are order-independent.
 */
@Suite("Payment invoice tap routing (PR #1260)", .serialized)
final class PaymentInvoiceRoutingTests {

    // MARK: - Test fixtures

    private let giniHealthAPI: GiniHealthAPI
    private let giniHealth: GiniHealth
    private let sut: PaymentComponentsController
    private let spyNavigationController: SpyNavigationController
    private let delegateSpy: PaymentComponentsControllerDelegateSpy

    private let savedShowPaymentReviewScreen: Bool
    private let savedUseInvoiceWithoutDocument: Bool

    init() {
        let sessionManager = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManager,
                                                    apiVersion: 5)
        let paymentService = PaymentService(sessionManager: sessionManager,
                                            apiVersion: 5)
        let clientConfigurationService = ClientConfigurationService(sessionManager: sessionManager,
                                                                    apiVersion: 5)
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: clientConfigurationService)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
        sut = giniHealth.paymentComponentsController

        spyNavigationController = SpyNavigationController()
        sut.navigationControllerProvided = spyNavigationController

        delegateSpy = PaymentComponentsControllerDelegateSpy()
        sut.delegate = delegateSpy

        savedShowPaymentReviewScreen = GiniHealthConfiguration.shared.showPaymentReviewScreen
        savedUseInvoiceWithoutDocument = GiniHealthConfiguration.shared.useInvoiceWithoutDocument
    }

    deinit {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = savedShowPaymentReviewScreen
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = savedUseInvoiceWithoutDocument
    }

    // MARK: - `didTapOnPayInvoice` config-based routing

    @Test("Review flow is routed to when `useInvoiceWithoutDocument` is false (isLoading toggles)")
    func routesToReviewFlow_whenUseInvoiceWithoutDocumentIsFalse() throws {
        // Route into `handlePaymentReviewFlow` → `loadPaymentReviewScreenFor` which
        // sets `isLoading = true` on the `!useInvoiceWithoutDocument` branch when
        // a document id is set. That toggle is observable through the delegate.
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = false
        sut.documentId = MockSessionManager.payableDocumentID

        sut.didTapOnPayInvoice(documentId: MockSessionManager.payableDocumentID)

        #expect(delegateSpy.loadingStateChanges.contains(true),
                "The review flow should toggle `isLoading = true` before fetching data-for-review")
    }

    @Test("External flow (no-op branches) is routed to when both flags favor external")
    func routesToExternalFlow_whenBothFlagsFalse() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        // A provider that supports neither openWith nor GPC means `handleExternalPaymentFlow`
        // falls through both branches. No navigation event is emitted, and no `isLoading`
        // toggle fires — proof that `shouldShowPaymentReviewScreen` returned false.
        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        sut.paymentInfo = nil

        sut.didTapOnPayInvoice(documentId: nil)

        #expect(spyNavigationController.presented.isEmpty)
        #expect(spyNavigationController.pushed.isEmpty)
        #expect(delegateSpy.loadingStateChanges.isEmpty,
                "External flow with unsupported provider must not toggle `isLoading`")
    }

    // MARK: - GPC branch — the key PR #1260 regression

    @Test("Install-app sheet is reachable via GPC when `paymentInfo` is nil (PR #1260 regression)")
    func installAppSheet_isPresented_onGPCPath_whenPaymentInfoIsNil() throws {
        // Route into `handleExternalPaymentFlow`
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        // A GPC-supporting provider whose scheme cannot be opened → `canOpenPaymentProviderApp`
        // returns false → the else branch of `handleGPCPayment` runs.
        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true,
                                                         openWithOnIOS: false,
                                                         scheme: "unopenable-scheme-\(UUID().uuidString)")
        sut.paymentInfo = nil

        sut.didTapOnPayInvoice(documentId: nil)

        #expect(spyNavigationController.presented.count == 1,
                "`presentInstallAppBottomSheet` must be reached even when `paymentInfo` is nil")
        let presentedView = try #require(spyNavigationController.presented.first?.viewController)
        #expect(presentedView is InstallAppBottomView,
                "Presented view controller should be the install-app bottom sheet")
    }

    @Test("Install-app sheet is reachable via GPC when `paymentInfo` is present too")
    func installAppSheet_isPresented_onGPCPath_whenPaymentInfoIsPresent() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true,
                                                         openWithOnIOS: false,
                                                         scheme: "unopenable-scheme-\(UUID().uuidString)")
        sut.paymentInfo = Self.makePaymentInfo()

        sut.didTapOnPayInvoice(documentId: nil)

        #expect(spyNavigationController.presented.count == 1)
        let presentedView = try #require(spyNavigationController.presented.first?.viewController)
        #expect(presentedView is InstallAppBottomView)
    }

    // MARK: - `handleOpenWithPayment` guard

    @Test("Open-with branch is a no-op when `paymentInfo` is nil")
    func openWithBranch_isNoOp_whenPaymentInfoIsNil() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: true)
        sut.paymentInfo = nil

        sut.didTapOnPayInvoice(documentId: nil)

        // Guarded by `guard let paymentInfo else { return }` — no request created,
        // no bottom sheet presented, no delegate loading-state toggle.
        #expect(spyNavigationController.presented.isEmpty)
        #expect(spyNavigationController.pushed.isEmpty)
        #expect(delegateSpy.loadingStateChanges.isEmpty)
    }

    // MARK: - Public predicates

    @Test("`supportsOpenWith` reflects the selected provider's iOS support")
    func supportsOpenWith_reflectsProviderPlatforms() {
        sut.selectedPaymentProvider = nil
        #expect(sut.supportsOpenWith() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        #expect(sut.supportsOpenWith() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: true)
        #expect(sut.supportsOpenWith() == true)
    }

    @Test("`supportsGPC` reflects the selected provider's iOS support")
    func supportsGPC_reflectsProviderPlatforms() {
        sut.selectedPaymentProvider = nil
        #expect(sut.supportsGPC() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        #expect(sut.supportsGPC() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true, openWithOnIOS: false)
        #expect(sut.supportsGPC() == true)
    }

    @Test("`canOpenPaymentProviderApp` is false when GPC is not supported")
    func canOpenPaymentProviderApp_isFalse_whenGPCUnsupported() {
        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        #expect(sut.canOpenPaymentProviderApp() == false)
    }

    @Test("`canOpenPaymentProviderApp` is false when scheme cannot be opened")
    func canOpenPaymentProviderApp_isFalse_whenSchemeUnopenable() {
        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true,
                                                         openWithOnIOS: false,
                                                         scheme: "unopenable-scheme-\(UUID().uuidString)")
        // GPC is supported but the scheme cannot be opened by the simulator.
        #expect(sut.canOpenPaymentProviderApp() == false)
    }

    // MARK: - Fixture builders

    private static func makeProvider(gpcOnIOS: Bool,
                                     openWithOnIOS: Bool,
                                     scheme: String = "test-scheme") -> PaymentProvider {
        PaymentProvider(id: "test-provider-\(UUID().uuidString)",
                        name: "Test Bank",
                        appSchemeIOS: scheme,
                        minAppVersion: nil,
                        colors: ProviderColors(background: "#FFFFFF",
                                                text: "#000000"),
                        iconData: Data(),
                        appStoreUrlIOS: "https://apps.apple.com/test",
                        universalLinkIOS: "https://example.com/pay",
                        index: 0,
                        gpcSupportedPlatforms: gpcOnIOS ? [.ios] : [],
                        openWithSupportedPlatforms: openWithOnIOS ? [.ios] : [])
    }

    private static func makePaymentInfo() -> GiniInternalPaymentSDK.PaymentInfo {
        GiniInternalPaymentSDK.PaymentInfo(recipient: "Test Recipient",
                                            iban: "DE00123456789012345678",
                                            amount: "1.00:EUR",
                                            purpose: "Test",
                                            paymentUniversalLink: "https://example.com/pay",
                                            paymentProviderId: "test-provider")
    }
}

// MARK: - Test doubles

/**
 Captures `present` and `pushViewController` calls without actually rendering,
 so tests can observe navigation intent without a live view hierarchy.
 */
private final class SpyNavigationController: UINavigationController {

    struct Presentation {
        let viewController: UIViewController
        let animated: Bool
    }

    var presented: [Presentation] = []
    var pushed: [UIViewController] = []

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        presented.append(Presentation(viewController: viewControllerToPresent, animated: flag))
        completion?()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushed.append(viewController)
    }
}

/**
 Records every delegate callback so tests can assert both what was called
 and (for `isLoadingStateChanged`) with which value, without depending on
 the real host-app plumbing.
 */
private final class PaymentComponentsControllerDelegateSpy: PaymentComponentsControllerProtocol {
    var loadingStateChanges: [Bool] = []
    var didFetchedPaymentProvidersCallCount = 0
    var didDismissPaymentComponentsCallCount = 0

    func isLoadingStateChanged(isLoading: Bool) {
        loadingStateChanges.append(isLoading)
    }

    func didFetchedPaymentProviders() {
        didFetchedPaymentProvidersCallCount += 1
    }

    func didDismissPaymentComponents() {
        didDismissPaymentComponentsCallCount += 1
    }
}
