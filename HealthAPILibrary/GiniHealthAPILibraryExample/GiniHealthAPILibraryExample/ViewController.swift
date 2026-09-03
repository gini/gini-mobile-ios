//
//  ViewController.swift
//  HealthAPILibraryExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthAPILibrary

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinningConfig = [
            "health-api.gini.net": [
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
            ],
        ]
        
        let lib = GiniHealthAPI.Builder(client: Client(id: "", secret: "", domain: "") , api: .default, pinningConfig: pinningConfig, logLevel: LogLevel.debug)
        
    }
}

