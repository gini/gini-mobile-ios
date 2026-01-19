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
    
    var normalConfiguration: TextFieldConfiguration
    var focusedConfiguration: TextFieldConfiguration
    var errorConfiguration: TextFieldConfiguration
    
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
         normalConfiguration: TextFieldConfiguration,
         focusedConfiguration: TextFieldConfiguration,
         errorConfiguration: TextFieldConfiguration) {
        self.lockedIcon = lockedIcon
        self.title = title
        self.state = state
        self.normalConfiguration = normalConfiguration
        self.focusedConfiguration = focusedConfiguration
        self.errorConfiguration = errorConfiguration
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .foregroundColor(Color(currentConfiguration.placeholderForegroundColor))
                
                if let lockedIcon {
                    lockedIcon
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            
            configuration
                .foregroundColor(Color(currentConfiguration.textColor))
                .font(Font(currentConfiguration.textFont))
        }
        .padding(.horizontal, 8.0)
        .frame(height: 56.0)
        .background(Color(currentConfiguration.backgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius,
                                    style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: currentConfiguration.cornerRadius,
                             style: .continuous)
            .stroke(Color(currentConfiguration.borderColor),
                    lineWidth: currentConfiguration.borderWidth)
        }
    }
}
