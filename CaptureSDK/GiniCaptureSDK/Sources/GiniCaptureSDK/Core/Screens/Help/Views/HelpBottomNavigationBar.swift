//
//  HelpBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit

class HelpBottomNavigationBar: UIView {

    @IBOutlet weak var backButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        let configuration = GiniConfiguration.shared
        backButton.setTitle("", for: .normal)
        backButton.setImage(
            UIImageNamedPreferred(named: "arrowBack") ?? UIImage(),
            for: .normal)
        backgroundColor = GiniColor(
            light: UIColor.GiniCapture.dark2,
            dark: UIColor.GiniCapture.dark2
        ).uiColor()
    }
}
