//
//  EducationFlowContent.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

enum EducationFlowContent {
    case qrCode(messageIndex: Int)
    case captureInvoice

    var items: [QRCodeEducationLoadingItem] {
        let intro = QRCodeEducationLoadingItem(image: Images.intro,
                                               text: LocalizedStrings.intro,
                                               duration: 1.5)
        let captureTip = QRCodeEducationLoadingItem(image: Images.capture,
                                                    text: LocalizedStrings.capture,
                                                    duration: 3)
        let uploadTip = QRCodeEducationLoadingItem(image: Images.uploadFile,
                                                   text: LocalizedStrings.uploadFile,
                                                   duration: 3)

        switch self {
        case .qrCode(let index):
            return index == 0 ? [intro, captureTip] : [intro, uploadTip]
        case .captureInvoice:
            return [intro, uploadTip]
        }
    }

}

private extension EducationFlowContent {
    enum LocalizedStrings {
        static let intro = NSLocalizedStringPreferredFormat("ginicapture.analysis.education.loading.intro",
                                                            comment: "Education loading intro")
        static let capture = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.education.loading.captureTip",
                                                              comment: "Capture hint")
        static let uploadFile = NSLocalizedStringPreferredFormat("ginicapture.analysis.education.loading.uploadTip",
                                                                 comment: "Upload tip")
    }

    enum Images {
        static let intro = UIImageNamedPreferred(named: "qrCodeEducationIntroIcon")
        static let capture = UIImageNamedPreferred(named: "qrCodeEducationCaptureIcon")
        static let uploadFile = UIImageNamedPreferred(named: "qrCodeEducationUploadIcon")
    }
}
