//
//  ServiceView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import SwiftUI

struct ServiceView: View {
    var serviceViewModel: ServiceViewModel

    var body: some View {
        HStack {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Style.ServiceView.backgroundColor)
                        .padding()
                        .aspectRatio(1, contentMode: .fit)
                    Image(serviceViewModel.iconName)
                        .offset(x: 0, y: -10)
                }
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    Text(serviceViewModel.title)
                        .font(Style.appFont(style: .semiBold))
                    Text(serviceViewModel.description)
                        .font(Style.appFont(14))
                }.padding([.leading, .trailing])
            }.overlay(
                RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)
                    )
        }
    }
}

struct ServiceView_Previews: PreviewProvider {
    static var previews: some View {
        let serviceViewModel = ServiceViewModel(title: "Medical treatments", description: "A detailed summary of a patient’s disease, the type of treatment ...", iconName: "doctor")
        HStack {
            Spacer()
            ServiceView(serviceViewModel: serviceViewModel)
            Spacer()
        }
    }
}
