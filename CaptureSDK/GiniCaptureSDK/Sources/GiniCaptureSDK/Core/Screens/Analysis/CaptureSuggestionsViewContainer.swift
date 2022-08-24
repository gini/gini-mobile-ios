//
//  CaptureSuggestionsViewContainer.swift
//  
//
//  Created by David Vizaknai on 23.08.2022.
//

import UIKit

final class CaptureSuggestionsViewContainer: UIView {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared

        backgroundColor = UIColor.Gini.systemGray05
        layer.cornerRadius = 16

        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = configuration.textStyleFonts[.callout]?.bold()
        titleLabel.textColor = UIColor.Gini.label

        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = configuration.textStyleFonts[.subheadline]
        descriptionLabel.textColor = UIColor.Gini.systemGray
    }

    func configureContent(with image: UIImage?, title: String, description: String) {
        self.imageView.image = image
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}
