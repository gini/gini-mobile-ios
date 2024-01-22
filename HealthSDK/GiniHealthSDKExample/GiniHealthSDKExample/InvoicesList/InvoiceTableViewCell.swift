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
            paymentComponentView = cellViewModel?.paymentComponentView
            
            guard let paymentComponentView = paymentComponentView else { return }
            if mainStackView.arrangedSubviews.count == 1 {
                mainStackView.addArrangedSubview(paymentComponentView)
            }
        }	
    }
    
    var paymentComponentView: UIView?

    @IBOutlet weak var recipientLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
