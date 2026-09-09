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

 Covers `didTapOnPayInvoice(documentId:)`, `didTapOnBankPicker(documentId:)`,
 the routing done through the four private helpers (`shouldShowPaymentReviewScreen`,
 `handlePaymentReviewFlow`, `handleExternalPaymentFlow`, `handleOpenWithPayment`,
 `handleGPCPayment`), the three public predicates the external flow branches
 on (`supportsOpenWith`, `supportsGPC`, `canOpenPaymentProviderApp`), and the
 payment-provider persistence helpers (`storeDefaultPaymentProvider`,
 `savedPaymentProvider`).

 The private helpers cannot be invoked directly, so they are covered by driving
 `didTapOnPayInvoice(documentId:)` with the state that routes into each branch
 and observing side effects on the spy `UINavigationController` and the delegate.

 The suite is `.serialized` because tests mutate `GiniHealthConfiguration.shared`
 and `UserDefaults.standard`. The class-based suite saves and restores all
 mutated global state in `init`/`deinit` so tests are order-independent.
 */
@Suite("Payment invoice tap routing (PR #1260)", .serialized)
@MainActor
final class PaymentInvoiceRoutingTests {

    // MARK: - Test fixtures

    private let giniHealthAPI: GiniHealthAPI
    private let giniHealth: GiniHealth
    private let sut: PaymentComponentsController
    private let spyNavigationController: SpyNavigationController
    private let delegateSpy: PaymentComponentsControllerDelegateSpy
    private let healthDelegateSpy: GiniHealthDelegateSpy

    private let savedShowPaymentReviewScreen: Bool
    private let savedUseInvoiceWithoutDocument: Bool
    private let savedUseBottomPaymentComponentView: Bool
    private let savedDefaultPaymentProviderData: Data?

    private static let defaultPaymentProviderKey = "defaultPaymentProvider"

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

        healthDelegateSpy = GiniHealthDelegateSpy()
        giniHealth.delegate = healthDelegateSpy

