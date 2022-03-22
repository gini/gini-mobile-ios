//
//  HomeScreenView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import SwiftUI

struct HomeScreenView: View {
    private let viewModel = HomeScreenViewModel()
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack(spacing: 16) {
                Text(viewModel.overviewSectionTitle)
                    .font(Style.appFont(style: .bold, 20))
                Spacer()
                Image(viewModel.notificationIcon)
                Image(viewModel.infoIcon)
            }.padding([.top, .bottom])

            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.tresholdTitle)
                        .font(Style.appFont(style: .bold, 24))
                    Text(viewModel.ammount)
                        .font(Style.appFont(style: .semiBold, 14))
                        .foregroundColor(.gray)
                    + Text(viewModel.tresholdAmmount)
                        .font(Style.appFont(14))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(viewModel.progressIcon)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)
                    )

            HStack {
                Text(viewModel.appointmentSectionTitle)
                    .font(Style.appFont())
                Spacer()
                Text(viewModel.allAppointmentsTitle)
                    .font(Style.appFont())
                    .foregroundColor(.gray)
            }.padding([.top, .bottom])

            
            ScrollView (.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.appointments, id: \.id) { appointmentViewModel in
                                                AppointmentView(appointmentViewModel: appointmentViewModel)
                    }
                }
            }.frame(height: 185)

            HStack {
                Text(viewModel.servicesSectionTitle)
                    .font(Style.appFont())
                Spacer()
            }.padding([.top, .bottom])

            ForEach(viewModel.serviceViewModels, id: \.id) { serviceViewModel in
                                        ServiceView(serviceViewModel: serviceViewModel)
                    .frame(height: 130)
                    .padding(.bottom)
            }
        }.padding()

    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
