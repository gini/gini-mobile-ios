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
        label.text = NSLocalizedStringPreferredFormat("ginicapture.albums.footer",
                                                      comment: "Albums footer message")
        label.font = configuration.customFont.with(weight: .regular, size: 14, style: .footnote)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
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
        let leadingContraint = contentLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        leadingContraint.priority = .defaultHigh
        
        // Hack to fix AutoLayout bug related to UIView-Encapsulated-Layout-Height
        let topConstraint = contentLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
        topConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            leadingContraint,
            topConstraint,
            contentLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func setupUI() {
        addSubview(contentLabel)
        setupConstraints()
    }
}
