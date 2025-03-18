//
//  QREngagementStep.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

enum QREngagementStep {
    case first
    case second
    case third

    var title: String {
        switch self {
        case .first:
            return NSLocalizedStringPreferredFormat("ginicapture.QRengagement.first.title",
                                     comment: "Title for first engagement step")
        case .second:
            return NSLocalizedStringPreferredFormat("ginicapture.QRengagement.second.title",
                                     comment: "Title for second engagement step")
        case .third:
            return NSLocalizedStringPreferredFormat("ginicapture.QRengagement.third.title",
                                     comment: "Title for third engagement step")
        }
    }

    var description: String {
        switch self {
        case .first:
            return NSLocalizedStringPreferredFormat("ginicapture.QRengagement.first.description",
                                     comment: "Description for first engagement step")
        case .second:
            return NSLocalizedStringPreferredFormat("ginicapture.QRengagement.second.description",
                                     comment: "Description for second engagement step")
        case .third:
            return NSLocalizedStringPreferredFormat("ginicapture.QRengagement.third.description",
                                     comment: "Description for third engagement step")
        }
    }

    var image: UIImage? {
        switch self {
        case .first:
            return GiniCaptureImages.qrCodeEngagementStep0.image
        case .second:
            return GiniCaptureImages.qrCodeEngagementStep1.image
        case .third:
            return GiniCaptureImages.qrCodeEngagementStep2.image
        }
    }

    var attributedDescription: NSAttributedString {
        let text = description
        let configuration = GiniConfiguration.shared
        guard let baseFont = configuration.textStyleFonts[.callout],
              let boldFont = configuration.textStyleFonts[.calloutBold] else {
            return NSAttributedString(string: text)
        }

        var substringsAttributes: [(String, [NSAttributedString.Key: Any])] = []

        if self == .first {
            let boldWordsString = NSLocalizedStringPreferredFormat("ginicapture.QRengagement.first.description.boldwords",
                                                                   comment: "Bold words for QR engagement step, separated by ';'")
            let wordsToBold = boldWordsString.components(separatedBy: ";")
            substringsAttributes = wordsToBold.map { ($0, [.font: boldFont]) }
        }

        return text.attributed(with: [.font: baseFont], substringsAttributes: substringsAttributes)
    }
}
