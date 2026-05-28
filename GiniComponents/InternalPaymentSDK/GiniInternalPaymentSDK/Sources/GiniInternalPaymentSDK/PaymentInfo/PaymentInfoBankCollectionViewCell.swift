//
//  PaymentInfoBankCollectionViewCell.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites

final class PaymentInfoBankCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PaymentInfoBankCollectionViewCell"
    
    var cellViewModel: PaymentInfoBankCollectionViewCellModel? {
        didSet {
            guard let cellViewModel else { return }
            bankIconImageView.image = cellViewModel.bankImageIcon
            bankIconImageView.layer.borderColor = cellViewModel.borderColor.cgColor
        }
    }

    private lazy var bankIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
        imageView.layer.borderWidth = Constants.bankIconBorderWidth
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bankIconImageView)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bankIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bankIconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bankIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bankIconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

final class PaymentInfoBankCollectionViewCellModel {
    let bankImageIcon: UIImage
    let borderColor: UIColor

    init(bankImageIconData: Data?, borderColor: UIColor) {
        self.borderColor = borderColor
        self.bankImageIcon = bankImageIconData?.toImage ?? UIImage()
    }
}

extension PaymentInfoBankCollectionViewCell {
    private enum Constants {
        static let bankIconCornerRadius = 6.0
        static let bankIconBorderWidth = 1.0
    }
}
