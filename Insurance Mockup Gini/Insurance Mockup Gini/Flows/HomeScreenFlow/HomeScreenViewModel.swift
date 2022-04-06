//
//  HomeScreenViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import Foundation

enum TresholdStatus {
    case below, submit

    mutating func toggle() {
        switch self {
        case .below:
            self = .submit
        case .submit:
            self = .below
        }
    }
}

class HomeScreenViewModel: ObservableObject {

    // MARK: - Overview section

    @Published var tresholdStatus: TresholdStatus = .below

    var overviewSectionTitle = NSLocalizedString("giniinsurancemock.homescreen.title", comment: "")
    var tresholdTitle = NSLocalizedString("giniinsurancemock.homescreen.treshold.description", comment: "")
    var tresholdTitleSubmit = NSLocalizedString("giniinsurancemock.homescreen.treshold.description.submit", comment: "")

    var ammount = "€1,248.00"
    var tresholdAmmount = " / €1,600.00"

    var notificationIcon = "bell_icon"
    var infoIcon = "info_icon"
    var progressIcon = "progress"

    // MARK: - Appointments section

    var appointmentSectionTitle = NSLocalizedString("giniinsurancemock.homescreen.appointments.upcoming", comment: "")
    var allAppointmentsTitle = NSLocalizedString("giniinsurancemock.homescreen.appointments.seeall", comment: "")

    var appointments: [AppointmentViewModel] = [
        AppointmentViewModel(type: .consultation,
                             title: "Prophylaxis - Dr. Thomas Schuster",
                             appointmentDay: NSLocalizedString("giniinsurancemock.homescreen.today", comment: ""),
                             appointmentHour: "16:45"),
        AppointmentViewModel(type: .treatment,
                             title: "Aromatic Pediatry - Saint Ludovic Hospital",
                             appointmentDay: NSLocalizedString("giniinsurancemock.homescreen.tomorrow", comment: ""),
                             appointmentHour: "12:30"),
        AppointmentViewModel(type: .consultation,
                             title: "Prophylaxis - Dr. Thomas Schuster",
                             appointmentDay: String(format: NSLocalizedString("giniinsurancemock.homescreen.appointments.in.x.days", comment: ""), Int.random(in: (2..<8))),
                             appointmentHour: "08:15"),
        AppointmentViewModel(type: .treatment,
                             title: "Pediatry - Saint Ludovic Hospital",
                             appointmentDay: String(format: NSLocalizedString("giniinsurancemock.homescreen.appointments.in.x.days", comment: ""), Int.random(in: (9..<12))),
                             appointmentHour: "13:00")]

    // MARK: - Services section
    
    var servicesSectionTitle = NSLocalizedString("giniinsurancemock.homescreen.services", comment: "")

    let serviceViewModels: [ServiceViewModel] = [
        ServiceViewModel(title: NSLocalizedString("giniinsurancemock.homescreen.medical.treatments", comment: ""),
                         description: NSLocalizedString("giniinsurancemock.homescreen.medical.treatments.description", comment: ""),
                         iconName: "doctor"),
        ServiceViewModel(title: NSLocalizedString("giniinsurancemock.homescreen.medical.treatments.2", comment: ""),
                         description: NSLocalizedString("giniinsurancemock.homescreen.medical.treatments.2.description", comment: ""),
                         iconName: "grass")
    ]
}
