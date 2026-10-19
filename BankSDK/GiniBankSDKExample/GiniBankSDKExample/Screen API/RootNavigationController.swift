//
//  RootNavigationController.swift
//  Example Swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 This wraps up the Screen API in a UINavigationController,
 to make the transition to the results screen (external screen) easier.
 This is only used as an example and is not mandatory to implement, it depends
 on how the Screen API and further screens are shown.
 */

final class RootNavigationController: UINavigationController {
    override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .portrait
    }
}
