//
//  AddPageButtonView.swift
//  
//
//  Created by David Vizaknai on 15.09.2022.
//

import UIKit

final class AddPageButtonView: UIView {

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var imageView: UIImageView?

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.text = "Pages"
        self.imageView?.image = UIImageNamedPreferred(named: "plus_icon")?.tintedImageWithColor(
            GiniColor(light: UIColor.GiniCapture.dark2, dark: UIColor.GiniCapture.light2).uiColor())
        let configuration = GiniConfiguration.shared
        titleLabel?.font = configuration.textStyleFonts[.footnote]
    }
}
