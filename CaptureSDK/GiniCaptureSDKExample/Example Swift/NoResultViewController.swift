//
//  NoResultViewController.swift
//  GiniCapture
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
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
