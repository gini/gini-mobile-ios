//
//  ConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public protocol ConfigurationServiceProtocol: AnyObject {
    func fetchConfiguration(completion: @escaping CompletionResult<Configuration>)
}

public final class ConfigurationService: ConfigurationServiceProtocol {
    public func fetchConfiguration(completion: @escaping CompletionResult<Configuration>) {
        self.fetchConfiguration(resourceHandler: sessionManager.data, completion: completion)
    }

    let sessionManager: SessionManagerProtocol
    public var apiDomain: APIDomain

    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
}

extension ConfigurationService {
    func fetchConfiguration(resourceHandler: ResourceDataHandler<APIResource<Configuration>>,
                            completion: @escaping CompletionResult<Configuration>) {
        let resource = APIResource<Configuration>(method: .fetchConfiguration, apiDomain: .default, httpMethod: .get)
        
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
