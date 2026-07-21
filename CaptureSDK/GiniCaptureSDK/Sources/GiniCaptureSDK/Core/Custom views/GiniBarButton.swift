//
// GiniBarButton.swift
//  
//
//  Created by David Vizaknai on 15.03.2023.
//

import UIKit

/// - Note: internal only

/**
 An enum representing the types of buttons that can appear in a navigation bar.

 Use the `BarButtonType` enum to specify the type of button to display in a navigation bar.

 - cancel: A cancel button. Used to cancel or dismiss the current view controller.

 - help: A help button. Used to open the help screen.

 - back(title: String): A back button. Used to navigate back to the previous view controller.
    The `title` parameter is a string that specifies the title to display on the button.

 - done: A done button. Used to open the selected images from the gallery picker.
 */
public enum BarButtonType {
    case cancel
    case help
    case back(title: String)
    case done
    case skip
}

/**
 A custom navigation bar button that displays a stack of subviews.

 Use the `GiniBarButton` class to create a custom toolbar button with a stack of subviews. This allows you to customize the appearance and behavior of the button by adding and configuring subviews within the stack view. The `GiniBarButton` class provides a convenient interface for creating a `UIBarButtonItem` with a custom view, and includes several helper methods for managing the subviews of the stack view.
 */

public final class GiniBarButton {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    // Native item so the system auto-styles the button (Liquid Glass on iOS 26+).
    // Icon-preferred when both are available; title survives on `accessibilityLabel`.
    private let nativeItem: UIBarButtonItem

    // MARK: - Public methods

    /**
     Wires the specified target/action to the button so it fires whether the caller
     uses `.barButton` (top nav) or `.buttonView` (embedded in a custom container).

     - Parameters:
        - target: The object that will handle the action message. If `nil`, the
          message is sent to the first responder.
        - action: The action method to invoke on the target.
     */
    public func addAction(_ target: Any?,
                          _ action: Selector) {
        nativeItem.target = target as? AnyObject
        nativeItem.action = action
        // stackView recognizer serves `.buttonView` callers; nativeItem handles `.barButton`.
        let tapRecognizer = UITapGestureRecognizer(target: target, action: action)
        stackView.addGestureRecognizer(tapRecognizer)
        stackView.isExclusiveTouch = true
    }

    /**
     Returns the button as a `UIBarButtonItem`, suitable for assignment to
     `navigationItem.leftBarButtonItem` / `rightBarButtonItem`.

     Uses a native `UIBarButtonItem(image:...)` when an icon is available (title
     customization survives via `accessibilityLabel`), otherwise `UIBarButtonItem(title:...)`.

     - Returns: A `UIBarButtonItem` ready to assign to a navigation item.
     */
    public var barButton: UIBarButtonItem {
        nativeItem
    }

    /**
     A computed property that returns a `UIView` with the `stackView` as its content.

     Use the `buttonView` property to create a `UIView` with the `stackView` as its content. This allows you to customize the appearance and behavior of the button by adding and configuring subviews within the stack view.

     - Returns: A `UIView` object with the `stackView` as its content.
     */
    public var buttonView: UIView {
        return stackView
    }

    /**
     A property that gets or sets the text alignment of the button's title label.

     Use `titleTextAlignment` to configure how the text inside the `titleLabel` is aligned horizontally.

     - Returns: The current `NSTextAlignment` of the `titleLabel`.
     */
    public var titleTextAlignment: NSTextAlignment {
        get {
            return titleLabel.textAlignment
        }
        set {
            titleLabel.textAlignment = newValue
        }
    }

