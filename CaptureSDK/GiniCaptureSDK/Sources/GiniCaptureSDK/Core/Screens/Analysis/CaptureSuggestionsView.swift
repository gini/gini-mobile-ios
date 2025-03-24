//
//  CaptureSuggestionView.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 9/26/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsView: UIView {

    private enum CaptureSuggestionsState {
        case shown
        case hidden
    }

    private let suggestionContainer: CaptureSuggestionsViewContainer?
    private let containerHeight: CGFloat = 96
    private var itemSeparationConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var leadingiPhoneConstraint = NSLayoutConstraint()
    private var trailingiPhoneConstraint = NSLayoutConstraint()
    private let repeatInterval: TimeInterval = 5
    private let superViewBottomAnchor: NSLayoutYAxisAnchor

    private var suggestionIconImages = [
        UIImageNamedPreferred(named: "captureSuggestion1"),
        UIImageNamedPreferred(named: "captureSuggestion2"),
        UIImageNamedPreferred(named: "captureSuggestion3"),
        UIImageNamedPreferred(named: "captureSuggestion4")
    ]

    private var suggestionTitle: [String] = [
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.1",
                                        comment: "First suggestion title for analysis screen"),
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.2",
                                         comment: "Second suggestion title for analysis screen"),
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.3",
                                         comment: "Third suggestion title for analysis screen"),
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.4",
                                         comment: "Fourth suggestion title for analysis screen")
    ]

    private var suggestionDescription: [String] = [
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.1.details",
                                         comment: "First suggestion description for analysis screen"),
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.2.details",
                                         comment: "Second suggestion description for analysis screen"),
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.3.details",
                                         comment: "Third suggestion description for analysis screen"),
        NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.4.details",
                                         comment: "Fourth suggestion description for analysis screen")
    ]

    init(superView: UIView, bottomAnchor: NSLayoutYAxisAnchor) {
        if GiniConfiguration.shared.multipageEnabled {
            suggestionIconImages.append(UIImageNamedPreferred(named: "captureSuggestion5"))
            suggestionTitle.append(NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.5",
                                                                    comment: "Fifth suggestion for analysis screen"))
            suggestionDescription.append(
                NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.5.details",
                                                 comment: "Fifth suggestion description for analysis screen"))
        }

        suggestionContainer = CaptureSuggestionsViewContainer().loadNib() as? CaptureSuggestionsViewContainer

        superViewBottomAnchor = bottomAnchor

        let randomIndex = Int.random(in: 0...suggestionTitle.count - 1)
        suggestionContainer?.configureContent(with: suggestionIconImages[randomIndex],
                                              title: suggestionTitle[randomIndex],
                                              description: suggestionDescription[randomIndex])
        super.init(frame: .zero)
        alpha = 0
        guard let suggestionContainer = suggestionContainer else { return }
        self.addSubview(suggestionContainer)
        superView.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        suggestionContainer.translatesAutoresizingMaskIntoConstraints = false

        addConstraints()
        layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init() initializer")
    }

    private func addConstraints() {
        guard let superview = superview, let suggestionContainer = suggestionContainer else { return }

        // self
        bottomConstraint = self.bottomAnchor.constraint(equalTo: superViewBottomAnchor, constant: containerHeight)
        Constraints.active(item: self, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        Constraints.active(item: self, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        Constraints.active(item: self, attr: .height, relatedBy: .greaterThanOrEqual,
                           to: nil, attr: .notAnAttribute, constant: containerHeight, priority: 250)
        Constraints.active(constraint: bottomConstraint)

        // suggestionContainer
        itemSeparationConstraint = NSLayoutConstraint(item: suggestionContainer, attribute: .bottom, relatedBy: .equal,
                                                      toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        Constraints.active(item: suggestionContainer, attr: .height, relatedBy: .greaterThanOrEqual,
                           to: nil, attr: .notAnAttribute, constant: containerHeight)
        Constraints.active(constraint: itemSeparationConstraint)

        // Center on align to margins depending on device
        if UIDevice.current.isIpad {
            Constraints.active(item: suggestionContainer, attr: .width, relatedBy: .equal, to: self,
                              attr: .width, multiplier: 0.7)
            Constraints.active(item: suggestionContainer, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
        } else {
            leadingiPhoneConstraint = Constraints.active(item: suggestionContainer, attr: .leading, relatedBy: .equal, to: self.safeAreaLayoutGuide, attr: .leading,
                              constant: 20)
            trailingiPhoneConstraint = Constraints.active(item: suggestionContainer, attr: .trailing, relatedBy: .equal, to: self.safeAreaLayoutGuide, attr: .trailing,
                              constant: -20)
        }
    }
}

// MARK: Animations

extension CaptureSuggestionsView {

    func start(after seconds: TimeInterval = 4) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let self = self, let superview = self.superview else { return }
            self.bottomConstraint.constant = UIDevice.current.isIpad ? -28 : -24
            self.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                superview.layoutIfNeeded()
            }, completion: { _ in
                self.changeView(toState: .hidden)
            })
        })
    }

    private func changeView(toState state: CaptureSuggestionsState) {
        let delay: TimeInterval
        let nextState: CaptureSuggestionsState

        if state == .shown {
            delay = 0
            nextState = .hidden
            changeSuggestionText()
            suggestionContainer?.layoutIfNeeded()
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

    private func changeSuggestionText() {
        if let currentTitle = suggestionContainer?.titleLabel.text,
            let currentIndex = suggestionTitle.firstIndex(of: currentTitle) {
            let nextIndex: Int
            if suggestionTitle.index(after: currentIndex) < suggestionTitle.endIndex {
                nextIndex = suggestionTitle.index(after: currentIndex)
            } else {
                nextIndex = 0
            }

            suggestionContainer?.configureContent(with: suggestionIconImages[nextIndex],
                                                  title: suggestionTitle[nextIndex],
                                                  description: suggestionDescription[nextIndex])
        }
    }

    private func updatePosition(withState state: CaptureSuggestionsState) {
        if state == .shown {
            self.itemSeparationConstraint.constant = 0
        } else {
            self.itemSeparationConstraint.constant = 2 * containerHeight
        }
    }
}
