import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK
@testable import GiniUtilites


final class GiniHealthTests: GiniHealthTestCase {

    // MARK: - Helper

    private func assertClientConfiguration(_ config: ClientConfiguration,
                                           communicationTone: GiniHealthAPILibrary.CommunicationToneEnum,
                                           brandType: GiniHealthAPILibrary.IngredientBrandTypeEnum) {
        XCTAssertNotNil(config, "Client configuration should not be nil")
        XCTAssertEqual(config.communicationTone, communicationTone, "Communication tone should match")
        XCTAssertEqual(config.ingredientBrandType, brandType, "Ingredient brand type should match")
    }

    func testSetConfiguration() throws {
        // Given
        let configuration = GiniHealthConfiguration()
        
        // When
        giniHealth.setConfiguration(configuration)
        
        // Then
        XCTAssertEqual(GiniHealthConfiguration.shared, configuration, "Shared configuration should match the set configuration")
    }
    
    func testFetchBankingAppsSuccess() {
        // Given
        let expectedProviders: [GiniHealthSDK.PaymentProvider]? = loadProviders(fileName: "providers")

        // When
        let expectation = self.expectation(description: "Fetching banking apps")
        var receivedProviders: [GiniHealthSDK.PaymentProvider]?
        giniHealth.fetchBankingApps { result in
            switch result {
            case .success(let providers):
                receivedProviders = providers
            case .failure(_):
                receivedProviders = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        // Then
        XCTAssertNotNil(receivedProviders, "Received providers should not be nil")
        XCTAssertEqual(receivedProviders?.count, expectedProviders?.count, "Providers count should match")
        XCTAssertEqual(receivedProviders, expectedProviders, "Received providers should match expected providers")
    }
    
    func testOpenLinkSuccess() {
        let mockUIApplication = MockUIApplication(canOpen: true)
        let urlOpener = URLOpener(mockUIApplication)
        let waitForWebsiteOpen = expectation(description: "Link was opened")

        giniHealth.openPaymentProviderApp(requestID: "123",
                                          universalLink: "ginipay-bank://",
                                          urlOpener: urlOpener,
                                          completion: { open in
            waitForWebsiteOpen.fulfill()
            XCTAssert(open == true, "TestOpenLink - FAILED to open link")
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testOpenLinkFailure() {
        let mockUIApplication = MockUIApplication(canOpen: false)
        let urlOpener = URLOpener(mockUIApplication)
        let waitForWebsiteOpen = expectation(description: "Link was not opened")

        giniHealth.openPaymentProviderApp(requestID: "123",
                                          universalLink: "ginipay-bank://",
                                          urlOpener: urlOpener,
                                          completion: { open in
            waitForWebsiteOpen.fulfill()
            XCTAssert(open == false, "TestOpenLink - MANAGED to open link")
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testLoadClientConfigurationFromFile() {
        // Given
        let expectedCommunicationType: GiniHealthAPILibrary.CommunicationToneEnum = .formal
        let expectedBrandType: GiniHealthAPILibrary.IngredientBrandTypeEnum = .invisible

        // When
        let expectation = self.expectation(description: "Getting client configuration details")
        var receivedClientConfiguration: ClientConfiguration?

        giniHealth.clientConfigurationService?.fetchConfigurations { result in
            switch result {
            case .success(let clientConfiguration):
                receivedClientConfiguration = clientConfiguration
            case .failure(_):
                receivedClientConfiguration = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedClientConfiguration, "Client configuration should not be nil")
        XCTAssertEqual(receivedClientConfiguration?.communicationTone, expectedCommunicationType, "Communication tone should match")
        XCTAssertEqual(receivedClientConfiguration?.ingredientBrandType, expectedBrandType, "Ingredient brand type should match")
    }

    func testLoadDefaultClientConfiguration() {
        let clientConfiguration = ClientConfiguration()
        assertClientConfiguration(clientConfiguration, communicationTone: .formal, brandType: .invisible)
    }

    func testFormalDE() {
        let clientConfiguration = ClientConfiguration()
        let configuration = GiniHealthConfiguration()
        configuration.customLocalization = .de
        configuration.clientConfiguration = clientConfiguration
        giniHealth.setConfiguration(configuration)

        assertClientConfiguration(clientConfiguration, communicationTone: .formal, brandType: .invisible)
        XCTAssertEqual(giniHealth.installAppStrings.moreInformationTipPattern, "Tipp: Tippen Sie auf 'Weiter', um die Zahlung in der [BANK]-App abzuschließen.", "Formal German tip pattern should match")
    }

    func testInformalDE() {
        let clientConfiguration = ClientConfiguration(communicationTone: .informal)
        let configuration = GiniHealthConfiguration()
        configuration.clientConfiguration = clientConfiguration
        configuration.customLocalization = .de
        giniHealth.setConfiguration(configuration)

        assertClientConfiguration(clientConfiguration, communicationTone: .informal, brandType: .invisible)
        XCTAssertEqual(giniHealth.installAppStrings.moreInformationTipPattern, "Tipp: Tippe auf 'Weiter', um die Zahlung in der [BANK]-App abzuschließen.", "Informal German tip pattern should match")
    }

    // MARK: - Initializers

    func testInitWithCredentialsCreatesValidInstance() throws {
        // Probe Keychain before invoking the credential init.
        // The SPM test runner lacks Keychain entitlements; skip instead of crashing.
        let probe = KeychainManagerItem(key: .clientId,
                                        value: "probe",
                                        service: .auth)
        do {
            try KeychainStore().save(item: probe)
            try? KeychainStore().remove(service: .auth, key: .clientId)
        } catch {
            throw XCTSkip("Keychain unavailable in this test environment — add the keychain-access-groups entitlement to run this test")
        }

        // When
        let instance = GiniHealth(id: "test-id",
                                  secret: "test-secret",
                                  domain: "test.domain")

        // Then
        XCTAssertNotNil(instance.paymentComponentsController, "paymentComponentsController should be set up by credential initializer")
    }

    func testInitWithPinningConfigCreatesValidInstance() throws {
        // Probe Keychain before invoking the pinning-config init.
        let probe = KeychainManagerItem(key: .clientId,
                                        value: "probe",
                                        service: .auth)
        do {
            try KeychainStore().save(item: probe)
            try? KeychainStore().remove(service: .auth, key: .clientId)
        } catch {
            throw XCTSkip("Keychain unavailable in this test environment — add the keychain-access-groups entitlement to run this test")
        }

        // When
        let instance = GiniHealth(id: "test-id",
                                  secret: "test-secret",
                                  domain: "test.domain",
                                  pinningConfig: ["test.domain": ["AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="]])

        // Then
        XCTAssertNotNil(instance.paymentComponentsController, "paymentComponentsController should be set up by pinning-config initializer")
    }

    // MARK: - Start Payment Flow

    func testStartPaymentFlowDoesNotCrash() {
        // Given
        let navigationController = UINavigationController()

        // When / Then — just verifies no crash on the public entry point
        giniHealth.startPaymentFlow(documentId: nil,
                                    paymentInfo: nil,
                                    navigationController: navigationController,
                                    trackingDelegate: nil)
    }

    // MARK: - Version String

    func testVersionString() {
        XCTAssertFalse(GiniHealth.versionString.isEmpty, "Version string should not be empty")
    }

    // MARK: - Fetch Bank Logos

    func testFetchBankLogos() {
        // Providers are loaded synchronously by the mock in setUp, so logos is non-nil
        let result = giniHealth.fetchBankLogos()
        XCTAssertNotNil(result.logos, "fetchBankLogos should return a logos value")
    }

    // MARK: - DataForReview init

    func testDataForReviewInitStoresValues() throws {
        // Given
        let apiDocument: GiniHealthAPILibrary.Document = try XCTUnwrap(GiniHealthSDKTests.load(fromFile: "document1"))
        let document = try XCTUnwrap(GiniHealthSDK.Document(healthDocument: apiDocument))
        let extractions: [GiniHealthSDK.Extraction] = []

        // When
        let dataForReview = DataForReview(document: document,
                                          extractions: extractions)

        // Then
        XCTAssertEqual(dataForReview.document, document, "DataForReview should store the document")
        XCTAssertEqual(dataForReview.extractions.count, extractions.count, "DataForReview should store the extractions")
    }

    // MARK: - Delegate Forwarding

    func testIsLoadingStateChangedForwardsToPaymentDelegate() {
        // Given
        let mockDelegate = MockPaymentComponentsDelegate()
        giniHealth.paymentDelegate = mockDelegate

        // When
        giniHealth.isLoadingStateChanged(isLoading: true)

        // Then
        XCTAssertTrue(mockDelegate.isLoadingStateChangedCalled, "isLoadingStateChanged should be forwarded to paymentDelegate")
        XCTAssertEqual(mockDelegate.lastLoadingState, true, "Loading state value should be forwarded")
    }

    func testIsLoadingStateChangedFalseForwardsToPaymentDelegate() {
        // Given
        let mockDelegate = MockPaymentComponentsDelegate()
        giniHealth.paymentDelegate = mockDelegate

        // When
        giniHealth.isLoadingStateChanged(isLoading: false)

        // Then
        XCTAssertTrue(mockDelegate.isLoadingStateChangedCalled, "isLoadingStateChanged should be forwarded to paymentDelegate")
        XCTAssertEqual(mockDelegate.lastLoadingState, false, "Loading state false should be forwarded")
    }

    func testDidFetchedPaymentProvidersForwardsToPaymentDelegate() {
        // Given
        let mockDelegate = MockPaymentComponentsDelegate()
        giniHealth.paymentDelegate = mockDelegate

        // When
        giniHealth.didFetchedPaymentProviders()

        // Then
        XCTAssertTrue(mockDelegate.didFetchedPaymentProvidersCalled, "didFetchedPaymentProviders should be forwarded to paymentDelegate")
    }

    func testDidDismissPaymentComponentsForwardsToHealthDelegate() {
        // Given
        let mockDelegate = MockGiniHealthDelegate()
        giniHealth.delegate = mockDelegate

        // When
        giniHealth.didDismissPaymentComponents()

        // Then
        XCTAssertTrue(mockDelegate.didDismissHealthSDKCalled, "didDismissPaymentComponents should call didDismissHealthSDK on the health delegate")
    }
}
