//
//  ClientConfigurationService.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary

/// The default document service. By default interacts with the `APIDomain.default` api.
public final class DefaultClientConfigurationService {
    
    private let clientConfigurationService: GiniHealthAPILibrary.ClientConfigurationService
    
    init(clientConfigurationService: GiniHealthAPILibrary.ClientConfigurationService) {
        self.clientConfigurationService = clientConfigurationService
        self.clientConfigurationService.apiDomain = .default
        self.clientConfigurationService.apiVersion = GiniHealth.Constants.defaultVersionAPI
    }
 
    /**
     A helper method to fetch configurations using a resource handler.
     
     - Parameters:
       - resourceHandler: A handler responsible for processing the API resource data.
       - completion: A closure to be called upon completion of the fetch operation. The closure takes a `CompletionResult<Configuration>` as its parameter.
     
     This method constructs an `APIResource` object with the required parameters and utilizes the resource handler to perform the network request. The result is then saved into UserDefaults and passed to the completion handler.
     */
    func fetchConfigurations(completion: @escaping CompletionResult<ClientConfiguration>) {
        clientConfigurationService.fetchConfigurations { result in
            switch result {
            case .success(let clientConfiguration):
                completion(.success(clientConfiguration))
            case .failure(let error):
                completion(.failure(GiniError.decorator(error)))
            }
        }
    }
}
