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
                                           text: LocalizedStrings.introText,
                                           duration: 1.5)
        let camera = QRCodeEducationLoadingItem(image: Images.camera,
                                            text: LocalizedStrings.cameraText,
                                            duration: 3)
        let photo = QRCodeEducationLoadingItem(image: Images.photo,
                                           text: LocalizedStrings.photoText,
                                           duration: 3)

        switch self {
        case .qrCode(let index):
            return index == 0 ? [intro, camera] : [intro, photo]
        case .captureInvoice:
            return [intro, photo]
        }
    }

}

private extension EducationFlowContent {
    enum LocalizedStrings {
        static let introText = NSLocalizedStringPreferredFormat("ginicapture.analysis.education.intro",
                                                                comment: "Education intro")
        static let cameraText = NSLocalizedStringPreferredFormat("ginicapture.QRscanning.education.camera",
                                                                 comment: "Camera education")
        static let photoText = NSLocalizedStringPreferredFormat("ginicapture.analysis.education.photo",
                                                                comment: "Photo education")
    }

    enum Images {
        static let intro = UIImageNamedPreferred(named: "qrEducationIntro")
        static let camera = UIImageNamedPreferred(named: "qrEducationCamera")
        static let photo = UIImageNamedPreferred(named: "qrEducationPhoto")
    }
}

