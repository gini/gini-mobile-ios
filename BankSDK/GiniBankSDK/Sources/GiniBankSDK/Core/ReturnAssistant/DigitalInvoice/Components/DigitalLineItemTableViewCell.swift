//
//  DigitalLineItemTableViewCell.swift
// GiniBank
//
//  Created by Maciej Trybilo on 22.11.19.
//

import UIKit
import GiniCaptureSDK

protocol DigitalLineItemTableViewCellDelegate: AnyObject {
    func modeSwitchValueChanged(cell: DigitalLineItemTableViewCell,
                                lineItemViewModel: DigitalLineItemTableViewCellViewModel)
    func editTapped(cell: DigitalLineItemTableViewCell, lineItemViewModel: DigitalLineItemTableViewCellViewModel)
}

class DigitalLineItemTableViewCell: UITableViewCell {
    static let reuseIdentifier = "DigitalLineItemTableViewCell"
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var backgroundContainerView: UIView!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    private let configuration = GiniBankConfiguration.shared

    var viewModel: DigitalLineItemTableViewCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }

            if let nameLabelString = viewModel.nameLabelString {
                setTextWithLimit(for: nameLabel,
                                 text: nameLabelString,
                                 maxCharacters: viewModel.nameMaxCharactersCount)
                nameLabel.accessibilityValue = nameLabelString
            }

            if let priceString = viewModel.totalPriceString {
                priceLabel.text = priceString
                priceLabel.accessibilityValue = priceString
                let format = NSLocalizedStringPreferredGiniBankFormat(
                                        "ginibank.digitalinvoice.total.accessibilitylabel",
                                        comment: "Total")
                priceLabel.accessibilityLabel = String.localizedStringWithFormat(format, priceString)
            }

            unitPriceLabel.text = viewModel.unitPriceString
            unitPriceLabel.accessibilityValue = viewModel.unitPriceString

            modeSwitch.addTarget(self, action: #selector(modeSwitchValueChange(sender:)), for: .valueChanged)

            modeSwitch.onTintColor = viewModel.modeSwitchTintColor

            [nameLabel, editButton, unitPriceLabel, priceLabel].forEach { view in
                view?.alpha = viewModel.lineItem.selectedState == .selected ? 1 : 0.5
                editButton.isEnabled = viewModel.lineItem.selectedState == .selected
            }

            switch viewModel.lineItem.selectedState {
            case .selected:
                modeSwitch.isOn = true
            case .deselected:
                modeSwitch.isOn = false
            }

            setup()
        }
    }

    weak var delegate: DigitalLineItemTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        let bgColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        backgroundColor = .clear
        contentView.backgroundColor = bgColor
        backgroundContainerView.backgroundColor = bgColor
        selectionStyle = .none

        if viewModel?.index == 0 {
            backgroundContainerView.round(corners: [.topLeft, .topRight], radius: 8)
            separatorView.isHidden = true
        }

        editButton.contentHorizontalAlignment = .left
        editButton.titleLabel?.adjustsFontForContentSizeCategory = true
        let editTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.lineitem.editbutton",
                                                                 comment: "Edit")
        editButton.setTitle(editTitle, for: .normal)
        editButton.isExclusiveTouch = true

        separatorView.backgroundColor = GiniColor(light: .GiniBank.light3, dark: .GiniBank.dark4).uiColor()
        unitPriceLabel.textColor = GiniColor(light: .GiniBank.dark6,
                                             dark: .GiniBank.light6).uiColor()
        editButton.setTitleColor(.GiniBank.accent1, for: .normal)
        nameLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        priceLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()

        priceLabel.font = configuration.textStyleFonts[.body]
        nameLabel.font = configuration.textStyleFonts[.body]
        unitPriceLabel.font = configuration.textStyleFonts[.body]
        editButton.titleLabel?.font = configuration.textStyleFonts[.body]
    }

    private func setTextWithLimit(for label: UILabel, text: String, maxCharacters: Int) {
        if text.count > maxCharacters {
            let limitedText = String(text.prefix(maxCharacters))
            label.text = "\(limitedText)…"
        } else {
            label.text = text
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // When reusing cells, reset the rounded corners and the separator view visibility to their default values
        backgroundContainerView.round(radius: 0)
        separatorView.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice.current.isIphone {
            let inset = safeAreaInsets.left + 16
            leadingConstraint.constant = inset
            trailingConstraint.constant = inset
        }
    }

    @objc func modeSwitchValueChange(sender: UISwitch) {
        if let viewModel = viewModel {
            delegate?.modeSwitchValueChanged(cell: self, lineItemViewModel: viewModel)
        }
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        if let viewModel = viewModel {
            delegate?.editTapped(cell: self, lineItemViewModel: viewModel)
        }
    }
}
