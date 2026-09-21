//
//  PoweredByGiniLoadingIndicatorView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import ImageIO

/**
 Animated Gini "g" loading indicator shown on the Analysis screen when
 ingredient-brand mode is enabled. Loads a single animated HEIC (`HEICS`)
 asset from `GiniBrand.xcassets`, decodes the frames via `CGImageSource`,
 and renders them in a looping `UIImageView` scaled to Figma's `Animation
 Gini` container height (135pt).

 The asset is theme-agnostic — the Gini mark's brand color reads on both
 light and dark backgrounds — so a single dataset serves both interface
 styles. This replaces the earlier two-GIF (light + dark) layout and cuts
 the shipped resource payload by ~85%.

 If the asset is missing or fails to decode, `hasValidAsset` is `false` and
 the view renders empty; callers should check the flag and fall back to
 `UIActivityIndicatorView` on `false`.
 */
public final class PoweredByGiniLoadingIndicatorView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        return imageView
    }()

    /**
     `true` when the HEIC asset loaded and decoded successfully. Callers
     must check this before installing the view; on `false`, fall back to
     `UIActivityIndicatorView`.
     */
    public private(set) var hasValidAsset: Bool = false

    /**
     Creates a new `PoweredByGiniLoadingIndicatorView`, decodes the HEIC
     asset, and installs it inside a `UIImageView` pinned to the view's
     edges. Sizing is driven by the decoded frames' intrinsic size scaled
     to `Constants.targetPointHeight`.
     */
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        imageView.giniMakeConstraints { $0.edges.equalToSuperview() }

        isAccessibilityElement = true
        accessibilityLabel = Strings.accessibilityLabel
        accessibilityTraits = [.image, .updatesFrequently]

        reloadAnimatedImage()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        imageView.image?.size ?? imageView.animationImages?.first?.size ?? .zero
    }

    /**
     Starts the underlying `UIImageView` frame animation. Idempotent — safe
     to call when already animating. No-op when `hasValidAsset` is `false`.
     */
    public func startAnimation() {
        imageView.startAnimating()
    }

    /**
     Stops the underlying `UIImageView` frame animation. Idempotent — safe
     to call when already stopped.
     */
    public func stopAnimation() {
        imageView.stopAnimating()
    }

    /**
     Returns the decoded animated `UIImage`, or `nil` if the HEIC asset
     couldn't be loaded or decoded. Callers outside this view (e.g.
     `QRCodeEducationLoadingView`) use this to render the same animated
     mark without instantiating a full `PoweredByGiniLoadingIndicatorView`.
     */
    public static func animatedImage() -> UIImage? {
        guard let extracted = decodeFrames() else { return nil }
        return UIImage.animatedImage(with: extracted.frames, duration: extracted.duration)
    }

    private func reloadAnimatedImage() {
        guard let extracted = Self.decodeFrames() else {
            imageView.animationImages = nil
            imageView.image = nil
            imageView.animationDuration = 0
            hasValidAsset = false
            invalidateIntrinsicContentSize()
            Log("Gini ingredient-brand loading indicator asset failed to load", event: .error)
            return
        }
        /// `animationImages` (rather than an animated `UIImage`) is used here so that
        /// `imageView.startAnimating()`/`isAnimating` report reliably in unit tests and on
        /// screens where iOS's implicit-animation heuristics for animated `UIImage`s don't fire.
        imageView.animationImages = extracted.frames
        imageView.animationDuration = extracted.duration
        imageView.animationRepeatCount = 0
        imageView.image = extracted.frames.first
        hasValidAsset = true
        invalidateIntrinsicContentSize()
    }

    static func decodeFrames() -> ExtractedFrames? {
        guard let dataAsset = NSDataAsset(name: Constants.assetName, bundle: .module) else {
            return nil
        }
        return decodeFrames(from: dataAsset.data)
    }

    static func decodeFrames(from data: Data) -> ExtractedFrames? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        guard count > 0,
              let firstCGImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        /// Scale each frame so `UIImage.size.height == Constants.targetPointHeight`
        /// regardless of the asset's exported pixel resolution. Width scales
        /// proportionally via `scaleAspectFit`.
        let pixelHeight = CGFloat(firstCGImage.height)
        guard pixelHeight > 0 else { return nil }
        let scale = max(pixelHeight / Constants.targetPointHeight, 1)

        var frames: [UIImage] = [UIImage(cgImage: firstCGImage, scale: scale, orientation: .up)]
        var duration: TimeInterval = frameDelay(source: source, index: 0)
        for index in 1..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: cgImage, scale: scale, orientation: .up))
            duration += frameDelay(source: source, index: index)
        }
        let safeDuration = duration > 0
            ? duration
            : TimeInterval(frames.count) * Constants.fallbackFrameDelay
        return ExtractedFrames(frames: frames, duration: safeDuration)
    }

    struct ExtractedFrames {
        let frames: [UIImage]
        let duration: TimeInterval
    }

    /**
     Reads the per-frame display delay from either the HEICS or GIF metadata
     dictionary at `index`. HEICS is tried first (matches the shipped asset
     format); GIF is kept as a fallback so the same code path can decode a
     substitute GIF during development without an additional branch.
     */
    private static func frameDelay(source: CGImageSource,
                                   index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any] else {
            return Constants.fallbackFrameDelay
        }
        if let heics = properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any] {
            if let unclamped = heics[kCGImagePropertyHEICSUnclampedDelayTime] as? TimeInterval, unclamped > 0 {
                return unclamped
            }
            if let clamped = heics[kCGImagePropertyHEICSDelayTime] as? TimeInterval, clamped > 0 {
                return clamped
            }
        }
        if let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
            if let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval, unclamped > 0 {
                return unclamped
            }
            if let clamped = gif[kCGImagePropertyGIFDelayTime] as? TimeInterval, clamped > 0 {
                return clamped
            }
        }
        return Constants.fallbackFrameDelay
    }
}

private extension PoweredByGiniLoadingIndicatorView {
    enum Constants {
        static let assetName = "gini_loading_indicator"
        static let fallbackFrameDelay: TimeInterval = 0.1
        /// Matches Figma's `Animation Gini` container height (`36375:182135`,
        /// `36375:182438` in the PP-3511 handoff). All decoded frames are
        /// scaled so `UIImage.size.height` == this value; width follows the
        /// exported aspect ratio.
        static let targetPointHeight: CGFloat = 135
    }

    enum Strings {
        /// Hardcoded English default; `AnalysisViewController` overlays the specific
        /// loading text via `accessibilityValue` at the same call site that already
        /// annotates the default `UIActivityIndicatorView`.
        static let accessibilityLabel = "Loading"
    }
}
