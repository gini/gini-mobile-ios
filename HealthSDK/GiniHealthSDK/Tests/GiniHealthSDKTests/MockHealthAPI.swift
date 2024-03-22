//
//  MockHealthAPI.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniHealthAPILibrary

class MockHealthAPI: HealthAPI {
    func documentService<T>() -> T where T : GiniHealthAPILibrary.DocumentService {
        return docService as! T
    }
    
    func paymentService() -> GiniHealthAPILibrary.PaymentService {
        payService!
    }
    
    public var docService: DocumentService!
    public var payService: PaymentService?
    var paymentProvidersResult: Result<PaymentProviders, Error> = .success([])
    
    init(docService: DocumentService!, payService: PaymentService? = nil) {
        self.docService = docService
        self.payService = payService
    }
}
