//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

extension UIView {
    var currentInterfaceOrientation: UIInterfaceOrientation {
        window?.windowScene?.interfaceOrientation ?? UIApplication.shared.statusBarOrientation
    }
}
