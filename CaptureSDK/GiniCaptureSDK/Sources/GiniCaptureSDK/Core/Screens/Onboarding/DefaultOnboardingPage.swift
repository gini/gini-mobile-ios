//
//  DefaultOnboardingPage.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

enum DefaultOnboardingPage {
    case flatPaper
    case lighting
    case multipage
    case qrcode

    var imageName: String {
        switch self {
        case .flatPaper:
            return "onboardingFlatPaper"
        case .lighting:
            return "onboardingGoodLighting"
        case .multipage:
            return "onboardingMultiPages"
        case .qrcode:
            return "onboardingQRCode"
        }
    }

    var title: String {
        switch self {
        case .flatPaper:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.flatPaper.title",
                                                    comment: "onboarding flat paper title")
        case .lighting:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.goodLighting.title",
                                                    comment: "onboarding good lighting title")
        case .multipage:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.multiPages.title",
                                                    comment: "onboarding multi pages title")
        case .qrcode:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.qrCode.title",
                                                    comment: "onboarding qrcode title")
        }
    }

    var description: String {
        switch self {
        case .flatPaper:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.flatPaper.description",
                                                    comment: "onboarding flat paper description")
        case .lighting:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.goodLighting.description",
                                                    comment: "onboarding good lighting description")
        case .multipage:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.multiPages.description",
                                                    comment: "onboarding multi pages description")
        case .qrcode:
            return NSLocalizedStringPreferredFormat("ginicapture.onboarding.qrCode.description",
                                                    comment: "onboarding qrcode description")
        }
    }
}
