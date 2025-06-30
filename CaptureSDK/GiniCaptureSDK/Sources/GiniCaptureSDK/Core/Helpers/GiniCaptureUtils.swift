//
//  GiniCaptureUtils.swift
//  GiniCapture
//
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

public func giniCaptureBundle() -> Bundle {
    Bundle.resource
}

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.

 - parameter name: The name of the image file without file extension.

 - returns: Image if found with name.
 */
public func UIImageNamedPreferred(named name: String) -> UIImage? {
    if let mainBundleImage = UIImage(named: name,
                                     in: Bundle.main,
                                     compatibleWith: nil) {
        return mainBundleImage
    }
    if let customBundle = GiniConfiguration.shared.customResourceBundle,
       let customBundleImage = UIImage(named: name,
                                       in: customBundle,
                                       compatibleWith: nil) {
        return customBundleImage
    }

    return UIImage(named: name,
                   in: giniCaptureBundle(),
                   compatibleWith: nil)
}

/**
 Returns an optional `UIColor` instance with the given `name` preferably from the client's bundle.

 - parameter name: The name of the UIColor from `GiniColors` asset catalog.

 - returns: color if found with name.
 */
public func UIColorPreferred(named name: String) -> UIColor {
    if let mainBundleColor = UIColor(named: name,
                                     in: Bundle.main,
                                     compatibleWith: nil) {
        return mainBundleColor
    }

    if let customBundle = GiniConfiguration.shared.customResourceBundle,
       let customBundleColor = UIColor(named: name,
                                       in: customBundle,
                                       compatibleWith: nil) {
        return customBundleColor
    }

    if let color = UIColor(named: name,
                           in: giniCaptureBundle(),
                           compatibleWith: nil) {
        return color
    } else {
        fatalError("The color named '\(name)' does not exist.")
    }
}

/**
 Returns an optional `UIColor` instance with the given `name` preferably from the client's custom resources provider.

 - parameter name: The name of the UIColor.

 - returns: UIColor if found with name.
 */

public func UIColorPreferredByProvider(named name: String) -> UIColor {
    if let customProvider = GiniConfiguration.shared.customResourceProvider {
        return customProvider.customPrefferedColor(name: name)
    }
    return UIColorPreferred(named: name)
}

/**
 Returns a localized string resource preferably from the client's bundle.

 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.

 - returns: String resource for the given key.
 */
public func NSLocalizedStringPreferredFormat(_ key: String,
                                             fallbackKey: String = "",
                                             comment: String,
                                             isCustomizable: Bool = true) -> String {
    if isCustomizable {
        if let clientLocalizedStringMainBundle = clientLocalizedString(key,
                                                                       fallbackKey: fallbackKey,
                                                                       comment: comment,
                                                                       bundle: .main) {
            return clientLocalizedStringMainBundle

        } else if let customBundle = GiniConfiguration.shared.customResourceBundle,
                  let clientLocalizedStringCustomBundle = clientLocalizedString(key,
                                                                                fallbackKey: fallbackKey,
                                                                                comment: comment,
                                                                                bundle: customBundle) {

            return clientLocalizedStringCustomBundle
        }
    }

    return giniLocalizedString(key, fallbackKey: fallbackKey, comment: comment)
}

private func giniLocalizedString(_ key: String,
                                 fallbackKey: String,
                                 comment: String) -> String {
    let giniBundle = giniCaptureBundle()

    var defaultFormat = NSLocalizedString(key,
                                          bundle: giniBundle,
                                          comment: comment)

    if defaultFormat.lowercased() == key.lowercased() {
        defaultFormat = NSLocalizedString(fallbackKey,
                                          bundle: giniBundle,
                                          comment: comment)
    }
    return defaultFormat
}

private func clientLocalizedString(_ key: String,
                                   fallbackKey: String,
                                   comment: String,
                                   bundle: Bundle) -> String? {
    var clientString = NSLocalizedString(key,
                                         bundle: bundle,
                                         comment: comment)
    var fallbackClientString = NSLocalizedString(fallbackKey,
                                                 bundle: bundle,
                                                 comment: comment)

    if let localizedResourceName = GiniConfiguration.shared.localizedStringsTableName {
        clientString = NSLocalizedString(key,
                                         tableName: localizedResourceName,
                                         bundle: bundle,
                                         comment: comment)
        fallbackClientString = NSLocalizedString(fallbackKey,
                                                 tableName: localizedResourceName,
                                                 bundle: bundle,
                                                 comment: comment)
    }

    guard clientString.lowercased() != key.lowercased()
            || fallbackClientString.lowercased() != fallbackKey.lowercased() else {
        return nil
    }

    return clientString
}

struct AnimationDuration {
    static var slow = 1.0
    static var medium = 0.6
    static var fast = 0.3
}

public class Constraints {
    enum Position {
        case top, bottom, right, left
    }

    @discardableResult
    public class func active(item view1: Any!,
                             attr attr1: NSLayoutConstraint.Attribute,
                             relatedBy relation: NSLayoutConstraint.Relation,
                             to view2: Any?,
                             attr attr2: NSLayoutConstraint.Attribute,
                             multiplier: CGFloat = 1.0,
                             constant: CGFloat = 0,
                             priority: Float = 1000,
                             identifier: String? = nil) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view1!,
                                            attribute: attr1,
                                            relatedBy: relation,
                                            toItem: view2, attribute: attr2,
                                            multiplier: multiplier,
                                            constant: constant)
        active(constraint: constraint, priority: priority, identifier: identifier)
        return constraint
    }

    class func active(constraint: NSLayoutConstraint,
                      priority: Float = 1000,
                      identifier: String? = nil) {
        constraint.priority = UILayoutPriority(priority)
        constraint.identifier = identifier
        constraint.isActive = true
    }

    class func pin(view: UIView,
                   toSuperView superview: UIView,
                   positions: [Position] = [.top, .bottom, .left, .right]) {

        if positions.contains(.top) {
            Constraints.active(item: view, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        }

        if positions.contains(.bottom) {
            Constraints.active(item: view, attr: .bottom, relatedBy: .equal, to: superview, attr: .bottom)
        }

        if positions.contains(.left) {
            Constraints.active(item: view, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        }

        if positions.contains(.right) {
            Constraints.active(item: view, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        }
    }

    class func center(view: UIView, with otherView: UIView) {
        Constraints.active(item: view, attr: .centerX, relatedBy: .equal, to: otherView, attr: .centerX)
        Constraints.active(item: view, attr: .centerY, relatedBy: .equal, to: otherView, attr: .centerY)
    }
}

/**
 Measure the time spent executing a block
 */

func measure(block: () -> Void) {
    let start = Date()
    block()
    let elaspsedTime = Date().timeIntervalSince(start)
    GiniCaptureSDK.Log(message: "Elapsed time: \(elaspsedTime) seconds", event: "⏲️")
}
private class CaptureSDKBundleFinder {}

extension Foundation.Bundle {
    /**
     The resource bundle associated with the current module.
     - important: When `GiniCaptureSDK` is distributed via Swift Package Manager, it will be synthesized automatically in the name of `Bundle.module`.
     */
    static var resource: Bundle = {
        let moduleName = "GiniCaptureSDK"
        let bundleName = "\(moduleName)_\(moduleName)"
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: CaptureSDKBundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle(for: GiniCapture.self)
    }()
}

public struct RoundedCorners {
    static let cornerRadius: CGFloat = 8
}
