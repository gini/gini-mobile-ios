//
//  GiniHealthAPILib.swift
//  GiniHealthAPILib
//
//  Created by Enrique del Pozo Gómez on 1/21/18.
//

import TrustKit
import GiniHealthAPILibrary

public extension GiniHealthAPILib.Builder {
    init(client: Client,
                api: APIDomain = .default,
                pinningConfig: [String: Any],
                logLevel: LogLevel = .none) {
        self.init(client: client, api: api, logLevel: logLevel)
        
        TrustKit.initSharedInstance(withConfiguration: pinningConfig)
    }
}
