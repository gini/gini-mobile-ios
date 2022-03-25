//
//  InvoiceItemCell.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import SwiftUI

struct InvoiceItemCell: View {
    var body: some View {
        HStack {
            Image("icon_dentist")

            VStack(alignment: .leading) {
                Text("Doctor")
                HStack {
                    Text("Sent")
                        .font(Style.appFont(12))
                    Text("Paid")
                        .font(Style.appFont(12))
                }
            }

            Spacer()

            Text("145 EUR")
        }
    }
}

struct InvoiceItemCell_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceItemCell()
    }
}
