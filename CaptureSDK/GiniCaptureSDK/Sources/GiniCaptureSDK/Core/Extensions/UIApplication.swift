//
//  UIApplication.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

extension UIApplication {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if self.canOpenURL(settingsUrl) {
            self.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }

    var hasNotch: Bool {
        UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
}
