//
//  ClientConfigurationService.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Foundation

/**
 A service responsible for fetching configuration settings.
 This service implements the ClientConfigurationServiceProtocol and provides methods to retrieve configuration data from a specified API domain.
 */
public final class ClientConfigurationService: ClientConfigurationServiceProtocol {
    /**
     Fetches configuration settings.
     
     This method initiates the process of fetching configuration settings by utilizing the provided session manager to handle the network request.
     
     - Parameters:
     - completion: A closure to be called upon completion of the fetch operation. The closure takes a `CompletionResult<ClientConfiguration>` as its parameter.
     */
    public func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>) {
        self.fetchConfigurations(resourceHandler: sessionManager.data, completion: completion)
    }

    /// The session manager responsible for handling network requests.
    let sessionManager: SessionManagerProtocol
    
    /// The API domain to be used for fetching configurations.
    public var apiDomain: APIDomain
    public var apiVersion: Int

    /**
     Initializes a new instance of `ClientConfigurationService`.
     
     - Parameters:
     - sessionManager: An object conforming to `SessionManagerProtocol` responsible for managing network sessions
     - apiDomain: The domain of the API to fetch configurations from. Defaults to `.default`.
     - apiVersion: The apiVersion of the API
     */
    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default, apiVersion: Int) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
        self.apiVersion = apiVersion
    }
}

extension ClientConfigurationService {
    /**
     A helper method to fetch configurations using a resource handler.
     
     This method constructs an `APIResource` object with the required parameters and utilizes the resource handler to perform the network request. The result is then saved into UserDefaults and passed to the completion handler.
     
     - Parameters:
     - resourceHandler: A handler responsible for processing the API resource data.
     - completion: A closure to be called upon completion of the fetch operation. The closure takes a `CompletionResult<Configuration>` as its parameter.
     */
    func fetchConfigurations(resourceHandler: ResourceDataHandler<APIResource<ClientConfiguration>>,
                             completion: @escaping CompletionResult<ClientConfiguration>) {
        let resource = APIResource<ClientConfiguration>(method: .configurations, apiDomain: apiDomain, apiVersion: apiVersion, httpMethod: .get)
        
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
