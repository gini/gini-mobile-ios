//
//  ViewController.swift
//  HealthSDKPinningExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthSDK
import GiniHealthAPILibrary
import GiniHealthAPILibraryPinning

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeSDK()
    }

    func initializeSDK() {
//        let yourPublicPinningConfig = [
//            kTSKPinnedDomains: [
//            "pay-api.gini.net": [
//                kTSKPublicKeyHashes: [
//                // old *.gini.net public key
//                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
//                // new *.gini.net public key, active from around June 2020
//                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
//            ]],
//            "user.gini.net": [
//                kTSKPublicKeyHashes: [
//                // old *.gini.net public key
//                "cNzbGowA+LNeQ681yMm8ulHxXiGojHE8qAjI+M7bIxU=",
//                // new *.gini.net public key, active from around June 2020
//                "zEVdOCzXU8euGVuMJYPr3DUU/d1CaKevtr0dW0XzZNo="
//            ]],
//        ]] as [String: Any]
//        let giniApiLib = GiniHealthAPI
//            .Builder(client: Client(id: "your-id",
//                                    secret: "your-secret",
//                                    domain: "your-domain"),
//                     api: .default,
//                     pinningConfig: yourPublicPinningConfig)
//            .build()
//        let sdk = GiniHealth(with: giniApiLib)
//        let documentService: DefaultDocumentService = sdk.documentService
    }
}

