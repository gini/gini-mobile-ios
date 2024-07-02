//
//  QueuedAnalyticsEvent.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct QueuedAnalyticsEvent {
    let event: AnalyticsEvent
    let screenNameString: String?
    let properties: [AnalyticsProperty]
}
