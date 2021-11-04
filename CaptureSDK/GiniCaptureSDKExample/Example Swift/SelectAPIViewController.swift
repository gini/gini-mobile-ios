//
//  ScreenAPIViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import GiniCaptureSDK
import UIKit

protocol SelectAPIViewControllerDelegate: AnyObject {
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniCaptureAPIType)
    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ())
}

/**
 Integration options for Gini Capture SDK.
 */
enum GiniCaptureAPIType {
    case screen
    case component
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    @IBOutlet var metaInformationButton: UIButton!

    weak var delegate: SelectAPIViewControllerDelegate?

    var clientId: String?

    // MARK: View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let metaTitle = "Gini Capture SDK: (\(GiniCapture.versionString)) / Client id: \(clientId ?? "")"
        metaInformationButton.setTitle(metaTitle, for: .normal)
    }

    // MARK: User interaction

    @IBAction func launchScreenAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .screen)
    }

    @IBAction func launchComponentAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .component)
    }

    @IBAction func launchSettings(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didTapSettings: ())
    }
}
