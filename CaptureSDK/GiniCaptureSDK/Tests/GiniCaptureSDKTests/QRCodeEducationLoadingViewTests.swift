//
//  QRCodeEducationLoadingViewTests.swift
//  GiniCaptureSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK
@testable import GiniUtilites

@Suite("QRCodeEducationLoadingView — carousel item rendering")
@MainActor
struct QRCodeEducationLoadingViewTests {

    @Test("imageView shows the carousel item's own image")
    func imageViewShowsItemImage() async {
        let itemImage = Self.makeSolidColorImage()
        let item = QRCodeEducationLoadingItem(image: itemImage,
                                              text: "In case you didn't know…",
                                              duration: Constants.itemDuration)
        let viewModel = QRCodeEducationLoadingViewModel(items: [item])
        let sut = QRCodeEducationLoadingView(viewModel: viewModel)

        await viewModel.start()

        let imageView = Self.findImageView(in: sut)
        #expect(imageView?.image === itemImage,
                "Expected the item's own image to be used unchanged")
    }

    @Test("text and animated-suffix label render alongside the carousel item")
    func textLabelAndAnalysingSuffixRender() async {
        let itemText = "In case you didn't know…"
        let item = QRCodeEducationLoadingItem(image: Self.makeSolidColorImage(),
                                              text: itemText,
                                              duration: Constants.itemDuration)
        let viewModel = QRCodeEducationLoadingViewModel(items: [item])
        let sut = QRCodeEducationLoadingView(viewModel: viewModel)

        await viewModel.start()

        #expect(Self.findLabelText(in: sut) == itemText,
                "Expected the item's text to render")
        #expect(Self.findAnimatedSuffixLabel(in: sut) != nil,
                "Expected the analysing-suffix label to exist")
    }

    // MARK: - Helpers

    private enum Constants {
        /// Short enough to keep the async test fast; long enough that `start()` reliably
        /// emits `currentItem` before the sleep completes.
        static let itemDuration: TimeInterval = 0.01
    }

    private static func findImageView(in view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView { return imageView }
        for subview in view.subviews {
            if let imageView = findImageView(in: subview) { return imageView }
        }
        return nil
    }

    private static func findLabelText(in view: UIView) -> String? {
        if let label = view as? UILabel, let text = label.text, !text.isEmpty {
            return text
        }
        for subview in view.subviews {
            if let text = findLabelText(in: subview) { return text }
        }
        return nil
    }

    private static func findAnimatedSuffixLabel(in view: UIView) -> GiniAnimatedSuffixLabelView? {
        if let suffix = view as? GiniAnimatedSuffixLabelView { return suffix }
        for subview in view.subviews {
            if let suffix = findAnimatedSuffixLabel(in: subview) { return suffix }
        }
        return nil
    }

    private static func makeSolidColorImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 4, height: 4), false, 1)
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 4, height: 4))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
