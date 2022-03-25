//
//  InvoiceFilterItemView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import SwiftUI

struct InvoiceFilterItemView: View {
    @State var selected = false
    var text: String

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text(text)
                    .font(Style.appFont(style: .semiBold, 14))
                    .foregroundColor(selected ? Color.black : Color.gray)
                    .padding(.bottom, 3)
                    .frame(maxWidth: .infinity)

                if selected {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 3)
                        .frame(maxWidth: .infinity)
                }
            }.fixedSize(horizontal: true, vertical: false)
            Spacer()
        }.onTapGesture {
            selected.toggle()
        }
    }
}

struct InvoiceFilterItemView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceFilterItemView(text: "Unpaid")
    }
}