    /**
     Initializes a new `GiniBarButton` object with the specified button type.

     Use the `init(ofType:)` initializer to create a new `GiniBarButton` object with the specified `BarButtonType`. The `BarButtonType` parameter determines the appearance and behavior of the button.

     - Parameter type: The `BarButtonType` that determines the appearance and behavior of the button.
     */
    public init(ofType type: BarButtonType) {
        let (label, icon) = Self.titleAndIcon(for: type)
        if #available(iOS 26.0, *), case .done = type {
            // iOS 26+ renders the Liquid Glass checkmark; earlier versions
            // fall through to the localized "Done" title below.
            nativeItem = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: nil,
                                         action: nil)
        } else if let icon = icon {
            nativeItem = UIBarButtonItem(image: icon,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        } else {
            nativeItem = UIBarButtonItem(title: label,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        }
        nativeItem.accessibilityLabel = Self.accessibilityValue(for: type,
                                                                title: label)
        nativeItem.tintColor = .GiniCapture.accent1
        let attrs = Self.textAttributes()
        nativeItem.setTitleTextAttributes(attrs, for: .normal)
        nativeItem.setTitleTextAttributes(attrs, for: .highlighted)
        setupContent(basedOnType: type)
        setupViews()
    }

    // MARK: - Private methods
    private func setupViews() {
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = Constants.spacing
        stackView.backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        titleLabel.textColor = .GiniCapture.accent1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = titleTextAlignment

        imageView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = false
        stackView.isAccessibilityElement = true
        stackView.accessibilityTraits = .button

        if imageView.image != nil {
            stackView.addArrangedSubview(imageView)
        }

        if titleLabel.text != nil {
            stackView.addArrangedSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
            ])
        }
    }

    private func setupContent(basedOnType type: BarButtonType) {
        let (buttonTitle, icon) = Self.titleAndIcon(for: type)
        imageView.image = icon?.tintedImageWithColor(.GiniCapture.accent1)
        titleLabel.attributedText = NSAttributedString(string: buttonTitle,
                                                       attributes: Self.textAttributes())
        stackView.accessibilityLabel = Self.accessibilityValue(for: type,
                                                               title: buttonTitle)
    }

    private static func titleAndIcon(for type: BarButtonType) -> (String, UIImage?) {
        switch type {
        case .cancel:
            return (NSLocalizedStringPreferredFormat("ginicapture.navigationbar.analysis.back",
                                                    comment: "Cancel"),
                    UIImageNamedPreferred(named: "barButton_cancel"))
        case .help:
            return (NSLocalizedStringPreferredFormat("ginicapture.navigationbar.camera.help",
                                                    comment: "Help"),
                    nil)
        case .back(let title):
            return (title, UIImageNamedPreferred(named: "barButton_back"))
        case .done:
            // Icon dropped from the SDK contract: iOS 26+ uses the system
            // Liquid Glass checkmark, earlier versions show localized text.
            return (NSLocalizedStringPreferredFormat("ginicapture.imagepicker.openbutton",
                                                    comment: "Done"),
                    nil)
        case .skip:
            return (NSLocalizedStringPreferredFormat("ginicapture.onboarding.skip",
                                                    comment: "Skip button"),
                    nil)
        }
    }

    private static func accessibilityValue(for type: BarButtonType, title: String) -> String {
        if case .back = type {
            let backString = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.accessibility.back",
                                                              comment: "Back")
            return (title == backString) ? title : "\(title) \(backString)"
        }
        return title
    }

    private static func textAttributes() -> [NSAttributedString.Key: Any] {
        let configuration = GiniConfiguration.shared
        var attributes: [NSAttributedString.Key: Any]
        let buttonFont = configuration.textStyleFonts[.body]
        if let font = buttonFont {
            if font.pointSize > Constants.maximumFontSize {
                attributes = [NSAttributedString.Key.font: font.withSize(Constants.maximumFontSize)]
            } else {
                attributes = [NSAttributedString.Key.font: font]
            }
        } else {
            let font = configuration.textStyleFonts[.bodyBold] as Any
            attributes = [NSAttributedString.Key.font: font]
        }

        return attributes
    }

    public func setContentHuggingPriority(_ priority: UILayoutPriority,
                                          for axis: NSLayoutConstraint.Axis) {
        stackView.setContentHuggingPriority(priority, for: axis)
        titleLabel.setContentHuggingPriority(priority, for: axis)
        imageView.setContentHuggingPriority(priority, for: axis)
    }

    public func setContentCompressionResistancePriority(_ priority: UILayoutPriority,
                                                        for axis: NSLayoutConstraint.Axis) {
        stackView.setContentCompressionResistancePriority(priority, for: axis)
        titleLabel.setContentCompressionResistancePriority(priority, for: axis)
        imageView.setContentCompressionResistancePriority(priority, for: axis)
    }
}

private extension GiniBarButton {
    enum Constants {
        static let maximumFontSize: CGFloat = 24
        static let spacing: CGFloat = 4
    }
}
