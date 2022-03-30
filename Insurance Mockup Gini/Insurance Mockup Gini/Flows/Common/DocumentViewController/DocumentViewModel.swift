//
//  DocumentViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 30.03.2022.
//

import Foundation
import SwiftUI

protocol DocuementViewModelDelegate: AnyObject {
    func didTapClose()
}

final class DocuementViewModel {
    var image: Image

    init(image: Image = Image("invoice1")) {
        self.image = image
    }
    weak var delegate: DocuementViewModelDelegate?

    func didTapClose() {
        delegate?.didTapClose()
    }
}
