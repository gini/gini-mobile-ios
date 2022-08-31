//
//  OnboardingBottomNavigationBar.swift
//  
//
//  Created by Nadya Karaban on 23.05.22.
//

import Foundation
import UIKit

final class OnboardingBottomNavigationBar: UIView {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var getStarted: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared
    }
}
