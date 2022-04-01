//
//  ConfirmationView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 30.03.2022.
//

import SwiftUI

struct ConfirmationView: View {
    var viewModel: ConfirmationViewModel
    var body: some View {
        VStack {
            Spacer()
            Image(viewModel.imageName)
                .padding()
            Text(viewModel.title)
                .font(Style.appFont(style: .bold, 20))
            Text(viewModel.description)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            Button(action: {
                viewModel.didTapContinue()
            }) {
                HStack {
                    Spacer()
                    Text(NSLocalizedString("giniinsurancemock.continue.button.title", comment: "continue"))
                        .foregroundColor(.white)
                        .padding()
                        .font(Style.appFont(style: .semiBold, 16))
                    Spacer()
                }
                .background(Style.NewInvoice.accentBlue)
                .cornerRadius(16)
                .padding()
            }
        }.padding()
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(viewModel: ConfirmationViewModel(type: .save))
    }
}
