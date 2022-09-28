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
        self.titleLabel?.text = NSLocalizedStringPreferredFormat("ginicapture.multipagereview.secondaryButtonTitle",
                                                                 comment: "Add pages button title")
        self.imageView?.image = UIImageNamedPreferred(named: "plus_icon")
        let configuration = GiniConfiguration.shared
        titleLabel?.font = configuration.textStyleFonts[.footnote]
    }
}
