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
            ctaButton.roundCorners(corners: .allCorners, radius: Constants.ctaButtonCornerRadius)
        }
    }
    @IBAction func ctaAction(_ sender: Any) {
        action?()
    }

    let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.rightStackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    var action: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeAllViews(from: rightStackView)
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
                rightStackView.trailingAnchor.constraint(equalTo: ctaButton.trailingAnchor, constant: Constants.rightStackViewTrailingConstant),
                rightStackView.heightAnchor.constraint(equalToConstant: Constants.rightStackViewHeight)
            ])

            ctaButton.titleEdgeInsets = Constants.ctaButtonTitleEdgeInsets
        }
    }

    private func createLogoImageView(data: Data) -> UIImageView {
        let image = UIImage(data: data)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.logoImageViewCornerRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.logoImageViewSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.logoImageViewSize)
        ])

        return imageView
    }

    private func createBadgeView(withNumber number: Int) -> UIView {
        let badgeView = UIView()
        badgeView.backgroundColor = Constants.badgeViewBackgroundColor
        badgeView.layer.cornerRadius = Constants.badgeViewCornerRadius
        badgeView.translatesAutoresizingMaskIntoConstraints = false

        let badgeLabel = UILabel()
        badgeLabel.text = "+\(number)"
        badgeLabel.textColor = Constants.badgeLabelTextColor
        badgeLabel.font = Constants.badgeLabelFont
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        badgeView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: Constants.badgeViewSize),
            badgeView.heightAnchor.constraint(equalToConstant: Constants.badgeViewSize)
        ])

        return badgeView
    }
    
    func removeAllViews(from stackView: UIStackView) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view) // Remove from layout management
            view.removeFromSuperview()           // Remove from view hierarchy
        }
    }
}

// MARK: - Constants

private extension InvoiceTableViewCell {
    enum Constants {
        static let ctaButtonCornerRadius: CGFloat = 10
        static let rightStackViewSpacing: CGFloat = 3
        static let rightStackViewTrailingConstant: CGFloat = -60
        static let rightStackViewHeight: CGFloat = 20
        static let ctaButtonTitleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        static let logoImageViewCornerRadius: CGFloat = 4
        static let logoImageViewSize: CGFloat = 20
        static let badgeViewBackgroundColor = UIColor.lightGray
        static let badgeViewCornerRadius: CGFloat = 10
        static let badgeLabelTextColor = UIColor.black
        static let badgeLabelFont = UIFont.systemFont(ofSize: 10)
        static let badgeViewSize: CGFloat = 20
    }
}
