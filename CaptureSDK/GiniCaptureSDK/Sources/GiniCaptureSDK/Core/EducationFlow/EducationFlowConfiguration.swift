//
//  EducationFlowConfiguration.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 A configuration object that defines parameters and dependencies for an education flow.

 - Parameters:
    - maxTotalDisplays: The maximum total number of times any education message should be shown.
    - numberOfMessages: The number of different messages to alternate between.
    - shouldBeDisplayed: A closure returning whether the education flow is enabled.
    - getDisplayCount: A closure returning the current display count.
    - setDisplayCount: A closure to update the display count.
 */
struct EducationFlowConfiguration {
    let maxTotalDisplays: Int
    let numberOfMessages: Int
    let shouldBeDisplayed: () -> Bool
    let getDisplayCount: () -> Int
    let setDisplayCount: (Int) -> Void
}
