//
//  CaptureSuggestionsCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsCollectionCell: UICollectionViewCell {

    var suggestionImage: UIImageView = {
        let suggestionImage = UIImageView()
        suggestionImage.translatesAutoresizingMaskIntoConstraints = false
        suggestionImage.contentMode = .scaleAspectFit
        return suggestionImage
    }()

    var suggestionText: UILabel = {
        let suggestionText = UILabel()
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.numberOfLines = 0
        suggestionText.adjustsFontSizeToFitWidth = true
        suggestionText.minimumScaleFactor = Constants.minScaleFactor
        return suggestionText
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(suggestionImage)
        contentView.addSubview(suggestionText)
        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            suggestionImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            suggestionImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            suggestionImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                     constant: Constants.horizontalInset),
            suggestionImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Constants.horizontalInset),
            suggestionImage.widthAnchor.constraint(equalToConstant: Constants.suggestionImageWidth),
            suggestionImage.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.suggestionImageHeight),
            suggestionImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            suggestionText.topAnchor.constraint(equalTo: contentView.topAnchor),
            suggestionText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            suggestionText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                     constant: -Constants.horizontalInset)
        ])
    }
}

extension CaptureSuggestionsCollectionCell {
    private enum Constants {
        static let horizontalInset: CGFloat = 20
        static let suggestionImageWidth: CGFloat = 85
        static let suggestionImageHeight: CGFloat = 75
        static let minScaleFactor: CGFloat = 10 / 14
    }
}
