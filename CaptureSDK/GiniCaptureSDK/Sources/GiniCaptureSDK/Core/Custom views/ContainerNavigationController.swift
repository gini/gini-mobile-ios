//
//  ContainerNavigationController.swift
//  GiniCaptureExample
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

/**
 Container that wraps a UINavigationController in order to handle rotation.
 The parent coordinator should be always `nil` excepts when there is no possibility
 to keep a strong reference outside of the Gini Capture SDK.
 */
final class ContainerNavigationController: UIViewController {

    var rootViewController: UINavigationController
    var coordinator: Coordinator?
    var giniConfiguration: GiniConfiguration

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isIpad ? .all : .all
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniConfiguration.statusBarStyle
    }

    init(rootViewController: UINavigationController,
         parent: Coordinator? = nil,
         giniConfiguration: GiniConfiguration = GiniConfiguration.shared) {
        self.rootViewController = rootViewController
        self.coordinator = parent
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(rootViewController:parent:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = rootViewController.navigationBar.backgroundColor
        addChild(rootViewController)
        view.addSubview(rootViewController.view)
        rootViewController.willMove(toParent: self)
        rootViewController.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootViewController.view.frame = self.view.bounds
    }
}
