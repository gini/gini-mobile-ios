//
//  ConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

public protocol ConfigurationServiceProtocol: AnyObject {
    var apiDomain: APIDomain { get set }
    func fetchConfigurations(completion: @escaping CompletionResult<Configuration>)
}

extension ConfigurationServiceProtocol {
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

