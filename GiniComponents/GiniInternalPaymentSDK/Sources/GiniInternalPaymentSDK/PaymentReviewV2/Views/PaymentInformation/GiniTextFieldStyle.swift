//
//  GiniTextFieldStyle.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniUtilites
import SwiftUI

struct GiniTextFieldStyle: TextFieldStyle {
    
    private let lockedIcon: Image?
    private let title: String
    
    init(lockedIcon: Image? = nil, title: String) {
        self.lockedIcon = lockedIcon
        self.title = title
    }
    
    var textFieldConfiguration: TextFieldConfiguration
    
    init(title: String, configuration: TextFieldConfiguration) {
        self.title = title
        self.textFieldConfiguration = configuration
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        if #available(iOS 15.0, *) {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .foregroundColor(Color(textFieldConfiguration.placeholderForegroundColor))
                        .font(Font(textFieldConfiguration.textFont))
                    
                    if let lockedIcon {
                        lockedIcon
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
                
                configuration
                    .foregroundColor(Color(textFieldConfiguration.textColor))
                    .font(Font(textFieldConfiguration.textFont))
            }
            .padding(.horizontal, 8.0)
            .frame(height: 56.0)
            .overlay {
                RoundedRectangle(cornerRadius: textFieldConfiguration.cornerRadius,
                                 style: .continuous)
                .stroke(Color(textFieldConfiguration.borderColor),
                        lineWidth: textFieldConfiguration.borderWidth)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
