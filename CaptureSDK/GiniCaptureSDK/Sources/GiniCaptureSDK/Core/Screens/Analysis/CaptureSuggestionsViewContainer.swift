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
    private var accessibilityImageDescription: String? {
        didSet {
            imageView.accessibilityLabel = accessibilityImageDescription
        }
    }

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = false
        imageView.accessibilityTraits = .image
        imageView.isAccessibilityElement = true
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.isAccessibilityElement = true
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.isAccessibilityElement = true
        accessibilityElements = [imageView as Any, titleLabel as Any, descriptionLabel as Any]
        configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared

        backgroundColor = UIColor.GiniCapture.systemGray05
        layer.cornerRadius = 16

        titleLabel.font = configuration.textStyleFonts[.calloutBold]
        titleLabel.textColor = UIColor.GiniCapture.label

        descriptionLabel.font = configuration.textStyleFonts[.subheadline]
        descriptionLabel.textColor = UIColor.GiniCapture.systemGray
    }

    func configureContent(with image: UIImage?, title: String, description: String) {
        self.imageView.image = image
        self.titleLabel.text = title
        self.titleLabel.accessibilityValue = title
        self.descriptionLabel.text = description
        self.descriptionLabel.accessibilityValue = description
        self.accessibilityImageDescription = description
    }
}
