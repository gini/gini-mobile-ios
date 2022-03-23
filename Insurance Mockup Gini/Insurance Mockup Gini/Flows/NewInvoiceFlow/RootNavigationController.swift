//
//  RootNavigationController.swift
//  GiniCaptureExample
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini. All rights reserved.
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
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(true, animated: animated)
    }
}
