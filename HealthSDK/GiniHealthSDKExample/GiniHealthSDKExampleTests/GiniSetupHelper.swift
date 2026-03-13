//
//  GiniSetupHelper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDK
@testable import GiniHealthSDKExample

final class GiniSetupHelper {
    private let giniHealthAPILib: GiniHealthAPI
    let giniHealthAPIDocumentService: GiniHealthSDK.DefaultDocumentService
    let giniHealth: GiniHealth

    init() {
        let client: GiniHealthAPILibrary.Client = Client(id: testClientID,
                                                        secret: testClientPassword,
                                                        domain: testClientDomain)
        giniHealthAPILib = GiniHealthAPI.Builder(client: client).build()
        giniHealth = GiniHealth(giniApiLib: giniHealthAPILib)
        giniHealthAPIDocumentService = giniHealth.documentService
    }

    func setup() {
        // Setup is now performed in init(); this method is kept for compatibility.
    }
}