        savedShowPaymentReviewScreen = GiniHealthConfiguration.shared.showPaymentReviewScreen
        savedUseInvoiceWithoutDocument = GiniHealthConfiguration.shared.useInvoiceWithoutDocument
        savedUseBottomPaymentComponentView = GiniHealthConfiguration.shared.useBottomPaymentComponentView
        savedDefaultPaymentProviderData = UserDefaults.standard.data(forKey: Self.defaultPaymentProviderKey)
        UserDefaults.standard.removeObject(forKey: Self.defaultPaymentProviderKey)
    }

    deinit {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = savedShowPaymentReviewScreen
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = savedUseInvoiceWithoutDocument
        GiniHealthConfiguration.shared.useBottomPaymentComponentView = savedUseBottomPaymentComponentView
        if let savedDefaultPaymentProviderData {
            UserDefaults.standard.set(savedDefaultPaymentProviderData, forKey: Self.defaultPaymentProviderKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.defaultPaymentProviderKey)
        }
    }

    // MARK: - `didTapOnPayInvoice` config-based routing

    @Test("Review flow is routed to when `useInvoiceWithoutDocument` is false (isLoading toggles)")
    func routesToReviewFlowWhenUseInvoiceWithoutDocumentIsFalse() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = false
        sut.documentId = MockSessionManager.payableDocumentID

        sut.didTapOnPayInvoice(documentId: MockSessionManager.payableDocumentID)

        #expect(delegateSpy.loadingStateChanges.contains(true),
                "The review flow should toggle `isLoading = true` before fetching data-for-review")
    }

    @Test("External flow (no-op branches) is routed to when both flags favor external")
    func routesToExternalFlowWhenBothFlagsFalse() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        sut.paymentInfo = nil

        // The initial `loadPaymentProviders()` fired from PCC init settles
        // asynchronously on main; clear its `isLoading = false` echo before acting.
        drainMainRunLoop()
        delegateSpy.loadingStateChanges.removeAll()

        sut.didTapOnPayInvoice(documentId: nil)

        #expect(spyNavigationController.presented.isEmpty)
        #expect(spyNavigationController.pushed.isEmpty)
        #expect(delegateSpy.loadingStateChanges.isEmpty,
                "External flow with unsupported provider must not toggle `isLoading`")
    }

    // MARK: - GPC branch — the key PR #1260 regression

    @Test("Install-app sheet is reachable via GPC when `paymentInfo` is nil (PR #1260 regression)")
    func installAppSheetIsPresentedOnGPCPathWhenPaymentInfoIsNil() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        // Drain PCC's `loadPaymentProviders()` before setting our provider, otherwise
        // its main-queue callback overwrites `selectedPaymentProvider` with the (nil)
        // `defaultInstalledPaymentProvider()`.
        drainMainRunLoop()

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
    func installAppSheetIsPresentedOnGPCPathWhenPaymentInfoIsPresent() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        drainMainRunLoop()

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true,
                                                         openWithOnIOS: false,
                                                         scheme: "unopenable-scheme-\(UUID().uuidString)")
        sut.paymentInfo = Self.makePaymentInfo()

        sut.didTapOnPayInvoice(documentId: nil)

        #expect(spyNavigationController.presented.count == 1)
        let presentedView = try #require(spyNavigationController.presented.first?.viewController)
        #expect(presentedView is InstallAppBottomView)
    }

    // MARK: - `handleOpenWithPayment`

    @Test("Open-with branch is a no-op when `paymentInfo` is nil")
    func openWithBranchIsNoOpWhenPaymentInfoIsNil() throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        drainMainRunLoop()

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: true)
        sut.paymentInfo = nil

        delegateSpy.loadingStateChanges.removeAll()

        sut.didTapOnPayInvoice(documentId: nil)

        // Guarded by `guard let paymentInfo else { return }` — no request created,
        // no bottom sheet presented, no delegate loading-state toggle.
        #expect(spyNavigationController.presented.isEmpty)
        #expect(spyNavigationController.pushed.isEmpty)
        #expect(delegateSpy.loadingStateChanges.isEmpty)
    }

    @Test("Open-with branch drives payment request creation when `paymentInfo` is present")
    func openWithBranchCreatesPaymentRequestWhenPaymentInfoIsPresent() async throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = true

        try await settleMainQueue()

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: true)
        sut.paymentInfo = Self.makePaymentInfo()

        sut.didTapOnPayInvoice(documentId: nil)

        // `handleOpenWithPayment` → PCC.createPaymentRequest → giniSDK.createPaymentRequest
        // → mock returns success synchronously → PCC completes with paymentRequestId and
        // fires `giniSDK.delegate?.didCreatePaymentRequest(paymentRequestId:)`. Yield the
        // main actor so any main-queue hops in the chain settle before asserting.
        try await settleMainQueue(hops: 6)

        #expect(!healthDelegateSpy.createdPaymentRequestIds.isEmpty,
                "handleOpenWithPayment should reach PCC.createPaymentRequest and fire didCreatePaymentRequest on the health delegate")
        #expect(!spyNavigationController.presented.contains { $0.viewController is InstallAppBottomView },
                "OpenWith branch must not present the install-app sheet")
    }

    // MARK: - Bank picker

    @Test("Bank picker presents the bank selection bottom sheet when bottom view is enabled")
    func bankPickerPresentsBankSelectionSheetWhenBottomViewEnabled() throws {
        GiniHealthConfiguration.shared.useBottomPaymentComponentView = true

        drainMainRunLoop()

        sut.didTapOnBankPicker(documentId: nil)

        #expect(spyNavigationController.presented.count == 1)
        let presented = try #require(spyNavigationController.presented.first?.viewController)
        #expect(presented is BanksBottomView,
                "Presented view controller should be the bank selection bottom sheet")
    }

    @Test("Bank picker does nothing when bottom view is disabled")
    func bankPickerIsNoOpWhenBottomViewDisabled() throws {
        GiniHealthConfiguration.shared.useBottomPaymentComponentView = false

        drainMainRunLoop()

        sut.didTapOnBankPicker(documentId: nil)

        #expect(spyNavigationController.presented.isEmpty)
    }

    // MARK: - Review flow error branch

    @Test("Review flow surfaces error via handleError when data-for-review fails")
    func reviewFlowSurfacesErrorWhenDataForReviewFails() async throws {
        GiniHealthConfiguration.shared.showPaymentReviewScreen = false
        GiniHealthConfiguration.shared.useInvoiceWithoutDocument = false
        sut.documentId = MockSessionManager.failurePayableDocumentID

        try await settleMainQueue()
        delegateSpy.loadingStateChanges.removeAll()

        sut.didTapOnPayInvoice(documentId: nil)

        // Chain: `handlePaymentReviewFlow` → `loadPaymentReviewScreenFor` calls
        // `fetchDataForReview` (mock returns extractions failure) → completion fires
        // with `error != nil` → `handleError(error)` → `showErrorsIfAny` dispatches
        // to main.async → `showErrorAlertView` → presents the alert on the spy nav.
        // Multi-hop chain — yield the main actor several times to let it settle.
        try await settleMainQueue(hops: 6)

        #expect(delegateSpy.loadingStateChanges.contains(false),
                "handleError should toggle isLoading back to false via the delegate")
        #expect(spyNavigationController.presented.contains(where: { $0.viewController is UIAlertController }),
                "handleError should surface an alert to the user")
    }

    // MARK: - Public predicates

    @Test("`supportsOpenWith` reflects the selected provider's iOS support")
    func supportsOpenWithReflectsProviderPlatforms() {
        sut.selectedPaymentProvider = nil
        #expect(sut.supportsOpenWith() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        #expect(sut.supportsOpenWith() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: true)
        #expect(sut.supportsOpenWith() == true)
    }

    @Test("`supportsGPC` reflects the selected provider's iOS support")
    func supportsGPCReflectsProviderPlatforms() {
        sut.selectedPaymentProvider = nil
        #expect(sut.supportsGPC() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        #expect(sut.supportsGPC() == false)

        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true, openWithOnIOS: false)
        #expect(sut.supportsGPC() == true)
    }

    @Test("`canOpenPaymentProviderApp` is false when GPC is not supported")
    func canOpenPaymentProviderAppIsFalseWhenGPCUnsupported() {
        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: false)
        #expect(sut.canOpenPaymentProviderApp() == false)
    }

    @Test("`canOpenPaymentProviderApp` is false when scheme cannot be opened")
    func canOpenPaymentProviderAppIsFalseWhenSchemeUnopenable() {
        sut.selectedPaymentProvider = Self.makeProvider(gpcOnIOS: true,
                                                         openWithOnIOS: false,
                                                         scheme: "unopenable-scheme-\(UUID().uuidString)")
        #expect(sut.canOpenPaymentProviderApp() == false)
    }

    // MARK: - Payment-provider persistence

    @Test("`storeDefaultPaymentProvider` persists an encoded provider to UserDefaults")
    func storeDefaultPaymentProviderPersistsToUserDefaults() throws {
        let provider = Self.makeProvider(gpcOnIOS: true, openWithOnIOS: false)

        sut.storeDefaultPaymentProvider(paymentProvider: provider)

        let storedData = try #require(UserDefaults.standard.data(forKey: Self.defaultPaymentProviderKey),
                                        "Encoded provider should be stored under the default-payment-provider key")
        let decoded = try JSONDecoder().decode(GiniHealthSDK.PaymentProvider.self, from: storedData)
        #expect(decoded.id == provider.id)
        #expect(decoded.name == provider.name)
    }

    @Test("`savedPaymentProvider` returns the stored provider when its id is in the known providers list")
    func savedPaymentProviderReturnsStoredProviderWhenIdIsKnown() throws {
        let provider = Self.makeProvider(gpcOnIOS: true, openWithOnIOS: false)
        sut.storeDefaultPaymentProvider(paymentProvider: provider)

        // `savedPaymentProvider` only returns the decoded provider if its id is in
        // `paymentProviders`. Preload the SDK's known list with the same id.
        sut.paymentProviders = [provider.toHealthPaymentProvider()]

        let saved = try #require(sut.savedPaymentProvider(),
                                  "Saved provider should be returned when its id is in the known providers list")
        #expect(saved.id == provider.id)
    }

    @Test("`savedPaymentProvider` returns nil when the stored provider's id is not in the known list")
    func savedPaymentProviderReturnsNilWhenIdIsUnknown() throws {
        let stored = Self.makeProvider(gpcOnIOS: true, openWithOnIOS: false)
        sut.storeDefaultPaymentProvider(paymentProvider: stored)

        // Populate the known providers with a DIFFERENT id so the stored one won't match.
        let unrelated = Self.makeProvider(gpcOnIOS: false, openWithOnIOS: true)
        sut.paymentProviders = [unrelated.toHealthPaymentProvider()]

        #expect(sut.savedPaymentProvider() == nil,
                "Stored provider is discarded when its id is not among the known providers")
    }

    @Test("`savedPaymentProvider` returns nil when nothing has been stored")
    func savedPaymentProviderReturnsNilWhenNothingStored() {
        #expect(sut.savedPaymentProvider() == nil)
    }

    // MARK: - Helpers

    /// Pumps the main run loop for a brief window so `DispatchQueue.main.async`
    /// blocks scheduled from `loadPaymentProviders()` (fired inside PCC init) can
    /// settle before the test drives the SUT.
    private func drainMainRunLoop() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
    }

    /// Yields the main actor for `hops` iterations, each sleeping for a short
    /// window so `DispatchQueue.main.async` blocks scheduled by the SDK chain
    /// can settle. Unlike `RunLoop.main.run(until:)`, this actually suspends
    /// the current `@MainActor` context and lets other main-queue work run.
    private func settleMainQueue(hops: Int = 3) async throws {
        for _ in 0..<hops {
            try await Task.sleep(nanoseconds: 20_000_000) // 20 ms per hop
        }
    }

    // MARK: - Fixture builders

    private static func makeProvider(gpcOnIOS: Bool,
                                     openWithOnIOS: Bool,
                                     scheme: String = "test-scheme") -> GiniHealthSDK.PaymentProvider {
        GiniHealthSDK.PaymentProvider(id: "test-provider-\(UUID().uuidString)",
                                       name: "Test Bank",
                                       appSchemeIOS: scheme,
                                       minAppVersion: nil,
                                       colors: GiniHealthSDK.ProviderColors(background: "#FFFFFF",
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
/**
 Records `didCreatePaymentRequest` calls on `GiniHealthDelegate`. Used as an
 observable signal for payment-request success in tests that would otherwise
 rely on downstream side effects (like presenting a share-invoice sheet)
 that the shared mock cannot reliably drive.
 */
private final class GiniHealthDelegateSpy: GiniHealthDelegate {
    var createdPaymentRequestIds: [String] = []
    var dismissedCount = 0
    var errorsAskedToHandleInternally: [GiniHealthError] = []

    func didCreatePaymentRequest(paymentRequestId: String) {
        createdPaymentRequestIds.append(paymentRequestId)
    }

    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        errorsAskedToHandleInternally.append(error)
        return true
    }

    func didDismissHealthSDK() {
        dismissedCount += 1
    }
}

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
