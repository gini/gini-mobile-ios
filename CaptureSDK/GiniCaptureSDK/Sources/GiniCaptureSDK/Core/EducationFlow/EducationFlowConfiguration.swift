//
//  EducationFlowConfiguration.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

struct EducationFlowConfiguration {
    let maxTotalDisplays: Int
    let numberOfMessages: Int
    let isEducationEnabled: () -> Bool
    let getDisplayCount: () -> Int
    let setDisplayCount: (Int) -> Void
}
