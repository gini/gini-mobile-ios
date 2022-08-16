//
//  OnboardingBottomNavigationBar.swift
//  
//
//  Created by Nadya Karaban on 23.05.22.
//

import Foundation
import UIKit

final class OnboardingBottomNavigationBar: UIView {
        
    var didTapBackButton: (() -> Void) = {}
    var didTapForwardButton: (() -> Void) = {}

    @IBOutlet weak var nextButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        print("nextButtonClicked")
    }
    
    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared
    }
    
    
    
}
