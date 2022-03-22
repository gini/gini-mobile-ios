//
//  HomeScreenViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import Foundation

struct HomeScreenViewModel {

    // MARK: - Overview section

    var overviewSectionTitle = "Overview"
    var tresholdTitle = "You are close to the threshold!"

    var ammount = "€8,970.26"
    var tresholdAmmount = " / €11,500.00"

    var notificationIcon = "bell_icon"
    var infoIcon = "info_icon"
    var progressIcon = "progress"

    // MARK: - Appointments section

    var appointmentSectionTitle = "Upcoming appointments"
    var allAppointmentsTitle = "See all"

    var appointments: [AppointmentViewModel] = [
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
                             appointmentDay: "6th August",
                             appointmentHour: "08:15"),
        AppointmentViewModel(type: .treatment,
                             title: "Pediatry - Saint Ludovic Hospital",
                             appointmentDay: "15th September",
                             appointmentHour: "13:00")]

    // MARK: - Services section
    
    var servicesSectionTitle = "Our services"

    let serviceViewModels: [ServiceViewModel] = [
        ServiceViewModel(title: "Medical treatments", description: "A detailed summary of a patient’s disease, the type of treatment ...", iconName: "doctor"),
        ServiceViewModel(title: "Naturopathy", description: "Naturopathy is a form of healthcare that combines modern treatment...", iconName: "grass")
    ]
}
