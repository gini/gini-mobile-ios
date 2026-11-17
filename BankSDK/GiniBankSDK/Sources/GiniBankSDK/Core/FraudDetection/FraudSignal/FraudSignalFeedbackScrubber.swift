//
//  FraudSignalFeedbackScrubber.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary

/**
 Defensive filter that removes the `fraudSignals` key from a feedback payload if it
 is ever reintroduced upstream. `GiniBankConfiguration` builds its own dictionaries
 and never copies the key in — this strip is belt-and-braces so a future refactor
 cannot regress the invariant that fraud signals stay SDK-internal.
 */
internal enum FraudSignalFeedbackScrubber {

    /**
     Key for the fraud-signal compound extraction. Must never appear in feedback payloads.
     */
    internal static let fraudSignalsKey = "fraudSignals"

    internal static func strip(_ compoundExtractions: [String: [[Extraction]]]?) -> [String: [[Extraction]]]? {
        guard var filtered = compoundExtractions else { return nil }
        filtered.removeValue(forKey: fraudSignalsKey)
        return filtered
    }
}
