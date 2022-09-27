//
//  ReviewCollectionCell.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
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
        imageView.backgroundColor = GiniColor(light: UIColor.GiniCapture.light3,
                                              dark: UIColor.GiniCapture.dark3).uiColor()
        return imageView
    }()

    private lazy var deleteButton: UIButton = {
        let deleteIcon = UIImageNamedPreferred(named: "delete_icon")
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(deleteIcon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        return button
    }()

    var isActive: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.documentImageView.layer.borderColor = self.isActive ? UIColor.GiniCapture.accent1.cgColor : UIColor.clear.cgColor
                self.documentImageView.layer.borderWidth = self.isActive ? 2 : 0
            }
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
}
