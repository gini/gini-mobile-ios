//
//  AppointmentViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import Foundation

enum AppointmentType {
    case consultation
    case treatment

    var stringValue: String {
        switch self {
        case .consultation: return NSLocalizedString("giniinsurancemock.appointmenttype.consultation", comment: "")
        case .treatment: return NSLocalizedString("giniinsurancemock.appointmenttype.treatment", comment: "")
        }
    }
}

struct AppointmentViewModel {
    var id: String = UUID().uuidString
    var type: AppointmentType
    var title: String
    var appointmentDay: String
    var appointmentHour: String
}
