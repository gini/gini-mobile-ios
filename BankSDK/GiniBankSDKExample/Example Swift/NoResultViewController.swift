//
//  ViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit

protocol NoResultsScreenDelegate: AnyObject {
    func noResults(viewController: NoResultViewController, didTapRetry:())
}

final class NoResultViewController: UIViewController {
    
    @IBOutlet var rotateImageView: UIImageView!
    weak var delegate: NoResultsScreenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rotateImageView.image = rotateImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    @IBAction func retry(_ sender: AnyObject) {
        delegate?.noResults(viewController: self, didTapRetry: ())
    }
}

