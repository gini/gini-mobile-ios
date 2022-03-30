//
//  InvoiceFilterItemView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import SwiftUI

struct InvoiceFilterItemView: View {
    var text: String
    var count: Int?
    var isSelected: Bool

    var body: some View {
        HStack {
            VStack(spacing: 4) {
                HStack {
                    Text(text)
                        .font(Style.appFont(style: .semiBold, 14))
                        .foregroundColor(isSelected ? Color.black : Color.gray)
                        .padding(.bottom, 3)

                    if let count = count, count > 0 {
                        Text("(\(count))")
                            .font(Style.appFont(style: .semiBold, 14))
                            .foregroundColor(isSelected ? Color.black : Color.gray)
                            .padding(.bottom, 3)
                    }
                }

                if isSelected {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 3)
                }
            }
        }
    }
}

struct InvoiceFilterItemView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceFilterItemView(text: "Unpaid", isSelected: false)
    }
}
