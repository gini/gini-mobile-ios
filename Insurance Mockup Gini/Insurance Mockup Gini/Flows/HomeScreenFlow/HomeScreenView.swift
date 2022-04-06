//
//  HomeScreenView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import SwiftUI

struct HomeScreenView: View {
    @ObservedObject private var viewModel = HomeScreenViewModel()
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack(spacing: 16) {
                Text(viewModel.overviewSectionTitle)
                    .font(Style.appFont(style: .bold, 20))
                Spacer()
                Image(viewModel.notificationIcon)
                Image(viewModel.infoIcon)
                    .onTapGesture {
                        withAnimation {
                            viewModel.tresholdStatus.toggle()
                        }
                    }
            }.padding([.top, .bottom])

            TresholdView(viewModel: viewModel)

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

struct TresholdView: View {
    @ObservedObject var viewModel: HomeScreenViewModel
    var body: some View {
        HStack {
            switch viewModel.tresholdStatus {
            case .below:
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
            case .submit:
                VStack {
                    HStack {
                        Text(viewModel.tresholdTitleSubmit)
                            .font(Style.appFont(style: .bold, 24))
                        Spacer()
                    }

                    Rectangle().fill(Color.gray).frame(height: 1, alignment: .center).padding([.leading, .trailing], -16)
                        .opacity(0.5)

                    VStack {
                        HStack {
                            Text(NSLocalizedString("giniinsurancemock.homescreen.treshold.description.documents.to.submit", comment: ""))
                                .font(Style.appFont(style: .medium, 16))
                            Spacer()
                        }

                        HStack(spacing: 8) {
                            Button(action: {

                            }) {
                                HStack {
                                    Spacer()
                                    Text(NSLocalizedString("giniinsurancemock.homescreen.treshold.button.showall", comment: "continue"))
                                        .foregroundColor(Style.NewInvoice.accentBlue)
                                        .padding(12)
                                        .font(Style.appFont(style: .semiBold, 16))
                                    Spacer()
                                }
                                .background(Style.NewInvoice.secondaryBlue)
                                .cornerRadius(16)
                            }

                            Button(action: {

                            }) {
                                HStack {
                                    Spacer()
                                    Text(NSLocalizedString("giniinsurancemock.homescreen.treshold.button.submit", comment: "continue"))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .font(Style.appFont(style: .semiBold, 16))
                                    Spacer()
                                }
                                .background(Style.NewInvoice.accentBlue)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.top, 6)
                }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray, lineWidth: 1)
                .opacity(0.5)
        )
        .background(
            VStack {
                if viewModel.tresholdStatus == .submit {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white, lineWidth: 1)
                        .background(Color.white)
                        .cornerRadius(24)
                    .opacity(0.5)

                    VStack {
                        Rectangle()
                            .stroke(Style.buttonContainerColor, lineWidth: 1)
                            .background(Style.buttonContainerColor)
                            .padding(.top, -12)
                            .padding(.bottom, -30)

                        Rectangle()
                            .stroke(Style.buttonContainerColor, lineWidth: 1)
                            .background(Style.buttonContainerColor)
                            .cornerRadius(24)
                            .padding(.top, -12)
                    }
                }
            }
        )
    }
}
