//
//  ErrorHeader.swift
//  GiniCapture
//
//  Created by Krzysztof Kryniecki on 22/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

class ErrorHeader: UIView {
    static var reuseIdentifier: String = "kErrorHeader"
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
}
