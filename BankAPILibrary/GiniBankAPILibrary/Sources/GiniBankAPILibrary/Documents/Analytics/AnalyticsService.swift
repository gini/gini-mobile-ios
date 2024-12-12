//
//  AnalyticsService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation


public final class AnalyticsService: AnalyticsServiceProtocol {
    public func sendEventsPayload(payload: AmplitudeEventsBatchPayload, completion: @escaping CompletionResult<String>) {
        self.sendEventsPayload(payload: payload, resourceHandler: sessionManager.data, completion: completion)
    }

    /// The session manager responsible for handling network requests.
    let sessionManager: SessionManagerProtocol
    
    /// The API domain to be used for fetching configurations.
    public var apiDomain: APIDomain

    /**
     Initializes a new instance of `AnalyticsService`.
     
     - Parameters:
       - sessionManager: An object conforming to `SessionManagerProtocol` responsible for managing network sessions.
       - apiDomain: The domain of the API to fetch configurations from. Defaults to `.default`.
     */
    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }
}

extension AnalyticsService {
    func sendEventsPayload(payload: AmplitudeEventsBatchPayload ,resourceHandler: ResourceDataHandler<APIResource<String>>,
                             completion: @escaping CompletionResult<String>) {
        let resource = APIResource<String>.init(method: .analyticsEvent,
                                                apiDomain: apiDomain,
                                                httpMethod: .post,
                                                additionalHeaders: [:],
                                                body: try? JSONEncoder().encode(payload))
        sessionManager.data(resource: resource, completion: completion)
    }
}
