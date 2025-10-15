//
//  DigitalLineItemTableViewCell.swift
//  GiniBank
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

    override var canBecomeFocused: Bool {
        false
    }

    private let configuration = GiniBankConfiguration.shared

    var viewModel: DigitalLineItemTableViewCellViewModel? {
        didSet {
            updateUIWithViewModel()
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
        let bgColor: UIColor = .giniBankColorScheme().container.background.uiColor()
        backgroundColor = .clear
        contentView.backgroundColor = bgColor
        backgroundContainerView.backgroundColor = bgColor
        selectionStyle = .none

        if viewModel?.index == 0 {
            backgroundContainerView.round(corners: [.topLeft, .topRight],
                                          radius: Constants.cornerRadius)
            separatorView.isHidden = true
        }

        editButton.contentHorizontalAlignment = .left
        editButton.titleLabel?.adjustsFontForContentSizeCategory = true
        editButton.setTitle(Strings.editButtonTitle, for: .normal)
        editButton.isExclusiveTouch = true

        separatorView.backgroundColor = .giniBankColorScheme().textField.border.uiColor()

        applySelectedColors()

        priceLabel.font = configuration.textStyleFonts[.body]
        nameLabel.font = configuration.textStyleFonts[.body]
        unitPriceLabel.font = configuration.textStyleFonts[.body]
        editButton.titleLabel?.font = configuration.textStyleFonts[.body]

        accessibilityElements = [nameLabel,
                                 modeSwitch,
                                 unitPriceLabel,
                                 priceLabel,
                                 editButton].compactMap { $0 }

        modeSwitch.removeTarget(self, action: #selector(modeSwitchValueChange(sender:)), for: .valueChanged)
        modeSwitch.addTarget(self, action: #selector(modeSwitchValueChange(sender:)), for: .valueChanged)
    }

    private func updateUIWithViewModel() {
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
            priceLabel.accessibilityLabel = String.localizedStringWithFormat(Strings.priceAccessibilityLabel,
                                                                             priceString)
        }

        unitPriceLabel.text = viewModel.unitPriceString
        unitPriceLabel.accessibilityValue = viewModel.unitPriceString
        editButton.isEnabled = viewModel.lineItem.selectedState == .selected

        if case .deselected = viewModel.lineItem.selectedState {
            applyDeselectedColors(viewModel)
            modeSwitch.isOn = false
        } else {
            // Reset to selected state
            applySelectedColors()
            modeSwitch.isOn = true
        }

        modeSwitch.onTintColor = viewModel.modeSwitchTintColor

        if viewModel.index == 0 {
            backgroundContainerView.round(corners: [.topLeft, .topRight],
                                          radius: Constants.cornerRadius)
            separatorView.isHidden = true
        }
    }

    private func applySelectedColors() {
        nameLabel.textColor = .giniBankColorScheme().text.primary.uiColor()
        priceLabel.textColor = .giniBankColorScheme().text.primary.uiColor()
        unitPriceLabel.textColor = .giniBankColorScheme().text.secondary.uiColor()
        editButton.setTitleColor(.GiniBank.accent1, for: .normal)
    }

    private func applyDeselectedColors(_ viewModel: DigitalLineItemTableViewCellViewModel) {
        nameLabel.textColor = viewModel.textTintColorStateDeselected
        unitPriceLabel.textColor = viewModel.textTintColorStateDeselected
        priceLabel.textColor = viewModel.textTintColorStateDeselected
        editButton.setTitleColor(viewModel.textTintColorStateDeselected, for: .normal)
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
// MARK: - Constants
private extension DigitalLineItemTableViewCell {
    struct Constants {
        static let cornerRadius: CGFloat = 8.0
    }
}

extension DigitalLineItemTableViewCell {
    private struct Strings {
        static let priceAccessibilityLabelKey = "ginibank.digitalinvoice.total.accessibilitylabel"
        static let editButtonTitleKey = "ginibank.digitalinvoice.lineitem.editbutton"

        static let priceAccessibilityLabel = NSLocalizedStringPreferredGiniBankFormat(priceAccessibilityLabelKey,
                                                                                      comment: "Total")

        static let editButtonTitle = NSLocalizedStringPreferredGiniBankFormat(editButtonTitleKey,
                                                                              comment: "Edit")
    }
}
