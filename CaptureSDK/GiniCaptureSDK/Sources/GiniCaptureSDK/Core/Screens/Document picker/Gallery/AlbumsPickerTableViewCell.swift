//
//  AlbumsPickerTableViewCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import UIKit

final class AlbumsPickerTableViewCell: UITableViewCell {
    
    static let identifier = "AlbumsPickerTableViewCellIdentifier"
    static let height: CGFloat = 90.0
    let padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 10)
    
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
        let albumTitle = UILabel(frame: .zero)
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        albumTitle.textColor = GiniColor(light: .GiniCapture.dark1, dark: .GiniCapture.light1).uiColor()
        return albumTitle
    }()
    
    lazy var albumSubTitleLabel: UILabel = {
        let albumSubTitle = UILabel(frame: .zero)
        albumSubTitle.translatesAutoresizingMaskIntoConstraints = false
        
        albumSubTitle.textColor = GiniColor(light: .GiniCapture.dark6, dark: .GiniCapture.light6).uiColor()
        
        return albumSubTitle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        addSubview(albumThumbnailView)
        addSubview(albumTitleLabel)
        addSubview(albumSubTitleLabel)

        backgroundColor = .clear
        addConstraints()
    }
    
    private func addConstraints() {
        // albumThumbnailView
        Constraints.active(item: albumThumbnailView, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                           constant: padding.left)
        Constraints.active(item: albumThumbnailView, attr: .top, relatedBy: .equal, to: self, attr: .top, constant:
            padding.top)
        Constraints.active(item: albumThumbnailView, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                           constant: -padding.bottom)
        Constraints.active(item: albumThumbnailView, attr: .trailing, relatedBy: .equal, to: albumTitleLabel,
                           attr: .leading, constant: -20)
        Constraints.active(item: albumThumbnailView, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 70)
        Constraints.active(item: albumThumbnailView, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 70)
        
        // albumTitleLabel
        Constraints.active(item: albumTitleLabel, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY,
                           constant: -padding.top)
        Constraints.active(item: albumTitleLabel, attr: .bottom, relatedBy: .equal, to: albumSubTitleLabel,
                           attr: .top, constant: -5)
        
        // albumSubTitleLabel
        Constraints.active(item: albumSubTitleLabel, attr: .bottom, relatedBy: .lessThanOrEqual, to: self,
                           attr: .bottom, constant: 0)
        Constraints.active(item: albumSubTitleLabel, attr: .leading, relatedBy: .equal, to: albumTitleLabel,
                           attr: .leading)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(with album: Album, giniConfiguration: GiniConfiguration, galleryManager: GalleryManagerProtocol) {
        albumTitleLabel.text = album.title
        albumSubTitleLabel.text = "\(album.count)"
        albumTitleLabel.font = giniConfiguration.textStyleFonts[.headline]
        albumSubTitleLabel.font = giniConfiguration.textStyleFonts[.subheadline]
        
        let asset = album.assets[album.assets.count - 1]
        galleryManager.fetchImage(from: asset,
                                  imageQuality: .thumbnail) {[weak self] image in
            guard let self = self else { return }
            self.albumThumbnailView.image = image
        }
    }
}
