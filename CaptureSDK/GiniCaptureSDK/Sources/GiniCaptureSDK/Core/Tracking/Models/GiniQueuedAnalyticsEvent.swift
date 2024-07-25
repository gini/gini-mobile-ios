//
//  GiniQueuedAnalyticsEvent.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

public struct GiniQueuedAnalyticsEvent {
    let event: GiniAnalyticsEvent
    let screenNameString: String?
    let properties: [GiniAnalyticsProperty]
}
