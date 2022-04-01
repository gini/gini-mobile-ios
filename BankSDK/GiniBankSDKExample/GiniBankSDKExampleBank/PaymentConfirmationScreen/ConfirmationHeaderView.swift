//
//  ConfirmationHeaderView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI

struct ConfirmationHeaderView: View {
    var invoiceTitle: String

    var body: some View {
        HStack {
            Image("confirmation_icon")
                .padding()

            VStack(alignment: .leading, spacing: 6) {
                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.transfer.status", comment:"success"))
                    .foregroundColor(Style.confirmationTextColor)
                    .fontWeight(.semibold)

                Text(NSLocalizedString("ginipaybank.paymentconfirmationscreen.transfer.to", comment: "to") + " \(invoiceTitle)")
            }

            Spacer()
        }
        .background(.white)
        .cornerRadius(8)
    }
}

struct ConfirmationHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ConfirmationHeaderView(invoiceTitle: "Maria")
                .padding()
        }.background(.black)
    }
}
