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
        imageView.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.documentImageTitle",
                                                                        comment: "Document")
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
        button.isHidden = true
        button.isAccessibilityElement = true
        button.accessibilityLabel = NSLocalizedStringPreferredFormat("ginicapture.review.delete", comment: "Delete")
        return button
    }()

    private func setActiveStatus(_ isActive: Bool) {
        documentImageView.layer.borderColor = isActive ? UIColor.GiniCapture.accent1.cgColor : UIColor.clear.cgColor
        documentImageView.layer.borderWidth = isActive ? 2 : 0
        deleteButton.isHidden = !isActive
    }

    var isActive: Bool = false {
        didSet {
            setActiveStatus(isActive)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(documentImageView)
        addSubview(deleteButton)
        bringSubviewToFront(deleteButton)

        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }

    private func addConstraints() {

        NSLayoutConstraint.activate([
            documentImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            documentImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            documentImageView.topAnchor.constraint(equalTo: topAnchor),
            documentImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc
    private func didTapDelete() {
        delegate?.didTapDelete(on: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isActive = false
    }
}
