//
//  QRCodeDetectedPopupView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/6/17.
//

import UIKit

final class QRCodeDetectedPopupView: UIView {
    
    let maxWidth: CGFloat = 375.0
    let margin: (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) = (10, 10, 10, 10)
    let padding: (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) = (20, 20, 10, 10)
    let imageSize: CGSize = CGSize(width: 35, height: 35)
    let hiddingDelay: TimeInterval = 10.0
    var bottomConstraint: NSLayoutConstraint?
    var didTapDone: (() -> Void) = {}

    lazy var qrImage: UIImageView = {
        let imageView = UIImageView(image: UIImageNamedPreferred(named: "toolTipCloseButton"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var qrText: UILabel = {
        let message: String = .localized(resource: CameraStrings.qrCodeDetectedPopupMessage)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.numberOfLines = 2
        label.minimumScaleFactor = 10/14
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var proceedButton: UIButton = {
        let title: String = .localized(resource: CameraStrings.qrCodeDetectedPopupButton)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(self.didTapDoneAction), for: .touchUpInside)
        return button
    }()
    
    init(parent: UIView, refView: UIView, document: GiniQRCodeDocument, giniConfiguration: GiniConfiguration) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addShadow()
        
        qrImage.image = document.previewImage
        setupViews(with: giniConfiguration)
        
        parent.insertSubview(self, aboveSubview: refView)
        addSubview(qrImage)
        addSubview(qrText)
        addSubview(proceedButton)
        addConstraints(onSuperView: parent, refView: refView)
        
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupViews(with giniConfiguration: GiniConfiguration) {
        backgroundColor = UIColor.from(giniColor: giniConfiguration.qrCodePopupBackgroundColor)
        qrText.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        qrText.textColor = UIColor.from(giniColor: giniConfiguration.qrCodePopupTextColor)
        proceedButton.titleLabel?.font = giniConfiguration.customFont.with(weight: .bold, size: 14, style: .caption1)
        proceedButton.setTitleColor(giniConfiguration.qrCodePopupButtonColor, for: .normal)
        proceedButton.setTitleColor(giniConfiguration.qrCodePopupButtonColor.withAlphaComponent(0.5),
                                    for: .highlighted)
    }
    
    fileprivate func addConstraints(onSuperView superView: UIView, refView: UIView) {
        Constraints.active(item: self, attr: .width, relatedBy: .lessThanOrEqual, to: nil, attr: .notAnAttribute,
                          constant: maxWidth)
        Constraints.active(item: self, attr: .leading, relatedBy: .greaterThanOrEqual, to: superView, attr: .leading,
                          constant: margin.left)
        Constraints.active(item: self, attr: .trailing, relatedBy: .lessThanOrEqual, to: superView, attr: .trailing,
                          constant: -margin.right)
        Constraints.active(item: self, attr: .centerX, relatedBy: .equal, to: refView, attr: .centerX)
        bottomConstraint = NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: refView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: imageSize.height +
                                                padding.top +
                                                padding.bottom +
                                                margin.bottom)
        Constraints.active(constraint: bottomConstraint!)
        
        Constraints.active(item: qrImage, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: imageSize.width)
        Constraints.active(item: qrImage, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: imageSize.height)
        Constraints.active(item: qrImage, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: padding.left)
        Constraints.active(item: qrImage, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: padding.top)
        Constraints.active(item: qrImage, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -padding.bottom)
        Constraints.active(item: qrImage, attr: .trailing, relatedBy: .equal, to: qrText, attr: .leading,
                          constant: -padding.right / 2, priority: 999)
        
        Constraints.active(item: qrText, attr: .centerY, relatedBy: .equal, to: qrImage, attr: .centerY)
        Constraints.active(item: qrText, attr: .trailing, relatedBy: .lessThanOrEqual, to: proceedButton,
                           attr: .leading, constant: -padding.right)
        Constraints.active(item: proceedButton, attr: .centerY, relatedBy: .equal, to: qrImage, attr: .centerY)
        Constraints.active(item: proceedButton, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -padding.right)
        if let minButtonWidth = proceedButton.titleLabel?.intrinsicContentSize.width {
            Constraints.active(item: proceedButton, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                              constant: minButtonWidth)
        }

    }
    
    fileprivate func addShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 0.8
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    @objc fileprivate func didTapDoneAction() {
        didTapDone()
    }
}

// MARK: - Animations

extension QRCodeDetectedPopupView {
    func show(after seconds: TimeInterval = 0, didDismiss: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let self = self, let superview = self.superview else { return }
            self.bottomConstraint?.constant = -self.margin.bottom
            UIView.animate(withDuration: AnimationDuration.medium,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            superview.layoutIfNeeded()
            }, completion: { [weak self] _ in
                guard let self = self else { return }
                self.hide(after: self.hiddingDelay, completion: didDismiss)
            })
        })
    }
    
    func hide(after seconds: TimeInterval = 0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let self = self, let superview = self.superview else { return }
            self.bottomConstraint?.constant = self.imageSize.height +
                self.padding.top +
                self.padding.bottom +
                self.margin.bottom
            UIView.animate(withDuration: AnimationDuration.medium,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            superview.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
                completion?()
            })
        })
    }
}
