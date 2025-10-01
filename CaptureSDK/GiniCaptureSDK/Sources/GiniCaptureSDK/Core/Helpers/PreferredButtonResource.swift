//
//  PreferredButtonResource.swift
//  Pods
//
//  Created by Nikola Sobadjiev on 16/03/2017.
//
//

import UIKit

@objc
public protocol PreferredButtonResource {

    var preferredImage: UIImage? { get }
    var preferredText: String? { get }
}

enum ResourceOrigin {
    case unknown
    case library
    case custom
}

/*
 * PreferredButtonResource typically controls what artwork (image and text) would be used in a UI element
 * such as a button or a bar button item. Resources in the Gini Capture SDK are usually brandable
 * via UIAppearance, Asset catalogs and localizable strings. For instance, many buttons have a default
 * image in the library's Asset catalog, but clients are free to add an image with the same image in
 * their catalog. In this case, the customized image will be used.
 */

class GiniPreferredButtonResource: PreferredButtonResource {

    private let imageName: String?
    private let localizedTextKey: String?
    private let localizedTextComment: String?
    private let localizedConfigEntry: String?
    private let appBundle = Bundle.main
    private let libBundle = giniCaptureBundle()
    private var customBundle: Bundle {
         guard let customBundle = GiniConfiguration.shared.customResourceBundle else {
             return Bundle.main
         }
         return customBundle
    }
    private var imageSource: ResourceOrigin {
        if let name = imageName {
            if UIImage(named: name, in: customBundle, compatibleWith: nil) != nil {
                return .custom
            } else if UIImage(named: name, in: libBundle, compatibleWith: nil) != nil {
                return .library
            }
        }
        return.unknown
    }

    private var textSource: ResourceOrigin {
        if let entry = localizedConfigEntry, !entry.isEmpty {
            return .custom
        }
        if let text = localizedTextKey,
            let comment = localizedTextComment {
            let textFromLibBundle = NSLocalizedString(text, bundle: libBundle, comment: comment)
            if textFromLibBundle != text {
                return .library
            }
        }
        return .unknown
    }

    init(image: String?, title: String?, comment: String?, configEntry: String? = nil) {
        imageName = image
        localizedTextKey = title
        localizedTextComment = comment
        localizedConfigEntry = configEntry
    }

    var preferredImage: UIImage? {
        if !shouldIgnoreImage && imageName != nil {
            return UIImageNamedPreferred(named: imageName!)
        }
        return nil
    }

    var preferredText: String? {
        guard localizedConfigEntry == nil || localizedConfigEntry?.isEmpty == true else {
            return localizedConfigEntry
        }
        if let text = localizedTextKey,
            let comment = localizedTextComment {
            return NSLocalizedStringPreferredFormat(text, comment: comment)
        }
        return ""
    }

    // if a custom text is supplied to the control, but the image is left to the default one
    // (or not set at all), the image property needs to be ignored so that the text is shown instead
    private var shouldIgnoreImage: Bool {
        return (textSource == .custom && imageSource != .custom)
    }
}
