//
//  ToolTipView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/21/17.
//

import Foundation
import UIKit

final class ToolTipView: UIView {

    enum ToolTipPosition {
        case above
        case below
        case left
        case right
    }

    fileprivate var arrowWidth: CGFloat = 30
    fileprivate var arrowHeight: CGFloat = 20
    fileprivate var closeButtonWidth: CGFloat = 20
    fileprivate var closeButtonHeight: CGFloat = 20
    fileprivate var itemSeparation: CGFloat = 16
    fileprivate var minimunDistanceToRefView: UIEdgeInsets
    fileprivate var margin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    fileprivate var maxWidth: CGFloat = 414
    // swiftlint:disable:large_tuple
    fileprivate var padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    fileprivate var textWidth: CGFloat {
        guard let superview = superview else { return 0 }
        let width: CGFloat
        if superview.frame.width > maxWidth && superview.frame.height > maxWidth {
            width = maxWidth
        } else {
            width = min(superview.frame.width, superview.frame.height)
        }
        return width - padding.left - padding.right - margin.left - margin.right - closeButtonWidth - itemSeparation
    }

    fileprivate var text: String
    fileprivate var toolTipPosition: ToolTipPosition
    fileprivate var textSize: CGSize = .zero

    fileprivate var arrowView: UIView
    fileprivate var closeButton: UIButton
    fileprivate let referenceView: UIView
    fileprivate var textLabel: UILabel
    fileprivate var tipContainer: UIView

    var willDismiss: (() -> Void)?
    var willDismissOnCloseButtonTap: (() -> Void)?

    init(text: String,
         giniConfiguration: GiniConfiguration,
         referenceView: UIView,
         superView: UIView,
         position: ToolTipPosition,
         distanceToRefView: UIEdgeInsets = .zero) {

        self.text = text
        self.referenceView = referenceView
        self.toolTipPosition = position
        self.textLabel = UILabel()
        self.closeButton = UIButton()
        self.tipContainer = UIView()
        self.minimunDistanceToRefView = distanceToRefView
        self.arrowView = ToolTipView.arrow(withHeight: arrowHeight,
                                           width: arrowWidth,
                                           color: .white,
                                           position: position)

        super.init(frame: .zero)
        superView.addSubview(self)
        alpha = 0

        let font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        self.textSize = size(forText: text, withFont: font)
        self.addTipContainer(backgroundColor: giniConfiguration.fileImportToolTipBackgroundColor)
        self.addTextLabel(withText: text, textColor: giniConfiguration.fileImportToolTipTextColor, font: font)
        self.addCloseButton(withColor: giniConfiguration.fileImportToolTipCloseButtonColor)
        self.addArrow()
        self.addShadow()

        self.arrangeFrame(withSuperView: superView)
        self.arrangeArrow(withSuperView: superView)
        self.setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.arrangeArrow(withSuperView: superview)
    }

    func arrangeViews() {
        self.arrangeFrame(withSuperView: superview)
        self.arrangeArrow(withSuperView: superview)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported. Use init(text) instead!")
    }

    // MARK: Add views
    fileprivate func addTipContainer(backgroundColor color: UIColor) {
        self.addSubview(tipContainer)
        self.tipContainer.backgroundColor = color
        self.tipContainer.layer.cornerRadius = 2.0
    }

    fileprivate func addTextLabel(withText text: String, textColor: UIColor, font: UIFont) {
        textLabel.text = text
        textLabel.textColor = textColor
        textLabel.font = font
        textLabel.numberOfLines = 0
        tipContainer.addSubview(textLabel)
    }

    fileprivate func addArrow() {
        arrowView.frame.origin = CGPoint(x: 0, y: self.frame.height)
        self.addSubview(arrowView)
    }

    fileprivate func addCloseButton(withColor color: UIColor) {
        let image = UIImageNamedPreferred(named: "toolTipCloseButton")
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = color
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        tipContainer.addSubview(closeButton)
    }

