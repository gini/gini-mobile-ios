//
//  DocumentPagesViewModelProtocol.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol DocumentPagesViewModelProtocol {
    var rightBarButtonAction: (() -> Void)? { get }
    var bottomInfoItems: [String] { get }

    func imagesForDisplay() -> [UIImage]
}
