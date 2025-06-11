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
    static func captureInvoiceFlowController(displayIfNeeded: Bool) -> EducationFlowController {
        let shouldBeDisplayed = { displayIfNeeded && (GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled ?? false) }
        let getDisplayCount = { GiniCaptureUserDefaultsStorage.captureInvoiceEducationMessageDisplayCount }
        let setDisplayCount = { GiniCaptureUserDefaultsStorage.captureInvoiceEducationMessageDisplayCount = $0 }

        let configuration = EducationFlowConfiguration(maxTotalDisplays: 2,
                                                       numberOfMessages: 1,
                                                       shouldBeDisplayed: shouldBeDisplayed,
                                                       getDisplayCount: getDisplayCount,
                                                       setDisplayCount: setDisplayCount)

        return EducationFlowController(configuration: configuration)
    }

    static func qrCodeFlowController(displayIfNeeded: Bool) -> EducationFlowController {
        let shouldBeDisplayed = { displayIfNeeded && (GiniCaptureUserDefaultsStorage.qrCodeEducationEnabled ?? false) }
        let getDisplayCount = { GiniCaptureUserDefaultsStorage.qrCodeEducationMessageDisplayCount }
        let setDisplayCount = { GiniCaptureUserDefaultsStorage.qrCodeEducationMessageDisplayCount = $0 }

        let configuration = EducationFlowConfiguration(maxTotalDisplays: 4,
                                                       numberOfMessages: 2,
                                                       shouldBeDisplayed: shouldBeDisplayed,
                                                       getDisplayCount: getDisplayCount,
                                                       setDisplayCount: setDisplayCount)

        return EducationFlowController(configuration: configuration)
    }
}
