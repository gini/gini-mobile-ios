//
//  InvoiceIconView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 30.03.2022.
//

import SwiftUI

struct InvoiceIconView: View {
    var paid: Bool = true
    var iconName: String = "aperture_icon"
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(paid ? Style.InvoiceIcon.backgroundColorOn : Style.InvoiceIcon.backgroundColorOff)
            Image(iconName)
                .resizable()
                .padding(13)
                .foregroundColor(paid ? Style.InvoiceIcon.iconColorOn : Style.InvoiceIcon.iconColorOff)
        }
    }
}

struct InvoiceIconView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceIconView()
    }
}
