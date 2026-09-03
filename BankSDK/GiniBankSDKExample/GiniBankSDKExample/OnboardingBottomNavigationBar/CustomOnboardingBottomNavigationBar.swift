//
//  CustomOnboardingNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 27/10/2022.
//

import UIKit

class CustomOnboardingBottomNavigationBar: UIView {

    @IBOutlet weak var nextButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.gray
    }
}
