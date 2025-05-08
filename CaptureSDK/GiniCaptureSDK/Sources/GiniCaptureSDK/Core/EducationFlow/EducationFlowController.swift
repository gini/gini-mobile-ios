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
class EducationFlowController {

    private let configuration: EducationFlowConfiguration

    private init(configuration: EducationFlowConfiguration) {
        self.configuration = configuration
    }
    /**
     Determines the next state of the education flow.

     - Returns: `.showMessage(index)` or `.showOriginalFlow`
     */
    func nextState() -> EducationFlowState {
        guard configuration.isEducationEnabled() else {
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

    /**
     Resets the education flow display count.
     */
    func reset() {
        configuration.setDisplayCount(0)
    }
}

extension EducationFlowController {
    static func qrCodeFlowController() -> EducationFlowController {
        let isEducationEnabled = { GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled ?? false }
        let getDisplayCount = { GiniCaptureUserDefaultsStorage.messageDisplayCount }
        let setDisplayCount = { GiniCaptureUserDefaultsStorage.messageDisplayCount = $0 }

        let configuration = EducationFlowConfiguration(maxTotalDisplays: 200,
                                                       numberOfMessages: 1,
                                                       isEducationEnabled: isEducationEnabled,
                                                       getDisplayCount: getDisplayCount,
                                                       setDisplayCount: setDisplayCount)

        return EducationFlowController(configuration: configuration)
    }
}
