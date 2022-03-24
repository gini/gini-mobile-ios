//
//  ButtonsSheetView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import SwiftUI

struct ButtonsSheetView: View {

    var viewModel: ButtonSheetViewModel

    var body: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.buttonViewModels, id: \.id) { buttonViewModel in
                HStack {
                    Image(buttonViewModel.iconName)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(buttonViewModel.title)
                            .font(Style.appFont(style: .medium))
                            .foregroundColor(.gray)
                        if buttonViewModel.belowTreshold {
                            HStack {
                                Image("exclamation_icon")
                                Text(buttonViewModel.description)
                                    .font(Style.appFont(12))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text(buttonViewModel.description)
                                .font(Style.appFont(12))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }.onTapGesture {
                    viewModel.didTapAction(withIndex: viewModel.buttonViewModels.firstIndex(of: buttonViewModel))
                }
            }
        }.padding()
    }
}

struct ButtonsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsSheetView(viewModel: ButtonSheetViewModel())
    }
}
