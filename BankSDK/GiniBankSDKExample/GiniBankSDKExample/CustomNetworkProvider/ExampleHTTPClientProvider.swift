//
//  ExampleHTTPClientProvider.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary

/// Provider for the example HTTP client.
final class ExampleHTTPClientProvider: GiniNetworkProvider {

    private let client: GiniHTTPClient

    init() {
        self.client = ExampleHTTPClient()
    }

    func httpClient() -> GiniHTTPClient {
        return client
    }
}
