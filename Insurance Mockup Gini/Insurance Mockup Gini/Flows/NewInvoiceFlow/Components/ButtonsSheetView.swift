//
//  ButtonsSheetView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import SwiftUI

struct ButtonSheetViewModel {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var iconName: String
    var belowTreshold: Bool
}

var buttonList: [ButtonSheetViewModel] = [
    ButtonSheetViewModel(title: "Pay and save",
                         description: "Pay and save the invoice",
                         iconName: "pay_save_icon",
                         belowTreshold: false),
    ButtonSheetViewModel(title: "Pay & submit for reimbursement",
                         description: "You are below the threshold",
                         iconName: "pay_submit_icon",
                         belowTreshold: true),
    ButtonSheetViewModel(title: "Submit for reimbursement",
                         description: "You are below the threshold",
                         iconName: "submit_icon",
                         belowTreshold: true),
    ButtonSheetViewModel(title: "Save for later",
                         description: "You can always come back to it later",
                         iconName: "save_icon",
                         belowTreshold: false)]

struct ButtonsSheetView: View {
    var body: some View {
        VStack(spacing: 20) {
            ForEach(buttonList, id: \.id) { buttonViewModel in
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
                }
            }
        }.padding()
    }
}

struct ButtonsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsSheetView()
    }
}
