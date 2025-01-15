//
//  GiniMerchant+Test.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

@testable import GiniHealthAPILibrary
@testable import GiniMerchantSDK

extension GiniMerchant {
    convenience init(documentService: GiniHealthAPILibrary.DocumentService,
         paymentService: GiniHealthAPILibrary.PaymentService) {
        let giniHealthAPI = GiniHealthAPI(documentService: documentService, 
                                          paymentService: paymentService,
                                          clientConfigurationService: nil)
        self.init(giniApiLib: giniHealthAPI)
    }
}
