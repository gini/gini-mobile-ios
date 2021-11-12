//
//  ScreenAPIViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniHealthSDK

protocol SelectAPIViewControllerDelegate: AnyObject {
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniCaptureAPIType)
}

/**
 Integration options for Gini Capture SDK.
 */
enum GiniCaptureAPIType {
    case screen
    case component
    case paymentReview
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var startWithTestDocumentButton: UIButton!
    @IBOutlet weak var startWithGiniCaptureButton: UIButton!
    
    weak var delegate: SelectAPIViewControllerDelegate?
        
    var clientId: String?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let metaTitle = "Gini Capture SDK: (\(GiniCapture.versionString)) / Client id: \(self.clientId ?? "")"
        metaInformationButton.setTitle(metaTitle, for: .normal)
    }
    
    // MARK: User interaction

    @IBAction func launchComponentAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .component)
    }
    
    @IBAction func launchPaymentReview(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .paymentReview)
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.startWithGiniCaptureButton.isEnabled = false
            self.startWithTestDocumentButton.isEnabled = false
            self.metaInformationButton.isEnabled = false
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.startWithGiniCaptureButton.isEnabled = true
            self.startWithTestDocumentButton.isEnabled = true
            self.metaInformationButton.isEnabled = true
        }
    }
    
}
