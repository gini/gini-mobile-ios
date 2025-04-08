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

    let paymentRequestID = "a6466506-acf1-4896-94c8-9b398d4e0ee1"

    // MARK: - Pinning Config
    let wrongPinningConfig = [
        "pay-api.gini.net": [
            // Wrong hashes
            "TQEtdMbmwFgYUifM4LDF+xgEtd0z69mPGmkp014d6ZY=",
            "rFjc3wG7lTZe43zeYTvPq8k4xdDEutCmIhI5dn4oCeE="
        ],
        "user.gini.net": [
            // Wrong hashes
            "TQEtdMbmwFgYUifM4LDF+xgEtd0z69mPGmkp014d6ZY=",
            "rFjc3wG7lTZe43zeYTvPq8k4xdDEutCmIhI5dn4oCeE="
        ]
    ]

    static let pinningConfig = [
        "pay-api.gini.net": [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
        ],
        "user.gini.net": [
            // old *.gini.net public key
            "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
            // new *.gini.net public key, active from around June 2020
            "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo=",
        ]
    ]

    private let bandSDKExampleDomain = "bank-sdk-example"
    private let pinningClient = Client(id: "", secret: "", domain: "")

    private var giniBankAPILib: GiniBankAPI!
    var giniCaptureSDKDocumentService: GiniCaptureSDK.DocumentService!
    var giniBankAPIDocumentService: GiniBankAPILibrary.DefaultDocumentService!
    var paymentService: PaymentService!

    func setup() {
        let client = Client(id: clientId, secret: clientSecret, domain: bandSDKExampleDomain)
        giniBankAPILib = Self.buildBankAPI(client: client)

        giniCaptureSDKDocumentService = DocumentService(lib: giniBankAPILib, metadata: nil)
        giniBankAPIDocumentService = giniBankAPILib.documentService()
        paymentService = giniBankAPILib.paymentService()
    }

    func setupWithPinningCertificates() {
        let client = Client(id: clientId, secret: clientSecret, domain: bandSDKExampleDomain)
        giniBankAPILib = Self.buildBankAPI(client: client, pinningConfig: GiniSetupHelper.pinningConfig)
        giniBankAPIDocumentService = giniBankAPILib.documentService()
        giniCaptureSDKDocumentService = DocumentService(lib: giniBankAPILib, metadata: nil)
        paymentService = giniBankAPILib.paymentService()
    }

    func setupWithWrongPinningCertificates() {
        let client = Client(id: clientId, secret: clientSecret, domain: bandSDKExampleDomain)
        giniBankAPILib = Self.buildBankAPI(client: client, pinningConfig: wrongPinningConfig)
        giniBankAPIDocumentService = giniBankAPILib.documentService()
        giniCaptureSDKDocumentService = DocumentService(lib: giniBankAPILib, metadata: nil)
        paymentService = giniBankAPILib.paymentService()
    }
}

extension GiniSetupHelper {
    static func buildBankAPI(client: Client? = nil,
                             customApiDomain: String? = nil,
                             customUserDomain: String? = nil,
                             alternativeTokenSource: AlternativeTokenSource? = nil,
                             pinningConfig: [String: [String]] = GiniSetupHelper.pinningConfig,
                             logLevel: LogLevel = .none) -> GiniBankAPI {
        if let customApiDomain, let alternativeTokenSource {
            return GiniBankAPI.Builder(customApiDomain: customApiDomain,
                                       alternativeTokenSource: alternativeTokenSource,
                                       pinningConfig: pinningConfig,
                                       logLevel: logLevel).build()
        } else {
            guard let client else {
                fatalError("Client must be provided when not using alternativeTokenSource")
            }

            let api: APIDomain? = customApiDomain.map { .custom(domain: $0, tokenSource: nil) }
            let userApi: UserDomain? = customUserDomain.map { .custom(domain: $0) }

            return GiniBankAPI.Builder(client: client,
                                       api: api ?? .default,
                                       userApi: userApi ?? .default,
                                       pinningConfig: pinningConfig,
                                       logLevel: logLevel).build()
        }
    }
}
