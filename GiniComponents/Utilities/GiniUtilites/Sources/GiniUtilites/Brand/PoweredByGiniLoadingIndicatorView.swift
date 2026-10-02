//
//  PoweredByGiniLoadingIndicatorView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit
import ImageIO

/**
 Animated Gini "g" loading indicator for ingredient-brand clients. Loads the light
 or dark HEIC dataset by `UIUserInterfaceStyle` and swaps on appearance change.
 Check `hasValidAsset` before installing — falls back to `UIActivityIndicatorView`.
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

    /// Caller intent, kept separate from `isAnimating` so reduce-motion can gate playback without losing state.
    private var wantsAnimation: Bool = false

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

        /// Not a VoiceOver element (relying on UIView's default `isAccessibilityElement == false`):
        /// iOS Text Recognition OCRs the pixel region inside the focus rectangle, which on
        /// screens overlaying document previews leaks invoice content underneath the "g" asset.

        reloadAnimatedImage()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reduceMotionStatusDidChange),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        reloadAnimatedImage()
        applyReducedMotionAwareAnimationState()
    }

    /**
     Starts the frame animation. When `isReduceMotionEnabled` is true, stays on the first frame.
     Idempotent; no-op when `hasValidAsset` is false.
     */
    public func startAnimation() {
        wantsAnimation = true
        applyReducedMotionAwareAnimationState()
    }

    /**
     Stops the underlying `UIImageView` frame animation. Idempotent — safe
     to call when already stopped.
     */
    public func stopAnimation() {
        wantsAnimation = false
        imageView.stopAnimating()
    }

    /**
     Applies `wantsAnimation` filtered through `isReduceMotionEnabled`.
     */
    private func applyReducedMotionAwareAnimationState() {
        guard hasValidAsset, wantsAnimation else { return }
        if UIAccessibility.isReduceMotionEnabled {
            /// First frame is already the poster on `imageView.image`, so stopping reveals it.
            imageView.stopAnimating()
        } else {
            imageView.startAnimating()
        }
    }

    @objc private func reduceMotionStatusDidChange() {
        applyReducedMotionAwareAnimationState()
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
        let extracted = Self.decodeFrames(for: traitCollection.userInterfaceStyle)
        apply(frames: extracted)
        if extracted == nil {
            Log("Gini ingredient-brand loading indicator asset failed to load", event: .error)
        }
    }

    private func apply(frames extracted: ExtractedFrames?) {
        /// `animationImages` (rather than an animated `UIImage`) is used here so that
        /// `imageView.startAnimating()`/`isAnimating` report reliably in unit tests and on
        /// screens where iOS's implicit-animation heuristics for animated `UIImage`s don't fire.
        imageView.animationImages = extracted?.frames
        imageView.animationDuration = extracted?.duration ?? 0
        imageView.animationRepeatCount = 0
        imageView.image = extracted?.frames.first
        hasValidAsset = (extracted != nil)
        invalidateIntrinsicContentSize()
    }

    /**
     Off-main prewarm of the frame cache; call at SDK idle so the first `init` decode is a cache hit.
     - Parameter styles: Appearance variants to decode. Defaults to both.
     */
    public nonisolated static func prewarm(styles: [UIUserInterfaceStyle] = [.light, .dark]) async {
        await withTaskGroup(of: Void.self) { group in
            for style in styles {
                group.addTask(priority: .userInitiated) {
                    _ = decodeFrames(for: style)
                }
            }
        }
    }

    /**
     Loads and decodes the HEIC dataset for `style` from the cache when possible.
     Thread-safe via `NSCache` — safe from a background queue.
     */
    nonisolated static func decodeFrames(for style: UIUserInterfaceStyle) -> ExtractedFrames? {
        let key = NSNumber(value: style.rawValue)
        if let box = PoweredByGiniLoadingFrameCache.shared.object(forKey: key) { return box.extracted }
        let assetName = style == .dark
            ? Constants.darkAssetName
            : Constants.lightAssetName
        guard let dataAsset = NSDataAsset(name: assetName, bundle: .module) else {
            return nil
        }
        guard let extracted = decodeFrames(from: dataAsset.data) else { return nil }
        /// Worst-case RGBA cost at the thumbnail cap — exact for the shipped square asset.
        let bytesPerFrame = Constants.thumbnailMaxPixelSize * Constants.thumbnailMaxPixelSize * 4
        let byteCost = extracted.frames.count * bytesPerFrame
        PoweredByGiniLoadingFrameCache.shared.setObject(ExtractedFramesBox(extracted), forKey: key, cost: byteCost)
        return extracted
    }

    /**
     Decodes each frame via `CGImageSourceCreateThumbnailAtIndex`, downsampled
     to `Constants.thumbnailMaxPixelSize`. Per-frame scale sets
     `UIImage.size.height == Constants.targetPointHeight`.
     */
    nonisolated static func decodeFrames(from data: Data) -> ExtractedFrames? {
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

    struct ExtractedFrames {
        let frames: [UIImage]
        let duration: TimeInterval
    }

    /// Class wrapper so `ExtractedFrames` (a value type) can live inside `NSCache`,
    /// which requires class-typed values.
    final class ExtractedFramesBox {
        let extracted: ExtractedFrames
        init(_ extracted: ExtractedFrames) {
            self.extracted = extracted
        }
    }

    /**
     Reads the per-frame display delay from either the HEICS or GIF metadata
     dictionary at `index`. HEICS is tried first (matches the shipped asset
     format); GIF is kept as a fallback so the same code path can decode a
     substitute GIF during development without an additional branch.
     */
    private nonisolated static func frameDelay(source: CGImageSource,
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

/// Process-wide frame cache. Lives outside `PoweredByGiniLoadingIndicatorView` so
/// it does not inherit the view's `@MainActor` isolation — `decodeFrames(for:)` /
/// `prewarm(styles:)` are `nonisolated` and must be able to read/write the cache
/// from off-main without hopping. `NSCache` is documented thread-safe.
private enum PoweredByGiniLoadingFrameCache {
    static let shared: NSCache<NSNumber, PoweredByGiniLoadingIndicatorView.ExtractedFramesBox> = {
        let cache = NSCache<NSNumber, PoweredByGiniLoadingIndicatorView.ExtractedFramesBox>()
        cache.name = "PoweredByGiniLoadingIndicatorView.cachedFrames"
        cache.totalCostLimit = PoweredByGiniLoadingIndicatorView.Constants.cacheTotalCostLimit
        return cache
    }()
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
        /// Max device pixel need at `@3x` (`targetPointHeight × 3`).
        static let thumbnailMaxPixelSize: Int = 405
        /// Byte ceiling for the frame cache; fits both variants and yields under memory pressure.
        static let cacheTotalCostLimit: Int = 128 * 1024 * 1024
    }

}
