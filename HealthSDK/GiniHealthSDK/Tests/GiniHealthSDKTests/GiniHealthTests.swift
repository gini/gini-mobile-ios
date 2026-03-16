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
        XCTAssertNotNil(config)
        XCTAssertEqual(config.communicationTone, communicationTone)
        XCTAssertEqual(config.ingredientBrandType, brandType)
    }

    func testSetConfiguration() throws {
        // Given
        let configuration = GiniHealthConfiguration()
        
        // When
        giniHealth.setConfiguration(configuration)
        
        // Then
        XCTAssertEqual(GiniHealthConfiguration.shared, configuration)
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
        XCTAssertNotNil(receivedProviders)
        XCTAssertEqual(receivedProviders?.count, expectedProviders?.count)
        XCTAssertEqual(receivedProviders, expectedProviders)
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
            XCTAssert(open == true, "testOpenLink - FAILED to open link")
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
            XCTAssert(open == false, "testOpenLink - MANAGED to open link")
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

        XCTAssertNotNil(receivedClientConfiguration)
        XCTAssertEqual(receivedClientConfiguration?.communicationTone, expectedCommunicationType)
        XCTAssertEqual(receivedClientConfiguration?.ingredientBrandType, expectedBrandType)
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
        XCTAssertEqual(giniHealth.installAppStrings.moreInformationTipPattern, "Tipp: Tippen Sie auf 'Weiter', um die Zahlung in der [BANK]-App abzuschließen.")
    }

    func testInformalDE() {
        let clientConfiguration = ClientConfiguration(communicationTone: .informal)
        let configuration = GiniHealthConfiguration()
        configuration.clientConfiguration = clientConfiguration
        configuration.customLocalization = .de
        giniHealth.setConfiguration(configuration)

        assertClientConfiguration(clientConfiguration, communicationTone: .informal, brandType: .invisible)
        XCTAssertEqual(giniHealth.installAppStrings.moreInformationTipPattern, "Tipp: Tippe auf 'Weiter', um die Zahlung in der [BANK]-App abzuschließen.")
    }
}
