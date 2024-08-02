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
        let client: GiniHealthAPILibrary.Client = CredentialsManager.fetchClientFromBundle()
        giniHealthAPILib = GiniHealthAPI
            .Builder(client: client)
            .build()

        giniHealthAPIDocumentService = giniHealthAPILib.documentService()
    }
}
