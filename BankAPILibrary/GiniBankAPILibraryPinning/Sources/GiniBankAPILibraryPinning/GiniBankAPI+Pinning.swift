//
//  GiniBankAPI+Pinning.swift
//  GiniBankAPI
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import TrustKit
import GiniBankAPILibrary

public extension GiniBankAPI.Builder {
    init(client: Client,
                api: APIDomain = .default,
                pinningConfig: [String: Any],
                logLevel: LogLevel = .none) {
        self.init(client: client, api: api, logLevel: logLevel)
        
        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
    }
}
