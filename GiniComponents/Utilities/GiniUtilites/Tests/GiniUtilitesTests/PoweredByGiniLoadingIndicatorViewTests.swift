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

    @Test("prewarm decodes both light and dark datasets off the main actor without stalling")
    func prewarmPopulatesCacheOffMain() async {
        let start = Date()
        await PoweredByGiniLoadingIndicatorView.prewarm()
        let elapsed = Date().timeIntervalSince(start)

        /// Post-prewarm view construction should hit the cache — `hasValidAsset` flips true immediately.
        let view = PoweredByGiniLoadingIndicatorView()
        #expect(view.hasValidAsset,
                "Expected hasValidAsset to be true after prewarm populates the cache")
        #expect(elapsed < 10,
                "Expected prewarm to complete inside a reasonable bound; measured \(elapsed) s")
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

    // MARK: - iOS 15 alpha-preserving fallback

    /// Loads the shipped light HEIC as a `CGImageSource` for the fallback tests.
    private func makeHEICImageSource() throws -> CGImageSource {
        let asset = try #require(NSDataAsset(name: "gini_loading_indicator_light", bundle: .module),
                                 "Expected the shipped light HEIC dataset to resolve from GiniUtilites.module")
        let source = try #require(CGImageSourceCreateWithData(asset.data as CFData, nil),
                                  "Expected CGImageSource to open the shipped HEIC payload")
        return source
    }

    @Test("iOS 15 fallback preserves alpha channel in the decoded frame")
    func decodeFrameWithAlphaKeepsAlphaChannel() throws {
        let source = try makeHEICImageSource()

        let cgImage = try #require(PoweredByGiniLoadingIndicatorView.decodeFrameWithAlpha(from: source, at: 0),
                                   "Expected the fallback to decode a frame from the shipped HEIC")

        let alphaInfo = cgImage.alphaInfo
        /// The hardware thumbnail path on iOS 15 flattens to `.none` / `.noneSkipLast` and composites against black.
        /// The fallback must land on an alpha-bearing format so transparent pixels stay transparent.
        let alphaBearing: Set<CGImageAlphaInfo> = [.premultipliedLast, .premultipliedFirst, .last, .first]
        #expect(alphaBearing.contains(alphaInfo),
                "Expected an alpha-bearing CGImageAlphaInfo, got \(alphaInfo.rawValue)")
    }

    @Test("iOS 15 fallback: a corner pixel of the Gini mark decodes as transparent, not solid black")
    func decodeFrameWithAlphaKeepsCornerPixelTransparent() throws {
        let source = try makeHEICImageSource()
        let cgImage = try #require(PoweredByGiniLoadingIndicatorView.decodeFrameWithAlpha(from: source, at: 0),
                                   "Expected the fallback to decode a frame from the shipped HEIC")

        /// Crop to the top-left 1×1 region. `CGImage.cropping(to:)` uses the image's own
        /// coordinate space with origin at top-left, so this is unambiguous — unlike drawing
        /// into a probe context with a negative Y translation, which is coordinate-order sensitive.
        /// The Gini "g" mark sits centered on a transparent canvas, so the corner must be transparent;
        /// a fully-opaque black sample here means the alpha channel was dropped.
        let topLeft = try #require(cgImage.cropping(to: CGRect(x: 0, y: 0, width: 1, height: 1)),
                                   "Expected to crop a 1×1 top-left region from the decoded frame")

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue
        var pixel: [UInt8] = [0, 0, 0, 0]
        let context = try #require(CGContext(data: &pixel,
                                             width: 1,
                                             height: 1,
                                             bitsPerComponent: 8,
                                             bytesPerRow: 4,
                                             space: colorSpace,
                                             bitmapInfo: bitmapInfo),
                                   "Expected to build a 1×1 RGBA probe context")
        context.draw(topLeft, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        #expect(pixel[3] == 0,
                "Expected the corner pixel's alpha to be 0 (transparent canvas); got \(pixel[3])")
    }

    @Test("iOS 15 fallback downsamples a large source to within the thumbnail cap")
    func decodeFrameWithAlphaDownsamplesLargeSource() throws {
        let source = try makeHEICImageSource()
        let fullImage = try #require(CGImageSourceCreateImageAtIndex(source, 0, nil),
                                     "Expected the full HEIC frame to decode for the size comparison")

        let decoded = try #require(PoweredByGiniLoadingIndicatorView.decodeFrameWithAlpha(from: source, at: 0),
                                   "Expected the fallback to decode a frame from the shipped HEIC")

        /// The shipped asset is 1006×1006 at @1x; thumbnailMaxPixelSize is 405 px. Downsampled frame
        /// must fit under the cap on its longest edge, and must be strictly smaller than the source.
        let maxSide = max(decoded.width, decoded.height)
        #expect(maxSide <= 405,
                "Expected downsample to clamp the longest edge to 405 px; got \(maxSide)")
        #expect(decoded.width < fullImage.width && decoded.height < fullImage.height,
                "Expected the fallback output to be smaller than the full source (\(fullImage.width)x\(fullImage.height)")
    }

    @Test("iOS 15 fallback returns nil when the frame index is out of range")
    func decodeFrameWithAlphaReturnsNilForInvalidIndex() throws {
        let source = try makeHEICImageSource()

        let decoded = PoweredByGiniLoadingIndicatorView.decodeFrameWithAlpha(from: source, at: Int.max)

        #expect(decoded == nil,
                "Expected nil for an out-of-range frame index (CGImageSource returns nil)")
    }

    @Test("decodeFrame dispatches via #available: on iOS 16+ it still returns a usable CGImage")
    func decodeFrameDispatchReturnsCGImage() throws {
        let source = try makeHEICImageSource()

        let decoded = try #require(PoweredByGiniLoadingIndicatorView.decodeFrame(from: source, at: 0),
                                   "Expected decodeFrame to produce a CGImage for either iOS branch")

        #expect(decoded.width > 0 && decoded.height > 0,
                "Expected a non-empty decoded frame regardless of which decode branch ran")
    }
}
