//
//  ScreenAPIViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniCaptureSDK

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
    case invoicesList
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet private weak var metaInformationButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var startWithTestDocumentButton: UIButton!
    @IBOutlet private weak var startWithGiniCaptureButton: UIButton!
    @IBOutlet private weak var invoicesListButton: UIButton!
    
    weak var delegate: SelectAPIViewControllerDelegate?
        
    var clientId: String?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let metaTitle = "Gini Capture SDK: (\(GiniCapture.versionString)) / Client id: \(self.clientId ?? "")"
        metaInformationButton.setTitle(metaTitle, for: .normal)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .whiteLarge
        }
    }
    
    // MARK: User interaction

    @IBAction func launchScreentAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .screen)
    }
    
    @IBAction func launchPaymentReview(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .paymentReview)
    }
    
    @IBAction func launchInvoicesList(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .invoicesList)
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
