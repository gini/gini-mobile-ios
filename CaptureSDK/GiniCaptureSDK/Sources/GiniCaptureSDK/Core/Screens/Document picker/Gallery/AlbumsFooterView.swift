//
//  AlbumsFooterView.swift
//  GiniCapture
//
//  Created by Nadya Karaban on 20.08.21.
//

import UIKit

final class AlbumsFooterView: UIView {
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        let configuration = GiniConfiguration.shared
        let titleString = NSLocalizedStringPreferredFormat("ginicapture.albums.footer",
                                                           comment: "Albums footer message")

        label.isAccessibilityElement = true
        label.text = titleString
        label.accessibilityValue = titleString
        label.font = configuration.textStyleFonts[.footnote]
        label.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupConstraints() {
        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Width
        let leadingContraint = contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                     constant: Constants.padding)
        leadingContraint.priority = .defaultHigh

        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Height
        let topConstraint = contentLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        topConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            leadingContraint,
            topConstraint,
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            contentLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func setupUI() {
        addSubview(contentLabel)
        setupConstraints()
    }
}

extension AlbumsFooterView {
    private enum Constants {
        static let padding: CGFloat = 16
    }
}
