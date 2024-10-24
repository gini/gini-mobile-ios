//
//  SwitchOptionTableViewCell.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 12.06.23.
//

import UIKit

protocol SwitchOptionTableViewCellDelegate: AnyObject {
	func didToggleOption(in cell: SwitchOptionTableViewCell)
}

struct SwitchOptionModelCell {
	let title: String
	let active: Bool
	let message: String?
}

final class SwitchOptionTableViewCell: UITableViewCell, NibLoadableView {
	
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var messageLabel: UILabel!
	@IBOutlet private weak var optionSwitch: UISwitch!
	
    var indexPath: IndexPath = .init(row: 0, section: 0)
    
	weak var delegate: SwitchOptionTableViewCellDelegate?
	
	var isSwitchOn: Bool = false {
		didSet {
			optionSwitch.isOn = isSwitchOn
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()
	}
	
	// MARK: - UI setup
	
	private func setupUI() {
		selectionStyle = .none
		optionSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
		titleLabel.numberOfLines = 0
		messageLabel.numberOfLines = 0
		messageLabel.textColor = ColorPalette.greySuit
	}
	
	func set(data: SwitchOptionModelCell) {
		titleLabel.text = data.title
		optionSwitch.isOn = data.active
		if let message = data.message {
			messageLabel.isHidden = false
			messageLabel.text = message
		} else {
			messageLabel.isHidden = true
		}
	}
	
	// MARK: - Actions

	@objc private func switchValueChanged(_ sender: UISwitch) {
		isSwitchOn = sender.isOn
		delegate?.didToggleOption(in: self)
	}
}
