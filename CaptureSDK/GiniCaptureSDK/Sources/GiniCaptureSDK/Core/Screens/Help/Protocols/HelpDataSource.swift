//
//  HelpDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 23/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

protocol HelpDataSource: UITableViewDelegate, UITableViewDataSource {
    init(
        configuration: GiniConfiguration
    )
}
