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

        backgroundColor = UIColorPreferred(named: "systemGray05")
        layer.cornerRadius = 16

        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = configuration.customFont.with(weight: .bold, size: 16, style: .body)
        titleLabel.textColor = UIColorPreferred(named: "label")

        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = configuration.customFont.with(weight: .regular, size: 15, style: .body)
        descriptionLabel.textColor = UIColorPreferred(named: "systemGray")
    }

    func configureContent(with image: UIImage?, title: String, description: String) {
        self.imageView.image = image
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}
