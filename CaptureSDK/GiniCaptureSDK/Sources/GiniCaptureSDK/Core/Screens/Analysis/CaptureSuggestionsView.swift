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
    fileprivate let suggestionTextTitle: UILabel
    fileprivate let suggestionTextDescription: UILabel
    fileprivate let suggestionContainer: UIView
    fileprivate let containerHeight: CGFloat = 96
    fileprivate var itemSeparationConstraint: NSLayoutConstraint = NSLayoutConstraint()
    fileprivate var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    fileprivate let repeatInterval: TimeInterval = 5
    fileprivate let superViewBottomAnchor: NSLayoutYAxisAnchor

    fileprivate var suggestionIconImages = [
        UIImageNamedPreferred(named: "captureSuggestion1"),
        UIImageNamedPreferred(named: "captureSuggestion2"),
        UIImageNamedPreferred(named: "captureSuggestion3"),
        UIImageNamedPreferred(named: "captureSuggestion4")
    ]

    fileprivate var suggestionTitle: [String] = [
        .localized(resource: AnalysisStrings.suggestion1Text),
        .localized(resource: AnalysisStrings.suggestion2Text),
        .localized(resource: AnalysisStrings.suggestion3Text),
        .localized(resource: AnalysisStrings.suggestion4Text)
    ]

    fileprivate var suggestionDescription: [String] = [
        .localized(resource: AnalysisStrings.suggestion1Details),
        .localized(resource: AnalysisStrings.suggestion2Details),
        .localized(resource: AnalysisStrings.suggestion3Details),
        .localized(resource: AnalysisStrings.suggestion4Details)
    ]
    
    init(superView: UIView, bottomAnchor: NSLayoutYAxisAnchor, font: GiniCaptureFont, multiPageEnabled: Bool) {
        if multiPageEnabled {
            suggestionIconImages.append(UIImageNamedPreferred(named: "captureSuggestion5"))
            suggestionTitle.append(.localized(resource: AnalysisStrings.suggestion5Text))
            suggestionDescription.append(.localized(resource: AnalysisStrings.suggestion5Details))
        }

        suggestionContainer = UIView()
        if #available(iOS 13.0, *) {
            suggestionContainer.backgroundColor = Colors.Gini.dynamicPearl
        } else {
            suggestionContainer.backgroundColor = Colors.Gini.pearl
        }
        suggestionContainer.layer.cornerRadius = 16
        
        suggestionTextTitle = UILabel()
        superViewBottomAnchor = bottomAnchor

        suggestionTextTitle.textColor = UIColor.from(giniColor: GiniColor(lightModeColor: .black, darkModeColor: .white))
        suggestionTextTitle.font = font.with(weight: .bold, size: 16, style: .body)
        suggestionTextTitle.numberOfLines = 0

        let randomIndex = Int.random(in: 0...suggestionTitle.count - 1)

        suggestionIcon = UIImageView(image: suggestionIconImages[randomIndex])
        suggestionIcon.contentMode = .scaleAspectFit

        suggestionTextTitle.text = suggestionTitle[randomIndex]

        suggestionTextDescription = UILabel()
        suggestionTextDescription.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        suggestionTextDescription.font = font.with(weight: .regular, size: 15, style: .body)
        suggestionTextDescription.numberOfLines = 0

        suggestionTextDescription.text = suggestionDescription[randomIndex]
        
        super.init(frame: .zero)
        alpha = 0
        
        suggestionContainer.addSubview(suggestionIcon)
        suggestionContainer.addSubview(suggestionTextTitle)
        suggestionContainer.addSubview(suggestionTextDescription)
        self.addSubview(suggestionContainer)
        superView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        suggestionContainer.translatesAutoresizingMaskIntoConstraints = false
        suggestionIcon.translatesAutoresizingMaskIntoConstraints = false
        suggestionTextTitle.translatesAutoresizingMaskIntoConstraints = false
        suggestionTextDescription.translatesAutoresizingMaskIntoConstraints = false
        
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

        // suggestionContainer
        itemSeparationConstraint = NSLayoutConstraint(item: suggestionContainer, attribute: .top, relatedBy: .equal,
                                                      toItem: self, attribute: .top, multiplier: 1,
                                                      constant: 0)
        Constraints.active(item: suggestionContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: containerHeight)
        Constraints.active(constraint: itemSeparationConstraint)
        
        // suggestionIcon
        Constraints.active(item: suggestionIcon, attr: .leading, relatedBy: .equal, to: suggestionContainer,
                          attr: .leading, constant: 16)
        Constraints.active(item: suggestionIcon, attr: .height, relatedBy: .lessThanOrEqual, to: nil,
                          attr: .notAnAttribute, constant: 48)
        Constraints.active(item: suggestionIcon, attr: .width, relatedBy: .equal, to: suggestionIcon, attr: .height)
        Constraints.active(item: suggestionIcon, attr: .centerY, relatedBy: .equal, to: suggestionContainer,
                          attr: .centerY)
        Constraints.active(item: suggestionIcon, attr: .trailing, relatedBy: .equal, to: suggestionTextTitle, attr: .leading,
                          constant: -16)
        Constraints.active(item: suggestionIcon, attr: .trailing, relatedBy: .equal, to: suggestionTextDescription, attr: .leading,
                          constant: -16)
        
        // suggestionText
        Constraints.active(item: suggestionTextTitle, attr: .top, relatedBy: .equal, to: suggestionContainer, attr: .top,
                          constant: 16)
        Constraints.active(item: suggestionTextTitle, attr: .trailing, relatedBy: .equal, to: suggestionContainer,
                           attr: .trailing, constant: -16)

        Constraints.active(item: suggestionTextDescription, attr: .top, relatedBy: .equal, to: suggestionTextTitle, attr: .bottom,
                          constant: 4)
        Constraints.active(item: suggestionTextDescription, attr: .trailing, relatedBy: .equal, to: suggestionContainer,
                           attr: .trailing, constant: -16)
        
        
        // Center on align to margins depending on device
        if UIDevice.current.isIpad {
            Constraints.active(item: suggestionContainer, attr: .width, relatedBy: .lessThanOrEqual, to: self,
                              attr: .width, multiplier: 0.9)
            Constraints.active(item: suggestionTextTitle, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
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
        if let currentTitle = suggestionTextTitle.text, let currentIndex = suggestionTitle.firstIndex(of: currentTitle) {
            let nextIndex: Int
            if suggestionTitle.index(after: currentIndex) < suggestionTitle.endIndex {
                nextIndex = suggestionTitle.index(after: currentIndex)
            } else {
                nextIndex = 0
            }

            suggestionIcon.image = suggestionIconImages[nextIndex]
            suggestionTextTitle.text = suggestionTitle[nextIndex]
            suggestionTextDescription.text = suggestionDescription[nextIndex]
        }
    }
    
    fileprivate func updatePosition(withState state: CaptureSuggestionsState) {
        if state == .shown {
            self.itemSeparationConstraint.constant = 0
        } else {
            self.itemSeparationConstraint.constant = 2 * containerHeight
        }
    }
}
