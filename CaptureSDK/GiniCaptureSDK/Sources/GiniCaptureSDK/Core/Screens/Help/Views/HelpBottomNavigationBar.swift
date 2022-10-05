//
//  HelpBottomNavigationBar.swift
//  
//
//  Created by Krzysztof Kryniecki on 04/10/2022.
//

import UIKit

public final class HelpBottomNavigationBar: UIView {

    @IBOutlet weak var backButton: UIButton!

    public override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
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
