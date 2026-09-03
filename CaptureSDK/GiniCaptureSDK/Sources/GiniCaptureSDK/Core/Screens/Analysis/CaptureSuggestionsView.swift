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
    private var itemSeparationConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var leadingiPhoneConstraint = NSLayoutConstraint()
    private var trailingiPhoneConstraint = NSLayoutConstraint()
    private let superViewBottomAnchor: NSLayoutYAxisAnchor

    private var suggestionIconImages = [
        UIImageNamedPreferred(named: "captureSuggestion1"),
        UIImageNamedPreferred(named: "captureSuggestion2"),
        UIImageNamedPreferred(named: "captureSuggestion3"),
        UIImageNamedPreferred(named: "captureSuggestion4")
    ]

    private var suggestionTitle: [String] = [
        Strings.suggestionTitle1,
        Strings.suggestionTitle2,
        Strings.suggestionTitle3,
        Strings.suggestionTitle4
    ]

    private var suggestionDescription: [String] = [
        Strings.suggestionDescription1,
        Strings.suggestionDescription2,
        Strings.suggestionDescription3,
        Strings.suggestionDescription4
    ]

    init(superView: UIView, bottomAnchor: NSLayoutYAxisAnchor) {
        if GiniConfiguration.shared.multipageEnabled {
            suggestionIconImages.append(UIImageNamedPreferred(named: "captureSuggestion5"))
            suggestionTitle.append(Strings.suggestionTitle5)
            suggestionDescription.append(Strings.suggestionDescription5)
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
        bottomConstraint = bottomAnchor.constraint(equalTo: superViewBottomAnchor,
                                                   constant: Constants.containerHeight)
        Constraints.active(item: self,
                           attr: .leading,
                           relatedBy: .equal,
                           to: superview,
                           attr: .leading)

        Constraints.active(item: self,
                           attr: .trailing,
                           relatedBy: .equal,
                           to: superview,
                           attr: .trailing)

        Constraints.active(item: self,
                           attr: .height,
                           relatedBy: .greaterThanOrEqual,
                           to: nil,
                           attr: .notAnAttribute,
                           constant: Constants.containerHeight,
                           priority: 250)

        Constraints.active(constraint: bottomConstraint)

        // suggestionContainer
        itemSeparationConstraint = NSLayoutConstraint(item: suggestionContainer,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: self,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: 0)
        Constraints.active(item: suggestionContainer,
                           attr: .height,
                           relatedBy: .greaterThanOrEqual,
                           to: nil,
                           attr: .notAnAttribute,
                           constant: Constants.containerHeight)
        
        Constraints.active(constraint: itemSeparationConstraint)

        // Center on align to margins depending on device
        if UIDevice.current.isIpad {
            Constraints.active(item: suggestionContainer,
                               attr: .width,
                               relatedBy: .equal,
                               to: self,
                              attr: .width,
                               multiplier: 0.7)
            Constraints.active(item: suggestionContainer,
                               attr: .centerX,
                               relatedBy: .equal,
                               to: self,
                               attr: .centerX)
        } else {
            leadingiPhoneConstraint = Constraints.active(item: suggestionContainer,
                                                         attr: .leading,
                                                         relatedBy: .equal,
                                                         to: self.safeAreaLayoutGuide,
                                                         attr: .leading,
                                                         constant: Constants.horizontalMargin)
            trailingiPhoneConstraint = Constraints.active(item: suggestionContainer,
                                                          attr: .trailing,
                                                          relatedBy: .equal,
                                                          to: self.safeAreaLayoutGuide,
                                                          attr: .trailing,
                                                          constant: -Constants.horizontalMargin)
        }
    }
}

// MARK: Animations

extension CaptureSuggestionsView {

    func start(after seconds: TimeInterval = 4) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let self = self, let superview = self.superview else { return }

            if let parentVC = self.parentViewController,
               parentVC.presentedViewController != nil {
                // Skipping suggestions - modal is presented
                return
            }

