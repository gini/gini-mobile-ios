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
    private let configuration = GiniConfiguration.shared
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()

    // MARK: - Public methods

    /**
     Adds a tap gesture recognizer to the stack view with the specified target and action.

     Use the `addAction(_ target: Any?, _ action: Selector)` function to call the specified action. When the tap gesture is recognized, the action method specified by the `action` parameter will be called on the `target` object.

     - Parameters:
        - target: The object that will handle the action message. If this parameter is `nil`, the action message will be sent to the first responder.
        - action: The action method to call on the target object when the tap gesture is recognized.
     */
    public func addAction(_ target: Any?, _ action: Selector) {
        let tapRecognizer = UITapGestureRecognizer(target: target, action: action)
        stackView.addGestureRecognizer(tapRecognizer)
        stackView.isExclusiveTouch = true
    }

    /**
     A computed property that returns a `UIBarButtonItem` with the `stackView` as its custom view.

     Use the `barButton` property to create a `UIBarButtonItem` with the `stackView` as its custom view. This allows you to customize the appearance and behavior of the button by adding and configuring subviews within the stack view.

     - Returns: A `UIBarButtonItem` object with the `stackView` as its custom view.
     */
    public var barButton: UIBarButtonItem {
        return UIBarButtonItem(customView: stackView)
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
        titleLabel.accessibilityTraits = .button
        titleLabel.isAccessibilityElement = true
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
        let (buttonTitle, icon) = titleAndIcon(for: type)

        // Ensure there’s at least a title or icon to avoid a crash
        guard buttonTitle != nil || icon != nil else {
            assertionFailure("""
    You need to provide at least a valid string or an icon \
    for the navigation bar button of type: \(type)
    """)
            return
        }

        imageView.image = icon?.tintedImageWithColor(.GiniCapture.accent1)

        // Set up title if available and accessibility value for the stackview
        if let buttonTitle = buttonTitle {
            titleLabel.attributedText = NSAttributedString(string: buttonTitle, attributes: textAttributes())

            // Add accessibility value with backString only for the back button when title is not equal to backString
            if case .back = type {
                let backString = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.accessibility.back",
                                                                  comment: "Back")
                stackView.accessibilityValue = (buttonTitle == backString) ? buttonTitle :
                "\(buttonTitle) \(backString)"
            } else {
                stackView.accessibilityValue = buttonTitle
            }
        }
    }

    private func titleAndIcon(for type: BarButtonType) -> (String?, UIImage?) {
        switch type {
        case .cancel:
            return (NSLocalizedStringPreferredFormat("ginicapture.navigationbar.analysis.back",
                                                    comment: "Cancel"),
                    UIImageNamedPreferred(named: "barButton_cancel"))
        case .help:
            return (NSLocalizedStringPreferredFormat("ginicapture.navigationbar.camera.help",
                                                    comment: "Help"),
                    UIImageNamedPreferred(named: "barButton_help"))
        case .back(let title):
            return (title, UIImageNamedPreferred(named: "barButton_back"))
        case .done:
            return (NSLocalizedStringPreferredFormat("ginicapture.imagepicker.openbutton",
                                                    comment: "Done"),
                    UIImageNamedPreferred(named: "barButton_done"))
        case .skip:
            return (NSLocalizedStringPreferredFormat("ginicapture.onboarding.skip",
                                                    comment: "Skip button"),
                    nil)
        }
    }

    private func textAttributes() -> [NSAttributedString.Key: Any] {
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
