//
//  GiniSetupHelper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import XCTest
import GiniHealthAPILibrary
import GiniHealthSDK

final class GiniSetupHelper {
    private var giniHealthAPILib: GiniHealthAPI!
    var giniHealthAPIDocumentService: GiniHealthAPILibrary.DefaultDocumentService!
    var giniHealth: GiniHealth!
    
    private var clientId: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_ID"]
        return value?.isEmpty == false ? value : nil
    }
    
    private var clientSecret: String? {
        let value = ProcessInfo.processInfo.environment["CLIENT_SECRET"]
        return value?.isEmpty == false ? value : nil
    }

    func setup() {
        guard let id = clientId, let secret = clientSecret else {
            XCTFail("CLIENT_ID and CLIENT_SECRET environment variables must be set for integration tests")
            return
        }
        let clientDomain = "client_domain"

        let client: GiniHealthAPILibrary.Client = Client(id: id, secret: secret, domain: "gini.net")
        giniHealthAPILib = GiniHealthAPI
            .Builder(client: client)
            .build()

        giniHealthAPIDocumentService = giniHealthAPILib.documentService()
        giniHealth = GiniHealth(id: id, secret: secret, domain: clientDomain)
    }
}
