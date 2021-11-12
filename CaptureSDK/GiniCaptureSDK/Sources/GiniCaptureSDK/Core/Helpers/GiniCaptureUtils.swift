//
//  GiniCaptureUtils.swift
//  GiniCapture
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

public func giniCaptureBundle() -> Bundle {
    Bundle.module
}

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the image file without file extension.
 
 - returns: Image if found with name.
 */
public func UIImageNamedPreferred(named name: String) -> UIImage? {
    if let clientImage = UIImage(named: name) {
        return clientImage
    }
    return UIImage(named: name, in: giniCaptureBundle(), compatibleWith: nil)
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
    let clientString = NSLocalizedString(key, comment: comment)
    let fallbackClientString = NSLocalizedString(fallbackKey, comment: comment)
    let format: String
    if (clientString.lowercased() != key.lowercased() || fallbackClientString.lowercased() != fallbackKey.lowercased())
        && isCustomizable {
        format = clientString
    } else {
        let bundle = giniCaptureBundle()

        var defaultFormat = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        if defaultFormat.lowercased() == key.lowercased() {
            defaultFormat = NSLocalizedString(fallbackKey, bundle: bundle, comment: comment)
        }
        
        format = defaultFormat
    }
    
    return format
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
    
    public class func active(item view1: Any!,
                      attr attr1: NSLayoutConstraint.Attribute,
                      relatedBy relation: NSLayoutConstraint.Relation,
                      to view2: Any?,
                      attr attr2: NSLayoutConstraint.Attribute,
                      multiplier: CGFloat = 1.0,
                      constant: CGFloat = 0,
                      priority: Float = 1000,
                      identifier: String? = nil) {
        
        let constraint = NSLayoutConstraint(item: view1!,
                                            attribute: attr1,
                                            relatedBy: relation,
                                            toItem: view2, attribute: attr2,
                                            multiplier: multiplier,
                                            constant: constant)
        active(constraint: constraint, priority: priority, identifier: identifier)
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

public struct Colors {
    
    public struct Gini {
        
        public static var blue = UIColor.from(hex: 0x009edc)
        public static var bluishGreen = UIColor.from(hex: 0x007c99)
        public static var crimson = UIColor.from(hex: 0xFF4F65)
        public static var lightBlue = UIColor.from(hex: 0x74d1f5)
        public static var grey = UIColor.from(hex: 0xAFB2B3)
        public static var raspberry = UIColor.from(hex: 0xe30b5d)
        public static var rose = UIColor.from(hex: 0xFC6B7E)
        public static var pearl = UIColor.from(hex: 0xF2F2F2)
        
        @available(iOS 13.0, *)
        public static var dynamicPearl = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.from(hex: 0x1C1C1C)
            } else {
                return pearl
            }
        }
        
        public static var paleGreen = UIColor.from(hex: 0xB8E986)
        public static var springGreen = UIColor.from(hex: 0x00FA9A)
        public static var veryLightGray = UIColor.from(hex: 0xD8D8D8)
        
        @available(iOS 13.0, *)
        public static var dynamicVeryLightGray = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.from(hex: 0x3A3A3A)
            } else {
                return UIColor.from(hex: 0xD8D8D8)
            }
        }
        
        @available(iOS 13.0, *)
        public static var shadowColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .black
            }
        }
    }
    
}

/**
    Set the status bar style when ViewControllerBasedStatusBarAppearance is disabled.
    If it is enabled it will not have effect.
 */

func setStatusBarStyle(to statusBarStyle: UIStatusBarStyle,
                       application: UIApplication = UIApplication.shared) {
    application.setStatusBarStyle(statusBarStyle, animated: true)
}

/**
    Measure the time spent executing a block
 */

func measure(block: () -> Void) {
    let start = Date()
    block()
    let elaspsedTime = Date().timeIntervalSince(start)
    Log(message: "Elapsed time: \(elaspsedTime) seconds", event: "⏲️")
}
