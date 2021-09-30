//
//  GiniPayApiLib.swift
//  GiniPayApiLib
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import TrustKit

extension GiniApiLib.Builder {
    public init(client: Client,
                api: APIDomain = .default,
                pinningConfig: [String: Any],
                logLevel: LogLevel = .none) {
        self.client = client
        self.api = api
        self.logLevel = logLevel
        
        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
    }
}
