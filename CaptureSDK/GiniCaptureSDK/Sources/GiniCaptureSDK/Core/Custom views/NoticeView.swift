//
//  NoticeView.swift
//  GiniCapture
//
//  Created by Peter Pult on 01/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

@objc public enum NoticeActionType: Int {
    case retry, retake
    
    var title: String {
        switch self {
        case .retry:
            return .localized(resource: MultipageReviewStrings.retryActionButton)
        case .retake:
            return .localized(resource: MultipageReviewStrings.retakeActionButton)
        }
    }
}

/**
 Block that will be executed when a notice is tapped. Can be used to restart a
 process or to give the user further guidance.
 
 - note: Screen API only.
 */

struct NoticeAction {
    let title: String
    let action: () -> Void
}

enum NoticeType {
    case information, error
}

final class NoticeView: UIView {
    
    // User interface
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12 / 14
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        label.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)

        button.titleLabel?.textColor = giniConfiguration.noticeErrorTextColor
        button.titleLabel?.font =  giniConfiguration.customFont.with(weight: .regular, size: 16, style: .caption1)
        button.addTarget(self, action: #selector(self.didTapActionButton), for: .touchUpInside)
        return button
    }()
    
    // Properties
    fileprivate let giniConfiguration: GiniConfiguration
    var userAction: NoticeAction? {
        didSet {
            actionButton.setTitle(userAction?.title, for: .normal)
        }
    }
    
    init(text: String,
         type: NoticeType = .information,
         giniConfiguration: GiniConfiguration = .shared,
         noticeAction: NoticeAction? = nil) {
        self.giniConfiguration = giniConfiguration
        super.init(frame: CGRect.zero)
        
        let textColor: UIColor
        switch type {
        case .information:
            textColor = giniConfiguration.noticeInformationTextColor
            backgroundColor = giniConfiguration
                .noticeInformationBackgroundColor
                .withAlphaComponent(0.8)
        case .error:
            textColor = giniConfiguration.noticeErrorTextColor
            backgroundColor = giniConfiguration
                .noticeErrorBackgroundColor
                .withAlphaComponent(0.9)
        }

        if let noticeAction = noticeAction {
            userAction = noticeAction
            actionButton.titleLabel?.textColor = textColor
            addSubview(actionButton)
        }
        
        textLabel.text = text
        textLabel.textColor = textColor
        addSubview(textLabel)
        
        addConstraints()
        alpha = 0.0
    }
    
    @objc func didTapActionButton() {
        UIImpactFeedbackGenerator().impactOccurred()
        self.userAction?.action()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addConstraints() {
        Constraints.active(item: self, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 70)
        // Text label
        Constraints.active(item: textLabel, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: 16)
        Constraints.active(item: textLabel, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom, constant: -16)
        Constraints.active(item: textLabel, attr: .leading, relatedBy: .equal, to: self, attr: .leading, constant: 20,
                           priority: 999)
        
        if userAction != nil {
            Constraints.active(item: actionButton, attr: .leading, relatedBy: .equal, to: textLabel, attr: .trailing,
                               constant: 16)
            Constraints.active(item: actionButton, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                               constant: -16)
            Constraints.active(item: actionButton, attr: .top, relatedBy: .equal, to: self, attr: .top)
            Constraints.active(item: actionButton, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom)
        } else {
            Constraints.active(item: textLabel, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                               constant: -16)
        }
    }
    
}

// MARK: - Toggle options

extension NoticeView {
    func show(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1.0
            }
        } else {
            self.alpha = 1.0
        }
    }
    
    func hide(_ animated: Bool = true, completion: (() -> Void)?) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                completion?()
            })
        } else {
            self.alpha = 0.0
            completion?()
        }
        
    }
}
