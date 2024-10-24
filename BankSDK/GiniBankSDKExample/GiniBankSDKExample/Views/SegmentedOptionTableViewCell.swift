//
//  SegmentedOptionTableViewCell.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 12.06.23.
//

import UIKit

protocol SegmentedOptionTableViewCellDelegate: AnyObject {
	func didSegmentedControlValueChanged(in cell: SegmentedOptionTableViewCell)
}

struct SegmentedOptionCellModel {
	let title: String
	let items: [String]
	let selectedIndex: Int
}

final class SegmentedOptionTableViewCell: UITableViewCell, NibLoadableView {

	@IBOutlet private weak var stackViewContainer: UIStackView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var segmentedControl: UISegmentedControl!

    var indexPath: IndexPath = .init(row: 0, section: 0)
    
	private (set) var selectedSegmentIndex: Int = 0 {
		didSet {
			guard oldValue != selectedSegmentIndex else { return }
			segmentedControl.selectedSegmentIndex = selectedSegmentIndex
		}
	}
	
	weak var delegate: SegmentedOptionTableViewCellDelegate?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		setupUI()
	}
	
	// MARK: - UI setup
	
	private func setupUI() {
		segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
		
		if UIDevice.current.isIpad {
			stackViewContainer.axis = .horizontal
			stackViewContainer.spacing = 20.0
		} else {
			stackViewContainer.axis = .vertical
			stackViewContainer.spacing = 8.0
		}
		
		segmentedControl.tintColor = .systemGray
	}

	func set(data: SegmentedOptionCellModel) {
		titleLabel.text = data.title
		// remove all segments from segmentedControl before adding new items
		segmentedControl.removeAllSegments()

		data.items.enumerated().forEach { index, title in
			segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
		}

		segmentedControl.selectedSegmentIndex = data.selectedIndex
	}
	
	// MARK: - Actions
	
	@objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
		selectedSegmentIndex = sender.selectedSegmentIndex
		delegate?.didSegmentedControlValueChanged(in: self)
	}
}
