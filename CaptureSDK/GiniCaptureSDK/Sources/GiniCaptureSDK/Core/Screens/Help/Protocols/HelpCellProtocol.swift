//
//  HelpCellProtocol.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

public protocol HelpCell: UITableViewCell {
    static var reuseIdentifier: String { get }
}
