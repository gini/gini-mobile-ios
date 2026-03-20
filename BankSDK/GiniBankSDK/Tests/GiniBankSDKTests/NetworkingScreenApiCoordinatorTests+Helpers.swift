//
//  NetworkingScreenApiCoordinatorTests+Helpers.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import XCTest

// MARK: - Helper Methods

extension NetworkingScreenApiCoordinatorTests {
    func makeTokenSource() -> MockTokenSource {
        let token = Token(expiration: .init(),
                          scope: "the_scope",
                          type: "the_type",
                          accessToken: "some_totally_random_gibberish")
       return MockTokenSource(token: token)
    }

    func makeCoordinatorAndService(fromViewController: Bool = false) throws -> (GiniBankNetworkingScreenApiCoordinator,
                                                                                DefaultDocumentService) {
        let coordinator: GiniBankNetworkingScreenApiCoordinator
        if fromViewController {
            let viewController = try XCTUnwrap(
                GiniBank.viewController(withAlternativeTokenSource: tokenSource,
                                        configuration: configuration,
                                        resultsDelegate: resultsDelegate,
                                        documentMetadata: metadata,
                                        trackingDelegate: trackingDelegate) as? ContainerNavigationController,
                "There should be an instance of `ContainerNavigationController`"
            )
            coordinator = try XCTUnwrap(
                viewController.coordinator as? GiniBankNetworkingScreenApiCoordinator,
                "The instance of `ContainerNavigationController` should have a coordinator of type `GiniBankNetworkingScreenApiCoordinator"
            )
        } else {
            coordinator = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: tokenSource,
                                                                 resultsDelegate: resultsDelegate,
                                                                 configuration: configuration,
                                                                 documentMetadata: metadata,
                                                                 trackingDelegate: trackingDelegate)
        }
        let documentService = try XCTUnwrap(
            coordinator.documentService as? GiniCaptureSDK.DocumentService,
            "The coordinator should have a document service of type `GiniCaptureSDK.DocumentService"
        )
        let captureNetworkService = try XCTUnwrap(
            documentService.captureNetworkService as? DefaultCaptureNetworkService,
            "The document service should have a capture network service of type `DefaultCaptureNetworkService"
        )

        return (coordinator, captureNetworkService.documentService)
    }

    func login(service: DefaultDocumentService) throws -> Token? {
        let logInExpectation = self.expectation(description: "login")
        var receivedToken: Token?
        service.sessionManager.logIn { result in
            switch result {
                case .success(let token):
                    receivedToken = token
                    logInExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failure: \(error.localizedDescription)")
            }
        }
        wait(for: [logInExpectation], timeout: 1)
        return receivedToken
    }

    // MARK: - Test Data Creation

    func createExtractionResult(paymentState: String? = nil,
                                paymentDueDate: String? = nil,
                                lineItems: [[Extraction]]? = nil,
                                skontoDiscounts: [[Extraction]]? = nil,
                                crossBorderPayment: [[Extraction]]? = nil) -> ExtractionResult {
        var extractions: [Extraction] = []

        if let paymentState = paymentState {
            let extraction = Extraction(box: nil,
                                        candidates: nil,
                                        entity: "paymentState",
                                        value: paymentState,
                                        name: "paymentState")
            extractions.append(extraction)
        }

        if let paymentDueDate = paymentDueDate {
            let dueDateExtraction = Extraction(box: nil,
                                               candidates: nil,
                                               entity: "paymentDueDate",
                                               value: paymentDueDate,
                                               name: "paymentDueDate")
            extractions.append(dueDateExtraction)
        }

        return ExtractionResult(extractions: extractions,
                                lineItems: lineItems,
                                returnReasons: [],
                                skontoDiscounts: skontoDiscounts,
                                crossBorderPayment: crossBorderPayment,
                                candidates: [:])
    }

    func createMockLineItems() -> [[Extraction]] {
        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: "lineItem",
                                    value: "Test Item",
                                    name: "lineItem")
        return [[extraction]]
    }

    func createMockSkontoDiscounts() -> [[Extraction]] {
        let extraction = Extraction(box: nil,
                                    candidates: nil,
                                    entity: "skontoDiscount",
                                    value: "2.0",
                                    name: "skontoDiscount")
        return [[extraction]]
    }

    func createMockCrossBorderPayment() -> [[Extraction]] {
        let iban = Extraction(box: nil,
                              candidates: nil,
                              entity: "iban",
                              value: "GB29NWBK60161331926819",
                              name: "iban")
        let bic = Extraction(box: nil,
                             candidates: nil,
                             entity: "bic",
                             value: "NWBKGB2L",
                             name: "bic")
        let currency = Extraction(box: nil,
                                  candidates: nil,
                                  entity: "currency",
                                  value: "GBP",
                                  name: "currency")
        let bankAddress = Extraction(box: nil,
                                     candidates: nil,
                                     entity: "bankAddress",
                                     value: "36 St Andrew Square, Edinburgh EH2 2AD",
                                     name: "bankAddress")
        let countryRegionCode = Extraction(box: nil,
                                           candidates: nil,
                                           entity: "countryRegionCode",
                                           value: "GB",
                                           name: "countryRegionCode")
        let abaRoutingNumber = Extraction(box: nil,
                                          candidates: nil,
                                          entity: "abaRoutingNumber",
                                          value: "026009593",
                                          name: "abaRoutingNumber")
        return [[iban, bic, currency, bankAddress, countryRegionCode, abaRoutingNumber]]
    }
}
