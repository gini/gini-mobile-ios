//
//  ComponentAPIHelpViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 06/07/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import GiniCaptureSDK
import UIKit

/**
 View controller showing how to implement the onboarding screen
 using the Component API of the Gini Capture SDK for iOS.
 */
final class ComponentAPIOnboardingViewController: UIViewController {
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()

    // MARK: View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

//        // 1. Create the onboarding view controller
//        contentController = OnboardingViewController(scrollViewDelegate: nil)
//
//        // 2. Display the onboarding view controller
//        displayContent(contentController)
    }

    // Displays the content controller inside the container view
    func displayContent(_ controller: UIViewController) {
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    // MARK: User actions

    @IBAction func nextPage(_ sender: AnyObject) {
        // Scroll the onboarding to the next page.
       // (contentController as? OnboardingViewController)?.scrollToNextPage(true)
    }
}
