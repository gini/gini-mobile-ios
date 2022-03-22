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
            Text(appointmentViewModel.type.rawValue)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background(Color.black)
                .cornerRadius(16)

            Text(appointmentViewModel.title)
                .fontWeight(.semibold)
                .font(.system(size: 16))

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appointmentViewModel.appointmentDay)
                        .font(.system(size: 12))
                        .foregroundColor(
                            AppointmentType.treatment == appointmentViewModel.type ?  Style.AppointmentView.treatmentTextColor : Style.AppointmentView.consultationTextColor
                        )
                    Text(appointmentViewModel.appointmentHour)
                        .font(.system(size: 16))
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

var appointments = [
    AppointmentViewModel(type: .consultation,
                         title: "Prophylaxis - Dr. Thomas Schuster",
                         appointmentDay: "Today",
                         appointmentHour: "16:45"),
    AppointmentViewModel(type: .treatment,
                         title: "Aromatic Pediatry - Saint Ludovic Hospital",
                         appointmentDay: "Tomorrow",
                         appointmentHour: "12:30"),
    AppointmentViewModel(type: .consultation,
                         title: "Prophylaxis - Dr. Thomas Schuster",
                         appointmentDay: "Today",
                         appointmentHour: "16:45"),
    AppointmentViewModel(type: .treatment,
                         title: "Aromatic Pediatry - Saint Ludovic Hospital",
                         appointmentDay: "Tomorrow",
                         appointmentHour: "12:30")
]

struct AppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentView(appointmentViewModel: AppointmentViewModel(type: .consultation,
                                                                   title: "Prophylaxis - Dr. Thomas Schuster",
                                                                   appointmentDay: "Today",
                                                                   appointmentHour: "16:45"))
    }
}
