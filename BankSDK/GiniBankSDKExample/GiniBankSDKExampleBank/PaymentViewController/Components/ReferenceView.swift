//
//  ReferenceView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI

struct ReferenceView: View {
    @Binding var referenceString: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.payment.reference.key", comment: "reference"))
                        .foregroundColor(.gray)

                    Spacer()

                    Text(NSLocalizedString("ginipaybank.paymentscreen.payment.edit.button", comment: "edit"))
                        .foregroundColor(.gray)
                }

                TextField(NSLocalizedString("ginipaybank.paymentscreen.payment.reference.key", comment: "reference"), text: $referenceString)
                    .multilineTextAlignment(.leading)
            }.padding()

            Spacer()
        }
        .background(.white)
        .cornerRadius(8)
    }
}

struct ReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        ReferenceView(referenceString: .constant("4567890"))
    }
}
