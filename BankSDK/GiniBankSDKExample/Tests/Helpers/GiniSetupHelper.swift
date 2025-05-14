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
    // When running from Xcode: update these environment variables.
    // Make sure not to commit the credentials if the scheme is shared!
    private let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"]!
    private let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"]!

    private var giniBankAPILib: GiniBankAPI!
    var giniCaptureSDKDocumentService: GiniCaptureSDK.DocumentService!
    var giniBankAPIDocumentService: GiniBankAPILibrary.DefaultDocumentService!
    var giniBankConfigurationService: GiniBankAPILibrary.ClientConfigurationServiceProtocol!
    var paymentService: PaymentService!

    func setup() {
        let client = Client(id: clientId,
                            secret: clientSecret,
                            domain: "bank-sdk-example")
        giniBankAPILib = GiniBankAPI
            .Builder(client: client)
            .build()

        giniCaptureSDKDocumentService = DocumentService(lib: giniBankAPILib, metadata: nil)

        giniBankAPIDocumentService = giniBankAPILib.documentService()
        paymentService = giniBankAPILib.paymentService()
        giniBankConfigurationService = giniBankAPILib.configurationService()
    }
}
