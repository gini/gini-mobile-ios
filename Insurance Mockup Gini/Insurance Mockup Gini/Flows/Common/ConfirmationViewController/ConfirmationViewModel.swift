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

    init(type: ConfirmationType) {
        switch type {
        case .reimbursment:
            self.title = "Document submitted"
            self.description = "Your document has been submitted for. We will process it as soon as possible."
            self.imageName = "sent_icon"
        case .save:
            self.title = "Document saved"
            self.description = "We will store your health document until you decide you want to submit it to the insurer."
            self.imageName = "saved_icon"
        }
    }

    weak var delegate: ConfirmationViewModelDelegate?

    func didTapContinue() {
        delegate?.didTapContinue()
    }
}
