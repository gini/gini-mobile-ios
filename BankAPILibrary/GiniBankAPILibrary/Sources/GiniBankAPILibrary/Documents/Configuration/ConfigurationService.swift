//
//  ConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/**
 A service class to fetch configuration settings
 */
public final class ConfigurationService: ConfigurationServiceProtocol {
    public func fetchConfigurations(completion: @escaping CompletionResult<Configuration>) {
        self.fetchConfigurations(resourceHandler: sessionManager.data, completion: completion)
    }

    let sessionManager: SessionManagerProtocol
    public var apiDomain: APIDomain

    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
}

extension ConfigurationService {
    func fetchConfigurations(resourceHandler: ResourceDataHandler<APIResource<Configuration>>,
                             completion: @escaping CompletionResult<Configuration>) {
        let resource = APIResource<Configuration>(method: .configurations, apiDomain: apiDomain, httpMethod: .get)
        
        resourceHandler(resource, { result in
            switch result {
            case let .success(configuration):
                completion(.success(configuration))
            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
}
