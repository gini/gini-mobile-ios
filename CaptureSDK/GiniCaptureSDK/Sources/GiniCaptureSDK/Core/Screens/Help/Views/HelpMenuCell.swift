//
//  HelpMenuCell.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//

import UIKit

final class HelpMenuCell: UITableViewCell, HelpCell {
    static var reuseIdentifier: String = "kHelpMenuCell"
    weak var separatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separatorView = separator
        addSubview(separator)
        configureConstraints()
    }

    private func configureConstraints() {
        if let separatorView = separatorView {
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                        constant: -Constants.separatorLeadingInset),
                separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
                separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                      constant: -Constants.separatorHeight)
            ])
        }
    }
}

extension HelpMenuCell {
    private enum Constants {
        static let separatorHeight: CGFloat = 1
        static let separatorLeadingInset: CGFloat = 8
    }
}
