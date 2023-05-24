//
//  RootNavigationController.swift
//  GiniHealthSDKExample
//
//  Created by Nadya Karaban on 22.05.23.
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
}