    fileprivate func addShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 0.8
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }

    // MARK: Actions
    @objc fileprivate func closeAction() {
        self.dismissOnCloseButtonTap(withCompletion: nil)
    }

    // MARK: Frame and size calculations
    fileprivate func size(forText text: String, withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]

        var textSize = text.boundingRect(with: CGSize(width: textWidth,
                                                      height: CGFloat.greatestFiniteMagnitude),
                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                         attributes: attributes, context: nil).size

        textSize.width = textWidth
        textSize.height = ceil(textSize.height)

        return textSize
    }

    fileprivate func absoluteFrame(for view: UIView, inside superView: UIView?) -> CGRect? {
        guard let superView = superView, let referenceViewParent = referenceView.superview else { return nil }

        return referenceViewParent.convert(referenceView.frame, to: superView)
    }

    // MARK: Constraints
    fileprivate func setupConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        tipContainer.translatesAutoresizingMaskIntoConstraints = false

        // tipContainer
        Constraints.active(item: self, attr: .top, relatedBy: .equal, to: tipContainer, attr: .top,
                          constant: -margin.top)
        Constraints.active(item: self, attr: .bottom, relatedBy: .equal, to: tipContainer, attr: .bottom,
                          constant: margin.bottom)
        Constraints.active(item: self, attr: .leading, relatedBy: .equal, to: tipContainer, attr: .leading,
                          constant: -margin.left)
        Constraints.active(item: self, attr: .trailing, relatedBy: .equal, to: tipContainer, attr: .trailing,
                          constant: margin.right)

        // textLabel
        Constraints.active(item: tipContainer, attr: .top, relatedBy: .equal, to: textLabel, attr: .top,
                          constant: -padding.top)
        Constraints.active(item: tipContainer, attr: .bottom, relatedBy: .equal, to: textLabel, attr: .bottom,
                          constant: padding.bottom)
        Constraints.active(item: tipContainer, attr: .leading, relatedBy: .equal, to: textLabel, attr: .leading,
                          constant: -padding.left)

        // closeButton
        Constraints.active(item: closeButton, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: closeButtonWidth)
        Constraints.active(item: closeButton, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: closeButtonHeight)
        Constraints.active(item: closeButton, attr: .centerY, relatedBy: .equal, to: tipContainer, attr: .centerY)
        Constraints.active(item: closeButton, attr: .leading, relatedBy: .equal, to: textLabel, attr: .trailing,
                          constant: itemSeparation)
        Constraints.active(item: tipContainer, attr: .trailing, relatedBy: .equal, to: closeButton, attr: .trailing,
                          constant: padding.right)

        self.setNeedsLayout()
    }

    // MARK: Draw arrow
    class fileprivate func arrow(withHeight height: CGFloat,
                                 width: CGFloat,
                                 color: UIColor,
                                 position: ToolTipPosition) -> UIView {
        let bezierPath = UIBezierPath()
        let arrowView: UIView
        switch position {
        case .above:
            arrowView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: width, y: 0))
            bezierPath.addLine(to: CGPoint(x: width / 2, y: height))
            bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        case .below:
            arrowView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            bezierPath.move(to: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width / 2, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: height))
        case .left:
            arrowView = UIView(frame: CGRect(x: 0, y: 0, width: height, height: width))
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: height, y: width / 2))
            bezierPath.addLine(to: CGPoint(x: 0, y: width))
            bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        case .right:
            arrowView = UIView(frame: CGRect(x: 0, y: 0, width: height, height: width))
            bezierPath.move(to: CGPoint(x: height, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: width / 2))
            bezierPath.addLine(to: CGPoint(x: height, y: width))
            bezierPath.addLine(to: CGPoint(x: height, y: 0))
        }
        bezierPath.close()
        arrowView.backgroundColor = color

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        arrowView.layer.mask = shapeLayer
        return arrowView
    }
}

// MARK: - Arrange views

extension ToolTipView {

    fileprivate func arrangeFrame(withSuperView superView: UIView?) {
        guard let superview = superView,
            let referenceViewAbsoluteFrame = absoluteFrame(for: referenceView, inside: superView) else { return }
        let frameHeight = max(textSize.height, closeButtonHeight) +
            padding.top +
            padding.bottom +
            margin.top +
            margin.bottom
        let frameWidth = textSize.width +
            closeButtonWidth +
            padding.left +
            padding.right +
            itemSeparation +
            margin.left +
            margin.right

        let size = CGSize(width: frameWidth, height: frameHeight)
        let origin: CGPoint
        if referenceViewAbsoluteFrame == .zero {
            origin = .zero
        } else {
            origin = frameOrigin(forRefViewAbsFrame: referenceViewAbsoluteFrame,
                                 withSize: size,
                                 onSuperview: superview)
        }

        self.frame = CGRect(origin: origin, size: size)
    }

