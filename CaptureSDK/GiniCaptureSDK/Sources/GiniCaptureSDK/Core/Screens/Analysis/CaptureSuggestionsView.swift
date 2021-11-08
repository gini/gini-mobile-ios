//
//  CaptureSuggestionView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/26/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsView: UIView {
    
    fileprivate enum CaptureSuggestionsState {
        case shown
        case hidden
    }
    
    fileprivate let suggestionIcon: UIImageView
    fileprivate let suggestionText: UILabel
    fileprivate let suggestionContainer: UIView
    fileprivate let suggestionTitle: UILabel
    fileprivate let containerHeight: CGFloat = 135
    fileprivate let suggestionTitleHeight: CGFloat = 20
    fileprivate var itemSeparationConstraint: NSLayoutConstraint = NSLayoutConstraint()
    fileprivate var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    fileprivate let repeatInterval: TimeInterval = 5
    fileprivate let superViewBottomAnchor: NSLayoutYAxisAnchor
    fileprivate let suggestionIconImage = UIImage(named: "analysisSuggestionsIcon",
                                                  in: Bundle.module, compatibleWith: nil)
    fileprivate var suggestionTexts: [String] = [
        .localized(resource: AnalysisStrings.suggestion1Text),
        .localized(resource: AnalysisStrings.suggestion2Text),
        .localized(resource: AnalysisStrings.suggestion3Text),
        .localized(resource: AnalysisStrings.suggestion4Text)
    ]
    
    init(superView: UIView, bottomAnchor: NSLayoutYAxisAnchor, font: UIFont) {
        suggestionContainer = UIView()
        suggestionTitle = UILabel()
        suggestionText = UILabel()
        superViewBottomAnchor = bottomAnchor

        suggestionIcon = UIImageView(image: suggestionIconImage)
        suggestionIcon.contentMode = .scaleAspectFit
        
        suggestionTitle.textColor = .white
        suggestionTitle.font = font
        suggestionTitle.numberOfLines = 1
        suggestionTitle.text = .localized(resource: AnalysisStrings.suggestionHeader)
        suggestionTitle.textAlignment = .center
        suggestionTitle.adjustsFontSizeToFitWidth = true
        suggestionTitle.minimumScaleFactor = 14/16
        
        suggestionText.textColor = .white
        suggestionText.font = font
        suggestionText.numberOfLines = 0
        suggestionTexts.shuffle()
        suggestionText.text = suggestionTexts.first!
        
        super.init(frame: .zero)
        alpha = 0
        
        suggestionContainer.addSubview(suggestionIcon)
        suggestionContainer.addSubview(suggestionText)
        self.addSubview(suggestionContainer)
        self.addSubview(suggestionTitle)
        superView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        suggestionContainer.translatesAutoresizingMaskIntoConstraints = false
        suggestionTitle.translatesAutoresizingMaskIntoConstraints = false
        suggestionIcon.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints()
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init() initializer")
    }
    
    fileprivate func addConstraints() {
        guard let superview = superview else { return }
        
        // self
        bottomConstraint = self.bottomAnchor.constraint(equalTo: superViewBottomAnchor, constant: containerHeight)
        Constraints.active(item: self, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        Constraints.active(item: self, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        Constraints.active(item: self, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: containerHeight)
        Constraints.active(constraint: bottomConstraint)

        // suggestionTitle
        Constraints.active(item: suggestionTitle, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Constraints.active(item: suggestionTitle, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: 8)
        Constraints.active(item: suggestionTitle, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -8, priority: 999)
        Constraints.active(item: suggestionTitle, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: suggestionTitleHeight)

        // suggestionContainer
        itemSeparationConstraint = NSLayoutConstraint(item: suggestionContainer, attribute: .top, relatedBy: .equal,
                                                      toItem: suggestionTitle, attribute: .bottom, multiplier: 1,
                                                      constant: 0)
        Constraints.active(item: suggestionContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: containerHeight - suggestionTitleHeight)
        Constraints.active(constraint: itemSeparationConstraint)
        
        // suggestionIcon
        Constraints.active(item: suggestionIcon, attr: .leading, relatedBy: .equal, to: suggestionContainer,
                          attr: .leading)
        Constraints.active(item: suggestionIcon, attr: .height, relatedBy: .lessThanOrEqual, to: nil,
                          attr: .notAnAttribute, constant: 48)
        Constraints.active(item: suggestionIcon, attr: .width, relatedBy: .equal, to: suggestionIcon, attr: .height)
        Constraints.active(item: suggestionIcon, attr: .centerY, relatedBy: .equal, to: suggestionContainer,
                          attr: .centerY)
        Constraints.active(item: suggestionIcon, attr: .trailing, relatedBy: .equal, to: suggestionText, attr: .leading,
                          constant: -16)
        
        // suggestionText
        Constraints.active(item: suggestionText, attr: .top, relatedBy: .equal, to: suggestionContainer, attr: .top,
                          constant: 16, priority: 999)
        Constraints.active(item: suggestionText, attr: .trailing, relatedBy: .equal, to: suggestionContainer,
                          attr: .trailing, priority: 999)
        Constraints.active(item: suggestionText, attr: .bottom, relatedBy: .equal, to: suggestionContainer,
                          attr: .bottom, constant: -16, priority: 999)
        
        // Center on align to margins depending on device
        if UIDevice.current.isIpad {
            Constraints.active(item: suggestionContainer, attr: .width, relatedBy: .lessThanOrEqual, to: self,
                              attr: .width, multiplier: 0.9)
            Constraints.active(item: suggestionText, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
        } else {
            Constraints.active(item: suggestionContainer, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                              constant: 20)
            Constraints.active(item: suggestionContainer, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                              constant: -20, priority: 999)
        }
    }
}

// MARK: Animations

extension CaptureSuggestionsView {
    
    func start(after seconds: TimeInterval = 4) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let self = self, let superview = self.superview else { return }
            self.bottomConstraint.constant = 0
            self.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                superview.layoutIfNeeded()
            }, completion: { _ in
                self.changeView(toState: .hidden)
            })
        })
    }
    
    fileprivate func changeView(toState state: CaptureSuggestionsState) {
        let delay: TimeInterval
        let nextState: CaptureSuggestionsState
        
        if state == .shown {
            delay = 0
            nextState = .hidden
            changeSuggestionText()
            suggestionContainer.layoutIfNeeded()
        } else {
            delay = repeatInterval
            nextState = .shown
        }
        
        updatePosition(withState: state)

        UIView.animate(withDuration: 0.5, delay: delay, options: [UIView.AnimationOptions.curveEaseInOut], animations: {
            self.layoutIfNeeded()
        }, completion: {[weak self] _ in
            guard let self = self else { return }
            self.changeView(toState: nextState)
        })
    }
    
    fileprivate func changeSuggestionText() {
        if let currentText = suggestionText.text, let currentIndex = suggestionTexts.firstIndex(of: currentText) {
            let nextIndex: Int
            if suggestionTexts.index(after: currentIndex) < suggestionTexts.endIndex {
                nextIndex = suggestionTexts.index(after: currentIndex)
            } else {
                nextIndex = 0
            }
            suggestionText.text = suggestionTexts[nextIndex]
        }
    }
    
    fileprivate func updatePosition(withState state: CaptureSuggestionsState) {
        if state == .shown {
            self.itemSeparationConstraint.constant = 0
        } else {
            self.itemSeparationConstraint.constant = containerHeight
        }
    }
}
