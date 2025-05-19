//
//  EducationFlowContent.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

enum EducationFlowContent {
    case qrCode(messageIndex: Int)
    case captureInvoice

    var items: [QREducationLoadingItem] {
        let intro = QREducationLoadingItem(
            image: UIImageNamedPreferred(named: "qrEducationIntro"),
            text: NSLocalizedStringPreferredFormat("ginicapture.analysis.education.intro", comment: "Education intro"),
            duration: 1.5
        )

        let camera = QREducationLoadingItem(
            image: UIImageNamedPreferred(named: "qrEducationCamera"),
            text: NSLocalizedStringPreferredFormat("ginicapture.QRscanning.education.camera", comment: "Camera education"),
            duration: 3
        )

        let photo = QREducationLoadingItem(
            image: UIImageNamedPreferred(named: "qrEducationPhoto"),
            text: NSLocalizedStringPreferredFormat("ginicapture.analysis.education.photo", comment: "Photo education"),
            duration: 3
        )

        switch self {
        case .qrCode(let index):
            return index == 0 ? [intro, camera] : [intro, photo]
        case .captureInvoice:
            return [intro, photo]
        }
    }
}