    fileprivate func frameOrigin(forRefViewAbsFrame referenceViewAbsoluteFrame: CGRect,
                                 withSize size: CGSize,
                                 onSuperview superview: UIView) -> CGPoint {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var refViewAbsFrame = referenceViewAbsoluteFrame

        switch toolTipPosition {
        case .above:
            x = refViewAbsFrame.midX - (size.width / 2)

            refViewAbsFrame.origin.y -= minimunDistanceToRefView.top
            if refViewAbsFrame.origin.y - size.height < 0 {
                y = refViewAbsFrame.origin.y + refViewAbsFrame.height - size.height
            } else {
                y = refViewAbsFrame.origin.y - size.height
            }
        case .below:
            x = refViewAbsFrame.midX - (size.width / 2)

            refViewAbsFrame.origin.y += minimunDistanceToRefView.bottom
            if refViewAbsFrame.origin.y + referenceView.frame.height + size.height > superview.frame.height {
                y = refViewAbsFrame.origin.y + refViewAbsFrame.height - size.height
            } else {
                y = refViewAbsFrame.origin.y + referenceView.frame.height
            }
        case .left:
            y = refViewAbsFrame.midY - size.height / 2

            refViewAbsFrame.origin.x -= minimunDistanceToRefView.left

            if refViewAbsFrame.origin.x - size.width < 0 {
                x = superview.frame.width - size.width
            } else {
                x = refViewAbsFrame.origin.x - size.width
            }
        case .right:
            y = refViewAbsFrame.origin.y - margin.top

            refViewAbsFrame.origin.x += minimunDistanceToRefView.right

            if refViewAbsFrame.origin.x + referenceView.frame.width + size.width > superview.frame.width {
                x = superview.frame.width - size.width
            } else {
                x = refViewAbsFrame.origin.x  - size.width
            }
        }

        if x < 0 || superview.frame.width - x < size.width {
            x = superview.frame.width - size.width
        }

        if superview.frame.height - y < size.height {
            y = refViewAbsFrame.origin.y + refViewAbsFrame.height - size.height
        }

        return CGPoint(x: x, y: y)
    }

    fileprivate func arrangeArrow(withSuperView superView: UIView?) {
        guard let referenceViewAbsoluteFrame = absoluteFrame(for: referenceView, inside: superView) else { return }

        let x: CGFloat
        let y: CGFloat
        switch toolTipPosition {
        case .above:
            x = referenceViewAbsoluteFrame.origin.x +
                referenceView.frame.width / 2 -
                self.frame.origin.x -
                arrowView.frame.width / 2
            y = tipContainer.frame.height + tipContainer.frame.origin.y
        case .below:
            x = referenceViewAbsoluteFrame.origin.x +
                referenceView.frame.width / 2 -
                self.frame.origin.x -
                arrowView.frame.width / 2
            y = 0
        case .left:
            x = tipContainer.frame.width + tipContainer.frame.origin.x
            y = referenceViewAbsoluteFrame.origin.y +
                referenceView.frame.height / 2 -
                self.frame.origin.y -
                arrowView.frame.height / 2
        case .right:
            x = 0
            y = referenceViewAbsoluteFrame.origin.y +
                referenceView.frame.height / 2 -
                self.frame.origin.y -
                arrowView.frame.height / 2
        }
        arrowView.frame.origin = CGPoint(x: x, y: y)
    }
}

// MARK: - Show and hide tip methods

extension ToolTipView {

    func show(alongsideAnimations:(() -> Void)? = nil) {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
            alongsideAnimations?()
        }
    }

    func dismiss(withCompletion completion: (() -> Void)? = nil) {
        willDismiss?()
        self.removeFromSuperview()
        completion?()
    }

    func dismissOnCloseButtonTap(withCompletion completion: (() -> Void)? = nil) {
        willDismissOnCloseButtonTap?()
        self.removeFromSuperview()
        completion?()
    }
}

// MARK: - UserDefaults flags

extension ToolTipView {
    private static let shouldShowFileImportToolTipKey = "ginicapture.defaults.shouldShowFileImportToolTip"
    private static let shouldShowQRCodeToolTipKey = "ginicapture.defaults.shouldShowQRCodeToolTip"

    static var shouldShowFileImportToolTip: Bool {
        get {
            let defaultsValue = UserDefaults
                .standard
                .object(forKey: ToolTipView.shouldShowFileImportToolTipKey) as? Bool
            return defaultsValue ?? true
        }

        set {
            UserDefaults.standard.set(newValue, forKey: ToolTipView.shouldShowFileImportToolTipKey)
        }
    }

    private static let shouldShowReorderPagesButtonToolTipKey =
    "ginicapture.defaults.shouldShowReorderPagesButtonToolTip"
    static var shouldShowReorderPagesButtonToolTip: Bool {
        get {
            let defaultsValue = UserDefaults
                .standard
                .object(forKey: ToolTipView.shouldShowReorderPagesButtonToolTipKey) as? Bool
            return defaultsValue ?? true
        }

        set {
            UserDefaults.standard.set(newValue, forKey: ToolTipView.shouldShowReorderPagesButtonToolTipKey)
        }
    }

    static var shouldShowQRCodeToolTip: Bool {
        get {
            let defaultsValue = UserDefaults
                .standard
                .object(forKey: ToolTipView.shouldShowQRCodeToolTipKey) as? Bool
            return defaultsValue ?? true
        }

        set {
            UserDefaults.standard.set(newValue, forKey: ToolTipView.shouldShowQRCodeToolTipKey)
        }
    }
}
