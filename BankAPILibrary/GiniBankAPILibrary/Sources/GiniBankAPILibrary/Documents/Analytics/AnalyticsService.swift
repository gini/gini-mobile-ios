//
//  AnalyticsService.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/// `AnalyticsService` is responsible for sending batched analytics events to a server.
/// It utilizes a session manager to manage network requests and communicates with a configurable API domain.
public final class AnalyticsService: AnalyticsServiceProtocol {

    // MARK: - Properties

    /// The session manager responsible for handling network requests.
    /// This must conform to the `SessionManagerProtocol`.
    let sessionManager: SessionManagerProtocol

    /// The API domain used for sending analytics event requests.
    /// This determines the base URL for API communication.
    public var apiDomain: APIDomain

    // MARK: - Initialization

    /**
     Initializes a new instance of `AnalyticsService`.

     - Parameters:
     - sessionManager: An object conforming to `SessionManagerProtocol` responsible for managing network requests.
     - apiDomain: The domain of the API for sending analytics events. Defaults to `.default`.

     - Important: The `sessionManager` is required to perform network communication,
     and the `apiDomain` configures the target API server.
     */
    init(sessionManager: SessionManagerProtocol, apiDomain: APIDomain = .default) {
        self.sessionManager = sessionManager
        self.apiDomain = apiDomain
    }

    // MARK: - Public Methods

    /**
     Sends a batch of analytics events payload to the server.

     - Parameters:
     - payload: The `AmplitudeEventsBatchPayload` object containing a batch of analytics events to send.
     - completion: A closure called when the request is completed.
     It provides a `Result` containing either a `String` on success or a `GiniError` on failure.

     - Note: Internally, this method delegates the request to `sessionManager` for execution.
     */
    public func sendEventsPayload(payload: AmplitudeEventsBatchPayload,
                                  completion: @escaping CompletionResult<String>) {
        sendEventsPayload(payload: payload,
                          resourceHandler: sessionManager.data,
                          completion: completion)
    }
}

extension AnalyticsService {
    // MARK: - Private Helper Methods

    /**
     Sends the analytics events payload using the provided resource handler.

     - Parameters:
     - payload: The `AmplitudeEventsBatchPayload` object containing the events data.
     - resourceHandler: A handler for performing the network request, provided by `sessionManager`.
     - completion: A closure called when the request completes with success or failure.

     - Note:
     The payload is encoded using `JSONEncoder`.
     */
    func sendEventsPayload(payload: AmplitudeEventsBatchPayload,
                           resourceHandler: ResourceDataHandler<APIResource<String>>,
                           completion: @escaping CompletionResult<String>) {
        let resource = APIResource<String>(
            method: .analyticsEvent,
            apiDomain: apiDomain,
            httpMethod: .post,
            additionalHeaders: [:],
            body: try? JSONEncoder().encode(payload)
        )
        sessionManager.data(resource: resource, completion: completion)
    }
}
