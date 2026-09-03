//
//  MockClientConfigurationService.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary

/**
 Test double for `ClientConfigurationServiceProtocol`. Fires `fetchConfigurations`
 synchronously with the preset `result`.
 */
final class MockClientConfigurationService: ClientConfigurationServiceProtocol {
    var result: Result<ClientConfiguration, GiniError>

    init(result: Result<ClientConfiguration, GiniError>) {
        self.result = result
    }

    func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>) {
        completion(result)
    }
}
