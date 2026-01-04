//
//  GiniTextFieldStyle.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct GiniTextFieldStyle: TextFieldStyle {
    
    @State var lockedIcon: Image?
    @State var title: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        if #available(iOS 15.0, *) {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                    
                    if lockedIcon != nil {
                        lockedIcon!
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
                
                configuration
            }
            .padding(.horizontal, 8.0)
            .frame(height: 56.0)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                    .stroke(Color(.secondarySystemBackground), lineWidth: 1.0)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
