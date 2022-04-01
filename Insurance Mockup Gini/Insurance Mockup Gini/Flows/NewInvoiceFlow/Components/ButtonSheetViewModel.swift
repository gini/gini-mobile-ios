//
//  ButtonSheetViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import Foundation

protocol ButtonSheetViewModelDelegate: AnyObject {
    func didTapPayAndSave()
    func didTapPayAndSubmit()
    func didTapSubmit()
    func didTapSave()
}

class SheetButtonViewModel: Equatable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var iconName: String
    var belowTreshold: Bool

    init(title: String, description: String, iconName: String, belowTreshold: Bool) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.belowTreshold = belowTreshold
    }

    static func == (lhs: SheetButtonViewModel, rhs: SheetButtonViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}


class ButtonSheetViewModel {
    var buttonViewModels: [SheetButtonViewModel]
    weak var delegate: ButtonSheetViewModelDelegate?

    init() {
        buttonViewModels = [
            SheetButtonViewModel(title: NSLocalizedString("giniinsurancemock.bottomsheet.payandsave.title", comment: ""),
                                 description: NSLocalizedString("giniinsurancemock.bottomsheet.payandsave.description", comment: ""),
                                 iconName: "pay_save_icon",
                                 belowTreshold: false),
            SheetButtonViewModel(title: NSLocalizedString("giniinsurancemock.bottomsheet.payandsubmit.title", comment: ""),
                                 description: NSLocalizedString("giniinsurancemock.bottomsheet.payandsubmit.description", comment: ""),
                                 iconName: "pay_submit_icon",
                                 belowTreshold: true),
            SheetButtonViewModel(title: NSLocalizedString("giniinsurancemock.bottomsheet.submit.title", comment: ""),
                                 description: NSLocalizedString("giniinsurancemock.bottomsheet.submit.description", comment: ""),
                                 iconName: "submit_icon",
                                 belowTreshold: true),
            SheetButtonViewModel(title: NSLocalizedString("giniinsurancemock.bottomsheet.save.title", comment: ""),
                                 description: NSLocalizedString("giniinsurancemock.bottomsheet.save.description", comment: ""),
                                 iconName: "save_icon",
                                 belowTreshold: false)]

    }

    func didTapAction(withIndex index: Int?) {
        guard let index = index else { return }

        switch index {
        case 0: delegate?.didTapPayAndSave()
        case 1: delegate?.didTapPayAndSubmit()
        case 2: delegate?.didTapSubmit()
        case 3: delegate?.didTapSave()
        default: return
        }
    }
}
