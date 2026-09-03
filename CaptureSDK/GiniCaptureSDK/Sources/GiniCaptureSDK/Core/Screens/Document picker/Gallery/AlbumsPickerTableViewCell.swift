//
//  AlbumsPickerTableViewCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import UIKit

final class AlbumsPickerTableViewCell: UITableViewCell {

    static let identifier = "AlbumsPickerTableViewCellIdentifier"

    lazy var albumThumbnailView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 1
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: -2, height: 2)
        imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds).cgPath
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    lazy var albumTitleLabel: UILabel = {
        let albumTitleLabel = UILabel(frame: .zero)
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleLabel.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        albumTitleLabel.isAccessibilityElement = true
        albumTitleLabel.adjustsFontForContentSizeCategory = true
        return albumTitleLabel
    }()

    lazy var albumSubTitleLabel: UILabel = {
        let albumSubTitleLabel = UILabel(frame: .zero)
        albumSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        albumSubTitleLabel.isAccessibilityElement = true
        albumSubTitleLabel.adjustsFontForContentSizeCategory = true
        albumSubTitleLabel.textColor = GiniColor(light: .GiniCapture.dark6, dark: .GiniCapture.light6).uiColor()
        return albumSubTitleLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let chevronImage = UIImageNamedPreferred(named: "chevron")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.image = chevronImage
        accessoryView = chevronImageView
        contentView.addSubview(albumThumbnailView)
        contentView.addSubview(albumTitleLabel)
        contentView.addSubview(albumSubTitleLabel)

        backgroundColor = .clear
        addConstraints()
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            albumThumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                        constant: Constants.paddingBig),
            albumThumbnailView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,
                                                    constant: Constants.padding),
            albumThumbnailView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                       constant: -Constants.padding),
            albumThumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumThumbnailView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height),
            albumThumbnailView.widthAnchor.constraint(equalTo: albumThumbnailView.heightAnchor),

            albumTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor,
                                                 constant: Constants.padding),
            albumTitleLabel.leadingAnchor.constraint(equalTo: albumThumbnailView.trailingAnchor,
                                                     constant: Constants.paddingBig),
            albumTitleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor,
                                                    constant: -Constants.paddingHalf),
            albumTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Constants.paddingHalf),

            albumSubTitleLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor,
                                                    constant: Constants.paddingHalf),
            albumSubTitleLabel.leadingAnchor.constraint(equalTo: albumTitleLabel.leadingAnchor),
            albumSubTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                         constant: -Constants.paddingBig),
            albumSubTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                       constant: -Constants.padding)

        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp(with album: Album, giniConfiguration: GiniConfiguration, galleryManager: GalleryManagerProtocol) {
        albumTitleLabel.text = album.title
        albumSubTitleLabel.text = "\(album.count)"

        albumTitleLabel.accessibilityValue = album.title
        albumSubTitleLabel.accessibilityValue = "\(album.count)"

        albumTitleLabel.font = giniConfiguration.textStyleFonts[.headline]
        albumSubTitleLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        separatorInset = UIEdgeInsets(top: 0, left: Constants.paddingBig, bottom: 0, right: 0)

        let asset = album.assets[album.assets.count - 1]
        galleryManager.fetchImage(from: asset,
                                  imageQuality: .thumbnail) {[weak self] image in
            guard let self = self else { return }
            self.albumThumbnailView.image = image
        }
    }
}

extension AlbumsPickerTableViewCell {
    private enum Constants {
        static let imageSize: CGSize = CGSize(width: 70, height: 70)
        static let paddingHalf: CGFloat = 4
        static let padding: CGFloat = 8
        static let paddingBig: CGFloat = 16
    }
}
