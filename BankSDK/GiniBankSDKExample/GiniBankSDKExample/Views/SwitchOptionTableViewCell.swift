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

struct SwitchOptionModelCell: Hashable {
	let title: String
	let active: Bool
}

final class SwitchOptionTableViewCell: UITableViewCell, NibLoadableView {
	
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var optionSwitch: UISwitch!
	
	weak var delegate: SwitchOptionTableViewCellDelegate?
	
	private (set) var isActive: Bool = false

	override func awakeFromNib() {
		super.awakeFromNib()
		setupUI()
	}
	
	// MARK: - UI setup
	
	private func setupUI() {
		selectionStyle = .none
		optionSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
	}
	
	func set(data: SwitchOptionModelCell) {
		titleLabel.text = data.title
		optionSwitch.isOn = data.active
	}
	
	@objc private func switchValueChanged(_ sender: UISwitch) {
		isActive = sender.isOn
		delegate?.didToggleOption(in: self)
	}
}
