//
//  CustomCameraBottomNavigationBar.swift
//  GiniBankSDKExample
//
//  Created by Krzysztof Kryniecki on 10/11/2022.
//

import Foundation
import UIKit

class CustomCameraBottomNavigationBar: UIView {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.gray
    }
}
