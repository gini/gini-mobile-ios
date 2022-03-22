//
//  AppointmentViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import Foundation

enum AppointmentType: String {
    case consultation = "Consultation"
    case treatment = "Treatment"
}

struct AppointmentViewModel {
    var id: String = UUID().uuidString
    var type: AppointmentType
    var title: String
    var appointmentDay: String
    var appointmentHour: String
}
