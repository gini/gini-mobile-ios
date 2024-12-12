//
//  AmplitudeEventsBatchPayload.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
/**
 A struct representing the payload for batching events to be sent to the Amplitude server.

 This struct conforms to the `Encodable` protocol to facilitate easy encoding
 to JSON format. It includes the API key and an array of events to be uploaded.

 - Parameters:
 - apiKey: The API key for the Amplitude analytics platform.
 - events: An array of `AmplitudeBaseEvent` objects to be included in the batch upload.
 */
public struct AmplitudeEventsBatchPayload: Encodable {
//    let apiKey: String
    let events: [AmplitudeBaseEvent]

    /**
     Customizes the coding keys for the `AmplitudeEventsBatchPayload` struct to match the expected JSON format.

     - apiKey: Encoded as "api_key" in the JSON payload.
     - events: Encoded as "events" in the JSON payload.
     */
    enum CodingKeys: String, CodingKey {
//        case apiKey = "api_key"
        case events
    }
    
    public init(events: [AmplitudeBaseEvent]) {
        self.events = events
    }
}
