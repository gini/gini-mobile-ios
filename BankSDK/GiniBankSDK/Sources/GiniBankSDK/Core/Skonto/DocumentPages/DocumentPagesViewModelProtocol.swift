//
//  DocumentPagesViewModelProtocol.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol DocumentPagesViewModelProtocol {
    var processedImages: [UIImage] { get }
    var bottomInfoItems: [String] { get }
    
    func processImages() -> [UIImage]
}

extension DocumentPagesViewModelProtocol {
    func processImages() -> [UIImage] { return [] }
}
