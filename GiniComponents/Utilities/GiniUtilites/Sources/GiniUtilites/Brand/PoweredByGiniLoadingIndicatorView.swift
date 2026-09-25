//
//  PoweredByGiniLoadingIndicatorView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import ImageIO

/**
 Animated Gini "g" loading indicator shown on the Analysis screen and QR
 overlay when ingredient-brand mode is enabled. Loads one of two animated
 HEIC (`HEICS`) assets from `GiniBrand.xcassets` —
 `gini_loading_indicator_light.dataset` or
 `gini_loading_indicator_dark.dataset` — picked by name from the current
 `UIUserInterfaceStyle`, decodes the frames via `CGImageSource`, and
 renders them in a looping `UIImageView` scaled to Figma's `Animation
 Gini` container height (135pt). `traitCollectionDidChange` swaps the
 decoded frame set when the appearance flips at runtime without recreating
 the view.

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
     Re-decodes and swaps in the appearance-matched HEIC when the interface
     style flips at runtime. `decodeFrames(for:)` picks between the
     `gini_loading_indicator_light` and `gini_loading_indicator_dark` datasets
     by name from the current `userInterfaceStyle`.
     */
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        let wasAnimating = imageView.isAnimating
        reloadAnimatedImage()
        if wasAnimating {
            imageView.startAnimating()
        }
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
     Returns the decoded animated `UIImage` for the given trait collection's
     `userInterfaceStyle`. Callers outside this view (e.g.
     `QRCodeEducationLoadingView`) use this to render the same animated mark
     without instantiating a full `PoweredByGiniLoadingIndicatorView`.

     - Parameters:
       - traitCollection: Trait collection whose `userInterfaceStyle` selects
         the light or dark HEIC variant. Defaults to `.current`.

     - Returns: The decoded animated `UIImage`, or `nil` if the HEIC asset
       could not be loaded or decoded.
     */
    public static func animatedImage(for traitCollection: UITraitCollection = .current) -> UIImage? {
        guard let extracted = decodeFrames(for: traitCollection.userInterfaceStyle) else { return nil }
        return UIImage.animatedImage(with: extracted.frames, duration: extracted.duration)
    }

    private func reloadAnimatedImage() {
        guard let extracted = Self.decodeFrames(for: traitCollection.userInterfaceStyle) else {
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

    /**
     Loads and decodes the HEIC data asset matching the given interface style
     from one of two universal datasets — `gini_loading_indicator_light` and
     `gini_loading_indicator_dark` — and returns the decoded frame set from
     the process-wide cache when available so repeat callers (e.g. the
     education carousel and the standalone view) don't re-decode. Main-thread
     use only.
     */
    static func decodeFrames(for style: UIUserInterfaceStyle) -> ExtractedFrames? {
        if let cached = cachedFrames[style] { return cached }
        let assetName = style == .dark
            ? Constants.darkAssetName
            : Constants.lightAssetName
        guard let dataAsset = NSDataAsset(name: assetName, bundle: .module) else {
            return nil
        }
        guard let extracted = decodeFrames(from: dataAsset.data) else { return nil }
        cachedFrames[style] = extracted
        return extracted
    }

    /**
     Decodes each frame via `CGImageSourceCreateThumbnailAtIndex` capped at
     `Constants.thumbnailMaxPixelSize` so the retained CGImage backing store
     stays well below the source's exported pixel resolution while still
     leaving headroom above the `@3x` device scale of the shipped 135pt
     layout container. The returned per-frame `scale` keeps
     `UIImage.size.height == Constants.targetPointHeight`; width scales
     proportionally via `scaleAspectFit`.
     */
    static func decodeFrames(from data: Data) -> ExtractedFrames? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        guard count > 0 else { return nil }
        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Constants.thumbnailMaxPixelSize
        ]
        guard let firstCGImage = CGImageSourceCreateThumbnailAtIndex(source,
                                                                     0,
                                                                     thumbnailOptions as CFDictionary) else {
            return nil
        }
        let pixelHeight = CGFloat(firstCGImage.height)
        guard pixelHeight > 0 else { return nil }
        let scale = max(pixelHeight / Constants.targetPointHeight, 1)

        var frames: [UIImage] = [UIImage(cgImage: firstCGImage, scale: scale, orientation: .up)]
        var duration: TimeInterval = frameDelay(source: source, index: 0)
        for index in 1..<count {
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source,
                                                                    index,
                                                                    thumbnailOptions as CFDictionary) else { continue }
            frames.append(UIImage(cgImage: cgImage, scale: scale, orientation: .up))
            duration += frameDelay(source: source, index: index)
        }
        let safeDuration = duration > 0
            ? duration
            : TimeInterval(frames.count) * Constants.fallbackFrameDelay
        return ExtractedFrames(frames: frames, duration: safeDuration)
    }

    /// Process-wide cache of decoded frame sets, keyed by interface style.
    /// At most two entries (light + dark). Populated lazily by
    /// `decodeFrames(for:)`. Main-thread access only.
    private static var cachedFrames: [UIUserInterfaceStyle: ExtractedFrames] = [:]

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
        static let lightAssetName = "gini_loading_indicator_light"
        static let darkAssetName = "gini_loading_indicator_dark"
        static let fallbackFrameDelay: TimeInterval = 0.1
        /// Height of Figma's `Animation Gini` container. All decoded frames are
        /// scaled so `UIImage.size.height` == this value; width follows the
        /// exported aspect ratio.
        static let targetPointHeight: CGFloat = 135
        /// Cap on decoded frame pixel dimensions, chosen to leave headroom above
        /// the maximum `@3x` device pixel need (`targetPointHeight × 3 ≈ 405`) while
        /// keeping the retained CGImage backing store far below the source HEIC's
        /// exported resolution (~1006×1006 in the shipped asset).
        static let thumbnailMaxPixelSize: Int = 512
    }

    enum Strings {
        /// Hardcoded English default; `AnalysisViewController` overlays the specific
        /// loading text via `accessibilityValue` at the same call site that already
        /// annotates the default `UIActivityIndicatorView`.
        static let accessibilityLabel = "Loading"
    }
}
