//
//  DigitalInvoiceSkontoTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

protocol DigitalInvoiceSkontoTableViewCellDelegate: AnyObject {
    func editTapped(cell: DigitalInvoiceSkontoTableViewCell)
    func reloadCell(cell: DigitalInvoiceSkontoTableViewCell)
}

class DigitalInvoiceSkontoTableViewCell: UITableViewCell {
    private var viewModel: SkontoViewModel?

    weak var delegate: DigitalInvoiceSkontoTableViewCellDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = GiniBankConfiguration.shared.textStyleFonts[.body]
        label.textColor = .giniColorScheme().text.tertiary.uiColor()
        label.text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.screen.title",
                                                              comment: "Skonto discount")
        label.numberOfLines = 0
        return label
    }()

    private lazy var edgeCaseLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = GiniBankConfiguration.shared.textStyleFonts[.caption2]
        label.textColor = .giniColorScheme().text.tertiary.uiColor()
        label.numberOfLines = 0
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = GiniBankConfiguration.shared.textStyleFonts[.bodyBold]
        label.textColor = .giniColorScheme().text.status.uiColor()
        return label
    }()

    private lazy var editButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.editbutton",
                                                             comment: "Edit")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.GiniBank.accent1, for: .normal)
        button.titleLabel?.font = GiniBankConfiguration.shared.textStyleFonts[.body]
        return button
    }()

    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .GiniBank.accent1
        return toggle
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel, edgeCaseLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelsStackView, editButton])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Constants.labelsEditButtonSpacing
        return stackView
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [contentStackView, toggleSwitch])
        stackView.axis = .horizontal
        stackView.spacing = Constants.toggleSwitchSpacing
        stackView.alignment = .top
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .giniColorScheme().bg.surface.uiColor()
        clipsToBounds = true
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        contentView.addSubview(mainStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Constants.stackViewHorizontalSpacing),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -Constants.stackViewHorizontalSpacing),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: Constants.stackViewVerticalSpacing),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -Constants.stackViewVerticalSpacing),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualTo: toggleSwitch.heightAnchor)
        ])
    }

    func configure(with viewModel: SkontoViewModel) {
        guard self.viewModel == nil else { return }
        self.viewModel = viewModel
        bindViewModel()
        configure()
        toggleSwitch.addTarget(self, action: #selector(toggleDiscount), for: .valueChanged)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel?.addStateChangeHandler { [weak self] in
            guard let self = self else { return }
            self.configure()
        }
    }

    private func configure() {
        guard let viewModel = viewModel else { return }
        edgeCaseLabel.isHidden = (viewModel.edgeCase == nil) ? viewModel.isSkontoApplied : false
        valueLabel.isHidden = !viewModel.isSkontoApplied
        let savingsPrice = "-\(viewModel.savingsPriceString)"
        valueLabel.text = savingsPrice
        toggleSwitch.isOn = viewModel.isSkontoApplied
        edgeCaseLabel.text = viewModel.localizedBannerInfoMessage
        delegate?.reloadCell(cell: self)
    }

    // MARK: - Actions
    @objc private func toggleDiscount() {
        viewModel?.toggleDiscount()
    }

    @objc private func editButtonTapped() {
        self.delegate?.editTapped(cell: self)
    }
}

// MARK: - Constants
private extension DigitalInvoiceSkontoTableViewCell {
    struct Constants {
        static let stackViewHorizontalSpacing: CGFloat = 16.0
        static let toggleSwitchSpacing: CGFloat = 16.0
        static let labelsEditButtonSpacing: CGFloat = 12.0
        static let stackViewVerticalSpacing: CGFloat = 16.0
    }
}
