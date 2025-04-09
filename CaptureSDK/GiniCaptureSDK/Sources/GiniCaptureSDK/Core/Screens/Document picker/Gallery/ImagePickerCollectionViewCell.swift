//
//  ImagePickerCollectionViewCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import UIKit

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImagePickerCollectionViewCell"
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.alpha = 0
        return indicator
    }()

    fileprivate lazy var galleryImage: UIImageView = {
        let galleryImage: UIImageView = UIImageView(frame: .zero)
        galleryImage.translatesAutoresizingMaskIntoConstraints = false
        galleryImage.contentMode = .scaleAspectFill
        galleryImage.clipsToBounds = true
        return galleryImage
    }()

    fileprivate lazy var selectedForegroundView: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.GiniCapture.accent1.cgColor
        view.layer.borderWidth = Constants.borderWidth
        view.backgroundColor = .GiniCapture.accent1.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    lazy var checkImage: UIImageView = {
        let image = UIImageNamedPreferred(named: "checkMarkBlue")
        var imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    lazy var checkCircleBackground: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.borderWidth = Constants.circleBorder
        circleView.layer.cornerRadius = Constants.selectedCircleSize.width / 2
        circleView.layer.borderColor = UIColor.GiniCapture.light1.cgColor
        return circleView
    }()

    var isProgramaticallySelected: Bool = false {
        didSet {
            selectedForegroundView.alpha = isProgramaticallySelected ? 1 : 0
            changeCheckCircle(to: isProgramaticallySelected)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            selectedForegroundView.alpha = isHighlighted ? 1 : 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.isAccessibilityElement = true
        contentView.addSubview(galleryImage)
        contentView.addSubview(selectedForegroundView)
        contentView.addSubview(checkCircleBackground)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(checkImage)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            galleryImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            galleryImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            galleryImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            galleryImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            selectedForegroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedForegroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedForegroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectedForegroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkCircleBackground.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                       constant: Constants.circlePadding),
            checkCircleBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                            constant: -Constants.circlePadding),
            checkCircleBackground.widthAnchor.constraint(equalToConstant: Constants.selectedCircleSize.width),
            checkCircleBackground.heightAnchor.constraint(equalToConstant: Constants.selectedCircleSize.height),

            checkImage.topAnchor.constraint(equalTo: checkCircleBackground.topAnchor),
            checkImage.leadingAnchor.constraint(equalTo: checkCircleBackground.leadingAnchor),
            checkImage.centerXAnchor.constraint(equalTo: checkCircleBackground.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: checkCircleBackground.centerYAnchor)
        ])
    }

    func fill(withAsset asset: Asset,
              multipleSelectionEnabled: Bool,
              galleryManager: GalleryManagerProtocol,
              isDownloading: Bool,
              isSelected: Bool) {
        checkCircleBackground.isHidden = !(multipleSelectionEnabled && !isDownloading)
        activityIndicator.alpha = isDownloading ? 1 : 0
        isProgramaticallySelected = isSelected
        selectedForegroundView.alpha = isSelected || isDownloading ? 1 : 0

        if isDownloading {
            activityIndicator.startAnimating()
        }

        galleryManager.fetchImage(from: asset, imageQuality: .thumbnail) { [weak self] image in
            self?.galleryImage.image = image
        }
    }

    class func size(for screen: UIScreen = UIScreen.main,
                    itemsInARow: Int,
                    collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let width = screen.bounds.width / CGFloat(itemsInARow)

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: width, height: width)
        }

        let spacing = flowLayout.minimumInteritemSpacing * CGFloat(itemsInARow - 1)
        let widthWithoutSpacing = (screen.bounds.width - spacing) / CGFloat(itemsInARow)

        return CGSize(width: widthWithoutSpacing, height: widthWithoutSpacing)
    }

    func changeCheckCircle(to selected: Bool, giniConfiguration: GiniConfiguration = .shared) {
        checkCircleBackground.isHidden = selected
        checkImage.isHidden = !selected
    }
}

extension ImagePickerCollectionViewCell {
    enum Constants {
        static let borderWidth: CGFloat = 2
        static let selectedCircleSize = CGSize(width: 25, height: 25)
        static let circlePadding: CGFloat = 5
        static let circleBorder: CGFloat = 1
    }
}
