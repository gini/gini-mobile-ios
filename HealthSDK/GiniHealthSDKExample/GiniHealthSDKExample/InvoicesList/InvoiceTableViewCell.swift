//
//  InvoiceTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class InvoiceTableViewCell: UITableViewCell {
    
    static let identifier = "InvoiceTableViewCell"
    
    var cellViewModel: InvoiceTableViewCellModel? {
        didSet {
            recipientLabel.text = cellViewModel?.recipientNameText
            dueDateLabel.text = cellViewModel?.dueDateText
            amountLabel.text = cellViewModel?.amountToPayText
            
            recipientLabel.isHidden = cellViewModel?.isRecipientLabelHidden ?? false
            dueDateLabel.isHidden = cellViewModel?.isDueDataLabelHidden ?? false

            addTrustMarkersView()
        }
    }

    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var recipientLabel: UILabel!
    @IBOutlet private weak var dueDateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var ctaButton: UIButton! {
        didSet {
            ctaButton.roundCorners(corners: .allCorners, radius: 10)
        }
    }
    @IBAction func ctaAction(_ sender: Any) {
        action?()
    }

    let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    var action: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    private func addTrustMarkersView() {
        if let bankLogosToShow = cellViewModel?.bankLogosToShow {
            for bankLogo in bankLogosToShow {
                let logoImageView = createLogoImageView(data: bankLogo)
                rightStackView.addArrangedSubview(logoImageView)
            }
        }
        if let additionalBankNumberToShow = cellViewModel?.additionalBankNumberToShow {
            let badgeView = createBadgeView(withNumber: additionalBankNumberToShow)
            rightStackView.addArrangedSubview(badgeView)
        }

        if cellViewModel?.bankLogosToShow?.count ?? 0 > 0 {
            contentView.addSubview(rightStackView)
            NSLayoutConstraint.activate([
                rightStackView.centerYAnchor.constraint(equalTo: ctaButton.centerYAnchor),
                rightStackView.trailingAnchor.constraint(equalTo: ctaButton.trailingAnchor, constant: -60),
                rightStackView.heightAnchor.constraint(equalToConstant: 20)
            ])

            ctaButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        }
    }

    private func createLogoImageView(data: Data) -> UIImageView {
        let image = UIImage(data: data)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])

        return imageView
    }

    private func createBadgeView(withNumber number: Int) -> UIView {
        let badgeView = UIView()
        badgeView.backgroundColor = .lightGray
        badgeView.layer.cornerRadius = 10
        badgeView.translatesAutoresizingMaskIntoConstraints = false

        let badgeLabel = UILabel()
        badgeLabel.text = "+\(number)"
        badgeLabel.textColor = .black
        badgeLabel.font = UIFont.systemFont(ofSize: 10)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        badgeView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: 20),
            badgeView.heightAnchor.constraint(equalToConstant: 20)
        ])

        return badgeView
    }
}
