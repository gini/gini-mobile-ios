//
//  GiniSetupHelper.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK
import GiniBankSDK

final class GiniSetupHelper {
    private let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    private let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!
    private var giniBankAPILib: GiniBankAPI!
    var giniCaptureSDKDocumentService: GiniCaptureSDK.DocumentService!
    var giniBankAPIDocumentService: GiniBankAPILibrary.DefaultDocumentService!

   func setup() {
        let client = Client(id: clientId,
                            secret: clientSecret,
                            domain: "bank-sdk-example")
        giniBankAPILib = GiniBankAPI
            .Builder(client: client)
            .build()

        giniCaptureSDKDocumentService = DocumentService(lib: giniBankAPILib, metadata: nil)

        giniBankAPIDocumentService = giniBankAPILib.documentService()
    }
}