            bottomConstraint.constant = Constants.bottomConstraint
            alpha = 1
            UIView.animate(withDuration: Constants.animationDuration,
                           animations: { [weak self] in
                superview.layoutIfNeeded()

                if let title = self?.suggestionContainer?.titleLabel.text,
                    let description = self?.suggestionContainer?.descriptionLabel.text {
                    UIAccessibility.post(notification: .announcement, argument: "\(title) \(description)")
                }
            }, completion: { [weak self] _ in
                self?.changeView(toState: .hidden)
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
            delay = Constants.repeatInterval
            nextState = .shown
        }

        updatePosition(withState: state)

        UIView.animate(withDuration: Constants.animationDuration,
                       delay: delay,
                       options: [UIView.AnimationOptions.curveEaseInOut], animations: {
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

            let title = suggestionTitle[nextIndex]
            let description = suggestionDescription[nextIndex]

            suggestionContainer?.configureContent(with: suggestionIconImages[nextIndex],
                                                  title: title,
                                                  description: description)

            // Only announce if no modal is presented
            if parentViewController?.presentedViewController == nil {
                UIAccessibility.post(notification: .announcement, argument: "\(title) \(description)")
            }
        }
    }

    private func updatePosition(withState state: CaptureSuggestionsState) {
        if state == .shown {
            self.itemSeparationConstraint.constant = 0
        } else {
            self.itemSeparationConstraint.constant = 2 * Constants.containerHeight
        }
    }
}

private extension CaptureSuggestionsView {
    private struct Constants {
        static let animationDuration: TimeInterval = 0.5
        static let bottomConstraint: CGFloat = UIDevice.current.isIpad ? -28 : -24
        static let horizontalMargin: CGFloat = 20
        static let repeatInterval: TimeInterval = 5
        static let containerHeight: CGFloat = 96
    }

    private struct Strings {

        // MARK: - Suggestion Titles

        static let suggestionTitle1Key = "ginicapture.analysis.suggestion.1"
        static let suggestionTitle2Key = "ginicapture.analysis.suggestion.2"
        static let suggestionTitle3Key = "ginicapture.analysis.suggestion.3"
        static let suggestionTitle4Key = "ginicapture.analysis.suggestion.4"
        static let suggestionTitle5Key = "ginicapture.analysis.suggestion.5"

        static let suggestionTitle1 = NSLocalizedStringPreferredFormat(suggestionTitle1Key,
                                                                       comment: "First suggestion title for analysis screen")
        static let suggestionTitle2 = NSLocalizedStringPreferredFormat(suggestionTitle2Key,
                                                                       comment: "Second suggestion title for analysis screen")
        static let suggestionTitle3 = NSLocalizedStringPreferredFormat(suggestionTitle3Key,
                                                                       comment: "Third suggestion title for analysis screen")
        static let suggestionTitle4 = NSLocalizedStringPreferredFormat(suggestionTitle4Key,
                                                                       comment: "Fourth suggestion title for analysis screen")
        static let suggestionTitle5 = NSLocalizedStringPreferredFormat(suggestionTitle5Key,
                                                                       comment: "Fifth suggestion title for analysis screen")

        // MARK: - Suggestion Descriptions

        static let suggestionDescription1Key = "ginicapture.analysis.suggestion.1.details"
        static let suggestionDescription2Key = "ginicapture.analysis.suggestion.2.details"
        static let suggestionDescription3Key = "ginicapture.analysis.suggestion.3.details"
        static let suggestionDescription4Key = "ginicapture.analysis.suggestion.4.details"
        static let suggestionDescription5Key = "ginicapture.analysis.suggestion.5.details"

        static let suggestionDescription1 = NSLocalizedStringPreferredFormat(suggestionDescription1Key,
                                                                             comment: "First suggestion description for analysis screen")
        static let suggestionDescription2 = NSLocalizedStringPreferredFormat(suggestionDescription2Key,
                                                                             comment: "Second suggestion description for analysis screen")
        static let suggestionDescription3 = NSLocalizedStringPreferredFormat(suggestionDescription3Key,
                                                                             comment: "Third suggestion description for analysis screen")
        static let suggestionDescription4 = NSLocalizedStringPreferredFormat(suggestionDescription4Key,
                                                                             comment: "Fourth suggestion description for analysis screen")
        static let suggestionDescription5 = NSLocalizedStringPreferredFormat(suggestionDescription5Key,
                                                                             comment: "Fifth suggestion description for analysis screen")
    }
}
