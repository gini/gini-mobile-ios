//
//  GiniSetupHelper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDK

final class GiniSetupHelper {
    private var giniHealthAPILib: GiniHealthAPI!
    var giniHealthAPIDocumentService: GiniHealthAPILibrary.DefaultDocumentService!
    var giniHealth: GiniHealth!

    func setup() {
        let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
        let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
        let clientDomain = "client_domain"

        let client: GiniHealthAPILibrary.Client = Client(id: clientId, secret: clientSecret, domain: "gini.net")
        giniHealthAPILib = GiniHealthAPI
            .Builder(client: client)
            .build()

        giniHealthAPIDocumentService = giniHealthAPILib.documentService()
        giniHealth = GiniHealth(id: clientId, secret: clientSecret, domain: clientDomain)
    }
}
