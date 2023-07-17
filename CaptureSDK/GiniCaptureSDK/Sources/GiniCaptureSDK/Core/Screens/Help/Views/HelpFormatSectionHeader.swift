//
//  HelpFormatSectionHeader.swift
//  
//
//  Created by Krzysztof Kryniecki on 12/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

final class HelpFormatSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    static var reuseIdentifier: String = "kHelpFormatSectionHeader"

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    func configureView() {
        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = .clear
            self.backgroundConfiguration = bgConfig
        }
    }
}
