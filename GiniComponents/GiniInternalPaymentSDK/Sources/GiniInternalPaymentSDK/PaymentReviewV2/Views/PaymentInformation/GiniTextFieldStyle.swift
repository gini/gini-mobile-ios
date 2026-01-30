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
    
    init(lockedIcon: Image? = nil,
         title: String,
         state: GiniTextFieldState = .normal,
         errorMessage: String? = nil,
         normalConfiguration: TextFieldConfiguration,
         focusedConfiguration: TextFieldConfiguration,
         errorConfiguration: TextFieldConfiguration) {
        self.lockedIcon = lockedIcon
        self.title = title
        self.state = state
        self.errorMessage = errorMessage
        self.normalConfiguration = normalConfiguration
        self.focusedConfiguration = focusedConfiguration
        self.errorConfiguration = errorConfiguration
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
            VStack(spacing: Constants.titleSpacing) {
                titleView
                
                configuration
                    .foregroundColor(Color(currentConfiguration.textColor))
                    .font(Font(currentConfiguration.textFont))
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .frame(height: Constants.textFieldHeight)
            .background(Color(currentConfiguration.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius,
                                        style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius,
                                 style: .continuous)
                .stroke(Color(currentConfiguration.borderColor),
                        lineWidth: currentConfiguration.borderWidth)
            }
            
            if state == .error,
               let errorMessage, !errorMessage.isEmpty {
                errorMessageView(errorMessage)
            }
        }
        .animation(.easeInOut(duration: Constants.animationDuration), value: state)
        .animation(.easeInOut(duration: Constants.animationDuration), value: errorMessage)
    }
    
    // MARK: Private views
    
    @ViewBuilder
    private var titleView: some View {
        HStack {
            Text(title)
                .foregroundColor(Color(currentConfiguration.placeholderForegroundColor))
            
            if let lockedIcon {
                lockedIcon
                    .resizable()
                    .frame(width: Constants.lockedIconSize.width,
                           height: Constants.lockedIconSize.height)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func errorMessageView(_ errorMessage: String) -> some View {
        Text(errorMessage)
            .foregroundStyle(Color(errorConfiguration.borderColor))
            .font(Font(errorConfiguration.textFont))
            .padding(.horizontal, Constants.errorMessageHorizontalPadding)
            .multilineTextAlignment(.leading)
            .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity))
    }
    
    private struct Constants {
        
        static let verticalSpacing = 4.0
        static let horizontalPadding = 8.0
        static let textFieldHeight = 56.0
        static let titleSpacing = 0.0
        static let errorMessageHorizontalPadding = 8.0
        static let lockedIconSize = CGSize(width: 16, height: 16)
        static let animationDuration = 0.25
    }
}
