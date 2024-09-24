//
//  GiniSetupHelper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
import GiniHealthSDKExample

final class GiniSetupHelper {
    private var giniHealthAPILib: GiniHealthAPI!
    var giniHealthAPIDocumentService: GiniHealthAPILibrary.DefaultDocumentService!

    func setup() {
        let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
        let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!

        let client: GiniHealthAPILibrary.Client = Client(id: clientId, secret: clientSecret, domain: "gini.net")
        giniHealthAPILib = GiniHealthAPI
            .Builder(client: client)
            .build()

        giniHealthAPIDocumentService = giniHealthAPILib.documentService()
    }
}
