//
//  EducationFlowController.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 A controller that manages the invoice photo flow state.

 It determines whether to show the education message or fallback to the original flow,
 based on a configuration flag and how many times the message has already been displayed.
 */
final class EducationFlowController {

    private let configuration: EducationFlowConfiguration

    init(configuration: EducationFlowConfiguration) {
        self.configuration = configuration
    }
    /**
     Determines the next state of the education flow.

     - Returns: `.showMessage(index)` or `.showOriginalFlow`
     */
    func nextState() -> EducationFlowState {
        guard configuration.shouldBeDisplayed() else {
            return .showOriginalFlow
        }

        let currentCount = configuration.getDisplayCount()

        guard currentCount < configuration.maxTotalDisplays else {
            return .showOriginalFlow
        }

        let messageIndex = currentCount % configuration.numberOfMessages

        configuration.setDisplayCount(currentCount + 1)

        return .showMessage(messageIndex: messageIndex)
    }
}
