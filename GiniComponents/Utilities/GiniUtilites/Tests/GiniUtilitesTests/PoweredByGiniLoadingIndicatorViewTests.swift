//
//  PoweredByGiniLoadingIndicatorViewTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniUtilites

@Suite("PoweredByGiniLoadingIndicatorView — animated Gini ingredient-brand indicator")
@MainActor
struct PoweredByGiniLoadingIndicatorViewTests {

    @Test("init decodes frames from the HEIC asset and hasValidAsset flips to true")
    func initExtractsFramesFromDataAsset() {
        let view = PoweredByGiniLoadingIndicatorView()

        #expect(view.hasValidAsset,
                "Expected hasValidAsset to be true after init when the asset catalog resolves")
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first
        #expect((imageView?.animationImages?.count ?? 0) > 0,
                "Expected UIImageView.animationImages to be non-empty (frames extracted via CGImageSource)")
        #expect((imageView?.animationDuration ?? 0) > 0,
                "Expected UIImageView.animationDuration to be positive (per-frame delays summed via CGImageSource)")
        #expect(imageView?.image != nil,
                "Expected the first frame to be assigned to .image as the static poster")
    }

    @Test("decodeFrames returns nil on empty or garbage data (R7 fallback path)")
    func decodeFramesReturnsNilOnInvalidData() {
        #expect(PoweredByGiniLoadingIndicatorView.decodeFrames(from: Data()) == nil,
                "Expected empty Data to decode to nil (no CGImageSource)")
        let garbage = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        #expect(PoweredByGiniLoadingIndicatorView.decodeFrames(from: garbage) == nil,
                "Expected non-image bytes to decode to nil (CGImageSource yields zero frames)")
    }

    @Test("startAnimation starts the underlying UIImageView animation")
    func startAnimationStartsUnderlyingImageView() {
        /// UIImageView only reports `isAnimating` truthfully once the view is in a window
        /// (animation timer isn't scheduled otherwise) — attach a host window for the test.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let view = PoweredByGiniLoadingIndicatorView()
        window.addSubview(view)
        window.makeKeyAndVisible()
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first

        view.startAnimation()

        #expect(imageView?.isAnimating == true,
                "Expected UIImageView.isAnimating to be true after startAnimation()")
    }

    @Test("stopAnimation stops the underlying UIImageView animation")
    func stopAnimationStopsUnderlyingImageView() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let view = PoweredByGiniLoadingIndicatorView()
        window.addSubview(view)
        window.makeKeyAndVisible()
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first
        view.startAnimation()

        view.stopAnimation()

        #expect(imageView?.isAnimating == false,
                "Expected UIImageView.isAnimating to be false after stopAnimation()")
    }

    @Test("animatedImage() resolves the shipped HEIC datasets and returns an animated UIImage")
    func animatedImageResolvesFromModuleBundle() throws {
        let lightAsset = try #require(NSDataAsset(name: "gini_loading_indicator_light", bundle: .module),
                                      "Expected the shipped light HEIC dataset to resolve from GiniUtilites.module")
        let darkAsset = try #require(NSDataAsset(name: "gini_loading_indicator_dark", bundle: .module),
                                     "Expected the shipped dark HEIC dataset to resolve from GiniUtilites.module")
        #expect(lightAsset.data.count > 0, "Expected the shipped light HEIC payload to be non-empty")
        #expect(darkAsset.data.count > 0, "Expected the shipped dark HEIC payload to be non-empty")
        #expect(lightAsset.data.count != darkAsset.data.count,
                "Expected the light and dark HEIC payloads to differ in size (Kate's exports are two distinct files)")

        let animated = PoweredByGiniLoadingIndicatorView.animatedImage()
        #expect(animated != nil, "Expected the animated UIImage to decode from the shipped dataset")
        #expect((animated?.images?.count ?? 0) > 1,
                "Expected the returned UIImage to carry the extracted frame sequence")
        #expect((animated?.duration ?? 0) > 0,
                "Expected the returned UIImage to carry a positive loop duration")
    }

    @Test("Exposes a single a11y image element with .updatesFrequently trait and a default label")
    func accessibilityIsSingleImageElementWithUpdatesFrequentlyTrait() {
        let view = PoweredByGiniLoadingIndicatorView()
        let imageView = view.subviews.compactMap { $0 as? UIImageView }.first

        #expect(view.isAccessibilityElement, "Expected the view itself to be a single a11y element")
        #expect(view.accessibilityLabel?.isEmpty == false,
                "Expected a non-empty default accessibilityLabel (AnalysisViewController overrides accessibilityValue with the loading text)")
        #expect(view.accessibilityTraits.contains(.image),
                "Expected .image trait so VoiceOver announces it as a graphic")
        #expect(view.accessibilityTraits.contains(.updatesFrequently),
                "Expected .updatesFrequently trait so VoiceOver doesn't re-read the label every frame")
        #expect(imageView?.isAccessibilityElement == false,
                "Expected the inner UIImageView to be excluded from VoiceOver focus (view is the a11y container)")
    }
}
