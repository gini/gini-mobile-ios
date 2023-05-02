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
        self.addSubview(separator)
        separatorView = separator
        configureConstraints()
    }

    private func configureConstraints() {
        if let separatorView = separatorView {
            NSLayoutConstraint.activate([
                separatorView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                separatorView.heightAnchor.constraint(equalToConstant: 1),
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
            ])
        }
    }
}
