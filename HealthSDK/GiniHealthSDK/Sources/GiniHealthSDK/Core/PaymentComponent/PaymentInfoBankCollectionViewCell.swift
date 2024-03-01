//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class PaymentInfoBankCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PaymentInfoBankCollectionViewCell"
    
    var cellViewModel: PaymentInfoBankCollectionViewCellModel? {
        didSet {
            guard let cellViewModel else { return }
            bankIconImageView.image = cellViewModel.bankImageIcon
        }
    }

    lazy var bankIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.roundCorners(corners: .allCorners, radius: Constants.bankIconCornerRadius)
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
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    
    init(bankImageIconData: Data?) {
        self.bankImageIconData = bankImageIconData
    }
}

extension PaymentInfoBankCollectionViewCell {
    private enum Constants {
        static let bankIconCornerRadius = 4.0
    }
}
