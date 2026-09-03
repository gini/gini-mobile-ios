//
//  MockFailingConfigurationService.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary

final class MockFailingConfigurationService: ClientConfigurationServiceProtocol {
    func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>) {
        completion(.failure(.noResponse))
    }
}
