//
//  ReviewCollectionCell.swift
//  GiniCapture
//
//  Created by Vizaknai David on 28.09.2022.
//

import UIKit

protocol ReviewCollectionViewDelegate: AnyObject {
    func didTapDelete(on cell: ReviewCollectionCell)
}

final class ReviewCollectionCell: UICollectionViewCell {
    weak var delegate: ReviewCollectionViewDelegate?

    lazy var documentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .button
        imageView.accessibilityLabel = Strings.imageViewAccessibilityLabel
        imageView.backgroundColor = GiniColor(light: UIColor.GiniCapture.light1,
                                              dark: UIColor.GiniCapture.dark1).uiColor()
        return imageView
    }()

    private lazy var deleteButton: UIButton = {
        let deleteIcon = UIImageNamedPreferred(named: "delete_icon")
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(deleteIcon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        button.isExclusiveTouch = true
        button.isHidden = true
        button.isAccessibilityElement = true
        button.accessibilityLabel = Strings.deleteButtonAccessibilityLabel
        return button
    }()

    override var canBecomeFocused: Bool {
        false
    }

    private func setActiveStatus(_ isActive: Bool) {
        documentImageView.layer.borderColor = isActive ? UIColor.GiniCapture.accent1.cgColor : UIColor.clear.cgColor
        documentImageView.layer.borderWidth = isActive ? Constants.documentBorderWidth : 0
        deleteButton.isHidden = !isActive
        
        /// This is needed to specify the order of the accessible elements. But it is still partially working. A task will be created
        /// to investigate more how to enable the detection of overlaping elements.
        accessibilityElements = isActive ? [documentImageView, deleteButton] : [documentImageView]
    }

    var isActive: Bool = false {
        didSet {
            setActiveStatus(isActive)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(documentImageView)
        contentView.addSubview(deleteButton)
        isAccessibilityElement = false

        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }

    private func addConstraints() {

        NSLayoutConstraint.activate([
            documentImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            documentImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            documentImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            documentImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                   constant: -Constants.deleteButtonWidthInset),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor,
                                              constant: Constants.deleteButtonWidthInset),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonHeight),
            deleteButton.widthAnchor.constraint(equalToConstant: Constants.deleteButtonWidth)
        ])
    }

    @objc
    private func didTapDelete() {
        delegate?.didTapDelete(on: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isActive = false
        accessibilityElements = [documentImageView]
    }
}

extension ReviewCollectionCell {
    private enum Constants {
        static let deleteButtonHeight: CGFloat = 44
        static let deleteButtonWidth: CGFloat = 44
        static let deleteButtonWidthInset: CGFloat = 16
        static let documentBorderWidth: CGFloat = 2
    }

    private struct Strings {
        static let imageViewAccessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.documentImageTitle",
                                                                                  comment: "Document")
        static let deleteButtonAccessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.delete",
                                                                                     comment: "Delete")
    }
}
