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

@Suite("QRCodeEducationLoadingView — ingredient-brand indicator swap on the item icon")
@MainActor
struct QRCodeEducationLoadingViewTests {

    @Test("imageView shows the carousel item's own image when useIngredientBrandIndicator is false")
    func imageViewShowsItemImageWhenIngredientBrandFalse() async {
        let itemImage = Self.makeSolidColorImage()
        let item = QRCodeEducationLoadingItem(image: itemImage,
                                              text: "In case you didn't know…",
                                              duration: Constants.itemDuration)
        let viewModel = QRCodeEducationLoadingViewModel(items: [item])
        let sut = QRCodeEducationLoadingView(viewModel: viewModel,
                                             style: .init(useIngredientBrandIndicator: false))

        await viewModel.start()

        let imageView = Self.findImageView(in: sut)
        #expect(imageView?.image === itemImage,
                "Expected the item's own image to be used unchanged when flag is off")
    }

    @Test("imageView shows the animated Gini image when useIngredientBrandIndicator is true")
    func imageViewShowsGiniAnimatedImageWhenIngredientBrandTrue() async {
        let itemImage = Self.makeSolidColorImage()
        let item = QRCodeEducationLoadingItem(image: itemImage,
                                              text: "Upload PDFs, images, or GIFs",
                                              duration: Constants.itemDuration)
        let viewModel = QRCodeEducationLoadingViewModel(items: [item])
        let sut = QRCodeEducationLoadingView(viewModel: viewModel,
                                             style: .init(useIngredientBrandIndicator: true))

        await viewModel.start()

        let imageView = Self.findImageView(in: sut)
        #expect((imageView?.image?.images?.count ?? 0) > 0,
                "Expected an animated image (non-empty .images) when flag is on")
        #expect(imageView?.image !== itemImage,
                "Expected the animated Gini image to replace the item's own icon (identity mismatch)")
    }

    @Test("text and animated-suffix label are unaffected by the ingredient-brand flag")
    func textLabelAndAnalysingSuffixAreUnaffectedByIngredientBrandFlag() async {
        let sharedText = "In case you didn't know…"
        let item = QRCodeEducationLoadingItem(image: Self.makeSolidColorImage(),
                                              text: sharedText,
                                              duration: Constants.itemDuration)

        let brandedVM = QRCodeEducationLoadingViewModel(items: [item])
        let brandedView = QRCodeEducationLoadingView(viewModel: brandedVM,
                                                     style: .init(useIngredientBrandIndicator: true))
        let plainVM = QRCodeEducationLoadingViewModel(items: [item])
        let plainView = QRCodeEducationLoadingView(viewModel: plainVM,
                                                   style: .init(useIngredientBrandIndicator: false))

        await brandedVM.start()
        await plainVM.start()

        #expect(Self.findLabelText(in: brandedView) == sharedText,
                "Expected the item's text on the branded view")
        #expect(Self.findLabelText(in: plainView) == sharedText,
                "Expected the item's text on the plain view")
        #expect(Self.findAnimatedSuffixLabel(in: brandedView) != nil,
                "Expected the analysing-suffix label to exist on the branded view")
        #expect(Self.findAnimatedSuffixLabel(in: plainView) != nil,
                "Expected the analysing-suffix label to exist on the plain view")
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
