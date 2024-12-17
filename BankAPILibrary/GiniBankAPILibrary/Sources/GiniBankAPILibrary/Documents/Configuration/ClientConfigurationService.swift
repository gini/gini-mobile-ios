//
//  ClientConfigurationService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

/**
 A service responsible for fetching configuration settings.
 
 This service implements the `ClientConfigurationServiceProtocol` and provides methods to retrieve configuration data from a specified API domain.
 */
public final class ClientConfigurationService: ClientConfigurationServiceProtocol {
    /**
     Fetches configuration settings.
     
     - Parameter completion: A closure to be called upon completion of the fetch operation. The closure takes a `CompletionResult<Configuration>` as its parameter.
     
     This method initiates the process of fetching configuration settings by utilizing the provided session manager to handle the network request.
     */
    public func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>) {
        self.fetchConfigurations(resourceHandler: sessionManager.data, completion: completion)
    }

    /// The session manager responsible for handling network requests.
    let sessionManager: SessionManagerProtocol
    
    /// The API domain to be used for fetching configurations.
    public var apiDomain: APIDomain

    /**
     Initializes a new instance of `ClientConfigurationService`.
     
     - Parameters:
       - sessionManager: An object conforming to `SessionManagerProtocol` responsible for managing network sessions.
       - apiDomain: The domain of the API to fetch configurations from. Defaults to `.default`.
     */
    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
}

extension ClientConfigurationService {
    /**
     A helper method to fetch configurations using a resource handler.
     
     - Parameters:
       - resourceHandler: A handler responsible for processing the API resource data.
       - completion: A closure to be called upon completion of the fetch operation. The closure takes a `CompletionResult<Configuration>` as its parameter.
     
     This method constructs an `APIResource` object with the required parameters and utilizes the resource handler to perform the network request. The result is then saved into UserDefaults and passed to the completion handler.
     */
    private func fetchConfigurations(resourceHandler: ResourceDataHandler<APIResource<ClientConfiguration>>,
                                     completion: @escaping CompletionResult<ClientConfiguration>) {
        let resource = APIResource<ClientConfiguration>(method: .configurations, 
                                                        apiDomain: apiDomain,
                                                        httpMethod: .get)

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
