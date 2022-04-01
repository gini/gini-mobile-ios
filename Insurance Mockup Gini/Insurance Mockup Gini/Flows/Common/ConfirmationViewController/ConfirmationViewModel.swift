//
//  ConfirmationViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 30.03.2022.
//

import Foundation

enum ConfirmationType {
    case reimbursment, save
}

protocol ConfirmationViewModelDelegate: AnyObject {
    func didTapContinue()
}

final class ConfirmationViewModel {
    var title: String
    var description: String
    var imageName: String

    var shouldDismiss: (() -> Void)?

    init(type: ConfirmationType) {
        switch type {
        case .reimbursment:
            self.title = NSLocalizedString("giniinsurancemock.confirmationscreen.sent.title", comment: "document sent")
            self.description = NSLocalizedString("giniinsurancemock.confirmationscreen.sent.description", comment: "description")
            self.imageName = "sent_icon"
        case .save:
            self.title = NSLocalizedString("giniinsurancemock.confirmationscreen.saved.title", comment: "title")
            self.description = NSLocalizedString("giniinsurancemock.confirmationscreen.saved.description", comment: "description")
            self.imageName = "saved_icon"
        }
    }

    weak var delegate: ConfirmationViewModelDelegate?

    func didTapContinue() {
        shouldDismiss?()
    }
}
