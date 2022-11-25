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

        DispatchQueue.main.async {
            self.titleLabel.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        }
    }
}
