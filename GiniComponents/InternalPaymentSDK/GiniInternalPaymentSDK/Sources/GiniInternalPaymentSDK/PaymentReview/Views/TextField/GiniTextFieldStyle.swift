//
//  GiniTextFieldStyle.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniUtilites
import SwiftUI

enum GiniTextFieldState {
    case error
    case focused
    case normal
}

struct GiniTextFieldStyle: TextFieldStyle {
    
    private let lockedIcon: Image?
    private let title: String
    private let state: GiniTextFieldState
    private let errorMessage: String?
    private let onTap: (() -> Void)?
    
    private let normalConfiguration: TextFieldConfiguration
    private let focusedConfiguration: TextFieldConfiguration
    private let errorConfiguration: TextFieldConfiguration
    
    private var currentConfiguration: TextFieldConfiguration {
        switch state {
        case .error:
            return errorConfiguration
        case .focused:
            return focusedConfiguration
        case .normal:
            return normalConfiguration
        }
    }
    
    private var shouldAnimate: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }

    init(lockedIcon: Image? = nil,
         title: String,
         state: GiniTextFieldState = .normal,
         errorMessage: String? = nil,
         normalConfiguration: TextFieldConfiguration,
         focusedConfiguration: TextFieldConfiguration,
         errorConfiguration: TextFieldConfiguration,
         onTap: (() -> Void)? = nil) {
        self.lockedIcon = lockedIcon
        self.title = title
        self.state = state
        self.errorMessage = errorMessage
        self.normalConfiguration = normalConfiguration
        self.focusedConfiguration = focusedConfiguration
        self.errorConfiguration = errorConfiguration
        self.onTap = onTap
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        let fieldAnimation = shouldAnimate ? Animation.easeInOut(duration: Constants.animationDuration) : nil
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            VStack(spacing: Constants.titleSpacing) {
                titleView
                
                configuration
                    .foregroundStyle(Color(currentConfiguration.textColor))
                    .font(Font(giniFont: currentConfiguration.textFont))
                    .frame(minHeight: Constants.textFieldHeight)
                    .accessibilityLabel(title)
                    .accessibilityHintIfPresent(state == .error ? errorMessage : nil)
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.verticalPadding)
            .background(Color(currentConfiguration.backgroundColor))
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
            .clipShape(RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius)
                .stroke(Color(currentConfiguration.borderColor),
                        lineWidth: currentConfiguration.borderWidth)
            }
            
            if state == .error,
               let errorMessage, !errorMessage.isEmpty {
                errorMessageView(errorMessage)
            }
        }
        // Only animate border/background transitions (state changes).
        // Height animation is intentionally excluded: animating the container height
        // propagates to parent stacks and causes sibling fields to overlap the error
        // label during the transition (HEAL-368). The label animates itself below.
        .animation(fieldAnimation, value: state)
    }
    
    // MARK: Private views
    
    @ViewBuilder
    private var titleView: some View {
        HStack {
            Text(title)
                .font(Font(giniFont: currentConfiguration.textFont))
                .foregroundStyle(Color(currentConfiguration.placeholderForegroundColor))

            if let lockedIcon {
                lockedIcon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.lockedIconSize.width,
                           height: Constants.lockedIconSize.height)
                    .accessibilityHidden(true)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }
    
    @ViewBuilder
    private func errorMessageView(_ errorMessage: String) -> some View {
        Text(errorMessage)
            .foregroundStyle(Color(errorConfiguration.borderColor))
            .font(Font(giniFont: errorConfiguration.textFont))
            .padding(.horizontal, Constants.errorMessageHorizontalPadding)
            .multilineTextAlignment(.leading)
            .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity))
            // Error is already surfaced via accessibilityHint on the field above.
            // Hiding here prevents VoiceOver from reading the same message twice.
            .accessibilityHidden(true)
            .animation(shouldAnimate ? Animation.easeInOut(duration: Constants.animationDuration) : nil,
                       value: errorMessage)
    }
    
    private struct Constants {
        
        static let verticalSpacing = 4.0
        static let horizontalPadding = 8.0
        static let verticalPadding = 8.0
        static let textFieldHeight = 30.0
        static let titleSpacing = 0.0
        static let errorMessageHorizontalPadding = 8.0
        static let lockedIconSize = CGSize(width: 12, height: 12)
        static let animationDuration = 0.25
    }
}
