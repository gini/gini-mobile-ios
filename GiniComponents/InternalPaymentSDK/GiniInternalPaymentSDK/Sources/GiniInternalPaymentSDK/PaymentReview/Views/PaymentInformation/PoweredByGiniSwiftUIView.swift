//
//  PoweredByGiniSwiftUIView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import SwiftUI

struct PoweredByGiniSwiftUIView: View {
    
    private let viewModel: PoweredByGiniViewModel
    
    init(viewModel: PoweredByGiniViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: Constants.spacingImageText) {
            Text(viewModel.strings.poweredByGiniText)
                .font(Font(viewModel.configuration.poweredByGiniLabelFont))
                .foregroundStyle(Color(viewModel.configuration.poweredByGiniLabelAccentColor))
                .lineLimit(Constants.textNumberOfLines)
                .minimumScaleFactor(Constants.minimumScaleFactor)
            
            Image(uiImage: viewModel.configuration.giniIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.widthGiniLogo,
                       height: Constants.heightGiniLogo)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.strings.poweredByGiniText + "Gini")
    }
    
    private struct Constants {
        static let spacingImageText: CGFloat = 4.0
        static let widthGiniLogo: CGFloat = 28.0
        static let heightGiniLogo: CGFloat = 18.0
        static let textNumberOfLines = 1
        static let minimumScaleFactor = 0.5
    }
}
