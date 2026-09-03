//
//  InfoTableViewCell.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 30.06.23.
//

import UIKit

final class InfoTableViewCell: UITableViewCell, NibLoadableView {

	@IBOutlet private weak var messageLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		messageLabel.numberOfLines = 0
    }
	
	func set(message: String) {
		messageLabel.text = message
	}
}
