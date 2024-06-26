//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


@testable import GiniHealthAPILibrary
 
extension GiniMerchant {
    convenience init(documentService: GiniHealthAPILibrary.DocumentService,
         paymentService: GiniHealthAPILibrary.PaymentService) {
        let giniHealthAPI = GiniHealthAPI(documentService: documentService, 
                                          paymentService: paymentService)
        self.init(giniApiLib: giniHealthAPI)
    }
}
