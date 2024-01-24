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
            
            mainStackView.distribution = cellViewModel?.shouldShowPaymentComponent ?? false ? .fillProportionally : .fill
            paymentComponentView?.isHidden = !(cellViewModel?.shouldShowPaymentComponent ?? false)
            if let paymentComponentView = cellViewModel?.paymentComponentView {
                mainStackView.addArrangedSubview(paymentComponentView)
            } 
        }
    }
    
    var paymentComponentView: UIView?

    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var recipientLabel: UILabel!
    @IBOutlet private weak var dueDateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if mainStackView.arrangedSubviews.count > 1 {
            mainStackView.arrangedSubviews.last?.removeFromSuperview()
        }
    }
}
