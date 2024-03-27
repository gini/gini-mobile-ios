//
//  PaymentComponentsControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary

final class PaymentComponentsControllerTests: XCTestCase {
    var giniHealthAPI: HealthAPI!
    var paymentComponentsController: PaymentComponentsProtocol!

    override func setUp() {
        super.setUp()
        let sessionManagerMock = MockSessionManager()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock)
        let paymentService = PaymentService(sessionManager: sessionManagerMock)
        giniHealthAPI = MockHealthAPI(docService: documentService, payService: paymentService)
        let giniHealth = GiniHealth(with: giniHealthAPI)
        paymentComponentsController = MockPaymentComponents(giniHealthSDK: giniHealth)
    }

    override func tearDown() {
        giniHealthAPI = nil
        paymentComponentsController = nil
        super.tearDown()
    }
    
    func testLoadPaymentProviders_Success() {
        // When
        paymentComponentsController.loadPaymentProviders()

        // Then
        XCTAssertFalse(paymentComponentsController.isLoading)
        XCTAssertNotNil(paymentComponentsController.selectedPaymentProvider)
    }
}
