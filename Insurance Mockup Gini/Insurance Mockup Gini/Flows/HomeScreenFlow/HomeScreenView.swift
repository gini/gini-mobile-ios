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
            HStack {
                Text(viewModel.overviewSectionTitle)
                    .font(Style.appFont(style: .bold, 20))
                Spacer()
                Image(systemName: viewModel.notificationIcon)
                Image(systemName: viewModel.infoIcon)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.tresholdTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(viewModel.ammount)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    + Text(viewModel.tresholdAmmount)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(viewModel.progressIcon)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.5)
                    )

            HStack {
                Text(viewModel.appointmentSectionTitle)
                Spacer()
                Text(viewModel.allAppointmentsTitle)
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
