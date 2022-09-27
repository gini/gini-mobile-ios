//
//  ScreenApiViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import Foundation
import UIKit
import GiniCaptureSDK
import GiniBankSDK

protocol SelectAPIViewControllerDelegate: AnyObject {
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniPayBankApiType)
    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ())
}

/**
 Integration options for Gini Capture SDK.
 */
enum GiniPayBankApiType {
    case screen
    case component
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationButton: UIButton!
    
    weak var delegate: SelectAPIViewControllerDelegate?
        
    var clientId: String?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let metaTitle = "Gini Bank SDK: (\(GiniBankSDKVersion)) / Gini Capture SDK: (\(GiniCaptureSDKVersion)) / Client id: \(self.clientId ?? "")"
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
