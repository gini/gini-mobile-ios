//
//  EstimatedView.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import UIKit

struct EstimatedView: View {
    var body: some View {
        HStack {
            Text(NSLocalizedString("ginipaybank.paymentscreen.payment.estimated.title", comment: "estimated arrival"))
                .foregroundColor(.gray)

            Spacer()

            Text(NSLocalizedString("ginipaybank.paymentscreen.payment.estimated.value", comment: "tomorrow"))
        }
        .padding()
        .background(.white)
        .cornerRadius(8)
    }
}

struct EstimatedView_Previews: PreviewProvider {
    static var previews: some View {
        EstimatedView()
    }
}
