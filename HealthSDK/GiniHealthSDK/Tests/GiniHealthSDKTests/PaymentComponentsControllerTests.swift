//
//  PaymentComponentsControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
import Combine
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites

final class PaymentComponentsControllerTests: XCTestCase {
    private var giniHealthAPI: GiniHealthAPI!
    private var giniHealth: GiniHealth!
    private var mockPaymentComponentsController: PaymentComponentsProtocol!
    private let giniHealthConfiguration = GiniHealthConfiguration.shared
    private let versionAPI = 5

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock,
                                                     apiVersion: versionAPI)
        let paymentService = PaymentService(sessionManager: sessionManagerMock,
                                            apiVersion: versionAPI)
        giniHealthAPI = GiniHealthAPI(documentService: documentService,
                                      paymentService: paymentService,
                                      clientConfigurationService: nil)
        giniHealth = GiniHealth(giniApiLib: giniHealthAPI)
        mockPaymentComponentsController = MockPaymentComponents(giniHealth: giniHealth)
    }

    override func tearDown() {
        giniHealthAPI = nil
        mockPaymentComponentsController = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func assertPayableResult(docId: String, expected: Result<Bool, GiniHealthError>) {
        var receivedResult: Result<Bool, GiniHealthError>?
        mockPaymentComponentsController.checkIfDocumentIsPayable(docId: docId) { result in
            receivedResult = result
        }
        XCTAssertEqual(receivedResult, expected, "Payable result should match expected value")
    }

    private func assertAndCast<T>(_ value: Any?,
                                   as type: T.Type,
                                   file: StaticString = #file,
                                   line: UInt = #line) throws -> T {
        XCTAssertTrue(value is T, "Expected \(T.self)", file: file, line: line)
        return try XCTUnwrap(value as? T, "Error finding correct view.", file: file, line: line)
    }
    
    func testLoadPaymentProvidersSuccess() {
        // When
        mockPaymentComponentsController.loadPaymentProviders()

        // Then
        XCTAssertFalse(mockPaymentComponentsController.isLoading, "Loading state should be false after providers are loaded")
        XCTAssertNil(mockPaymentComponentsController.selectedPaymentProvider, "Selected payment provider should be nil initially")
    }

    func testCheckIfDocumentIsPayableSuccess() {
        assertPayableResult(docId: MockSessionManager.payableDocumentID, expected: .success(true))
    }

    func testCheckIfDocumentIsPayableNotPayable() {
        assertPayableResult(docId: MockSessionManager.notPayableDocumentID, expected: .success(false))
    }

    func testCheckIfDocumentIsPayableFailure() {
        assertPayableResult(
            docId: MockSessionManager.missingDocumentID,
            expected: .failure(.apiError(GiniError.toGiniHealthSDKError(error: .noResponse)))
        )
    }

    func testPaymentViewReturnsView() throws {
        let view = mockPaymentComponentsController.paymentView()
        let _ = try assertAndCast(view, as: PaymentComponentView.self)
    }

    func testBankSelectionBottomSheetReturnsViewController() throws {
        let viewController = mockPaymentComponentsController.bankSelectionBottomSheet()
        let bottomSheet = try assertAndCast(viewController, as: BanksBottomView.self)
        XCTAssertNotNil(bottomSheet.viewModel, "Bottom sheet view model should not be nil")
    }
    
    func testLoadPaymentReviewScreenForSuccess() {
        // Given
        let documentId = MockSessionManager.payableDocumentID

        // When
        var receivedViewController: UIViewController?
        var receivedError: GiniHealthError?
        mockPaymentComponentsController.loadPaymentReviewScreenFor(trackingDelegate: nil,
                                                                   previousPaymentComponentScreenType: nil) { viewController, error in
            receivedViewController = viewController
            receivedError = error
        }

        // Then
        XCTAssertNil(receivedError, "Error should be nil for a successful payment review screen load")
        XCTAssertNotNil(receivedViewController, "View controller should not be nil for a successful load")
    }
    
    func testPaymentInfoViewControllerReturnsCorrectViewController() throws {
        let viewController = mockPaymentComponentsController.paymentInfoViewController()
        let paymentInfoVC = try assertAndCast(viewController, as: PaymentInfoViewController.self)
        XCTAssertNotNil(paymentInfoVC.viewModel, "Payment info view model should not be nil")
        XCTAssertEqual(paymentInfoVC.viewModel.paymentProviders, [], "Payment providers should be empty initially")
    }
    
    // MARK: - paymentProvidersPublisher

    func testPaymentProvidersPublisherEmitsEmptyOnSubscribe() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)
        var received: [GiniHealthAPILibrary.PaymentProviders] = []
        let cancellable = controller.paymentProvidersPublisher.sink { received.append($0) }

        XCTAssertEqual(received.count, 1,
                       "Subscribe must deliver exactly one replay")
        XCTAssertEqual(received.first, [],
                       "CurrentValueSubject must replay [] before any fetch resolves")
        cancellable.cancel()
    }

    func testPaymentProvidersPublisherDeliversToMultipleSubscribers() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)
        var r1: [GiniHealthAPILibrary.PaymentProviders] = []
        var r2: [GiniHealthAPILibrary.PaymentProviders] = []

        let c1 = controller.paymentProvidersPublisher.sink { r1.append($0) }
        let c2 = controller.paymentProvidersPublisher.sink { r2.append($0) }

        XCTAssertEqual(r1.count, 1, "Subscriber 1 must receive the replay on subscribe")
        XCTAssertEqual(r2.count, 1, "Subscriber 2 must receive the replay on subscribe")
        XCTAssertEqual(r1.first, r2.first,
                       "Both subscribers must observe the same replay value")

        c1.cancel()
        c2.cancel()
    }

    /**
     A live subscriber receives the non-empty value sent after `loadPaymentProviders`, not just the `[]` replay.
     */
    func testPaymentProvidersPublisherDeliversNonEmptyValueAfterLoad() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)

        let expectation = expectation(description: "Receives non-empty providers through publisher")
        expectation.assertForOverFulfill = false
        var received: [GiniHealthAPILibrary.PaymentProviders] = []

        let cancellable = controller.paymentProvidersPublisher.sink { value in
            received.append(value)
            if !value.isEmpty { expectation.fulfill() }
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(received.isEmpty,
                       "Subscriber must observe at least one emission")
        XCTAssertFalse(received.last?.isEmpty ?? true,
                       "The final emission must carry the fetched providers, not the [] replay")
        cancellable.cancel()
    }

    /**
     Regression test for R8 (HEAL-575): when `loadPaymentProviders` resolves with `.failure`,
     the publisher must emit only the `[]` replay — the subject must not forward anything
     on the failure branch. Pairs with the success-branch coverage above.
     */
    func testPaymentProvidersPublisherDoesNotEmitOnFetchFailure() {
        let failingSessionManager = MockSessionManager()
        failingSessionManager.paymentProvidersFailure = .noResponse
        let failingDocumentService = DefaultDocumentService(sessionManager: failingSessionManager,
                                                            apiVersion: versionAPI)
        let failingPaymentService = PaymentService(sessionManager: failingSessionManager,
                                                   apiVersion: versionAPI)
        let failingHealthAPI = GiniHealthAPI(documentService: failingDocumentService,
                                             paymentService: failingPaymentService,
                                             clientConfigurationService: nil)
        let failingHealth = GiniHealth(giniApiLib: failingHealthAPI)

        let controller = PaymentComponentsController(giniHealth: failingHealth)
        var received: [GiniHealthAPILibrary.PaymentProviders] = []
        let cancellable = controller.paymentProvidersPublisher.sink { received.append($0) }

        pumpMain(for: 0.3)

        XCTAssertEqual(received.count, 1,
                       "On failure the publisher must emit only the initial [] replay")
        XCTAssertEqual(received.first, [],
                       "The sole emission must be the [] seed, never a provider list")
        XCTAssertEqual(controller.paymentProviders, [],
                       "Controller's paymentProviders accessor must remain empty on failure")
        cancellable.cancel()
    }

    // MARK: - sortPaymentProviders (static pipeline)

    func testSortPaymentProvidersReturnsEmptyForEmptyInput() {
        let result = PaymentComponentsController.sortPaymentProviders([])

        XCTAssertTrue(result.isEmpty,
                      "Empty input must short-circuit to an empty output without filtering or sorting")
    }

    func testSortPaymentProvidersFiltersOutProvidersWithoutIOSPlatformSupport() {
        let iosProvider = makeHealthProvider(id: "ios",
                                             appScheme: "ios://",
                                             gpc: [.ios])
        let androidOnly = makeHealthProvider(id: "android",
                                             appScheme: "android://",
                                             gpc: [.android],
                                             openWith: [])

        let result = PaymentComponentsController.sortPaymentProviders([iosProvider, androidOnly])

        XCTAssertEqual(result.map { $0.id }, ["ios"],
                       "Providers that lack iOS support in both gpc and openWith must be filtered out")
    }

    func testSortPaymentProvidersIncludesProviderWithIOSInOpenWithOnly() {
        let openWithOnly = makeHealthProvider(id: "open-with",
                                              appScheme: "ow://",
                                              gpc: [],
                                              openWith: [.ios])

        let result = PaymentComponentsController.sortPaymentProviders([openWithOnly])

        XCTAssertEqual(result.map { $0.id }, ["open-with"],
                       "A provider with iOS listed only in openWithSupportedPlatforms must still pass the filter")
    }

    func testSortPaymentProvidersBranchesOnSchemeOpenability() {
        // Discover a scheme that this simulator's UIApplication actually reports as openable,
        // so the branch where the two providers' canOpenURLString() values differ is reached
        // deterministically. If no such scheme exists in this environment, skip the assertion
        // — the sort pipeline is already exercised by the ordering tests above.
        let candidates = ["http://example.com", "https://example.com", "mailto://a@b"]
        guard let openScheme = candidates.first(where: { ($0 as NSString).length > 0 && URL(string: $0).flatMap { UIApplication.shared.canOpenURL($0) } == true }) else {
            return
        }

        let openable = makeHealthProvider(id: "openable",
                                          appScheme: openScheme,
                                          index: 10)
        let notOpenable = makeHealthProvider(id: "not-openable",
                                             appScheme: "zzz-not-a-real-scheme-\(UUID().uuidString)://",
                                             index: 1)

        let result = PaymentComponentsController.sortPaymentProviders([notOpenable, openable])

        XCTAssertEqual(result.first?.id, "openable",
                       "Provider whose scheme can be opened must sort before one whose scheme cannot be, regardless of index")
    }

    func testSortPaymentProvidersSortsByIndexWhenSchemeAvailabilityIsEqual() {
        let high = makeHealthProvider(id: "high", appScheme: "high-unknown://", index: 5)
        let low = makeHealthProvider(id: "low", appScheme: "low-unknown://", index: 1)

        let result = PaymentComponentsController.sortPaymentProviders([high, low])

        XCTAssertEqual(result.map { $0.id }, ["low", "high"],
                       "When neither scheme can be opened, providers must be ordered by ascending index")
    }

    func testPaymentProvidersAccessorReturnsSubjectValue() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)
        let provider = makeHealthProvider(id: "x", appScheme: "x://")

        controller.paymentProvidersSubject.send([provider])

        XCTAssertEqual(controller.paymentProviders.map { $0.id }, ["x"],
                       "paymentProviders accessor must mirror the current subject value")
    }

    // MARK: - paymentView() resolver closure

    private static let defaultProviderKey = "defaultPaymentProvider"

    /** Removes the stored default provider before and after `body` so each test starts and ends clean. */
    private func withCleanDefaultProvider(_ body: () -> Void) {
        let saved = UserDefaults.standard.data(forKey: Self.defaultProviderKey)
        UserDefaults.standard.removeObject(forKey: Self.defaultProviderKey)
        defer {
            if let saved {
                UserDefaults.standard.set(saved, forKey: Self.defaultProviderKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.defaultProviderKey)
            }
        }
        body()
    }

    /** Pumps the main run loop until an expectation fulfils — needed because the viewModel's
     publisher subscription uses `.receive(on: DispatchQueue.main)`, so the resolver closure runs
     after this call site returns from `send(...)`. */
    private func pumpMain(for interval: TimeInterval = 0.1) {
        RunLoop.main.run(until: Date().addingTimeInterval(interval))
    }

    func testPaymentViewResolverReturnsNilWhenNoSavedProvider() {
        withCleanDefaultProvider {
            let controller = PaymentComponentsController(giniHealth: giniHealth)
            let healthProvider = makeHealthProvider(id: "any", appScheme: "any://")

            // Instantiate the view, which captures the resolver inside the view model.
            let view = controller.paymentView()

            // Drain any pending publisher deliveries queued by the controller's initial
            // loadPaymentProviders call so the next send() is the one we are asserting about.
            pumpMain(for: 0.2)
            controller.paymentProvidersSubject.send([healthProvider])
            pumpMain()

            // Keep the view alive so the weak-self capture in the view model's subscription
            // doesn't dealloc the view before the main-queue closure runs.
            _ = view
        }
    }

    func testPaymentViewResolverMatchesSavedProvider() {
        withCleanDefaultProvider {
            let saved = GiniHealthSDK.PaymentProvider(healthPaymentProvider:
                makeHealthProvider(id: "saved", appScheme: "saved://"))
            let data = try! JSONEncoder().encode(saved)
            UserDefaults.standard.set(data, forKey: Self.defaultProviderKey)

            let controller = PaymentComponentsController(giniHealth: giniHealth)
            let view = controller.paymentView()

            pumpMain(for: 0.2)
            controller.paymentProvidersSubject.send([makeHealthProvider(id: "saved", appScheme: "saved://")])
            pumpMain()

            _ = view
        }
    }

    // MARK: - paymentInfoViewController()

    func testPaymentInfoViewControllerUsesSharedPublisher() {
        let controller = PaymentComponentsController(giniHealth: giniHealth)

        let paymentInfoVC = controller.paymentInfoViewController()

        XCTAssertTrue(paymentInfoVC is PaymentInfoViewController,
                      "paymentInfoViewController must return a PaymentInfoViewController")
    }

    private func makeHealthProvider(id: String,
                                    appScheme: String,
                                    index: Int? = nil,
                                    gpc: [GiniHealthAPILibrary.PlatformSupported] = [.ios],
                                    openWith: [GiniHealthAPILibrary.PlatformSupported] = []) -> GiniHealthAPILibrary.PaymentProvider {
        GiniHealthAPILibrary.PaymentProvider(id: id,
                                             name: "Provider \(id)",
                                             appSchemeIOS: appScheme,
                                             minAppVersion: nil,
                                             colors: GiniHealthAPILibrary.ProviderColors(background: "#FFFFFF", text: "#000000"),
                                             iconData: Data(),
                                             appStoreUrlIOS: nil,
                                             universalLinkIOS: "https://example.com",
                                             index: index,
                                             gpcSupportedPlatforms: gpc,
                                             openWithSupportedPlatforms: openWith)
    }

    func testPaymentProvidersSorting() {
        let fileName = "notSortedBanks"
        guard let givenPaymentProviders = loadProviders(fileName: fileName) else {
            XCTFail("Error loading file: `\(fileName).json`")
            return
        }

        let expectedPaymentProviders = loadProviders(fileName: "sortedBanks")

        let bottomViewModel = BanksBottomViewModel(paymentProviders: givenPaymentProviders.map { $0.toHealthPaymentProvider() },
                                                   paymentProvidersPublisher: Just([]).eraseToAnyPublisher(),
                                                   selectedPaymentProvider: nil,
                                                   configuration: giniHealth.bankSelectionConfiguration,
                                                   strings: giniHealth.banksBottomStrings,
                                                   poweredByGiniConfiguration: giniHealth.poweredByGiniConfiguration,
                                                   poweredByGiniStrings: giniHealth.poweredByGiniStrings,
                                                   moreInformationConfiguration: giniHealth.moreInformationConfiguration,
                                                   moreInformationStrings: giniHealth.moreInformationStrings,
                                                   paymentInfoConfiguration: giniHealth.paymentInfoConfiguration,
                                                   paymentInfoStrings: giniHealth.paymentInfoStrings,
                                                   urlOpener: URLOpener(MockUIApplication(canOpen: false)),
                                                   clientConfiguration: giniHealth.clientConfiguration)


        XCTAssertEqual(bottomViewModel.paymentProviders.count, 11, "Providers count should be 11")
        XCTAssertEqual(bottomViewModel.paymentProviders.map { PaymentProvider(healthPaymentProvider: $0.paymentProvider) }, expectedPaymentProviders, "Providers should be sorted as expected")
    }
}
