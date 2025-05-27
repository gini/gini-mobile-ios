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
        configureAccessibility()
    }

    private func configureView() {
        let configuration = GiniConfiguration.shared

        backgroundColor = GiniColor(light: UIColor.GiniCapture.light1, dark: UIColor.GiniCapture.dark3).uiColor()
        layer.cornerRadius = 16

        titleLabel.font = configuration.textStyleFonts[.calloutBold]
        titleLabel.textColor = GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.light1).uiColor()

        descriptionLabel.font = configuration.textStyleFonts[.subheadline]
        descriptionLabel.textColor = GiniColor(light: .GiniCapture.dark6,
                                               dark: .GiniCapture.light6).uiColor()
    }

    private func configureAccessibility() {
        isAccessibilityElement = false
        imageView.accessibilityTraits = .image
        imageView.isAccessibilityElement = true
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.isAccessibilityElement = true
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.isAccessibilityElement = true
        accessibilityElements = [imageView as Any, titleLabel as Any, descriptionLabel as Any]
    }

    func configureContent(with image: UIImage?, title: String, description: String) {
        imageView.image = image
        imageView.accessibilityLabel = description
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
