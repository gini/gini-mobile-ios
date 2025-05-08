//
//  EducationFlowController+QRCode.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

extension EducationFlowController {
    /**
     Creates and returns an `EducationFlowController` configured for the QR code education flow.

     This controller uses `GiniCaptureUserDefaultsStorage` to manage the education flow state
     (enabled flag and display count) specific to the QR code flow.
     */
    static func qrCodeFlowController() -> EducationFlowController {
        let isEducationEnabled = { GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled ?? false }
        let getDisplayCount = { GiniCaptureUserDefaultsStorage.captureInvoiceEducationMessageDisplayCount }
        let setDisplayCount = { GiniCaptureUserDefaultsStorage.captureInvoiceEducationMessageDisplayCount = $0 }

        let configuration = EducationFlowConfiguration(maxTotalDisplays: 200,
                                                       numberOfMessages: 1,
                                                       isEducationEnabled: isEducationEnabled,
                                                       getDisplayCount: getDisplayCount,
                                                       setDisplayCount: setDisplayCount)

        return EducationFlowController(configuration: configuration)
    }
}
