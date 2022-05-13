//
//  AppointmentView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import SwiftUI

struct AppointmentView: View {
    var appointmentViewModel: AppointmentViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(appointmentViewModel.type.stringValue)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background(Color.black)
                .cornerRadius(16)

            Text(appointmentViewModel.title)
                .font(Style.appFont(style: .medium))

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appointmentViewModel.appointmentDay)
                        .font(Style.appFont(12))
                        .foregroundColor(
                            AppointmentType.treatment == appointmentViewModel.type ?  Style.AppointmentView.treatmentTextColor : Style.AppointmentView.consultationTextColor
                        )
                    Text(appointmentViewModel.appointmentHour)
                        .font(Style.appFont(style: .semiBold))
                }

                Spacer()

                Image("icon_location")
                Image("icon_phone")
            }

        }
        .padding()
        .background(AppointmentType.treatment == appointmentViewModel.type ?  Style.AppointmentView.treatmentBackgroundColor : Style.AppointmentView.consultationBackgroundColor)
        .cornerRadius(16)
        .aspectRatio(0.9, contentMode: .fill)
    }
}

struct AppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentView(appointmentViewModel: AppointmentViewModel(type: .consultation,
                                                                   title: "Prophylaxe - Dr. Thomas Schuster",
                                                                   appointmentDay: "Today",
                                                                   appointmentHour: "16:45"))
    }
}
