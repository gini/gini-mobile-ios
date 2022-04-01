//
//  BeneficiaryBankDetailView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import UIKit

struct BeneficiaryBankDetailView: View {
    @Binding var paymentTitle: String
    @Binding var iban: String

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(NSLocalizedString("ginipaybank.paymentscreen.payment.adreess.key", comment: "to"))
                        .foregroundColor(.gray)

                    Spacer()

                    TextField(NSLocalizedString("ginipaybank.paymentscreen.payment.adress.placeholder", comment: "payment adress"), text: $paymentTitle)
                        .multilineTextAlignment(.trailing)
                }.padding(.top, 6)

                HStack {
                    Text(NSLocalizedString("ginipaybank.reviewscreen.iban.placeholder", comment: "iban"))
                        .foregroundColor(.gray)

                    Spacer()

                    TextField(NSLocalizedString("ginipaybank.reviewscreen.iban.placeholder", comment: "iban"), text: $iban)
                        .multilineTextAlignment(.trailing)
                }.padding(.bottom, 6)
            }.padding()
        }
        .background(.white)
        .cornerRadius(8)
    }
}

struct BeneficiaryBankDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BeneficiaryBankDetailView(paymentTitle: .constant("hfcgjfgkjxm"), iban: .constant("kfkjhvcke"))
    }
}
