//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

extension UIView {
    var currentInterfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13, *) {
            return window?.windowScene?.interfaceOrientation ?? UIApplication.shared.statusBarOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
